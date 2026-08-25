extends Node

const PauseMenuScene = preload("res://scenes/ui/pause_menu.tscn")
const PauseMenuScript = preload("res://scripts/ui/pause_menu.gd")

var _pause_requests := 0
var _retry_requests := 0
var _resume_requests := 0
var _failures := 0


func _ready() -> void:
	var menu: PauseMenuScript = PauseMenuScene.instantiate()
	add_child(menu)
	menu.pause_requested.connect(func() -> void: _pause_requests += 1)
	menu.retry_requested.connect(func() -> void: _retry_requests += 1)
	menu.resume_requested.connect(func() -> void: _resume_requests += 1)

	var gameplay_state := {"value": 17}
	var pause_event := InputEventAction.new()
	pause_event.action = "pause_game"
	pause_event.pressed = true
	menu._unhandled_input(pause_event)
	_expect(_pause_requests == 1, "Pause input must emit one request.")

	menu.retry_button.pressed.emit()
	_expect(_retry_requests == 1, "Retry button must emit one request.")
	_expect(gameplay_state.value == 17, "Request UI must not mutate gameplay state.")

	menu.set_paused(true)
	_expect(menu.pause_modal.visible and not menu.pause_button.visible, "Paused view must show the modal instead of the quick controls.")
	_expect(menu.settings_button.get_index() + 1 == menu.how_to_play_button.get_index(), "How to Play must follow Settings.")
	_expect(menu.how_to_play_button.get_index() + 1 == menu.main_menu_button.get_index(), "How to Play must precede Main Menu.")
	menu.how_to_play_button.pressed.emit()
	_expect(menu.how_to_play_modal.visible, "How to Play must open the shared controls guide.")
	menu.how_to_play_dismiss_button.pressed.emit()
	_expect(not menu.how_to_play_modal.visible, "How to Play guide must dismiss without resuming gameplay.")
	menu.resume_button.pressed.emit()
	_expect(_resume_requests == 1, "Resume button must emit one request without changing runtime state.")
	menu.set_paused(false)
	_expect(not menu.pause_modal.visible and menu.pause_button.visible, "Playing view must restore the quick controls.")
	_expect(not get_tree().paused, "Request UI must not pause the SceneTree directly.")

	if _failures == 0:
		print("S1_G5_VERIFIED pause_requests=1 retry_requests=1 gameplay_mutation=none")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S1-G5 verification failed: %s" % message)
