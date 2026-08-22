class_name EffectManager
extends Control

const BallCatalog = preload("res://scripts/data/ball_catalog.gd")
const FinalSettlementEffectScript = preload("res://scripts/presentation/final_settlement_effect.gd")
const MergeEffectScene = preload("res://scenes/effects/merge_effect.tscn")
const CashoutEffectScene = preload("res://scenes/effects/cashout_effect.tscn")
const FinalSettlementEffectScene = preload("res://scenes/effects/final_settlement_effect.tscn")

signal merge_effect_spawned(result_level: int, world_position: Vector2)
signal cashout_effect_spawned(global_level: int, world_position: Vector2)
signal priority_event_reserved(event_key: StringName, priority: int)
signal final_settlement_visual_started(duration: float)
signal final_settlement_presentation_finished

const PHASE_PLAYING: StringName = &"PLAYING"
const PHASE_TRANSITION: StringName = &"TRANSITION"
const PHASE_TERMINAL: StringName = &"TERMINAL"

const EVENT_STAGE_CLEAR: StringName = &"STAGE_CLEAR"
const EVENT_FINAL_SETTLEMENT: StringName = &"FINAL_SETTLEMENT"
const EVENT_SCALE_SHIFT: StringName = &"SCALE_SHIFT"
const EVENT_STAGE_FAIL: StringName = &"STAGE_FAIL"
const EVENT_RUN_END: StringName = &"RUN_END"
const EVENT_BLACK_HOLE_PHASE: StringName = &"BLACK_HOLE_PHASE"
const EVENT_BLACK_HOLE_FINALE: StringName = &"BLACK_HOLE_FINALE"

const PRIORITY_BY_EVENT := {
	EVENT_STAGE_CLEAR: 80,
	EVENT_FINAL_SETTLEMENT: 70,
	EVENT_SCALE_SHIFT: 85,
	EVENT_STAGE_FAIL: 95,
	EVENT_RUN_END: 95,
	EVENT_BLACK_HOLE_PHASE: 90,
	EVENT_BLACK_HOLE_FINALE: 100,
}

const GAMEPLAY_PRIORITY_BY_TIER := [10, 25, 40, 55, 65]
const ACTIVE_LIMIT_BY_TIER := [12, 8, 4, 2, 1]
const SPAWN_LIMIT_PER_FRAME_BY_TIER := [4, 4, 3, 2, 1]
const MAX_ACTIVE_GAMEPLAY_EFFECTS := 24
const CASHOUT_EFFECT_BOTTOM_MARGIN := 96.0

var merge_effect_count := 0
var cashout_effect_count := 0
var value_popups_enabled := true
var dropped_effect_count := 0
var evicted_effect_count := 0
var priority_event_count := 0

var _simulation_source: Node
var _stage_source: Node
var _ball_catalog = BallCatalog.new()
var _presentation_phase: StringName = PHASE_PLAYING
var _spawned_this_frame := PackedInt32Array([0, 0, 0, 0, 0])
var _effect_sequence := 0
var _last_priority_event: StringName = &""
var _reserved_priority := -1
var _last_stage_index := -1
var _settlement_target: Control
var _active_settlement_effect: Node2D


func _ready() -> void:
	call_deferred("_bind_main_stage_source")


func _process(_delta: float) -> void:
	for tier in range(_spawned_this_frame.size()):
		_spawned_this_frame[tier] = 0


func set_simulation_source(simulation_source: Node) -> void:
	_disconnect_simulation_source()
	_simulation_source = simulation_source
	if not is_instance_valid(_simulation_source):
		return
	if _simulation_source.has_signal("ball_merged"):
		_simulation_source.ball_merged.connect(_on_ball_merged)
	if _simulation_source.has_signal("cashout_completed"):
		_simulation_source.cashout_completed.connect(_on_cashout_completed)


