class_name PauseMenu
extends Control

signal pause_requested
signal retry_requested
signal resume_requested
signal settings_requested
signal main_menu_requested

@onready var pause_button: Button = $Buttons/PauseButton
@onready var retry_button: Button = $Buttons/RetryButton
@onready var pause_modal: Control = $PauseModal
@onready var resume_button: Button = $PauseModal/Center/Panel/Margin/Content/Actions/ResumeButton
@onready var modal_retry_button: Button = $PauseModal/Center/Panel/Margin/Content/Actions/RetryButton
@onready var settings_button: Button = $PauseModal/Center/Panel/Margin/Content/Actions/SettingsButton
@onready var main_menu_button: Button = $PauseModal/Center/Panel/Margin/Content/Actions/MainMenuButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.pressed.connect(_request_pause)
	retry_button.pressed.connect(_request_retry)
	resume_button.pressed.connect(_request_resume)
	modal_retry_button.pressed.connect(_request_retry)
	settings_button.pressed.connect(_request_settings)
	main_menu_button.pressed.connect(_request_main_menu)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game") and not _is_echo(event):
		if pause_modal.visible:
			_request_resume()
		else:
			_request_pause()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart_game") and not _is_echo(event):
		_request_retry()
		get_viewport().set_input_as_handled()


func set_paused(is_paused: bool) -> void:
	pause_modal.visible = is_paused
	pause_button.visible = not is_paused
	retry_button.visible = not is_paused


func apply_frame_layout(right_bottom_panel: Rect2) -> void:
	$Buttons.position = right_bottom_panel.position + Vector2(16.0, 16.0)


func _request_pause() -> void:
	pause_requested.emit()


func _request_retry() -> void:
	retry_requested.emit()


func _request_resume() -> void:
	resume_requested.emit()


func _request_settings() -> void:
	settings_requested.emit()


func _request_main_menu() -> void:
	main_menu_requested.emit()


func _is_echo(event: InputEvent) -> bool:
	return event is InputEventKey and event.echo
