extends Node2D

const BallTextureLodCatalogScript = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")

const SAMPLE_FRAMES := 60
const CAPTURE_BASENAME := "galactic_ball_assets_runtime_capture_1600x900"
const NAMES := ["LV0 GALAXY", "LV1 CLUSTER", "LV2 QUASAR", "LV3 EVENT HORIZON", "LV4 BLACK HOLE"]
const GLOBAL_LEVELS := [10, 11, 12, 13]
const POSITIONS := [Vector2(350, 430), Vector2(520, 430), Vector2(700, 430), Vector2(920, 430), Vector2(1180, 430)]
const RADII := [4.0, 8.0, 16.0, 32.0, 64.0]

@onready var simulation = $BallSimulationManager
@onready var renderer = $BallRenderer


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Galactic ball capture requires a native rendering display driver.")
		get_tree().quit(1)
		return
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	renderer.process_mode = Node.PROCESS_MODE_DISABLED
	for local_level in range(GLOBAL_LEVELS.size()):
		simulation.spawn_ball(POSITIONS[local_level], Vector2.ZERO, RADII[local_level], GLOBAL_LEVELS[local_level])
	renderer.refresh_render_snapshot()
	var lod_catalog = BallTextureLodCatalogScript.new()
	var black_hole_texture := lod_catalog.resolve_texture(14, 128.0, null)
	if black_hole_texture == null:
		push_error("Galactic ball capture could not resolve the Black Hole hero texture.")
		get_tree().quit(1)
		return
	var black_hole_sprite := Sprite2D.new()
	black_hole_sprite.name = "BlackHoleHero"
	black_hole_sprite.texture = black_hole_texture
	black_hole_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	black_hole_sprite.position = POSITIONS[4]
	add_child(black_hole_sprite)
	queue_redraw()

	var performance := await _measure_frames(SAMPLE_FRAMES)
	await RenderingServer.frame_post_draw
	var viewport_texture := get_viewport().get_texture()
	if viewport_texture == null:
		push_error("Galactic ball capture did not receive a viewport texture.")
		get_tree().quit(1)
		return
	var image := viewport_texture.get_image()
	if image == null or image.is_empty():
		push_error("Galactic ball capture did not receive a rendered viewport image.")
		get_tree().quit(1)
		return
	var requested_path := OS.get_environment("SNOWBALL_GALACTIC_BALL_CAPTURE_PATH").strip_edges()
	var capture_path := requested_path if not requested_path.is_empty() else "user://" + CAPTURE_BASENAME + ".png"
	var save_error := image.save_png(capture_path)
	var metrics: Dictionary = renderer.get_render_metrics()
	print("GALACTIC_BALL_RUNTIME_CAPTURED path=%s viewport=%dx%d save_error=%d standard=%d black_hole_hero=true sizes=8/16/32/64/128 avg_fps=%.1f min_fps=%.1f max_frame_ms=%.2f" % [ProjectSettings.globalize_path(capture_path), image.get_width(), image.get_height(), save_error, metrics["standard_ball_count"], performance["average_fps"], performance["minimum_fps"], performance["maximum_frame_ms"]])
	get_tree().quit(save_error)


func _measure_frames(frame_count: int) -> Dictionary:
	var previous_ticks := Time.get_ticks_usec()
	var elapsed_usec := 0
	var maximum_frame_usec := 0
	for _frame_index in range(frame_count):
		await get_tree().process_frame
		var now := Time.get_ticks_usec()
		var frame_usec := now - previous_ticks
		previous_ticks = now
		elapsed_usec += frame_usec
		maximum_frame_usec = maxi(maximum_frame_usec, frame_usec)
	return {
		"average_fps": float(frame_count) * 1000000.0 / maxf(float(elapsed_usec), 1.0),
		"minimum_fps": 1000000.0 / maxf(float(maximum_frame_usec), 1.0),
		"maximum_frame_ms": float(maximum_frame_usec) / 1000.0,
	}


func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 900), Color("16143e"))
	draw_rect(Rect2(250, 110, 1100, 670), Color("02040c"))
	draw_rect(Rect2(250, 110, 1100, 670), Color("805cff"), false, 4.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(285, 175), "GALACTIC BALL FAMILY / NATIVE RUNTIME LODS", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color("fff1b8"))
	for local_level in range(POSITIONS.size()):
		var label_origin: Vector2 = POSITIONS[local_level] + Vector2(-90, 145)
		draw_string(font, label_origin, NAMES[local_level], HORIZONTAL_ALIGNMENT_CENTER, 180, 14, Color("f7faff"))
		draw_string(font, label_origin + Vector2(0, 26), "%d x %d PX" % [int(RADII[local_level] * 2.0), int(RADII[local_level] * 2.0)], HORIZONTAL_ALIGNMENT_CENTER, 180, 14, Color("85ded1"))
	draw_string(font, Vector2(285, 730), "OPEN ASTRONOMICAL SILHOUETTES / NEAREST / RGBA ALPHA / GAMEPLAY RADII UNCHANGED", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("85ded1"))
	draw_string(font, Vector2(285, 756), "BLACK HOLE = GALACTIC FINAL-PHASE HANDOFF / NOT A NEW STAGE OR CLEAR CONDITION", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("f1c66b"))
