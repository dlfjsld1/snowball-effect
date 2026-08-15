extends Node

const EffectManagerScript = preload("res://scripts/presentation/effect_manager.gd")

var _failures := 0


class FakeSimulationSource extends Node:
	signal ball_merged(result_level: int, world_position: Vector2)
	signal cashout_completed(score_amount: float, global_level: int, world_position: Vector2)


class FakeStageSource extends Node:
	signal stage_state_changed(state: StringName)
	signal stage_changed(definition)
	var current_state: StringName = &"PLAYING"
	var current_stage_index := 0


	func get_runtime_snapshot() -> Dictionary:
		return {"state": current_state, "stage_index": current_stage_index}


class FakeStageDefinition extends RefCounted:
	var stage_index := 0


	func _init(value: int) -> void:
		stage_index = value


func _ready() -> void:
	_test_burst_throttle_and_high_tier_preservation()
	_test_total_budget_eviction()
	_test_queued_effect_releases_budget()
	_test_read_only_signal_sources()
	_test_active_retry_resets_runtime_fx()
	_test_authored_transition_sequence()
	_test_terminal_escalation()
	_test_transition_and_terminal_reservations()
	if _failures == 0:
		print("S6_G1_VERIFIED low_burst_throttled=true high_tier_preserved=true total_cap_eviction=true queued_release=true invalid_tier_query=true cashout_visible_anchor=true transition_sequence=true terminal_dominance=true retry_reentry=true retry_counter_reset=true active_retry_reset=true")
	get_tree().quit(_failures)


func _test_burst_throttle_and_high_tier_preservation() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	add_child(manager)
	for index in range(20):
		manager._on_ball_merged(0, Vector2(100.0 + index, 100.0))
	_expect(manager.get_active_effect_count_for_tier(0) == 4, "Tier 0 same-frame burst must respect its spawn budget.")
	_expect(manager.get_active_effect_count_for_tier(-1) == 0, "An invalid negative tier query must not alias Tier 0.")
	_expect(manager.get_active_effect_count_for_tier(5) == 0, "An out-of-range tier query must not alias Tier 4.")
	_expect(manager.dropped_effect_count == 16, "Tier 0 overflow must be dropped without spawning Nodes.")

	manager._on_ball_merged(13, Vector2(400.0, 240.0))
	_expect(manager.get_active_effect_count_for_tier(3) == 1, "Tier 3 Merge must survive a saturated low-tier burst.")
	_expect(manager.merge_effect_count == 5, "Accepted Merge count must exclude throttled events.")
	manager.queue_free()


func _test_total_budget_eviction() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	add_child(manager)
	_spawn_across_frames(manager, 0, 0, 12)
	_spawn_across_frames(manager, 1, 1, 8)
	_spawn_across_frames(manager, 4, 2, 4)
	var before := manager.get_budget_snapshot()
	_expect(int(before["active_gameplay_effects"]) == EffectManager.MAX_ACTIVE_GAMEPLAY_EFFECTS, "Mixed low-tier FX must fill the shared active budget exactly.")

	manager._process(0.0)
	manager._on_ball_merged(13, Vector2(400.0, 240.0))
	var after := manager.get_budget_snapshot()
	_expect(int(after["active_gameplay_effects"]) == EffectManager.MAX_ACTIVE_GAMEPLAY_EFFECTS, "High-tier admission must keep the shared active count capped.")
	_expect(manager.get_active_effect_count_for_tier(0) == 11, "A high-tier Merge must evict the oldest lower-priority effect first.")
	_expect(manager.get_active_effect_count_for_tier(3) == 1, "A high-tier Merge must be admitted when the shared budget is full of lower tiers.")
	_expect(manager.evicted_effect_count == 1, "Shared-budget replacement must be counted as one eviction.")
	manager.queue_free()


func _test_queued_effect_releases_budget() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	add_child(manager)
	manager._on_ball_merged(14, Vector2(400.0, 240.0))
	_expect(manager.get_active_effect_count_for_tier(4) == 1, "Tier 4 effect must initially occupy its single active slot.")
	var expiring_effect := manager.get_child(-1)
	expiring_effect.queue_free()
	_expect(manager.get_active_effect_count_for_tier(4) == 0, "An effect queued for deletion must release its active slot immediately.")
	manager._process(0.0)
	manager._on_ball_merged(14, Vector2(420.0, 240.0))
	_expect(manager.get_active_effect_count_for_tier(4) == 1, "A replacement Tier 4 effect must not be blocked by an expiring Node.")
	manager.queue_free()


