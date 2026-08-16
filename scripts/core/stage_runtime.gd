class_name StageRuntime
extends Node

const Ledger = preload("res://scripts/core/score_ledger.gd")
const BLACK_HOLE_ABSORPTION_SCORE_RATIO := 0.125
const BLACK_HOLE_ABSORPTION_BASELINE_CAP_RATIO := 0.25

signal stage_time_changed(time_left: float)
signal score_changed(stage_score: float, run_score: float)
signal stage_entered(definition: StageDefinition)
signal end_decision_requested(reason: StringName)
signal black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2)
signal black_hole_run_end_requested()
signal black_hole_finale_locked(result_snapshot: Dictionary)

var current_stage: StageDefinition
var stage_time_left := 0.0
var score_ledger: Ledger = Ledger.new()
var _end_decision_locked := false
var _next_black_hole_phase_id := 1
var _black_hole_run_end_locked := false
var _black_hole_finale_locked := false
var _black_hole_finale_snapshot: Dictionary = {}
var _black_hole_phase_run_score_baseline := 0.0
var _black_hole_phase_baseline_captured := false


func enter_stage(definition: StageDefinition) -> void:
	assert(definition != null, "StageRuntime requires a StageDefinition.")
	_ensure_ledger_connection()
	current_stage = definition
	score_ledger.begin_stage()
	stage_time_left = definition.base_time
	_end_decision_locked = false
	_next_black_hole_phase_id = 1
	_black_hole_run_end_locked = false
	_black_hole_finale_locked = false
	_black_hole_finale_snapshot.clear()
	_black_hole_phase_run_score_baseline = 0.0
	_black_hole_phase_baseline_captured = false
	stage_time_changed.emit(stage_time_left)
	stage_entered.emit(definition)


func apply_stage_definition(definition: StageDefinition) -> void:
	enter_stage(definition)


func get_stage_snapshot() -> Dictionary:
	if current_stage == null:
		return {}
	return {
		"stage_index": current_stage.stage_index,
		"base_global_level": current_stage.base_global_level,
		"top_global_level": current_stage.top_global_level,
		"local_ball_levels": current_stage.local_ball_levels.duplicate(),
		"spawn_rate": current_stage.spawn_rate,
		"stage_time_left": stage_time_left,
		"stage_score": score_ledger.stage_score,
		"run_score": score_ledger.run_score,
		"end_decision_locked": _end_decision_locked,
	}


func apply_active_cashout(score_amount: float, global_level: int) -> float:
	assert(current_stage != null, "Active Cashout requires an entered Stage.")
	assert(score_amount >= 0.0, "Cashout score must not be negative.")

	var local_level := current_stage.local_ball_levels.find(global_level)
	assert(local_level >= 0, "Cashout ball must belong to the current Stage progression.")
	assert(local_level < current_stage.time_bonus_by_local_level.size(), "Stage Time Bonus data must cover each local level.")

	var time_bonus: float = current_stage.time_bonus_by_local_level[local_level]
	score_ledger.apply_score_event(score_amount)
	stage_time_left += time_bonus
	stage_time_changed.emit(stage_time_left)
	return time_bonus


func process_tick(delta: float, top_ball_created: bool, cashouts: Array[Dictionary]) -> StringName:
	assert(current_stage != null, "Tick processing requires an entered Stage.")
	if _end_decision_locked:
		return &""

	stage_time_left -= delta
	stage_time_changed.emit(stage_time_left)

	for cashout in cashouts:
		apply_active_cashout(cashout["score_amount"], cashout["global_level"])

	if top_ball_created:
		return _request_end_decision(&"TOP_BALL_CLEAR")
	if stage_time_left <= 0.0:
		return _request_end_decision(&"TIME_UP")
	return &""


func is_current_stage_top_ball(global_level: int) -> bool:
	return current_stage != null and global_level == current_stage.top_global_level


func begin_black_hole_phase(from_rect: Rect2, to_rect: Rect2) -> int:
	assert(current_stage != null and current_stage.black_hole_enabled, "Black Hole Phase requires the Galactic Black Hole Stage.")
	if not _black_hole_phase_baseline_captured:
		_black_hole_phase_run_score_baseline = maxf(score_ledger.run_score, 0.0)
		_black_hole_phase_baseline_captured = true
	var phase_id := _next_black_hole_phase_id
	_next_black_hole_phase_id += 1
	black_hole_phase_started.emit(phase_id, from_rect, to_rect)
	return phase_id


func apply_black_hole_absorption(score_amount: float) -> bool:
	assert(score_amount >= 0.0, "Black Hole absorption penalty must not be negative.")
	var penalty := calculate_black_hole_absorption_penalty(score_amount)
	score_ledger.stage_score = maxf(score_ledger.stage_score - penalty, 0.0)
	score_ledger.run_score = maxf(score_ledger.run_score - penalty, 0.0)
	score_ledger.score_changed.emit(score_ledger.stage_score, score_ledger.run_score)
	if score_ledger.run_score <= 0.0 and not _black_hole_run_end_locked:
		_black_hole_run_end_locked = true
		black_hole_run_end_requested.emit()
	return _black_hole_run_end_locked


func calculate_black_hole_absorption_penalty(cashout_score: float) -> float:
	assert(cashout_score >= 0.0, "Black Hole absorption Cashout score must not be negative.")
	var scaled_penalty := cashout_score * BLACK_HOLE_ABSORPTION_SCORE_RATIO
	var phase_cap := _black_hole_phase_run_score_baseline * BLACK_HOLE_ABSORPTION_BASELINE_CAP_RATIO
	return minf(scaled_penalty, phase_cap)


func get_black_hole_phase_run_score_baseline() -> float:
	return _black_hole_phase_run_score_baseline


func lock_black_hole_finale(contact_snapshot: Dictionary) -> Dictionary:
	assert(not contact_snapshot.is_empty(), "Black Hole finale requires a contact snapshot.")
	if _black_hole_finale_locked:
		return get_black_hole_finale_snapshot()
	_black_hole_finale_locked = true
	_black_hole_finale_snapshot = contact_snapshot.duplicate(true)
	_black_hole_finale_snapshot["stage_index"] = current_stage.stage_index if current_stage != null else -1
	_black_hole_finale_snapshot["stage_score"] = score_ledger.stage_score
	_black_hole_finale_snapshot["run_score"] = score_ledger.run_score
	black_hole_finale_locked.emit(get_black_hole_finale_snapshot())
	return get_black_hole_finale_snapshot()


func is_black_hole_finale_locked() -> bool:
	return _black_hole_finale_locked


func get_black_hole_finale_snapshot() -> Dictionary:
	return _black_hole_finale_snapshot.duplicate(true)


func _on_ledger_score_changed(stage_score: float, run_score: float) -> void:
	score_changed.emit(stage_score, run_score)


func _ensure_ledger_connection() -> void:
	if score_ledger.get_parent() == null:
		add_child(score_ledger)
	if not score_ledger.score_changed.is_connected(_on_ledger_score_changed):
		score_ledger.score_changed.connect(_on_ledger_score_changed)


func _request_end_decision(reason: StringName) -> StringName:
	_end_decision_locked = true
	end_decision_requested.emit(reason)
	return reason
