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
signal stage_run_ended(result_snapshot: Dictionary)
signal final_settlement_started(amount: float)
signal final_settlement_finished(amount: float)
signal black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2)
signal black_hole_phase_gameplay_resumed(phase_id: int, logical_rect: Rect2)
signal black_hole_finale_locked(result_snapshot: Dictionary)

const READY: StringName = &"READY"
const PLAYING: StringName = &"PLAYING"
const CLEAR_LOCKED: StringName = &"CLEAR_LOCKED"
const TIME_UP_LOCKED: StringName = &"TIME_UP_LOCKED"
const SETTLING: StringName = &"SETTLING"
const CLEARED: StringName = &"CLEARED"
const SHIFTING: StringName = &"SHIFTING"
const FAILED: StringName = &"FAILED"
const BLACK_HOLE_PHASE_LOCKED: StringName = &"BLACK_HOLE_PHASE_LOCKED"
const RUN_ENDED: StringName = &"RUN_ENDED"

@export var simulation_path: NodePath
@export var auto_complete_shift_presentation := false

var current_state: StringName = READY
var current_stage_index := 0

var _simulation: SimulationManager
var _stage_catalog = StageCatalog.new()
var _stage_runtime: StageRuntime
var _settlement_service: SettlementService
var _pending_cashouts: Array[Dictionary] = []
var _pending_shift_id := -1
var _pending_shift_definition: StageDefinition
var _next_shift_id := 1
var _pending_black_hole_phase_id := -1
var _pending_black_hole_logical_rect := Rect2()


func _ready() -> void:
	_simulation = get_node(simulation_path) as SimulationManager
	_simulation.set_physics_process(false)
	call_deferred("_disable_simulation_physics_process")
	_stage_runtime = StageRuntime.new()
	_settlement_service = SettlementService.new()
	add_child(_stage_runtime)
	add_child(_settlement_service)
	_settlement_service.configure(_stage_runtime.score_ledger)
	_simulation.cashout_completed.connect(_on_cashout_completed)
	_simulation.ball_merged.connect(_on_ball_merged)
	_simulation.black_hole_absorbed.connect(_on_black_hole_absorbed)
	_simulation.black_hole_finale_started.connect(_on_black_hole_finale_started)
	_stage_runtime.end_decision_requested.connect(_on_end_decision_requested)
	_stage_runtime.black_hole_phase_started.connect(_on_black_hole_phase_started)
	_stage_runtime.black_hole_run_end_requested.connect(_on_black_hole_run_end_requested)
	_stage_runtime.black_hole_finale_locked.connect(_on_black_hole_finale_locked)
	_settlement_service.final_settlement_started.connect(_on_final_settlement_started)
	_settlement_service.final_settlement_finished.connect(_on_final_settlement_finished)


func _disable_simulation_physics_process() -> void:
	# The sibling simulation node may register its default physics callback after
	# this manager's _ready. StageManager is the single authoritative tick owner.
	_simulation.set_physics_process(false)


func _physics_process(delta: float) -> void:
	if current_state != PLAYING:
		return

	_pending_cashouts.clear()
	var valid_play_delta := _stage_runtime.get_valid_play_delta(delta)
	_stage_runtime.advance_run_time(valid_play_delta)
	_simulation.step_simulation(valid_play_delta)
	if current_state != PLAYING:
		return
	_stage_runtime.process_tick(valid_play_delta, false, _pending_cashouts)


func start_run() -> void:
	current_stage_index = 0
	_pending_shift_id = -1
	_pending_shift_definition = null
	_pending_black_hole_phase_id = -1
	_pending_black_hole_logical_rect = Rect2()
	_stage_runtime.score_ledger.reset_runtime()
	_stage_runtime.reset_run_statistics()
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
		"run_merge_count": _stage_runtime.get_run_statistics()["merge_count"],
		"run_time_seconds": _stage_runtime.get_run_statistics()["run_time_seconds"],
		"pending_shift_id": _pending_shift_id,
		"pending_black_hole_phase_id": _pending_black_hole_phase_id,
		"black_hole_finale_locked": _stage_runtime.is_black_hole_finale_locked(),
	}