func set_stage_source(stage_source: Node) -> void:
	_disconnect_stage_source()
	_stage_source = stage_source
	if not is_instance_valid(_stage_source):
		_last_stage_index = -1
		return
	if _stage_source.has_signal("stage_state_changed"):
		_stage_source.stage_state_changed.connect(_on_stage_state_changed)
	if _stage_source.has_signal("stage_changed"):
		_stage_source.stage_changed.connect(_on_stage_changed)
	if _stage_source.has_signal("final_settlement_started"):
		_stage_source.final_settlement_started.connect(_on_final_settlement_started)
	if _stage_source.has_method("get_runtime_snapshot"):
		var snapshot: Dictionary = _stage_source.get_runtime_snapshot()
		_last_stage_index = int(snapshot.get("stage_index", -1))
		_on_stage_state_changed(StringName(snapshot.get("state", &"")))


func set_settlement_target(target: Control) -> void:
	_settlement_target = target


func notify_priority_event(event_key: StringName) -> bool:
	if not PRIORITY_BY_EVENT.has(event_key):
		return false

	var priority: int = PRIORITY_BY_EVENT[event_key]
	if _presentation_phase == PHASE_TERMINAL:
		if not _is_terminal_event(event_key) or priority <= _reserved_priority:
			return false
	if event_key == _last_priority_event and _presentation_phase != PHASE_PLAYING:
		return false

	_last_priority_event = event_key
	_reserved_priority = priority
	priority_event_count += 1
	_presentation_phase = PHASE_TERMINAL if _is_terminal_event(event_key) else PHASE_TRANSITION
	_retire_effects_below_priority(priority)
	priority_event_reserved.emit(event_key, priority)
	return true


func resume_gameplay_fx() -> void:
	if _presentation_phase == PHASE_TERMINAL:
		return
	_presentation_phase = PHASE_PLAYING
	_last_priority_event = &""
	_reserved_priority = -1


func reset_runtime_fx(reset_counters := false) -> void:
	_cancel_active_settlement_effect()
	for child in get_children():
		if _is_active_effect(child):
			_retire_effect(child)
	_presentation_phase = PHASE_PLAYING
	_last_priority_event = &""
	_reserved_priority = -1
	_effect_sequence = 0
	for tier in range(_spawned_this_frame.size()):
		_spawned_this_frame[tier] = 0
	if reset_counters:
		merge_effect_count = 0
		cashout_effect_count = 0
		dropped_effect_count = 0
		evicted_effect_count = 0
		priority_event_count = 0


func get_presentation_phase() -> StringName:
	return _presentation_phase


func get_active_merge_effect_count() -> int:
	return _get_active_effect_count(&"MERGE")


func get_active_cashout_effect_count() -> int:
	return _get_active_effect_count(&"CASHOUT")


func set_value_popups_enabled(enabled: bool) -> void:
	value_popups_enabled = enabled


func get_active_effect_count_for_tier(tier: int) -> int:
	if tier < 0 or tier >= ACTIVE_LIMIT_BY_TIER.size():
		return 0
	var count := 0
	for child in get_children():
		if _is_active_effect(child) and int(child.get_meta("s6_fx_tier", -1)) == tier:
			count += 1
	return count


func get_budget_snapshot() -> Dictionary:
	return {
		"phase": _presentation_phase,
		"active_gameplay_effects": _get_active_gameplay_effect_count(),
		"merge_effects_spawned": merge_effect_count,
		"cashout_effects_spawned": cashout_effect_count,
		"dropped_effects": dropped_effect_count,
		"evicted_effects": evicted_effect_count,
		"priority_events": priority_event_count,
		"reserved_event": _last_priority_event,
		"reserved_priority": _reserved_priority,
	}


func _on_ball_merged(result_level: int, world_position: Vector2) -> void:
	var definition = _ball_catalog.get_definition(result_level)
	if definition == null:
		return
	var tier := clampi(definition.fx_tier, 0, ACTIVE_LIMIT_BY_TIER.size() - 1)
	if not _reserve_gameplay_effect(tier):
		return
	var effect = MergeEffectScene.instantiate()
	_register_effect(effect, &"MERGE", tier)
	add_child(effect)
	effect.setup(world_position, definition.display_name, _get_effect_color(definition.base_color, tier), tier)
	if tier == 0 or not value_popups_enabled:
		effect.value_label.visible = false
	merge_effect_count += 1
	merge_effect_spawned.emit(result_level, world_position)


