class_name StageRuntime
extends Node

const Ledger = preload("res://scripts/core/score_ledger.gd")

signal stage_time_changed(time_left: float)
signal score_changed(stage_score: float, run_score: float)
signal stage_entered(definition: StageDefinition)

var current_stage: StageDefinition
var stage_time_left := 0.0
var score_ledger: Ledger = Ledger.new()


func enter_stage(definition: StageDefinition) -> void:
	assert(definition != null, "StageRuntime requires a StageDefinition.")
	_ensure_ledger_connection()
	current_stage = definition
	score_ledger.begin_stage()
	stage_time_left = definition.base_time
	stage_time_changed.emit(stage_time_left)
	stage_entered.emit(definition)


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


func _on_ledger_score_changed(stage_score: float, run_score: float) -> void:
	score_changed.emit(stage_score, run_score)


func _ensure_ledger_connection() -> void:
	if score_ledger.get_parent() == null:
		add_child(score_ledger)
	if not score_ledger.score_changed.is_connected(_on_ledger_score_changed):
		score_ledger.score_changed.connect(_on_ledger_score_changed)