func _test_read_only_signal_sources() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	var simulation_source := FakeSimulationSource.new()
	var stage_source := FakeStageSource.new()
	add_child(manager)
	add_child(simulation_source)
	add_child(stage_source)
	manager.set_simulation_source(simulation_source)
	manager.set_stage_source(stage_source)
	var source_position := Vector2(320.0, 1200.0)
	simulation_source.cashout_completed.emit(1000000.0, 3, source_position)
	_expect(manager.cashout_effect_count == 1, "Cashout must use the shared FX budget path.")
	_expect(manager.get_active_cashout_effect_count() == 1, "Accepted Cashout must create one visible effect.")
	var effect := manager.get_child(-1)
	_expect(StringName(effect.get_meta("s6_event_key", &"")) == &"CASHOUT", "Cashout effect must retain event metadata.")
	_expect(int(effect.get_meta("s6_fx_tier", -1)) == 1, "Cashout tier must come from BallDefinition.fx_tier.")
	_expect(is_equal_approx(effect.position.x, source_position.x), "Cashout visual anchoring must preserve the gameplay event X position.")
	_expect(effect.position.y <= manager.get_viewport_rect().end.y - EffectManager.CASHOUT_EFFECT_BOTTOM_MARGIN, "Cashout popup must remain visible when the gameplay event occurs below the viewport.")
	stage_source.stage_state_changed.emit(&"CLEAR_LOCKED")
	_expect(manager.get_presentation_phase() == EffectManager.PHASE_TRANSITION, "Stage source must reserve Clear presentation without mutating gameplay.")
	stage_source.current_state = &"PLAYING"
	stage_source.current_stage_index = 1
	stage_source.stage_state_changed.emit(&"PLAYING")
	stage_source.stage_changed.emit(FakeStageDefinition.new(1))
	_expect(manager.get_presentation_phase() == EffectManager.PHASE_PLAYING, "Stage source PLAYING must release transition FX suppression.")
	_expect(manager.cashout_effect_count == 1, "A normal Stage transition must preserve Run-level FX diagnostic counters.")
	manager.queue_free()
	simulation_source.queue_free()
	stage_source.queue_free()


func _test_active_retry_resets_runtime_fx() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	var stage_source := FakeStageSource.new()
	add_child(manager)
	add_child(stage_source)
	manager.set_stage_source(stage_source)
	manager._on_ball_merged(13, Vector2(300.0, 200.0))
	_expect(manager.get_active_merge_effect_count() == 1, "Active Run must have one FX before Pause Retry.")
	stage_source.current_state = &"PLAYING"
	stage_source.current_stage_index = 0
	stage_source.stage_state_changed.emit(&"PLAYING")
	stage_source.stage_changed.emit(FakeStageDefinition.new(0))
	var retry_snapshot := manager.get_budget_snapshot()
	_expect(int(retry_snapshot["active_gameplay_effects"]) == 0, "Pause Retry must remove FX from the previous active Run.")
	_expect(int(retry_snapshot["merge_effects_spawned"]) == 0, "Pause Retry must reset active-Run FX counters.")
	manager.queue_free()
	stage_source.queue_free()


func _test_transition_and_terminal_reservations() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	var stage_source := FakeStageSource.new()
	add_child(manager)
	add_child(stage_source)
	manager.set_stage_source(stage_source)
	var reserved_events: Array[StringName] = []
	manager.priority_event_reserved.connect(func(event_key: StringName, _priority: int) -> void: reserved_events.append(event_key))
	manager._on_ball_merged(1, Vector2(200.0, 200.0))
	_expect(manager.get_active_merge_effect_count() == 1, "Pre-transition gameplay FX must be active.")

	_expect(manager.notify_priority_event(EffectManager.EVENT_STAGE_CLEAR), "Stage Clear reservation must be accepted.")
	_expect(manager.get_presentation_phase() == EffectManager.PHASE_TRANSITION, "Stage Clear must reserve the transition phase.")
	_expect(manager.get_active_merge_effect_count() == 0, "Stage Clear must retire lower-priority gameplay FX.")
	var dropped_before := manager.dropped_effect_count
	manager._on_ball_merged(13, Vector2(300.0, 200.0))
	_expect(manager.dropped_effect_count == dropped_before + 1, "Gameplay FX must be suppressed during transition presentation.")

	manager.resume_gameplay_fx()
	manager._on_ball_merged(13, Vector2(300.0, 200.0))
	_expect(manager.get_active_merge_effect_count() == 1, "Gameplay FX must resume after an explicit transition completion.")
	_expect(manager.notify_priority_event(EffectManager.EVENT_BLACK_HOLE_FINALE), "Black Hole finale reservation must be accepted.")
	_expect(manager.get_presentation_phase() == EffectManager.PHASE_TERMINAL, "Finale must lock terminal presentation.")
	manager.resume_gameplay_fx()
	_expect(manager.get_presentation_phase() == EffectManager.PHASE_TERMINAL, "Terminal phase must not resume through the transition API.")
	_expect(not manager.notify_priority_event(EffectManager.EVENT_RUN_END), "A lower-priority terminal event must not supersede Black Hole Finale.")
	_expect(not manager.notify_priority_event(EffectManager.EVENT_SCALE_SHIFT), "A non-terminal event must not unlock or supersede a terminal reservation.")
	var terminal_snapshot := manager.get_budget_snapshot()
	_expect(StringName(terminal_snapshot["reserved_event"]) == EffectManager.EVENT_BLACK_HOLE_FINALE, "Rejected terminal events must not overwrite the authoritative reservation.")
	_expect(int(terminal_snapshot["reserved_priority"]) == 100, "Terminal reservation must retain the highest accepted priority.")
	_expect(reserved_events == [EffectManager.EVENT_STAGE_CLEAR, EffectManager.EVENT_BLACK_HOLE_FINALE], "Priority reservation order must remain deterministic.")
	var persistent_child := Node.new()
	manager.add_child(persistent_child)
	stage_source.stage_state_changed.emit(&"PLAYING")
	stage_source.stage_changed.emit(FakeStageDefinition.new(0))
	_expect(manager.get_presentation_phase() == EffectManager.PHASE_PLAYING, "Authoritative Stage PLAYING re-entry must reset a terminal lock for Retry.")
	_expect(persistent_child.get_parent() == manager, "Runtime reset must preserve children that are not registered gameplay FX.")
	var retry_snapshot := manager.get_budget_snapshot()
	_expect(int(retry_snapshot["merge_effects_spawned"]) == 0, "Retry re-entry must reset the previous Run's accepted Merge counter.")
	_expect(int(retry_snapshot["dropped_effects"]) == 0, "Retry re-entry must reset the previous Run's dropped FX counter.")
	_expect(int(retry_snapshot["priority_events"]) == 0, "Retry re-entry must reset the previous Run's priority event counter.")
	manager._on_ball_merged(13, Vector2(300.0, 200.0))
	_expect(manager.get_active_merge_effect_count() == 1, "Gameplay FX must be accepted after the Retry state re-entry reset.")
	_expect(manager.merge_effect_count == 1, "The first post-Retry Merge must start the new Run counter at one.")
	manager.queue_free()
	stage_source.queue_free()


