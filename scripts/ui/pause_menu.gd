class_name PauseMenu
extends Control

signal pause_requested
signal retry_requested

@onready var pause_button: Button = $Buttons/PauseButton
@onready var retry_button: Button = $Buttons/RetryButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.pressed.connect(_request_pause)
	retry_button.pressed.connect(_request_retry)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game") and not _is_echo(event):
		_request_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart_game") and not _is_echo(event):
		_request_retry()
		get_viewport().set_input_as_handled()


func set_paused(is_paused: bool) -> void:
	pause_button.text = "RESUME" if is_paused else "PAUSE"


func apply_frame_layout(right_bottom_panel: Rect2) -> void:
	$Buttons.position = right_bottom_panel.position + Vector2(16.0, 16.0)


func _request_pause() -> void:
	pause_requested.emit()


func _request_retry() -> void:
	retry_requested.emit()


func _is_echo(event: InputEvent) -> bool:
	return event is InputEventKey and event.echo
