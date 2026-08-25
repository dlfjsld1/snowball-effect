extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const StageCatalogScript := preload("res://scripts/data/stage_catalog.gd")
const VOID_CATHEDRAL_RESOURCE := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres"
const VOID_CATHEDRAL_PNG := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.png"
const PHASE_OUTPUT := "res://docs/design/mockups/drafts/galactic-black-hole-redesign-v1/black-hole-C-void-cathedral-main-final-phase-1600x900.png"
const FINALE_OUTPUT := "res://docs/design/mockups/drafts/galactic-black-hole-redesign-v1/black-hole-C-void-cathedral-main-finale-1600x900.png"


class CaptureCutInStub extends Node:
	func play_first_contact_cutin(_payload: Dictionary) -> bool:
		return true


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("S8_G5_CAPTURE_SKIPPED headless_renderer=true")
		get_tree().quit()
		return
	await get_tree().process_frame

	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var renderer: BallRenderer = main.get_node("PlayField/SimulationMount/BallRenderer")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var overlay: BlackHolePhaseEffect = presenter.get_node("BlackHoleOverlay")
	var title_screen: TitleScreen = main.get_node("UI/TitleScreen")
	var cutin_stub := CaptureCutInStub.new()
	add_child(cutin_stub)
	game_manager.set_first_contact_cutin_consumer_for_verification(cutin_stub)
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	presenter.black_hole_phase_duration = 0.2
	presenter.black_hole_finale_duration = 1.0
	title_screen.start_button.pressed.emit()

	var galactic := StageCatalogScript.new().get_stage(2) as StageDefinition
	stage_manager.current_stage_index = 2
	stage_manager._enter_stage(galactic)
	var radius := simulation.get_runtime_radius_for_level(13)
	simulation.spawn_ball(Vector2(798.0, 430.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(802.0, 430.0), Vector2.ZERO, radius, 13)
	stage_manager._stage_runtime.stage_time_left = 5.0
	stage_manager._physics_process(0.1)
	await get_tree().process_frame

	var runtime := game_manager.get_runtime_snapshot()
	var event_id := int(runtime["first_contact_active_event_id"])
	var run_epoch := int(runtime["first_contact_run_epoch"])
	assert(event_id > 0 and game_manager.accept_first_contact_cutin_finished(event_id, run_epoch))
	while presenter.is_black_hole_phase_active():
		await get_tree().process_frame
	await get_tree().process_frame
	renderer.refresh_render_snapshot()

	var texture := overlay.get_black_hole_visual_texture()
	var draw_texture := overlay.get_black_hole_draw_texture()
	var renderer_metrics := renderer.get_render_metrics()
	assert(texture != null and texture.resource_path == VOID_CATHEDRAL_RESOURCE)
	assert(draw_texture != null and draw_texture.resource_path == VOID_CATHEDRAL_PNG)
	assert(overlay.visible and overlay.get_visual_metrics()["phase_active"])
	assert(overlay.get_visual_metrics()["black_hole_count"] == 1)
	assert(renderer_metrics["black_hole_count"] == 1)
	assert(renderer_metrics["standard_ball_count"] == 0 and renderer_metrics["special_fallback_count"] == 0)
	_save_capture(PHASE_OUTPUT)
	var performance := await _measure_phase_frames(60)

	simulation.spawn_ball(Vector2(900.0, 430.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(904.0, 430.0), Vector2.ZERO, radius, 13)
	assert(simulation.commit_merge_candidates() == 1)
	simulation._black_hole_positions[0] = Vector2(760.0, 430.0)
	simulation._black_hole_positions[1] = Vector2(840.0, 430.0)
	simulation._black_hole_velocities[0] = Vector2(600.0, 0.0)
	simulation._black_hole_velocities[1] = Vector2(-600.0, 0.0)
	simulation.step_simulation(0.1)
	await get_tree().process_frame
	renderer.refresh_render_snapshot()
	assert(simulation.is_black_hole_terminal_locked())
	assert(presenter.is_black_hole_finale_active())
	assert(overlay.get_visual_metrics()["black_hole_count"] == 2)
	assert(renderer.get_render_metrics()["black_hole_count"] == 0)
	await get_tree().create_timer(0.45).timeout
	_save_capture(FINALE_OUTPUT)
	print("S8_G5_MAIN_CAPTURED phase=%s finale=%s texture=%s base_terminal_black_holes=0 avg_fps=%.1f min_fps=%.1f max_frame_ms=%.2f" % [
		ProjectSettings.globalize_path(PHASE_OUTPUT),
		ProjectSettings.globalize_path(FINALE_OUTPUT),
		texture.resource_path,
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
