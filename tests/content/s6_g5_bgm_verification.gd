extends Node

const AudioManagerScript = preload("res://scripts/presentation/audio_manager.gd")
const StageDefinitionScript = preload("res://scripts/data/stage_definition.gd")

signal black_hole_phase_requested()
signal black_hole_finale_started(contact_snapshot: Dictionary)
signal stage_changed(definition: Resource)
signal pause_requested()
signal retry_requested()
signal main_menu_requested()
signal start_requested()

var _failures := 0
var _audio_manager


func _ready() -> void:
	_audio_manager = AudioManagerScript.new()
	add_child(_audio_manager)
	_audio_manager.configure_sources(self, self, self, self)
	_audio_manager.audio_unlocked = true

	_expect(_music_key() == &"bgm_title", "Initial configured state must request title BGM.")
	start_requested.emit()
	_expect(_music_key() == &"bgm_ground", "Start must switch to Ground BGM.")
	var playing: Dictionary = _audio_manager.get_debug_snapshot()
	_expect(is_equal_approx(float(playing["music_volume_db"]), -14.0), "BGM policy must keep music below foreground SFX.")
	_expect(is_equal_approx(float(playing["music_player_volume_db"]), -14.0), "The active music player must apply the BGM volume policy.")
	stage_changed.emit(_stage(&"planetary"))
	_expect(_music_key() == &"bgm_planetary", "Planetary stage must select its BGM.")
	stage_changed.emit(_stage(&"galactic"))
	_expect(_music_key() == &"bgm_galactic", "Galactic stage must select its BGM.")

	pause_requested.emit()
	var paused: Dictionary = _audio_manager.get_debug_snapshot()
	_expect(_music_key() == &"bgm_pause", "Pause must replace the active Stage BGM.")
	_expect(paused["paused_stage_music_key"] == &"bgm_galactic", "Pause must preserve the interrupted Stage BGM key.")
	pause_requested.emit()
	_expect(_music_key() == &"bgm_galactic", "Resume must restore the interrupted Stage BGM.")

	black_hole_phase_requested.emit()
	_expect(_music_key() == &"", "Black Hole phase must stop Galactic BGM.")
	_expect(_audio_manager.get_debug_snapshot()["black_hole_loop_playing"], "Black Hole phase must keep its existing loop active.")
	black_hole_finale_started.emit({})
	_expect(not _audio_manager.get_debug_snapshot()["black_hole_loop_playing"], "Finale must stop the Black Hole loop.")
	_expect(_music_key() == &"bgm_result", "Finale must switch to Result BGM.")

	retry_requested.emit()
	_expect(_music_key() == &"bgm_ground", "Retry must start a fresh Ground BGM.")
	main_menu_requested.emit()
	_expect(_music_key() == &"bgm_title", "Main Menu must restore Title BGM.")

	if _failures == 0:
		print("S6_G5_BGM_VERIFIED music_transitions=10")
	_audio_manager.reset_runtime()
	_audio_manager.queue_free()
	await get_tree().process_frame
	get_tree().quit(_failures)


func _stage(background_id: StringName) -> Resource:
	var definition: Resource = StageDefinitionScript.new()
	definition.background_id = background_id
	return definition


func _music_key() -> StringName:
	return _audio_manager.get_debug_snapshot()["current_music_key"]


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G5 verification failed: %s" % message)