func debug_force_score_clear() -> bool:
	if not OS.is_debug_build() or current_state != PLAYING or _stage_runtime.current_stage == null:
		return false
	var clear_score := _stage_runtime.current_stage.clear_score
	if clear_score <= 0.0:
		return false
	var missing_score := maxf(clear_score - _stage_runtime.score_ledger.stage_score, 0.0)
	if missing_score > 0.0:
		_stage_runtime.score_ledger.apply_score_event(missing_score)
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


func begin_black_hole_phase(from_rect: Rect2, to_rect: Rect2) -> bool:
	if current_state != PLAYING or _stage_runtime.current_stage == null or not _stage_runtime.current_stage.black_hole_enabled:
		return false
	if _pending_black_hole_phase_id != -1 or to_rect.size.x <= 0.0 or to_rect.size.y <= 0.0:
		return false

	_set_state(BLACK_HOLE_PHASE_LOCKED)
	_pending_black_hole_logical_rect = to_rect
	_pending_black_hole_phase_id = _stage_runtime.begin_black_hole_phase(from_rect, to_rect)
	return true


func accept_black_hole_phase_presentation_finished(phase_id: int) -> bool:
	if current_state != BLACK_HOLE_PHASE_LOCKED or phase_id != _pending_black_hole_phase_id:
		return false

	var logical_rect := _pending_black_hole_logical_rect
	_pending_black_hole_phase_id = -1
	_pending_black_hole_logical_rect = Rect2()
	black_hole_phase_gameplay_resumed.emit(phase_id, logical_rect)
	_set_state(PLAYING)
	return true


func end_run_to_main_menu() -> void:
	_pending_shift_id = -1
	_pending_shift_definition = null
	_pending_black_hole_phase_id = -1
	_pending_black_hole_logical_rect = Rect2()
	_simulation.reset_runtime()
	_settlement_service.reset_for_stage()
	_stage_runtime.score_ledger.reset_runtime()
	_stage_runtime.reset_run_statistics()
	_set_state(READY)


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


func _on_ball_merged(_result_level: int, _world_position: Vector2) -> void:
	if current_state == PLAYING or current_state == BLACK_HOLE_PHASE_LOCKED:
		_stage_runtime.record_run_merge()


func _on_black_hole_absorbed(score_amount: float, _global_level: int, _world_position: Vector2) -> void:
	if current_state == PLAYING or current_state == BLACK_HOLE_PHASE_LOCKED:
		_stage_runtime.apply_black_hole_absorption(score_amount)


func _on_black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2) -> void:
	black_hole_phase_started.emit(phase_id, from_rect, to_rect)


func _on_black_hole_finale_started(contact_snapshot: Dictionary) -> void:
	if current_state != PLAYING:
		return
	_stage_runtime.lock_black_hole_finale(contact_snapshot)


func _on_black_hole_run_end_requested() -> void:
	if current_state == PLAYING or current_state == BLACK_HOLE_PHASE_LOCKED:
		_pending_black_hole_phase_id = -1
		_pending_black_hole_logical_rect = Rect2()
		_set_state(FAILED)


func _on_black_hole_finale_locked(result_snapshot: Dictionary) -> void:
	if current_state != PLAYING:
		return
	_set_state(RUN_ENDED)
	black_hole_finale_locked.emit(result_snapshot.duplicate(true))


func _on_final_settlement_started(amount: float) -> void:
	final_settlement_started.emit(amount)


func _on_final_settlement_finished(amount: float) -> void:
	final_settlement_finished.emit(amount)


func _on_end_decision_requested(reason: StringName) -> void:
	if reason != &"SCORE_CLEAR" and reason != &"TIME_UP":
		return
	_set_state(CLEAR_LOCKED if reason == &"SCORE_CLEAR" else TIME_UP_LOCKED)
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

	var is_non_final_stage := _stage_catalog.get_stage(current_stage_index + 1) != null
	if is_non_final_stage and _stage_runtime.score_ledger.stage_score >= _stage_runtime.current_stage.clear_score:
		_set_state(CLEARED)
		_begin_scale_shift_if_available()
	else:
		if is_non_final_stage:
			_set_state(FAILED)
		else:
			_set_state(RUN_ENDED)
			stage_run_ended.emit({
				"stage_index": current_stage_index,
				"stage_score": _stage_runtime.score_ledger.stage_score,
				"run_score": _stage_runtime.score_ledger.run_score,
			})

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
