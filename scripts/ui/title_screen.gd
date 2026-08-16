class_name TitleScreen
extends Control

## Content-owned title surface. Integration decides when a run may begin.

signal start_requested

@onready var start_button: Button = $Center/Panel/Content/StartButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(_request_start)


func show_title() -> void:
	visible = true
	start_button.grab_focus()


func hide_title() -> void:
	visible = false


func _request_start() -> void:
	start_requested.emit()
