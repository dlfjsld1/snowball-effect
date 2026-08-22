extends Node

## Disposable Content preview: loads the real Main scene without changing the
## Integration-owned Main file, then places the Content-owned visual in PlayField.

const MainScene := preload("res://scenes/main/main.tscn")
const BlizzardVisualScene := preload("res://scenes/effects/item_blizzard_visual.tscn")


func _ready() -> void:
	var main := MainScene.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	main.get_node("GameManager").call("_start_run")
	var visual := BlizzardVisualScene.instantiate()
	main.get_node("PlayField").add_child(visual)
	visual.show_item_planet_spawned(&"blizzard", Vector2(800.0, 315.0), 24.0)
	visual.show_item_planet_damaged(&"blizzard", 2, 5, Vector2(800.0, 315.0))
	visual.show_item_orb_spawned(&"blizzard", Vector2(800.0, 430.0))
	visual.set_blizzard_state({"item_type": &"blizzard", "active": true, "remaining_seconds": 4.3})
