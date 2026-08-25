class_name TitleScreen
extends Control

## Content-owned title surface. Integration decides when a run may begin.

signal start_requested
signal settings_requested

@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var help_button: Button = %HelpButton
@onready var help_visual: Control = %HelpVisual
@onready var help_modal: Control = %HelpModal
@onready var help_dismiss_button: Button = %DismissButton
@onready var help_image: TextureRect = %GuideImage

var _help_hovered := false
var _help_held := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_button.pressed.connect(_request_start)
	settings_button.pressed.connect(_request_settings)
	help_button.mouse_entered.connect(_on_help_mouse_entered)
	help_button.mouse_exited.connect(_on_help_mouse_exited)
	help_button.button_down.connect(_on_help_button_down)
	help_button.button_up.connect(_on_help_button_up)
	help_button.pressed.connect(_open_help_modal)
	help_dismiss_button.pressed.connect(_close_help_modal)


func show_title() -> void:
	help_modal.visible = false
	visible = true
	start_button.grab_focus()


func hide_title() -> void:
	help_modal.visible = false
	visible = false


func _request_start() -> void:
	start_requested.emit()


func _request_settings() -> void:
	settings_requested.emit()


func _on_help_mouse_entered() -> void:
	_help_hovered = true
	_update_help_visual_alpha()


func _on_help_mouse_exited() -> void:
	_help_hovered = false
	_help_held = false
	_update_help_visual_alpha()


func _on_help_button_down() -> void:
	_help_held = true
	_update_help_visual_alpha()


func _on_help_button_up() -> void:
	_help_held = false
	_update_help_visual_alpha()


func _update_help_visual_alpha() -> void:
	help_visual.modulate.a = 0.45 if _help_hovered or _help_held else 1.0


func _open_help_modal() -> void:
	_help_hovered = false
	_help_held = false
	_update_help_visual_alpha()
	help_modal.visible = true
	help_dismiss_button.grab_focus()


func _close_help_modal() -> void:
	if not help_modal.visible:
		return
	help_modal.visible = false
	if visible:
		start_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if help_modal.visible and event.is_action_pressed(&"ui_cancel"):
		_close_help_modal()
		get_viewport().set_input_as_handled()
