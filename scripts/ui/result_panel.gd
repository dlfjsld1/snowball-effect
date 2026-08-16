class_name ResultPanel
extends Control

## Displays a copied terminal snapshot. The Core snapshot remains read-only.

const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")

signal main_menu_requested

@onready var score_label: Label = $Center/Panel/Content/ScoreLabel
@onready var main_menu_button: Button = $Center/Panel/Content/MainMenuButton

var _result_snapshot: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	main_menu_button.pressed.connect(_request_main_menu)


func show_result(result_snapshot: Dictionary) -> void:
	_result_snapshot = result_snapshot.duplicate(true)
	var run_score := float(_result_snapshot.get("run_score", 0.0))
	score_label.text = "CLEAR SCORE\n%s" % ScoreFormatter.format_score(run_score)
	visible = true
	main_menu_button.grab_focus()


func hide_result() -> void:
	visible = false
	_result_snapshot.clear()


func get_result_snapshot() -> Dictionary:
	return _result_snapshot.duplicate(true)


func _request_main_menu() -> void:
	main_menu_requested.emit()
