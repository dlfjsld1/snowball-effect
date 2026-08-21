extends Node2D

const CAPTURE_BASENAME := "ground_ball_assets_runtime_capture"
const NAMES := ["LV0 SNOWFLAKE", "LV1 SNOWBALL", "LV2 BIG SNOWBALL", "LV3 GIANT SNOWBALL", "LV4 MOON"]
const POSITIONS := [Vector2(350, 430), Vector2(520, 430), Vector2(700, 430), Vector2(920, 430), Vector2(1180, 430)]
const RADII := [4.0, 8.0, 16.0, 32.0, 64.0]

@onready var simulation = $BallSimulationManager
@onready var renderer = $BallRenderer


func _ready() -> void:
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	renderer.process_mode = Node.PROCESS_MODE_DISABLED
	for level in range(POSITIONS.size()):
		simulation.spawn_ball(POSITIONS[level], Vector2.ZERO, RADII[level], level)
	renderer.refresh_render_snapshot()
	queue_redraw()
	for frame in range(4):
		await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	var capture_tag := OS.get_environment("SNOWBALL_GROUND_BALL_CAPTURE_TAG").strip_edges()
	var capture_name := CAPTURE_BASENAME + ("_" + capture_tag if not capture_tag.is_empty() else "") + ".png"
	var capture_path := "user://" + capture_name
	var save_error := image.save_png(capture_path)
	var metrics: Dictionary = renderer.get_render_metrics()
	print("GROUND_BALL_RUNTIME_CAPTURED path=%s viewport=%dx%d save_error=%d standard=%d sizes=8/16/32/64/128" % [ProjectSettings.globalize_path(capture_path), image.get_width(), image.get_height(), save_error, metrics["standard_ball_count"]])
	get_tree().quit(save_error)


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 900), Color("1f285d"))
	draw_rect(Rect2(250, 110, 1100, 670), Color("0b1730"))
	draw_rect(Rect2(250, 110, 1100, 670), Color("4b849a"), false, 4.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(285, 175), "GROUND BALL FAMILY / ACTUAL MULTIMESH RUNTIME SIZES", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("ecf2cb"))
	for level in range(POSITIONS.size()):
		var label_origin: Vector2 = POSITIONS[level] + Vector2(-80, 145)
		draw_string(font, label_origin, NAMES[level], HORIZONTAL_ALIGNMENT_CENTER, 160, 14, Color("eaf8ff"))
		draw_string(font, label_origin + Vector2(0, 26), "%d x %d PX" % [int(RADII[level] * 2.0), int(RADII[level] * 2.0)], HORIZONTAL_ALIGNMENT_CENTER, 160, 14, Color("98d8b1"))
	draw_string(font, Vector2(285, 730), "NEAREST / BINARY ALPHA / FIXED GROUND PALETTE / COLLISION RADII UNCHANGED", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("98d8b1"))
