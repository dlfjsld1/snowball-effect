extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var _completion_count := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var stage_manager: StageManager = main.get_node("StageManager")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var background: BackgroundManager = main.get_node("StageWorld/BackgroundManager")
	var frame: GameplayFrame = main.get_node("UI/GameplayFrame")
	presenter.shift_duration = 0.05
	presenter.stage_shift_presentation_finished.connect(_count_completion)

	assert(not stage_manager.auto_complete_shift_presentation)
	assert(stage_manager.current_stage_index == 0)
	stage_manager._on_end_decision_requested(&"TOP_BALL_CLEAR")
	assert(stage_manager.current_state == StageManager.SHIFTING)
	assert(stage_manager.current_stage_index == 0, "Stage must not advance before Presentation completion.")
	assert(presenter.is_shift_active())

	await get_tree().create_timer(0.12).timeout
	assert(_completion_count == 1)
	assert(stage_manager.current_stage_index == 1)
	assert(stage_manager.current_state == StageManager.PLAYING)
	assert(frame.profile_index == 1)
	assert(background.current_background_id == &"planetary")

	presenter.stage_shift_presentation_finished.emit(1)
	assert(stage_manager.current_stage_index == 1, "Stale completion must not advance the Stage twice.")
	print("S5_G4_SHIFT_WIRING_VERIFIED delayed_activation=true completion_once=true stale_rejected=true")
	get_tree().quit()


func _count_completion(_shift_id: int) -> void:
	_completion_count += 1
