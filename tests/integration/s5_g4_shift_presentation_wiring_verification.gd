extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var _completion_count := 0
var _visual_field_rects: Array[Rect2] = []


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var stage_manager: StageManager = main.get_node("StageManager")
	var game_manager: GameManager = main.get_node("GameManager")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var background: BackgroundManager = main.get_node("StageWorld/BackgroundManager")
	var frame: GameplayFrame = main.get_node("UI/GameplayFrame")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var backdrop: Polygon2D = main.get_node("PlayField/Backdrop")
	var clear_panel: StageClearPanel = main.get_node("UI/StageClearPanel")
	game_manager._apply_stage_frame(0)
	var initial_logical_field := simulation.play_field_rect
	var initial_visual_field := frame.get_field_visual_rect_for_profile(0)
	var target_visual_field := frame.get_field_visual_rect_for_profile(1)
	presenter.shift_duration = 0.30
	presenter.stage_shift_presentation_finished.connect(_count_completion)
	presenter.visual_field_rect_changed.connect(_on_visual_field_rect_changed)

	assert(not stage_manager.auto_complete_shift_presentation)
	assert(stage_manager.current_stage_index == 0)
	stage_manager.get_score_ledger().apply_score_event(stage_manager.get_current_stage().clear_score)
	stage_manager._physics_process(0.1)
	assert(stage_manager.current_state == StageManager.CLEARED)
	assert(clear_panel.request_next_stage(clear_panel.get_active_clear_id()))
	assert(stage_manager.current_state == StageManager.SHIFTING)
	assert(stage_manager.current_stage_index == 0, "Stage must not advance before Presentation completion.")
	assert(presenter.is_shift_active())

	var saw_intermediate_backdrop := false
	var timeout_at := Time.get_ticks_msec() + 2000
	while presenter.is_shift_active() and Time.get_ticks_msec() < timeout_at:
		await get_tree().process_frame
		var backdrop_rect := _get_backdrop_rect(backdrop)
		if backdrop_rect.size.x > initial_visual_field.size.x + 0.01 and backdrop_rect.size.x < target_visual_field.size.x - 0.01:
			saw_intermediate_backdrop = true
			assert(not _visual_field_rects.is_empty(), "Frame tween must emit its current visual Field rect before Backdrop sampling.")
			assert(_rect_matches(backdrop_rect, _visual_field_rects.back()), "Backdrop must use the exact visual Frame rect emitted for this tween frame.")
			assert(_rect_matches(simulation.play_field_rect, initial_logical_field), "Visual Backdrop interpolation must not change logical simulation bounds before shift completion.")

	assert(not presenter.is_shift_active(), "Shift presentation must complete before the verification timeout.")
	assert(_completion_count == 1)
	assert(stage_manager.current_stage_index == 1)
	assert(stage_manager.current_state == StageManager.PLAYING)
	assert(frame.profile_index == 1)
	assert(background.current_background_id == &"planetary")
	assert(saw_intermediate_backdrop, "Backdrop must visibly interpolate between the Ground and Planetary Frame widths.")
	assert(_rect_matches(_get_backdrop_rect(backdrop), target_visual_field), "Backdrop must end at the Planetary visual Field rect.")
	assert(_rect_matches(simulation.play_field_rect, frame.get_field_rect_for_profile(1)), "Logical bounds must update only after Presentation completes.")

	presenter.stage_shift_presentation_finished.emit(1)
	assert(stage_manager.current_stage_index == 1, "Stale completion must not advance the Stage twice.")
	print("S5_G4_SHIFT_WIRING_VERIFIED delayed_activation=true backdrop_lerp=true logical_bounds_deferred=true completion_once=true stale_rejected=true")
	get_tree().quit()


func _count_completion(_shift_id: int) -> void:
	_completion_count += 1


func _on_visual_field_rect_changed(visual_rect: Rect2) -> void:
	_visual_field_rects.append(visual_rect)


func _get_backdrop_rect(backdrop: Polygon2D) -> Rect2:
	assert(backdrop.polygon.size() == 4, "Backdrop must remain a rectangular visual backing.")
	return Rect2(backdrop.polygon[0], backdrop.polygon[2] - backdrop.polygon[0])


func _rect_matches(left: Rect2, right: Rect2) -> bool:
	return left.position.is_equal_approx(right.position) and left.size.is_equal_approx(right.size)
