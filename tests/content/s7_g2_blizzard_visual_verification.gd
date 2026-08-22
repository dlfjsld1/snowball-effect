extends Node

const BlizzardVisualScript = preload("res://scripts/presentation/item_blizzard_visual.gd")

var _failures := 0


func _ready() -> void:
	var visual = BlizzardVisualScript.new()
	add_child(visual)
	visual.show_item_planet_spawned(&"blizzard", Vector2(800.0, 270.0), 24.0)
	_expect(visual.get_visual_snapshot()["planet_visible"], "Blizzard Item Ball must be visible on spawn.")
	visual.show_item_planet_damaged(&"blizzard", 3, 5, Vector2(800.0, 270.0))
	visual.show_item_orb_spawned(&"blizzard", Vector2(800.0, 300.0))
	_expect(visual.get_visual_snapshot()["orb_visible"], "Blizzard Orb must be visible after the Item Ball breaks.")
	visual.set_blizzard_state({"item_type": &"blizzard", "active": true, "remaining_seconds": 5.0})
	_expect(visual.get_visual_snapshot()["blizzard_active"] and visual.get_visual_snapshot()["snow_particle_count"] == 48, "Active Blizzard must show its cue and bounded decorative snow.")
	visual.set_blizzard_state({"item_type": &"blizzard", "active": false, "remaining_seconds": 0.0})
	_expect(not visual.get_visual_snapshot()["blizzard_active"] and visual.get_visual_snapshot()["snow_particle_count"] == 0, "Expired Blizzard must remove its cue and decorative snow.")
	visual.hide_item_orb(&"blizzard", Vector2.ZERO)
	visual.show_item_planet_broken(&"blizzard", Vector2.ZERO)
	_expect(not visual.get_visual_snapshot()["planet_visible"] and not visual.get_visual_snapshot()["orb_visible"], "Break and resolve events must remove Item Ball and Orb visuals.")
	if _failures == 0:
		print("S7_G2_BLIZZARD_VISUAL_IMPLEMENTED planet=true orb=true cue=true snow=48 cleanup=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G2 Blizzard visual verification failed: %s" % message)
