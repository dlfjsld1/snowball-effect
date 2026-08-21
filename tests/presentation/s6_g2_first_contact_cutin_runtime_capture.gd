extends Node

const MainScene := preload("res://scenes/main/main.tscn")
const SAMPLE_FRAMES := 8
const CAPTURE_PATH := "res://tmp/s6_g2_first_contact_cutin_main_capture.png"
const EXPECTED_CAPTURE_SIZE := Vector2i(1600, 900)
const COMPLETION_TIMEOUT_MARGIN := 0.50

var _failures := 0
var _completion_count := 0


func _ready() -> void:
	var main := MainScene.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var cutin := presenter.get_node("FirstContactCutIn") as CutInController
	presenter.first_contact_cutin_finished.connect(func(_event_id: int, _run_epoch: int) -> void: _completion_count += 1)
	game_manager._on_start_requested()
	await get_tree().process_frame

	var epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	var payload := {
		"schema_version": 1,
		"event_id": 9001,
		"run_epoch": epoch,
		"stage_index": 0,
		"stage_id": &"ground",
		"global_level": 3,
		"local_level": 3,
		"world_position": Vector2(800.0, 360.0),
		"first_contact_id": &"ground_giant_snowball",
		"handoff_kind": &"RESUME_PLAYING",
		"black_hole_entity_ordinal": 0,
	}
	_expect(game_manager.accept_first_contact_discovery(payload), "Main producer fixture must accept the visible payload.")
	await get_tree().process_frame
	await get_tree().process_frame
	_expect(cutin.visible and stage_manager.is_first_contact_pause_locked(), "Visible capture must occur under the existing gameplay pause lock.")
	await _wait_for_visible_hold(cutin)
	_expect(cutin.visible and is_zero_approx(cutin.card_root.position.x), "Native capture must reach the visible hold phase.")

	await RenderingServer.frame_post_draw
	var absolute_capture_path := ProjectSettings.globalize_path(CAPTURE_PATH)
	var capture_image := get_viewport().get_texture().get_image()
	_expect(capture_image.get_size() == EXPECTED_CAPTURE_SIZE, "Native viewport capture must remain exactly 1600x900.")
	var capture_error := capture_image.save_png(absolute_capture_path)
	_expect(capture_error == OK, "Native viewport capture must save successfully.")

	var sample_started_usec := Time.get_ticks_usec()
	var previous_frame_usec := sample_started_usec
	var maximum_frame_usec := 0
	for _frame_index in SAMPLE_FRAMES:
		await get_tree().process_frame
		var current_frame_usec := Time.get_ticks_usec()
		maximum_frame_usec = maxi(maximum_frame_usec, current_frame_usec - previous_frame_usec)
		previous_frame_usec = current_frame_usec
	var sample_elapsed_usec := maxi(Time.get_ticks_usec() - sample_started_usec, 1)
	var average_fps := float(SAMPLE_FRAMES) * 1000000.0 / float(sample_elapsed_usec)
	var maximum_frame_msec := float(maximum_frame_usec) / 1000.0
	await _wait_for_normal_completion(cutin)
	_expect(_completion_count == 1 and not cutin.visible, "Capture fixture must observe one normal completion after the hold.")
	_expect(not stage_manager.is_first_contact_pause_locked(), "Normal completion must release the existing Main pause lock.")

	print("S6_G2_CAPTURE path=%s error=%d size=%dx%d frames=%d avg_fps=%.1f max_frame_ms=%.2f completion=%d" % [absolute_capture_path, capture_error, capture_image.get_width(), capture_image.get_height(), SAMPLE_FRAMES, average_fps, maximum_frame_msec, _completion_count])
	get_tree().quit(_failures)


func _wait_for_visible_hold(cutin: CutInController) -> void:
	var deadline_usec := Time.get_ticks_usec() + int(cutin.get_total_duration() * 1000000.0)
	while cutin.visible and not is_zero_approx(cutin.card_root.position.x) and Time.get_ticks_usec() < deadline_usec:
		await get_tree().process_frame


func _wait_for_normal_completion(cutin: CutInController) -> void:
	var timeout_seconds := cutin.get_total_duration() + COMPLETION_TIMEOUT_MARGIN
	var deadline_usec := Time.get_ticks_usec() + int(timeout_seconds * 1000000.0)
	while _completion_count == 0 and Time.get_ticks_usec() < deadline_usec:
		await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G2 capture failed: %s" % message)
