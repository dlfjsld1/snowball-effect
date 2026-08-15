class_name StageManager
extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const StageRuntime = preload("res://scripts/core/stage_runtime.gd")
const SettlementService = preload("res://scripts/core/settlement_service.gd")
const Ledger = preload("res://scripts/core/score_ledger.gd")

signal stage_changed(definition: StageDefinition)
signal stage_state_changed(state: StringName)
signal stage_shift_started(next_definition: StageDefinition, shift_id: int)
signal final_settlement_started(amount: float)
signal final_settlement_finished(amount: float)

const READY: StringName = &"READY"
const PLAYING: StringName = &"PLAYING"
const CLEAR_LOCKED: StringName = &"CLEAR_LOCKED"
const TIME_UP_LOCKED: StringName = &"TIME_UP_LOCKED"
const SETTLING: StringName = &"SETTLING"
const CLEARED: StringName = &"CLEARED"
const SHIFTING: StringName = &"SHIFTING"
const FAILED: StringName = &"FAILED"

@export var simulation_path: NodePath
@export var auto_complete_shift_presentation := false

var current_state: StringName = READY
var current_stage_index := 0

var _simulation: SimulationManager
var _stage_catalog = StageCatalog.new()
var _stage_runtime: StageRuntime
var _settlement_service: SettlementService
var _pending_cashouts: Array[Dictionary] = []
var _top_ball_created := false
var _pending_shift_id := -1
var _pending_shift_definition: StageDefinition
var _next_shift_id := 1


func _ready() -> void:
	_simulation = get_node(simulation_path) as SimulationManager
	_simulation.set_physics_process(false)
	_stage_runtime = StageRuntime.new()
	_settlement_service = SettlementService.new()
	add_child(_stage_runtime)
	add_child(_settlement_service)
	_settlement_service.configure(_stage_runtime.score_ledger)
	_simulation.cashout_completed.connect(_on_cashout_completed)
	_simulation.top_ball_created.connect(_on_top_ball_created)
	_stage_runtime.end_decision_requested.connect(_on_end_decision_requested)
	_settlement_service.final_settlement_started.connect(_on_final_settlement_started)
	_settlement_service.final_settlement_finished.connect(_on_final_settlement_finished)


func _physics_process(delta: float) -> void:
	if current_state != PLAYING:
		return

	_pending_cashouts.clear()
	_top_ball_created = false
	_stage_runtime.stage_time_left -= delta
	_stage_runtime.stage_time_changed.emit(_stage_runtime.stage_time_left)
	_simulation.step_simulation(delta)
	_stage_runtime.process_tick(0.0, _top_ball_created, _pending_cashouts)


func start_run() -> void:
	current_stage_index = 0
	_pending_shift_id = -1
	_pending_shift_definition = null
	_stage_runtime.score_ledger.reset_runtime()
	_enter_stage(_stage_catalog.get_stage(current_stage_index))


func get_score_ledger() -> Ledger:
	return _stage_runtime.score_ledger


func get_current_stage() -> StageDefinition:
	return _stage_runtime.current_stage


func is_playing() -> bool:
	return current_state == PLAYING


func get_runtime_snapshot() -> Dictionary:
	return {
		"state": current_state,
		"stage_index": current_stage_index,
		"stage_time_left": _stage_runtime.stage_time_left,
		"stage_score": _stage_runtime.score_ledger.stage_score,
		"run_score": _stage_runtime.score_ledger.run_score,
		"pending_shift_id": _pending_shift_id,
	}


func debug_force_top_ball_clear() -> bool:
	if not OS.is_debug_build() or current_state != PLAYING:
		return false
	_on_end_decision_requested(&"TOP_BALL_CLEAR")
	return current_state == SHIFTING or current_state == CLEARED


func debug_force_score_clear() -> bool:
	if not OS.is_debug_build() or current_state != PLAYING or _stage_runtime.current_stage == null:
		return false
	var clear_score := _stage_runtime.current_stage.clear_score
	if clear_score <= 0.0:
		return false
	var missing_score := maxf(clear_score - _stage_runtime.score_ledger.stage_score, 0.0)
	if missing_score > 0.0:
		_stage_runtime.score_ledger.apply_score_event(missing_score)
	_stage_runtime.stage_time_left = 0.0
	_stage_runtime.process_tick(0.0, false, [])
	return current_state == SHIFTING


func accept_stage_shift_presentation_finished(shift_id: int) -> bool:
	if current_state != SHIFTING or shift_id != _pending_shift_id or _pending_shift_definition == null:
		return false

	var next_definition := _pending_shift_definition
	_pending_shift_id = -1
	_pending_shift_definition = null
	current_stage_index += 1
	_enter_stage(next_definition)
	return true


func _enter_stage(definition: StageDefinition) -> void:
	assert(definition != null, "StageManager requires a valid StageDefinition.")
	_simulation.apply_stage_definition(definition)
	_settlement_service.reset_for_stage()
	_stage_runtime.enter_stage(definition)
	_set_state(PLAYING)
	stage_changed.emit(definition)


func _on_cashout_completed(score_amount: float, global_level: int, _world_position: Vector2) -> void:
	if current_state == PLAYING:
		_pending_cashouts.append({"score_amount": score_amount, "global_level": global_level})


func _on_top_ball_created(global_level: int) -> void:
	if current_state == PLAYING and _stage_runtime.is_current_stage_top_ball(global_level):
		_top_ball_created = true


func _on_final_settlement_started(amount: float) -> void:
	final_settlement_started.emit(amount)


func _on_final_settlement_finished(amount: float) -> void:
	final_settlement_finished.emit(amount)


func _on_end_decision_requested(reason: StringName) -> void:
	if reason == &"TOP_BALL_CLEAR":
		_set_state(CLEAR_LOCKED)
	else:
		_set_state(TIME_UP_LOCKED)
	_settle_and_resolve(reason)


func _settle_and_resolve(reason: StringName) -> void:
	_set_state(SETTLING)
	var active_snapshot: Array[Dictionary] = []
	var active_indices: Array[int] = _simulation.active_indices.duplicate()
	for index in active_indices:
		active_snapshot.append({"global_level": _simulation.get_ball_global_level(index)})

	_settlement_service.settle(active_snapshot)
	for index in active_indices:
		_simulation.deactivate_ball(index)

	if reason == &"TOP_BALL_CLEAR" or _stage_runtime.score_ledger.stage_score >= _stage_runtime.current_stage.clear_score:
		_set_state(CLEARED)
		_begin_scale_shift_if_available()
	else:
		_set_state(FAILED)


func _begin_scale_shift_if_available() -> void:
	var next_definition := _stage_catalog.get_stage(current_stage_index + 1) as StageDefinition
	if next_definition == null:
		return

	_pending_shift_id = _next_shift_id
	_next_shift_id += 1
	_pending_shift_definition = next_definition
	_set_state(SHIFTING)
	stage_shift_started.emit(next_definition, _pending_shift_id)
	if auto_complete_shift_presentation:
		call_deferred("_complete_temporary_shift_presentation", _pending_shift_id)


func _complete_temporary_shift_presentation(shift_id: int) -> void:
	accept_stage_shift_presentation_finished(shift_id)


func _set_state(next_state: StringName) -> void:
	current_state = next_state
	stage_state_changed.emit(current_state)