func _test_authored_transition_sequence() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	var stage_source := FakeStageSource.new()
	add_child(manager)
	add_child(stage_source)
	manager.set_stage_source(stage_source)
	var reserved_events: Array[StringName] = []
	var reserved_priorities: Array[int] = []
	manager.priority_event_reserved.connect(
		func(event_key: StringName, priority: int) -> void:
			reserved_events.append(event_key)
			reserved_priorities.append(priority)
	)
	stage_source.stage_state_changed.emit(&"CLEAR_LOCKED")
	stage_source.stage_state_changed.emit(&"SETTLING")
	stage_source.stage_state_changed.emit(&"SHIFTING")
	_expect(
		reserved_events == [EffectManager.EVENT_STAGE_CLEAR, EffectManager.EVENT_FINAL_SETTLEMENT, EffectManager.EVENT_SCALE_SHIFT],
		"Authored Stage transition events must remain ordered even when Settlement has a lower numeric priority."
	)
	_expect(reserved_priorities == [80, 70, 85], "Transition reservations must expose the documented event priorities.")
	var shift_snapshot := manager.get_budget_snapshot()
	_expect(StringName(shift_snapshot["reserved_event"]) == EffectManager.EVENT_SCALE_SHIFT, "Scale Shift must own the final transition reservation.")
	stage_source.current_stage_index = 1
	stage_source.stage_state_changed.emit(&"PLAYING")
	stage_source.stage_changed.emit(FakeStageDefinition.new(1))
	_expect(manager.get_presentation_phase() == EffectManager.PHASE_PLAYING, "Stage Shift completion must resume gameplay FX.")
	_expect(manager.priority_event_count == 3, "Stage Shift completion must preserve transition diagnostics within the same Run.")
	manager.queue_free()
	stage_source.queue_free()


func _test_terminal_escalation() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	add_child(manager)
	_expect(manager.notify_priority_event(EffectManager.EVENT_RUN_END), "Run End must establish a terminal reservation.")
	_expect(manager.notify_priority_event(EffectManager.EVENT_BLACK_HOLE_FINALE), "A higher-priority terminal event must supersede Run End.")
	var snapshot := manager.get_budget_snapshot()
	_expect(StringName(snapshot["reserved_event"]) == EffectManager.EVENT_BLACK_HOLE_FINALE, "Terminal escalation must retain the highest accepted event.")
	_expect(int(snapshot["reserved_priority"]) == 100, "Terminal escalation must retain priority 100.")
	_expect(manager.priority_event_count == 2, "Only accepted terminal reservations must increment diagnostics.")
	manager.queue_free()


func _spawn_across_frames(manager: EffectManager, global_level: int, tier: int, count: int) -> void:
	var frame_limit: int = EffectManager.SPAWN_LIMIT_PER_FRAME_BY_TIER[tier]
	for index in range(count):
		if index > 0 and index % frame_limit == 0:
			manager._process(0.0)
		manager._on_ball_merged(global_level, Vector2(100.0 + index, 100.0 + tier * 30.0))


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G1 verification failed: %s" % message)
