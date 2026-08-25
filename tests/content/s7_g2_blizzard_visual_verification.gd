extends Node

const BlizzardVisualScript = preload("res://scripts/presentation/item_blizzard_visual.gd")
const ITEM_BALL_TEXTURE: Texture2D = BlizzardVisualScript.ITEM_BALL_TEXTURE
const BREAK_FRAGMENTS_TEXTURE: Texture2D = BlizzardVisualScript.BREAK_FRAGMENTS_TEXTURE

var _failures := 0


func _ready() -> void:
	var visual = BlizzardVisualScript.new()
	add_child(visual)
	_expect(visual.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Item Ball and fragment sheets must render with nearest-neighbor filtering.")
	_expect(ITEM_BALL_TEXTURE.resource_path.ends_with("item_ball_rescue_beacon_h0_h4.png"), "The shared Item Ball must load the approved Rescue Beacon Capsule atlas.")
	_expect(BREAK_FRAGMENTS_TEXTURE.resource_path.ends_with("item_ball_rescue_beacon_rupture_4f.png"), "Break must load the approved Rescue Beacon rupture atlas.")
	_expect(ITEM_BALL_TEXTURE.get_width() == 320 and ITEM_BALL_TEXTURE.get_height() == 64, "Item Ball sheet must contain five contiguous 64x64 frames.")
	_expect(BREAK_FRAGMENTS_TEXTURE.get_width() == 256 and BREAK_FRAGMENTS_TEXTURE.get_height() == 64, "Rupture sheet must contain four contiguous 64x64 frames.")
	_expect(_frame_edges_are_transparent(ITEM_BALL_TEXTURE.get_image(), 5), "Each Rescue Beacon Item Ball frame must keep transparent edges for clean 64x64 placement.")
	_expect(_frame_edges_are_transparent(BREAK_FRAGMENTS_TEXTURE.get_image(), 4), "Each Rescue Beacon rupture frame must keep transparent edges for clean 64x64 placement.")

	visual.show_item_planet_spawned(&"fire_core", Vector2(800.0, 270.0), 24.0)
	var snapshot: Dictionary = visual.get_visual_snapshot()
	_expect(snapshot.get("planet_visible", false), "The intact Item Ball must use the shared Rescue Beacon Capsule visual for every hidden item type.")
	_expect(is_equal_approx(float(snapshot.get("item_ball_radius", 0.0)), 24.0), "The shared Rescue Beacon Capsule visual must preserve the 24px gameplay radius passed by ItemManager.")
	_expect(int(snapshot.get("item_ball_remaining_hits", -1)) == 5, "H0 must represent the intact five-hits-remaining state.")
	_expect(int(snapshot.get("item_ball_frame_index", -1)) == 0, "Five remaining hits must select H0.")
	_expect(snapshot.get("item_ball_source_region", Rect2()) == Rect2(0.0, 0.0, 64.0, 64.0), "H0 must use the first exact 64x64 sheet region.")
	for current_hits in range(1, 5):
		visual.show_item_planet_damaged(&"fire_core", current_hits, 5, Vector2(800.0, 270.0))
		snapshot = visual.get_visual_snapshot()
		var remaining_hits := 5 - current_hits
		_expect(int(snapshot.get("item_ball_remaining_hits", -1)) == remaining_hits, "Damage state must retain the authoritative remaining-hit count.")
		_expect(int(snapshot.get("item_ball_frame_index", -1)) == current_hits, "Remaining-hit state must map H1 through H4 without an off-by-one.")
		_expect(snapshot.get("item_ball_source_region", Rect2()) == Rect2(float(current_hits * 64), 0.0, 64.0, 64.0), "Each damage state must use its exact 64x64 sheet region.")
	visual.show_item_planet_broken(&"fire_core", Vector2(800.0, 270.0))
	snapshot = visual.get_visual_snapshot()
	_expect(not snapshot.get("planet_visible", true), "The fifth hit must remove the H4 pre-break Item Ball visual.")
	_expect(snapshot.get("break_fragments_visible", false), "The existing break hook must start the approved Rescue Beacon rupture visual.")
	_expect(snapshot.get("break_fragment_source_region", Rect2()) == Rect2(0.0, 0.0, 64.0, 64.0), "Rupture animation must begin at its first exact 64x64 region.")
	for break_frame in range(1, 4):
		visual._physics_process(0.08)
		snapshot = visual.get_visual_snapshot()
		_expect(int(snapshot.get("break_fragment_frame_index", -1)) == break_frame, "Rupture animation must advance through all four frames in order.")
		_expect(snapshot.get("break_fragment_source_region", Rect2()) == Rect2(float(break_frame * 64), 0.0, 64.0, 64.0), "Each rupture frame must use its exact 64x64 sheet region.")
	visual._physics_process(0.08)
	_expect(not visual.get_visual_snapshot().get("break_fragments_visible", true), "Rupture frames must clean up after the fourth frame.")
	visual.reset_runtime()
	snapshot = visual.get_visual_snapshot()
	_expect(not snapshot.get("planet_visible", true) and not snapshot.get("break_fragments_visible", true) and not snapshot.get("orb_visible", true), "Runtime reset must clear Item Ball, rupture, and Orb visuals without leakage.")

	visual.reset_runtime()
	visual.show_item_planet_spawned(&"blizzard", Vector2(800.0, 270.0), 24.0)
	_expect(visual.get_visual_snapshot()["planet_visible"], "Blizzard Item Ball must be visible on spawn.")
	_expect(visual.get_visual_snapshot()["item_ball_source_region"] == Rect2(0.0, 0.0, 64.0, 64.0), "Blizzard must use the same shared Rescue Beacon intact Item Ball frame.")
	visual.show_item_planet_damaged(&"blizzard", 3, 5, Vector2(800.0, 270.0))
	visual.show_item_orb_spawned(&"blizzard", Vector2(800.0, 300.0))
	_expect(visual.get_visual_snapshot()["orb_visible"], "Blizzard Orb must be visible after the Item Ball breaks.")
	visual.set_blizzard_state({"item_type": &"blizzard", "active": true, "remaining_seconds": 5.0})
	_expect(visual.get_visual_snapshot()["blizzard_active"] and visual.get_visual_snapshot()["snow_particle_count"] == 48, "Active Blizzard must show bounded decorative snow without a center timer panel.")
	visual.set_blizzard_state({"item_type": &"blizzard", "active": false, "remaining_seconds": 0.0})
	_expect(not visual.get_visual_snapshot()["blizzard_active"] and visual.get_visual_snapshot()["snow_particle_count"] == 0, "Expired Blizzard must remove its decorative snow.")
	visual.hide_item_orb(&"blizzard", Vector2.ZERO)
	visual.show_item_planet_broken(&"blizzard", Vector2.ZERO)
	_expect(not visual.get_visual_snapshot()["planet_visible"] and not visual.get_visual_snapshot()["orb_visible"], "Break and resolve events must remove Item Ball and Orb visuals.")

	for item_type in [&"blizzard", &"fire_core", &"magnet"]:
		visual.reset_runtime()
		visual.show_item_orb_spawned(item_type, Vector2(800.0, 300.0))
		snapshot = visual.get_visual_snapshot()
		_expect(snapshot.get("orb_visible", false), "%s Orb must be visible through the shared world renderer." % item_type)
		_expect(snapshot.get("orb_type", &"") == item_type, "%s Orb must retain its matching visual identity." % item_type)
		var initial_position: Vector2 = snapshot.get("orb_position", Vector2.ZERO)
		visual._physics_process(0.1)
		_expect(visual.get_visual_snapshot().get("orb_position", Vector2.ZERO).y > initial_position.y, "%s Orb visual must fall downward." % item_type)
		var frozen_position: Vector2 = visual.get_visual_snapshot().get("orb_position", Vector2.ZERO)
		visual.set_orb_motion_frozen(true)
		visual._physics_process(0.1)
		_expect(visual.get_visual_snapshot().get("orb_motion_frozen", false), "%s Orb visual must report terminal freeze state." % item_type)
		_expect(visual.get_visual_snapshot().get("orb_position", Vector2.ZERO) == frozen_position, "%s Orb visual must stop in place during a terminal finale." % item_type)
		visual.set_orb_motion_frozen(false)
		visual._physics_process(0.1)
		_expect(visual.get_visual_snapshot().get("orb_position", Vector2.ZERO).y > frozen_position.y, "%s Orb visual must resume only when terminal freeze is released." % item_type)
		visual.hide_item_orb(item_type, Vector2.ZERO)
		_expect(not visual.get_visual_snapshot().get("orb_visible", true), "%s Orb visual must clear on matching resolution." % item_type)
	if _failures == 0:
		print("S7_G2_BLIZZARD_VISUAL_IMPLEMENTED rescue_beacon_h0_h4=true rupture_frames=4 orb_types=3 falling=true snow=48 cleanup=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G2 Blizzard visual verification failed: %s" % message)


func _frame_edges_are_transparent(image: Image, frame_count: int) -> bool:
	for frame_index in range(frame_count):
		var left := frame_index * 64
		var right := left + 63
		for offset in range(64):
			if image.get_pixel(left, offset).a > 0.0:
				return false
			if image.get_pixel(right, offset).a > 0.0:
				return false
			if image.get_pixel(left + offset, 0).a > 0.0:
				return false
			if image.get_pixel(left + offset, 63).a > 0.0:
				return false
	return true
