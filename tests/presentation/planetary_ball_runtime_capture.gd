extends Node2D

const CAPTURE_BASENAME := "planetary_ball_assets_runtime_capture"
const NAMES := ["LV0 MOON", "LV1 EARTH", "LV2 SUN", "LV3 SUPERNOVA", "LV4 GALAXY"]
const GLOBAL_LEVELS := [4, 5, 6, 8, 10]
const POSITIONS := [Vector2(350, 430), Vector2(520, 430), Vector2(700, 430), Vector2(920, 430), Vector2(1180, 430)]
const RADII := [4.0, 8.0, 16.0, 32.0, 64.0]

@onready var simulation = $BallSimulationManager
@onready var renderer = $BallRenderer


func _ready() -> void:
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	renderer.process_mode = Node.PROCESS_MODE_DISABLED
	for local_level in range(POSITIONS.size()):
		simulation.spawn_ball(POSITIONS[local_level], Vector2.ZERO, RADII[local_level], GLOBAL_LEVELS[local_level])
	renderer.refresh_render_snapshot()
	queue_redraw()
	for frame in range(4):
		await get_tree().process_frame
	if DisplayServer.get_name() == "headless":
		push_error("Planetary ball capture requires a native rendering display driver.")
		get_tree().quit(1)
		return
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		push_error("Planetary ball capture requires a native rendering display driver.")
		get_tree().quit(1)
		return
	var image := viewport_texture.get_image()
	if image == null or image.is_empty():
		push_error("Planetary ball capture did not receive a rendered viewport image.")
		get_tree().quit(1)
		return
	var capture_tag := OS.get_environment("SNOWBALL_PLANETARY_BALL_CAPTURE_TAG").strip_edges()
	var capture_name := CAPTURE_BASENAME + ("_" + capture_tag if not capture_tag.is_empty() else "") + ".png"
	var requested_path := OS.get_environment("SNOWBALL_PLANETARY_BALL_CAPTURE_PATH").strip_edges()
	var capture_path := requested_path if not requested_path.is_empty() else "user://" + capture_name
	var save_error := image.save_png(capture_path)
	var metrics: Dictionary = renderer.get_render_metrics()
	print("PLANETARY_BALL_RUNTIME_CAPTURED path=%s viewport=%dx%d save_error=%d standard=%d chain=4/5/6/8/10 sizes=8/16/32/64/128" % [ProjectSettings.globalize_path(capture_path), image.get_width(), image.get_height(), save_error, metrics["standard_ball_count"]])
	get_tree().quit(save_error)


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 900), Color("16143e"))
	draw_rect(Rect2(250, 110, 1100, 670), Color("080d22"))
	draw_rect(Rect2(250, 110, 1100, 670), Color("57c4c8"), false, 4.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(285, 175), "PLANETARY BALL FAMILY / ACTUAL MULTIMESH RUNTIME SIZES", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("fff1b8"))
	for local_level in range(POSITIONS.size()):
		var label_origin: Vector2 = POSITIONS[local_level] + Vector2(-80, 145)
		draw_string(font, label_origin, NAMES[local_level], HORIZONTAL_ALIGNMENT_CENTER, 160, 14, Color("f7faff"))
		draw_string(font, label_origin + Vector2(0, 26), "%d x %d PX" % [int(RADII[local_level] * 2.0), int(RADII[local_level] * 2.0)], HORIZONTAL_ALIGNMENT_CENTER, 160, 14, Color("85ded1"))
	draw_string(font, Vector2(285, 730), "NATIVE LODS / NEAREST / BINARY ALPHA / COLLISION RADII UNCHANGED", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("85ded1"))
