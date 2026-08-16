extends Node

const TitleScreenScene = preload("res://scenes/ui/title_screen.tscn")
const PauseMenuScene = preload("res://scenes/ui/pause_menu.tscn")
const ResultPanelScene = preload("res://scenes/ui/result_panel.tscn")

var _failures := 0
var _start_requests := 0
var _pause_requests := 0
var _resume_requests := 0
var _retry_requests := 0
var _settings_requests := 0
var _main_menu_requests := 0


func _ready() -> void:
	var title = TitleScreenScene.instantiate()
	var pause_menu: PauseMenu = PauseMenuScene.instantiate()
	var result = ResultPanelScene.instantiate()
	add_child(title)
	add_child(pause_menu)
	add_child(result)
	await get_tree().process_frame

	title.start_requested.connect(func() -> void: _start_requests += 1)
	pause_menu.pause_requested.connect(func() -> void: _pause_requests += 1)
	pause_menu.resume_requested.connect(func() -> void: _resume_requests += 1)
	pause_menu.retry_requested.connect(func() -> void: _retry_requests += 1)
	pause_menu.settings_requested.connect(func() -> void: _settings_requests += 1)
	pause_menu.main_menu_requested.connect(func() -> void: _main_menu_requests += 1)
	result.main_menu_requested.connect(func() -> void: _main_menu_requests += 1)

	_verify_title(title)
	_verify_pause_modal(pause_menu)
	_verify_result(result)
	_expect(not get_tree().paused, "Content UI must not change the SceneTree pause state.")

	if _failures == 0:
		print("S8_G3_VERIFIED title=true pause_modal=true result_snapshot=read_only requests=once")
	get_tree().quit(_failures)


func _verify_title(title) -> void:
	title.show_title()
	_expect(title.visible, "Title API must reveal the title screen.")
	title.start_button.pressed.emit()
	_expect(_start_requests == 1, "Title start action must emit exactly one request.")
	title.hide_title()
	_expect(not title.visible, "Title API must hide the title screen.")


func _verify_pause_modal(pause_menu: PauseMenu) -> void:
	pause_menu.set_paused(false)
	pause_menu.pause_button.pressed.emit()
	_expect(_pause_requests == 1, "Quick pause control must emit exactly one request.")
	pause_menu.set_paused(true)
	_expect(pause_menu.pause_modal.visible, "Paused UI must reveal the modal.")
	pause_menu.resume_button.pressed.emit()
	pause_menu.modal_retry_button.pressed.emit()
	pause_menu.settings_button.pressed.emit()
	pause_menu.main_menu_button.pressed.emit()
	_expect(_resume_requests == 1 and _retry_requests == 1, "Resume and retry actions must each emit once.")
	_expect(_settings_requests == 1 and _main_menu_requests == 1, "Settings and main-menu actions must each emit once.")


func _verify_result(result) -> void:
	var supplied_snapshot := {
		"run_score": 1234567.0,
		"black_holes": [{"position": Vector2(10.0, 20.0)}],
	}
	result.show_result(supplied_snapshot)
	_expect(result.visible, "Result API must reveal the result panel.")
	_expect(result.score_label.text == "CLEAR SCORE\n1.23M", "Result must format the final run score.")
	supplied_snapshot["black_holes"][0]["position"] = Vector2.ZERO
	var copied_snapshot: Dictionary = result.get_result_snapshot()
	_expect(copied_snapshot["black_holes"][0]["position"] == Vector2(10.0, 20.0), "Result must keep a read-only copy of the terminal snapshot.")
	result.main_menu_button.pressed.emit()
	_expect(_main_menu_requests == 2, "Result main-menu action must emit exactly once.")
	result.hide_result()
	_expect(not result.visible and result.get_result_snapshot().is_empty(), "Hiding the result must clear only its UI copy.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G3 verification failed: %s" % message)
