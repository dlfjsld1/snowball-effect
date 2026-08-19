class_name TitleScreen
extends Control

## Content-owned title surface. Integration decides when a run may begin.

signal start_requested
signal settings_requested

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(_request_start)
	settings_button.pressed.connect(_request_settings)


func show_title() -> void:
	visible = true
	start_button.grab_focus()


func hide_title() -> void:
	visible = false


func _request_start() -> void:
	start_requested.emit()


func _request_settings() -> void:
	settings_requested.emit()