func _on_cashout_completed(score_amount: float, global_level: int, world_position: Vector2) -> void:
	var definition = _ball_catalog.get_definition(global_level)
	if definition == null:
		return
	var tier := clampi(definition.fx_tier, 0, ACTIVE_LIMIT_BY_TIER.size() - 1)
	if not _reserve_gameplay_effect(tier):
		return
	var effect = CashoutEffectScene.instantiate()
	_register_effect(effect, &"CASHOUT", tier)
	add_child(effect)
	var visual_position := Vector2(
		world_position.x,
		minf(world_position.y, get_viewport_rect().end.y - CASHOUT_EFFECT_BOTTOM_MARGIN)
	)
	effect.setup(visual_position, definition.display_name, score_amount, _get_effect_color(definition.base_color, tier), tier)
	if not value_popups_enabled:
		effect.value_label.visible = false
	cashout_effect_count += 1
	cashout_effect_spawned.emit(global_level, world_position)


func _on_final_settlement_started(_amount: float) -> void:
	if not is_instance_valid(_simulation_source) or not _simulation_source.has_method("get_render_snapshot"):
		final_settlement_presentation_finished.emit()
		return
	_cancel_active_settlement_effect()
	var snapshot: Dictionary = _simulation_source.get_render_snapshot()
	var target_position := get_viewport_rect().size * Vector2(0.82, 0.12)
	if is_instance_valid(_settlement_target):
		target_position = _settlement_target.global_position + _settlement_target.size * 0.5
	_active_settlement_effect = FinalSettlementEffectScene.instantiate()
	add_child(_active_settlement_effect)
	_active_settlement_effect.finished.connect(
		_on_final_settlement_effect_finished.bind(_active_settlement_effect),
		CONNECT_ONE_SHOT
	)
	_active_settlement_effect.setup(snapshot, target_position)
	final_settlement_visual_started.emit(_active_settlement_effect.duration)


func _on_final_settlement_effect_finished(effect: Node2D) -> void:
	if effect != _active_settlement_effect:
		return
	_active_settlement_effect = null
	final_settlement_presentation_finished.emit()


func _cancel_active_settlement_effect() -> void:
	if not is_instance_valid(_active_settlement_effect):
		_active_settlement_effect = null
		return
	_active_settlement_effect.set_process(false)
	_active_settlement_effect.queue_free()
	_active_settlement_effect = null


func _reserve_gameplay_effect(tier: int) -> bool:
	if _presentation_phase != PHASE_PLAYING:
		dropped_effect_count += 1
		return false
	if _spawned_this_frame[tier] >= SPAWN_LIMIT_PER_FRAME_BY_TIER[tier]:
		dropped_effect_count += 1
		return false
	if get_active_effect_count_for_tier(tier) >= ACTIVE_LIMIT_BY_TIER[tier]:
		dropped_effect_count += 1
		return false

	var incoming_priority: int = GAMEPLAY_PRIORITY_BY_TIER[tier]
	if _get_active_gameplay_effect_count() >= MAX_ACTIVE_GAMEPLAY_EFFECTS:
		var candidate := _find_oldest_effect_below_priority(incoming_priority)
		if candidate == null:
			dropped_effect_count += 1
			return false
		_retire_effect(candidate)
		evicted_effect_count += 1

	_spawned_this_frame[tier] += 1
	return true


func _register_effect(effect: Node, event_key: StringName, tier: int) -> void:
	_effect_sequence += 1
	effect.set_meta("s6_event_key", event_key)
	effect.set_meta("s6_fx_tier", tier)
	effect.set_meta("s6_priority", GAMEPLAY_PRIORITY_BY_TIER[tier])
	effect.set_meta("s6_sequence", _effect_sequence)
	effect.set_meta("s6_retired", false)


func _get_effect_color(base_color: Color, tier: int) -> Color:
	match tier:
		2:
			return base_color.lerp(Color.WHITE, 0.18)
		3:
			return base_color.lerp(Color.WHITE, 0.52)
		4:
			return base_color.lerp(Color.WHITE, 0.68)
		_:
			return base_color


