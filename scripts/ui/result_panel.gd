class_name ResultPanel
extends Control

## Displays a copied terminal snapshot. The Core snapshot remains read-only.

const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")

signal retry_requested
signal main_menu_requested

@onready var slide_panel: Control = %SlidePanel
@onready var mechanical_motion: Control = %MechanicalMotion
@onready var score_label: Label = %ScoreLabel
@onready var stats_row: Control = %StatsRow
@onready var merge_count_label: Label = $SlidePanel/StatsRow/MergeCount
@onready var run_time_label: Label = $SlidePanel/StatsRow/RunTime
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainButton

var _result_snapshot: Dictionary = {}
var _entrance_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	retry_button.pressed.connect(_request_retry)
	main_menu_button.pressed.connect(_request_main_menu)


func show_result(result_snapshot: Dictionary) -> void:
	_result_snapshot = result_snapshot.duplicate(true)
	var run_score := float(_result_snapshot.get("run_score", 0.0))
	score_label.text = ScoreFormatter.format_score(run_score)
	_update_optional_stats()
	visible = true
	mechanical_motion.set_process(true)
	_play_entrance()
	retry_button.grab_focus()


func hide_result() -> void:
	if _entrance_tween != null and _entrance_tween.is_valid():
		_entrance_tween.kill()
	visible = false
	mechanical_motion.set_process(false)
	slide_panel.position = Vector2.ZERO
	_result_snapshot.clear()


func get_result_snapshot() -> Dictionary:
	return _result_snapshot.duplicate(true)


static func format_run_time(seconds: float) -> String:
	var total_seconds := maxi(int(floor(maxf(seconds, 0.0))), 0)
	var hours := total_seconds / 3600
	var minutes := (total_seconds % 3600) / 60
	var remaining_seconds := total_seconds % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, remaining_seconds]
	return "%02d:%02d" % [minutes, remaining_seconds]


func _play_entrance() -> void:
	if _entrance_tween != null and _entrance_tween.is_valid():
		_entrance_tween.kill()
	slide_panel.position = Vector2(0.0, size.y + 48.0)
	_entrance_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_entrance_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_entrance_tween.tween_property(slide_panel, "position:y", 0.0, 0.82)


func _update_optional_stats() -> void:
	var raw_stats = _result_snapshot.get("optional_stats", {})
	var optional_stats: Dictionary = raw_stats if raw_stats is Dictionary else {}
	var has_merge_count := optional_stats.has("merge_count")
	var has_run_time := optional_stats.has("run_time_seconds")
	merge_count_label.visible = has_merge_count
	run_time_label.visible = has_run_time
	stats_row.visible = has_merge_count or has_run_time
	if has_merge_count:
		merge_count_label.text = "%d" % maxi(int(optional_stats["merge_count"]), 0)
	if has_run_time:
		run_time_label.text = format_run_time(float(optional_stats["run_time_seconds"]))


func _request_retry() -> void:
	retry_requested.emit()


func _request_main_menu() -> void:
	main_menu_requested.emit()
