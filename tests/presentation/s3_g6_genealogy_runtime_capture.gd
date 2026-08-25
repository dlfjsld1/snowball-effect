extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const GROUND_STAGE := preload("res://resources/stages/stage_00_ground.tres")
const SHORT_SAMPLE_FRAMES := 60
const LONG_SAMPLE_FRAMES := 120
const OUTPUT_DIR := "res://docs/design/mockups/drafts/crt-genealogy-paper8-v1"
const LOCKED_OUTPUT := OUTPUT_DIR + "/s3-g6-genealogy-locked-1600x900.png"
const PARTIAL_OUTPUT := OUTPUT_DIR + "/s3-g6-genealogy-partial-1600x900.png"
const FULL_OUTPUT := OUTPUT_DIR + "/s3-g6-genealogy-full-1600x900.png"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("S3_G6_GENEALOGY_CAPTURE_SKIPPED headless_renderer=true")
		get_tree().quit()
		return

	var output_directory := ProjectSettings.globalize_path(OUTPUT_DIR)
	assert(DirAccess.make_dir_recursive_absolute(output_directory) == OK)
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	for _frame_index in range(6):
		await get_tree().process_frame
	(main.get_node("UI/TitleScreen") as TitleScreen).start_requested.emit()
	for _frame_index in range(12):
		await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var frame: GameplayFrame = main.get_node("UI/GameplayFrame")
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	simulation.set_physics_process(false)
	var hud: Hud = main.get_node("UI/HUDMount/HUD")
	hud._unbind_sources()
	hud._on_stage_changed(GROUND_STAGE)
	_verify_layout_bounds(hud, frame)
	await _capture_reveal_state(hud, 1, LOCKED_OUTPUT)

	for global_level in [1, 2]:
		hud._on_ball_merged(global_level, Vector2.ZERO)
	await _capture_reveal_state(hud, 3, PARTIAL_OUTPUT)
	var performance_60 := await _measure_frames(SHORT_SAMPLE_FRAMES)

	for global_level in [3, 4]:
		hud._on_ball_merged(global_level, Vector2.ZERO)
	await _capture_reveal_state(hud, 5, FULL_OUTPUT)
	var performance_120 := await _measure_frames(LONG_SAMPLE_FRAMES)

	hud.bind_sources(stage_manager.get_score_ledger(), simulation, stage_manager)
	game_manager._on_main_menu_requested()
	await get_tree().process_frame
	assert(not hud.visible, "Main reset must hide the gameplay genealogy before a fresh Run.")
	(main.get_node("UI/TitleScreen") as TitleScreen).start_requested.emit()
	for _frame_index in range(6):
		await get_tree().process_frame
	assert(hud.visible and hud.get_genealogy_visual_metrics()["revealed_count"] == 1)
	for slot_index in range(hud.genealogy_icons.size()):
		assert(hud.genealogy_icons[slot_index].visible == (slot_index == 0))
		assert((hud.genealogy_icons[slot_index].texture != null) == (slot_index == 0))

	print("S3_G6_GENEALOGY_CAPTURED locked=%s partial=%s full=%s title=BALLS display=24x24 node_diameter=38 crt_bounds=106x317 margin=2px bounds=true main_reset=true sample60_avg_fps=%.1f sample60_min_fps=%.1f sample60_max_frame_ms=%.2f sample120_avg_fps=%.1f sample120_min_fps=%.1f sample120_max_frame_ms=%.2f" % [
		ProjectSettings.globalize_path(LOCKED_OUTPUT),
		ProjectSettings.globalize_path(PARTIAL_OUTPUT),
		ProjectSettings.globalize_path(FULL_OUTPUT),
		performance_60["average_fps"],
		performance_60["minimum_fps"],
		performance_60["maximum_frame_ms"],
		performance_120["average_fps"],
		performance_120["minimum_fps"],
		performance_120["maximum_frame_ms"],
	])
	get_tree().quit()


func _capture_reveal_state(hud: Hud, expected_revealed: int, path: String) -> void:
	var metrics := hud.get_genealogy_visual_metrics()
	assert(metrics["revealed_count"] == expected_revealed)
	assert(metrics["title"] == "BALLS")
	assert(metrics["icon_size"] == Vector2(24.0, 24.0))
	for slot_index in range(hud.genealogy_icons.size()):
		assert(hud.genealogy_icons[slot_index].visible == (slot_index < expected_revealed))
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	assert(image != null and image.get_size() == Vector2i(1600, 900))
	assert(image.save_png(path) == OK)


func _verify_layout_bounds(hud: Hud, frame: GameplayFrame) -> void:
	var metrics := hud.get_genealogy_visual_metrics()
	var display_bounds := Rect2()
	for mask in frame.get_crt_surface_metrics()["masks"]:
		if mask["id"] == &"genealogy":
			display_bounds = mask["mask_bounds"]
			break
	assert(display_bounds.size == Vector2(106.0, 317.0))
	assert(metrics["display_bounds"] == display_bounds)
	var safe_bounds := display_bounds.grow(-Hud.GENEALOGY_DISPLAY_INSET)
	for bounds in [metrics["title_bounds"]] + metrics["node_bounds"] + metrics["connector_bounds"] + metrics["icon_bounds"] + metrics["label_bounds"]:
		assert(safe_bounds.encloses(bounds), "Every genealogy visual bound must remain inside the actual CRT scanline display.")


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
