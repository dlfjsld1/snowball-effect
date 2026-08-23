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
	var audio_manager: AudioManager = main.get_node("AudioManager")
	var effect_manager = main.get_node("UI/HUDMount/HUD/EffectManager")
	adapter.settings_path = "user://s10_g1_three_volume_test.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(adapter.settings_path))
	var session_id := game_manager.open_settings(&"title")
	_expect(session_id == 1, "A direct title session must open.")
	_expect(game_manager.apply_settings(session_id, {"master_volume": 8, "bgm_volume": 6, "sfx_volume": 4, "value_popups_enabled": false}), "Valid settings draft must apply.")
	_expect(adapter.get_snapshot() == {"master_volume": 8, "bgm_volume": 6, "sfx_volume": 4, "value_popups_enabled": false}, "Adapter must retain all Settings v1 values.")
	var master_bus := AudioServer.get_bus_index(&"Master")
	_expect(master_bus >= 0 and is_equal_approx(AudioServer.get_bus_volume_db(master_bus), linear_to_db(8.0 / 5.0)), "Master volume must apply relative to the level-5 authored baseline.")
	var audio_snapshot := audio_manager.get_debug_snapshot()
	_expect(audio_snapshot["settings_bgm_volume"] == 6 and audio_snapshot["settings_sfx_volume"] == 4, "BGM and SFX volumes must relay to AudioManager channels.")
	_expect(not effect_manager.value_popups_enabled, "Value Popups setting must relay to EffectManager.")
	_expect(game_manager.close_settings(session_id), "Matching session must close.")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(adapter.settings_path))
	if _failures == 0:
		print("S10_G1_THREE_VOLUME_VERIFIED persistence=true master=true bgm_sfx_relay=true")
	main.free()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S10-G1 three-volume verification failed: %s" % message)
