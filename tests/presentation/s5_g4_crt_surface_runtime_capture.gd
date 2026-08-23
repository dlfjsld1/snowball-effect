extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const GALACTIC_STAGE := preload("res://resources/stages/stage_02_galactic.tres")
const SAMPLE_FRAMES := 120
const GROUND_OUTPUT := "res://tmp/s5_g4_crt_surface_ground_1600x900.png"
const GALACTIC_OUTPUT := "res://tmp/s5_g4_crt_surface_galactic_l2_1600x900.png"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("S5_G4_CRT_SURFACE_CAPTURE_SKIPPED headless_renderer=true")
		get_tree().quit()
		return

	var main := MAIN_SCENE.instantiate()
	add_child(main)
	for _frame_index in range(6):
		await get_tree().process_frame
	(main.get_node("UI/TitleScreen") as TitleScreen).start_requested.emit()
	for _frame_index in range(12):
		await get_tree().process_frame

	var frame: GameplayFrame = main.get_node("UI/GameplayFrame")
	var treatment: CrtSurfaceTreatment = frame.get_crt_surface_treatment()
	var hud: Hud = main.get_node("UI/HUDMount/HUD")
	(main.get_node("GameManager") as Node).set_physics_process(false)
	frame.set_cashout_cue_reduced_effects(true)
	hud._unbind_sources()
	hud.set("_current_clear_score", 400000000.0)
	hud._on_score_changed(280000000.0, 360000000.0)
	for level in [1, 2, 3, 4]:
		hud._on_ball_merged(level, Vector2.ZERO)

	treatment.visible = false
	var treatment_off := await _measure_frames(SAMPLE_FRAMES)
	treatment.visible = true
	var treatment_on := await _measure_frames(SAMPLE_FRAMES)
	var ground_error := _save_viewport(GROUND_OUTPUT)

	var presenter: PresentationManager = frame.get_node("PresentationManager")
	presenter.apply_stage(GALACTIC_STAGE)
	hud._on_stage_changed(GALACTIC_STAGE)
	for level in [11, 12, 13, 14]:
		hud._on_ball_merged(level, Vector2.ZERO)
	for _frame_index in range(8):
		await get_tree().process_frame
	var galactic_error := _save_viewport(GALACTIC_OUTPUT)

	print("S5_G4_CRT_SURFACE_CAPTURE ground=%s galactic=%s errors=%d/%d off_avg_fps=%.1f off_max_frame_ms=%.2f on_avg_fps=%.1f on_max_frame_ms=%.2f avg_frame_delta_ms=%.3f" % [
		ProjectSettings.globalize_path(GROUND_OUTPUT),
		ProjectSettings.globalize_path(GALACTIC_OUTPUT),
		ground_error,
		galactic_error,
		treatment_off["average_fps"],
		treatment_off["maximum_frame_ms"],
		treatment_on["average_fps"],
		treatment_on["maximum_frame_ms"],
		treatment_on["average_frame_ms"] - treatment_off["average_frame_ms"],
	])
	if ground_error != OK or galactic_error != OK:
		get_tree().quit(1)
		return
	get_tree().quit()


func _save_viewport(path: String) -> Error:
	var image := get_viewport().get_texture().get_image()
	assert(image != null and image.get_size() == Vector2i(1600, 900))
	return image.save_png(path)


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
		"average_frame_ms": float(elapsed_usec) / float(frame_count) / 1000.0,
		"maximum_frame_ms": float(maximum_frame_usec) / 1000.0,
	}
