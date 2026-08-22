extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const SettingsAdapterScript = preload("res://scripts/core/settings_adapter.gd")

var _failures := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var game_manager: GameManager = main.get_node("GameManager")
	var settings_adapter = main.get_node("SettingsAdapter")
	var title_screen = main.get_node("UI/TitleScreen")
	var pause_menu = main.get_node("UI/PauseMenu")

	title_screen.settings_requested.emit()
	_expect(settings_adapter.get_active_session_id() == 1, "Title request must open the first Settings session.")
	_expect(settings_adapter.get_active_return_view() == SettingsAdapterScript.RETURN_VIEW_TITLE, "Title request must retain the title return view.")
	_expect(game_manager.close_settings(1), "Title session must close through GameManager.")

	var paused_before := get_tree().paused
	pause_menu.settings_requested.emit()
	_expect(settings_adapter.get_active_session_id() == 2, "Pause request must receive a new Settings session.")
	_expect(settings_adapter.get_active_return_view() == SettingsAdapterScript.RETURN_VIEW_PAUSE, "Pause request must retain the pause return view.")
	_expect(get_tree().paused == paused_before, "Settings open must not resume or pause gameplay.")
	_expect(game_manager.close_settings(2), "Pause session must close through GameManager.")
	_expect(get_tree().paused == paused_before, "Settings close must not resume gameplay.")

	if _failures == 0:
		print("S10_G1_SETTINGS_WIRING_VERIFIED title_pause_origin=true no_auto_resume=true")
	main.free()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S10-G1 settings wiring verification failed: %s" % message)
