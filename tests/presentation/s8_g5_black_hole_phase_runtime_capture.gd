extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const STAGE_WORLD_SCENE := preload("res://scenes/backgrounds/stage_world.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const PAUSE_SCENE := preload("res://scenes/ui/pause_menu.tscn")

const PHASE_OUTPUT := "user://s8_g5_black_hole_phase.png"
const FINALE_OUTPUT := "user://s8_g5_black_hole_finale.png"

class CaptureSource:
	extends Node

	var positions := PackedVector2Array([Vector2(625.0, 445.0)])
	var radii := PackedFloat32Array([16.0])

	func get_black_hole_snapshot() -> Dictionary:
		return {"count": positions.size(), "positions": positions.duplicate(), "radii": radii.duplicate()}


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("S8_G5_CAPTURE_SKIPPED headless_renderer=true")
		get_tree().quit()
		return
	var source := CaptureSource.new()
	add_child(source)
	var background: BackgroundManager = STAGE_WORLD_SCENE.instantiate()
	add_child(background)
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

	var l2_rect := frame.get_field_rect_for_profile(2)
	var l3_rect := frame.get_field_rect_for_profile(3)
	presenter.black_hole_phase_duration = 0.2
	assert(presenter.play_black_hole_phase(501, l2_rect, l3_rect))
	while presenter.is_black_hole_phase_active():
		await get_tree().process_frame
	await get_tree().process_frame
	_save_capture(PHASE_OUTPUT)
	var performance := await _measure_phase_frames(60)

	var finale_snapshot := {
		"contact_position": Vector2(800.0, 445.0),
		"black_holes": [
			{"position": Vector2(720.0, 445.0), "velocity": Vector2(120.0, 0.0), "radius": 16.0},
			{"position": Vector2(880.0, 445.0), "velocity": Vector2(-120.0, 0.0), "radius": 16.0},
		],
		"run_score": 1.0e50,
	}
	presenter.black_hole_finale_duration = 1.0
	assert(presenter.play_black_hole_finale(finale_snapshot, 501))
	await get_tree().create_timer(0.91).timeout
	_save_capture(FINALE_OUTPUT)
	print("S8_G5_CAPTURED phase=%s finale=%s avg_fps=%.1f min_fps=%.1f max_frame_ms=%.2f" % [
		ProjectSettings.globalize_path(PHASE_OUTPUT),
		ProjectSettings.globalize_path(FINALE_OUTPUT),
		performance["average_fps"],
		performance["minimum_fps"],
		performance["maximum_frame_ms"],
	])
	get_tree().quit()


func _save_capture(path: String) -> void:
	var image := get_viewport().get_texture().get_image()
	assert(image != null and image.get_size() == Vector2i(1600, 900))
	assert(image.save_png(path) == OK)


func _measure_phase_frames(frame_count: int) -> Dictionary:
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
	var average_fps := float(frame_count) * 1000000.0 / maxf(float(elapsed_usec), 1.0)
	var minimum_fps := 1000000.0 / maxf(float(maximum_frame_usec), 1.0)
	return {
		"average_fps": average_fps,
		"minimum_fps": minimum_fps,
		"maximum_frame_ms": float(maximum_frame_usec) / 1000.0,
	}
