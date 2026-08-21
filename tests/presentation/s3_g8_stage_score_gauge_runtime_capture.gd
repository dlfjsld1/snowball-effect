extends Node

const FrameScene = preload("res://scenes/backgrounds/gameplay_frame.tscn")
const StageWorldScene = preload("res://scenes/backgrounds/stage_world.tscn")
const HudScene = preload("res://scenes/ui/hud.tscn")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")

const ZERO_OUTPUT := "user://s3_g8_stage_score_gauge_zero.png"
const PARTIAL_OUTPUT := "user://s3_g8_stage_score_gauge_partial.png"
const COMPLETE_OUTPUT := "user://s3_g8_stage_score_gauge_complete.png"
const GALACTIC_OUTPUT := "user://s3_g8_stage_score_gauge_galactic.png"


func _ready() -> void:
	if DisplayServer.get_name() == "headless":
		print("S3_G8_CAPTURE_SKIPPED headless_renderer=true")
		get_tree().quit()
		return

	var background: BackgroundManager = StageWorldScene.instantiate()
	var frame: GameplayFrame = FrameScene.instantiate()
	var hud: Hud = HudScene.instantiate()
	add_child(background)
	add_child(frame)
	add_child(hud)
	await get_tree().process_frame

	var catalog = StageCatalog.new()
	var presenter: PresentationManager = frame.get_node("PresentationManager")
	presenter.configure(background, hud, null)
	presenter.apply_stage(catalog.get_stage(0))
	hud._on_stage_changed(catalog.get_stage(0))
	hud._on_score_changed(0.0, 0.0)
	await get_tree().process_frame
	_save_capture(ZERO_OUTPUT)

	hud._on_score_changed(2500000.0, 2500000.0)
	await get_tree().process_frame
	_save_capture(PARTIAL_OUTPUT)
	var performance := await _measure_frames(120)

	hud._on_score_changed(4000000.0, 4000000.0)
	await get_tree().process_frame
	_save_capture(COMPLETE_OUTPUT)

	presenter.apply_stage(catalog.get_stage(2))
	hud._on_stage_changed(catalog.get_stage(2))
	hud._on_score_changed(1.0e50, 1.0e50)
	await get_tree().process_frame
	assert(not hud.stage_score_gauge.visible)
	_save_capture(GALACTIC_OUTPUT)

	print("S3_G8_CAPTURED zero=%s partial=%s complete=%s galactic=%s avg_fps=%.1f min_fps=%.1f max_frame_ms=%.2f" % [
		ProjectSettings.globalize_path(ZERO_OUTPUT),
		ProjectSettings.globalize_path(PARTIAL_OUTPUT),
		ProjectSettings.globalize_path(COMPLETE_OUTPUT),
		ProjectSettings.globalize_path(GALACTIC_OUTPUT),
		performance["average_fps"],
		performance["minimum_fps"],
		performance["maximum_frame_ms"],
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
