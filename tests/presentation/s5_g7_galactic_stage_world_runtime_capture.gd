extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const STAGE_WORLD_SCENE := preload("res://scenes/backgrounds/stage_world.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const PAUSE_SCENE := preload("res://scenes/ui/pause_menu.tscn")

const L2_OUTPUT := "user://s5_g7_galactic_l2.png"
const L3_OUTPUT := "user://s5_g7_galactic_l3.png"
const REDUCED_OUTPUT := "user://s5_g7_galactic_l3_reduced.png"


class BlackHoleSource:
	extends Node

	var positions := PackedVector2Array([Vector2(780.0, 390.0)])
	var radii := PackedFloat32Array([16.0])

	func get_black_hole_snapshot() -> Dictionary:
		return {"count": positions.size(), "positions": positions.duplicate(), "radii": radii.duplicate()}


class ReadabilityFixture:
	extends Node2D

	var profile := 2

	func _draw() -> void:
		var field_width := 880.0 if profile == 2 else 1040.0
		var field_left := (1600.0 - field_width) * 0.5
		var colors := [Color("4d42b8"), Color("805cff"), Color("e8e6ff"), Color("3a1a61")]
		for index in range(colors.size()):
			var center := Vector2(field_left + 150.0 + float(index) * 155.0, 250.0 + float(index % 2) * 120.0)
			draw_circle(center, 16.0 + float(index) * 5.0, colors[index])
		var paddle_center := Vector2(800.0, 735.0)
		var half_size := Vector2(78.0, 8.0)
		var paddle_transform := Transform2D(0.14, paddle_center)
		var points := PackedVector2Array([
			paddle_transform * Vector2(-half_size.x, -half_size.y),
			paddle_transform * Vector2(half_size.x, -half_size.y),
			paddle_transform * Vector2(half_size.x, half_size.y),
			paddle_transform * Vector2(-half_size.x, half_size.y),
		])
		draw_colored_polygon(points, Color("f4f5e8"))


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("S5_G7_CAPTURE_SKIPPED headless_renderer=true")
		get_tree().quit()
		return
	var source := BlackHoleSource.new()
	add_child(source)
	var background: BackgroundManager = STAGE_WORLD_SCENE.instantiate()
	add_child(background)
	var fixture := ReadabilityFixture.new()
	add_child(fixture)
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	add_child(frame)
	var hud: Hud = HUD_SCENE.instantiate()
	add_child(hud)
	var pause_menu: PauseMenu = PAUSE_SCENE.instantiate()
	add_child(pause_menu)
	await get_tree().process_frame

	var presenter: PresentationManager = frame.get_node("PresentationManager")
	presenter.configure(background, hud, pause_menu)
	presenter.configure_black_hole_sources(null, source)
	var galactic := StageDefinition.new()
	galactic.stage_index = 2
	galactic.display_name = "Galactic"
	galactic.background_id = &"galactic"
	presenter.apply_stage(galactic)
	hud._on_stage_changed(galactic)
	hud.visible = true
	pause_menu.visible = true
	background.set_background(&"galactic")
	frame.set_profile(2)
	fixture.profile = 2
	fixture.queue_redraw()
	await get_tree().process_frame
	_save_capture(L2_OUTPUT)

	presenter.black_hole_phase_duration = 0.2
	assert(presenter.play_black_hole_phase(507, frame.get_field_rect_for_profile(2), frame.get_field_rect_for_profile(3)))
	while presenter.is_black_hole_phase_active():
		await get_tree().process_frame
	fixture.profile = 3
	fixture.queue_redraw()
	await get_tree().process_frame
	_save_capture(L3_OUTPUT)
	var normal_performance := await _measure_frames(120)

	background.set_reduced_effects(true)
	await get_tree().process_frame
	_save_capture(REDUCED_OUTPUT)
	var reduced_performance := await _measure_frames(120)
	print("S5_G7_CAPTURED l2=%s l3=%s reduced=%s normal_avg_fps=%.1f normal_min_fps=%.1f normal_max_frame_ms=%.2f reduced_avg_fps=%.1f reduced_min_fps=%.1f reduced_max_frame_ms=%.2f" % [
		ProjectSettings.globalize_path(L2_OUTPUT),
		ProjectSettings.globalize_path(L3_OUTPUT),
		ProjectSettings.globalize_path(REDUCED_OUTPUT),
		normal_performance["average_fps"],
		normal_performance["minimum_fps"],
		normal_performance["maximum_frame_ms"],
		reduced_performance["average_fps"],
		reduced_performance["minimum_fps"],
		reduced_performance["maximum_frame_ms"],
	])
	get_tree().quit()


func _save_capture(path: String) -> void:
	var image := get_viewport().get_texture().get_image()
	assert(image != null and image.get_size() == Vector2i(1600, 900))
	assert(image.save_png(path) == OK)


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
