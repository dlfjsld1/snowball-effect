extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var _failures := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var audio_manager: AudioManager = main.get_node("AudioManager")
	audio_manager.audio_unlocked = true
	game_manager._start_run()
	for item_type in [&"blizzard", &"fire_core", &"magnet"]:
		audio_manager.reset_runtime()
		game_manager._on_item_collected(item_type, Vector2(800.0, 420.0))
		var active_keys := _active_keys(audio_manager)
		_expect(active_keys.has(&"item_collect"), "Item Orb collection must play item_collect before requesting its CUT-IN.")
		_expect(active_keys.has(&"item_cutin"), "Item Orb collection must play item_cutin when its CUT-IN request is emitted.")

	if _failures == 0:
		print("S7_G1_ITEM_AUDIO_WIRING_VERIFIED item_collect_and_cutin=true item_types=3")
	main.free()
	get_tree().quit(_failures)


func _active_keys(audio_manager: AudioManager) -> Array:
	return audio_manager.get_debug_snapshot()["active_event_keys"]


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G1 item audio wiring verification failed: %s" % message)
