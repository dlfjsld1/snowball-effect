extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const SAMPLE_FRAMES := 120
const OUTPUT_PATH := "res://tmp/s5_g4_cashout_direction_cue_ground.png"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("S5_G4_CASHOUT_CUE_CAPTURE_SKIPPED headless_renderer=true")
		get_tree().quit()
		return

	var main := MAIN_SCENE.instantiate()
	add_child(main)
	for _frame_index in range(6):
		await get_tree().process_frame

	var frame: GameplayFrame = main.get_node("UI/GameplayFrame")
	var cue: Control = frame.get_cashout_cue_node()
	var play_field: Node = main.get_node("PlayField")
	assert(cue.get_parent() == play_field)
	assert(cue.get_index() < main.get_node("PlayField/SimulationMount").get_index(), "The cue must render behind balls and Paddle.")
	assert(not cue.visible, "Title lifecycle must not leave an active Cashout cue.")
	var title: TitleScreen = main.get_node("UI/TitleScreen")
	title.start_requested.emit()
	for _frame_index in range(12):
		await get_tree().process_frame
	assert(cue.visible, "The actual Ground Main mount must show the cue during gameplay.")
	assert(frame.profile_index == 0)

	# Keep the exact mounted frame static so the off/on comparison isolates this cue.
	(main.get_node("GameManager") as Node).set_physics_process(false)
	frame.set_cashout_cue_active(false)
	var cue_off := await _measure_frames(SAMPLE_FRAMES)
	frame.set_cashout_cue_active(true)
	for _frame_index in range(4):
		await get_tree().process_frame
	var cue_on := await _measure_frames(SAMPLE_FRAMES)

	var image := get_viewport().get_texture().get_image()
	assert(image != null and image.get_size() == Vector2i(1600, 900))
	var error := image.save_png(OUTPUT_PATH)
	print("S5_G4_CASHOUT_CUE_CAPTURE path=%s error=%d off_avg_fps=%.1f off_max_frame_ms=%.2f on_avg_fps=%.1f on_max_frame_ms=%.2f avg_frame_delta_ms=%.3f" % [
		ProjectSettings.globalize_path(OUTPUT_PATH),
		error,
		cue_off["average_fps"],
		cue_off["maximum_frame_ms"],
		cue_on["average_fps"],
		cue_on["maximum_frame_ms"],
		cue_on["average_frame_ms"] - cue_off["average_frame_ms"],
	])
	if error != OK:
		push_error("Native Cashout cue capture could not be saved.")
		get_tree().quit(1)
		return
	get_tree().quit()


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
