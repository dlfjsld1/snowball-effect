extends Node

const AudioManagerScript = preload("res://scripts/presentation/audio_manager.gd")

signal ball_merged(result_level: int, world_position: Vector2)
signal cashout_completed(score_amount: float, global_level: int, world_position: Vector2)
signal black_hole_phase_requested()
signal black_hole_absorbed(score_amount: float, global_level: int, world_position: Vector2)
signal black_hole_finale_started(contact_snapshot: Dictionary)
signal stage_state_changed(state: StringName)
signal stage_shift_started(next_definition: Resource, shift_id: int)
signal stage_changed(definition: Resource)
signal pause_requested()
signal retry_requested()

var _failures := 0
var _audio_manager


func _ready() -> void:
	_audio_manager = AudioManagerScript.new()
	add_child(_audio_manager)
	_audio_manager.configure_sources(self, self, self)

	_expect(not _audio_manager.play_event(&"merge_t0"), "Playback must wait for an input unlock.")
	_audio_manager.audio_unlocked = true
	var merge_t0_policy: Dictionary = _audio_manager.get_event_policy(&"merge_t0")
	_expect(merge_t0_policy["priority"] == 10 and merge_t0_policy["polyphony"] == 2 and merge_t0_policy["volume_db"] == -12.0, "Tier 0 policy must have bounded priority, polyphony, and volume.")
	var finale_policy: Dictionary = _audio_manager.get_event_policy(&"black_hole_finale")
	_expect(finale_policy["priority"] == 100 and finale_policy["terminal"], "Finale must be the highest terminal priority.")

	ball_merged.emit(0, Vector2.ZERO)
	_expect(_active_keys().has(&"merge_t0"), "Tier 0 merge must resolve to merge_t0.")
	_expect(not _audio_manager.play_event(&"merge_t0"), "Tier 0 cooldown must drop an immediate duplicate.")
	_expect(_audio_manager.get_debug_snapshot()["dropped_event_count"] >= 1, "Dropped events must be observable for verification.")

	_audio_manager.reset_runtime()
	_expect(_audio_manager.play_event(&"settlement_start"), "The first settlement sound must play.")
	_expect(not _audio_manager.play_event(&"settlement_finish"), "Shared settlement polyphony must reject overlapping state sounds.")

	_audio_manager.reset_runtime()
	ball_merged.emit(0, Vector2.ZERO)
	stage_state_changed.emit(&"CLEAR_LOCKED")
	_expect(not _audio_manager.play_event(&"merge_t1"), "Transitions must suppress new gameplay sounds.")

	_audio_manager.reset_runtime()
	stage_state_changed.emit(&"CLEAR_LOCKED")
	stage_state_changed.emit(&"CLEARED")
	_expect(_active_keys().count(&"stage_clear") == 1, "A clear transition must not duplicate stage_clear.")

	_audio_manager.reset_runtime()
	black_hole_phase_requested.emit()
	_expect(_active_keys().has(&"black_hole_phase"), "Black Hole phase must play its one-shot event.")
	_expect(_active_keys().has(&"black_hole_loop"), "Black Hole phase must start its loop.")
	black_hole_finale_started.emit({})
	_expect(not _active_keys().has(&"black_hole_loop"), "Finale must stop the Black Hole loop.")
	_expect(not _active_keys().has(&"black_hole_phase"), "Finale must clear lower-priority phase audio.")
	_expect(_active_keys().has(&"black_hole_finale"), "Finale must play its one-shot event.")

	_audio_manager.reset_runtime()
	_audio_manager.configure_sources(self, self, self)
	pause_requested.emit()
	_expect(_active_keys().count(&"ui_pause") == 1, "Reconfiguring sources must not duplicate pause connections.")
	pause_requested.emit()
	_expect(_active_keys().count(&"ui_pause") == 1, "Resume must not replay ui_pause while ui_resume is deferred.")

	_audio_manager.reset_runtime()
	black_hole_phase_requested.emit()
	retry_requested.emit()
	_expect(not _active_keys().has(&"black_hole_loop"), "Retry must stop the Black Hole loop.")
	_expect(_active_keys().has(&"ui_retry"), "Retry must play ui_retry.")
	_expect(not _audio_manager.get_debug_snapshot()["gameplay_suppressed"], "Retry must clear transition suppression.")
	_expect(_audio_manager.play_event(&"merge_t0"), "Retry must clear cooldown state for the next run.")

	var constrained_manager = AudioManagerScript.new()
	constrained_manager.player_pool_size = 1
	add_child(constrained_manager)
	constrained_manager.audio_unlocked = true
	_expect(constrained_manager.play_event(&"merge_t0"), "A free player must start low-priority audio.")
	_expect(constrained_manager.play_event(&"black_hole_finale"), "A higher-priority terminal event must preempt lower-priority audio.")
	var constrained_keys: Array = constrained_manager.get_debug_snapshot()["active_event_keys"]
	_expect(constrained_keys.size() == 1 and constrained_keys[0] == &"black_hole_finale", "Preempted pool must retain only the terminal event.")
	_expect(constrained_manager.get_debug_snapshot()["preempted_event_count"] == 1, "Terminal cleanup must report its preempted lower-priority event.")

	if _failures == 0:
		print("S6_G4_FOUNDATION_VERIFIED player_pool=%d" % _audio_manager.get_debug_snapshot()["player_count"])
	await get_tree().create_timer(0.25).timeout
	get_tree().quit(_failures)


func _active_keys() -> Array:
	return _audio_manager.get_debug_snapshot()["active_event_keys"]


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G4 foundation verification failed: %s" % message)
