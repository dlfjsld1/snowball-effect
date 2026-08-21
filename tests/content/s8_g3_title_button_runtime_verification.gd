extends SceneTree

const TitleScreenScene = preload("res://scenes/ui/title_screen.tscn")

var _failures := 0
var _start_requests := 0
var _settings_requests := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var title: TitleScreen = TitleScreenScene.instantiate()
	root.add_child(title)
	await process_frame

	title.start_requested.connect(func() -> void: _start_requests += 1)
	title.settings_requested.connect(func() -> void: _settings_requests += 1)
	title.show_title()

	_expect(title.start_button is Button, "START RUN must be a Godot Button.")
	_expect(title.settings_button is Button, "SETTINGS must be a Godot Button.")
	_expect(title.start_button.has_focus(), "START RUN must receive initial keyboard focus.")
	_expect(title.get_node("MechanicalMotion").mouse_filter == Control.MOUSE_FILTER_IGNORE, "Decorative motion must not intercept button input.")

	title.start_button.pressed.emit()
	title.settings_button.pressed.emit()
	_expect(_start_requests == 1, "START RUN must emit one start request.")
	_expect(_settings_requests == 1, "SETTINGS must emit one settings request.")

	if _failures == 0:
		print("S8_G3_TITLE_BUTTONS_VERIFIED actual_buttons=true start_request=1 settings_request=1")
	quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G3 Title button verification failed: %s" % message)
