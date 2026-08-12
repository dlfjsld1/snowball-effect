class_name ScoreLedger
extends Node

signal score_changed(stage_score: float, run_score: float)

var stage_score := 0.0
var run_score := 0.0


func apply_score_event(amount: float, _local_level := 0, _world_position := Vector2.ZERO) -> void:
	assert(amount >= 0.0, "Score amount must not be negative.")
	stage_score += amount
	run_score += amount
	score_changed.emit(stage_score, run_score)


func begin_stage() -> void:
	stage_score = 0.0
	score_changed.emit(stage_score, run_score)


func reset_runtime() -> void:
	stage_score = 0.0
	run_score = 0.0
	score_changed.emit(stage_score, run_score)
