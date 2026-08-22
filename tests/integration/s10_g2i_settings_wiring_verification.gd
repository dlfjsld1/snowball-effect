extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var _failures := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var game_manager: GameManager = main.get_node("GameManager")
	var adapter = main.get_node("SettingsAdapter")
	var panel = main.get_node("UI/SettingsPanel")
	var title_screen = main.get_node("UI/TitleScreen")
	var pause_menu = main.get_node("UI/PauseMenu")
	var initial_snapshot: Dictionary = adapter.get_snapshot()
	adapter.settings_path = "user://s10_g2i_settings_wiring_test.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(adapter.settings_path))

	title_screen.settings_requested.emit()
	_expect(panel.visible and panel.get_active_session_id() == 1, "Title request must open the mounted shared panel.")
	_expect(panel.get_return_view() == &"title", "Title session must retain the title return view.")
	panel._adjust_master(2)
	panel._adjust_bgm(1)
	panel._adjust_sfx(-1)
	panel.value_popups_toggle.button_pressed = false
	_expect(adapter.get_snapshot() == {"master_volume": 7, "bgm_volume": 6, "sfx_volume": 4, "value_popups_enabled": false}, "Panel edits must preview immediately through the adapter.")
	panel.apply_button.emit_signal("pressed")
	_expect(adapter.get_snapshot() == {"master_volume": 7, "bgm_volume": 6, "sfx_volume": 4, "value_popups_enabled": false}, "Panel Apply must relay the session draft to the adapter.")
	_expect(not panel.visible and title_screen.visible, "Title Apply must save, hide Settings and return to Title.")
	_expect(get_viewport().gui_get_focus_owner() == title_screen.settings_button, "Title Apply must restore focus to the Settings trigger.")

	var paused_before := get_tree().paused
	pause_menu.settings_requested.emit()
	_expect(panel.visible and panel.get_active_session_id() == 2 and panel.get_return_view() == &"pause", "Pause request must reuse the mounted panel with a pause return view.")
	_expect(get_tree().paused == paused_before, "Opening Settings must not alter the gameplay pause state.")
	panel._adjust_master(-3)
	_expect(adapter.get_snapshot()["master_volume"] == 4, "Pause edits must preview immediately.")
	panel.close_button.emit_signal("pressed")
	_expect(not panel.visible and get_tree().paused == paused_before, "Pause close must not resume gameplay.")
	_expect(adapter.get_snapshot() == {"master_volume": 7, "bgm_volume": 6, "sfx_volume": 4, "value_popups_enabled": false}, "Close must discard preview values and restore the latest Apply snapshot.")
	_expect(get_viewport().gui_get_focus_owner() == pause_menu.settings_button, "Pause close must restore focus to the Settings trigger.")

	var restore_session: int = adapter.open_settings(&"title")
	adapter.apply_settings(restore_session, initial_snapshot)
	adapter.close_settings(restore_session)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(adapter.settings_path))
	if _failures == 0:
		print("S10_G2I_SETTINGS_WIRING_VERIFIED shared_mount=true title_pause=true apply_relay=true no_auto_resume=true")
	main.free()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S10-G2I settings wiring verification failed: %s" % message)
