class_name Hud
extends Control

@onready var stage_score_label: Label = $Readout/StageScoreLabel
@onready var run_score_label: Label = $Readout/RunScoreLabel
@onready var ball_count_label: Label = $Readout/BallCountLabel

var _score_source: Node
var _ball_source: Node


func bind_sources(score_source: Node, ball_source: Node) -> void:
	_unbind_sources()
	_score_source = score_source
	_ball_source = ball_source
	if is_instance_valid(_score_source):
		_score_source.score_changed.connect(_on_score_changed)
		_on_score_changed(_score_source.stage_score, _score_source.run_score)
	if is_instance_valid(_ball_source):
		_ball_source.ball_count_changed.connect(_on_ball_count_changed)
		_on_ball_count_changed(_ball_source.get_active_count())


func reset_view() -> void:
	_on_score_changed(0.0, 0.0)
	_on_ball_count_changed(0)


func _exit_tree() -> void:
	_unbind_sources()


func _on_score_changed(stage_score: float, run_score: float) -> void:
	stage_score_label.text = "STAGE %d" % int(stage_score)
	run_score_label.text = "RUN %d" % int(run_score)


func _on_ball_count_changed(active_count: int) -> void:
	ball_count_label.text = "BALLS %d" % active_count


func _unbind_sources() -> void:
	if is_instance_valid(_score_source) and _score_source.score_changed.is_connected(_on_score_changed):
		_score_source.score_changed.disconnect(_on_score_changed)
	if is_instance_valid(_ball_source) and _ball_source.ball_count_changed.is_connected(_on_ball_count_changed):
		_ball_source.ball_count_changed.disconnect(_on_ball_count_changed)
	_score_source = null
	_ball_source = null