func _retire_effects_below_priority(priority: int) -> void:
	for child in get_children():
		if _is_active_effect(child) and int(child.get_meta("s6_priority", -1)) < priority:
			_retire_effect(child)


func _retire_effect(effect: Node) -> void:
	if not is_instance_valid(effect) or bool(effect.get_meta("s6_retired", false)):
		return
	effect.set_meta("s6_retired", true)
	if effect.get_parent() == self:
		remove_child(effect)
	effect.queue_free()


func _find_oldest_effect_below_priority(priority: int) -> Node:
	var candidate: Node
	var oldest_sequence := 2147483647
	for child in get_children():
		if not _is_active_effect(child):
			continue
		if int(child.get_meta("s6_priority", -1)) >= priority:
			continue
		var sequence := int(child.get_meta("s6_sequence", 0))
		if sequence < oldest_sequence:
			oldest_sequence = sequence
			candidate = child
	return candidate


func _get_active_gameplay_effect_count() -> int:
	var count := 0
	for child in get_children():
		if _is_active_effect(child):
			count += 1
	return count


func _get_active_effect_count(event_key: StringName) -> int:
	var count := 0
	for child in get_children():
		if _is_active_effect(child) and StringName(child.get_meta("s6_event_key", &"")) == event_key:
			count += 1
	return count


func _is_active_effect(effect: Node) -> bool:
	return (
		effect.has_meta("s6_event_key")
		and not bool(effect.get_meta("s6_retired", false))
		and not effect.is_queued_for_deletion()
	)


func _is_terminal_event(event_key: StringName) -> bool:
	return event_key == EVENT_STAGE_FAIL or event_key == EVENT_RUN_END or event_key == EVENT_BLACK_HOLE_FINALE


func _on_stage_state_changed(state: StringName) -> void:
	match state:
		&"READY":
			reset_runtime_fx(true)
		&"PLAYING":
			if _presentation_phase == PHASE_TERMINAL:
				reset_runtime_fx(true)
			else:
				resume_gameplay_fx()
		&"CLEAR_LOCKED":
			notify_priority_event(EVENT_STAGE_CLEAR)
		&"SETTLING":
			notify_priority_event(EVENT_FINAL_SETTLEMENT)
		&"SHIFTING":
			notify_priority_event(EVENT_SCALE_SHIFT)
		&"FAILED":
			notify_priority_event(EVENT_STAGE_FAIL)


func _on_stage_changed(definition) -> void:
	if definition == null:
		return
	var stage_index := int(definition.stage_index)
	if _last_stage_index >= 0 and stage_index <= _last_stage_index:
		reset_runtime_fx(true)
	_last_stage_index = stage_index


func _bind_main_stage_source() -> void:
	if is_instance_valid(_stage_source) or get_tree().current_scene == null:
		return
	var stage_source := get_tree().current_scene.get_node_or_null("StageManager")
	if stage_source != null:
		set_stage_source(stage_source)


func _disconnect_simulation_source() -> void:
	if not is_instance_valid(_simulation_source):
		return
	if _simulation_source.has_signal("ball_merged") and _simulation_source.ball_merged.is_connected(_on_ball_merged):
		_simulation_source.ball_merged.disconnect(_on_ball_merged)
	if _simulation_source.has_signal("cashout_completed") and _simulation_source.cashout_completed.is_connected(_on_cashout_completed):
		_simulation_source.cashout_completed.disconnect(_on_cashout_completed)


func _disconnect_stage_source() -> void:
	if not is_instance_valid(_stage_source):
		return
	if _stage_source.has_signal("stage_state_changed") and _stage_source.stage_state_changed.is_connected(_on_stage_state_changed):
		_stage_source.stage_state_changed.disconnect(_on_stage_state_changed)
	if _stage_source.has_signal("stage_changed") and _stage_source.stage_changed.is_connected(_on_stage_changed):
		_stage_source.stage_changed.disconnect(_on_stage_changed)
	if _stage_source.has_signal("final_settlement_started") and _stage_source.final_settlement_started.is_connected(_on_final_settlement_started):
		_stage_source.final_settlement_started.disconnect(_on_final_settlement_started)


func _exit_tree() -> void:
	set_simulation_source(null)
	set_stage_source(null)
