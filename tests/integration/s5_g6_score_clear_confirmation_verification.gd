extends Node

const MAIN_SCENE = preload("res://scenes/main/main.tscn")

var _failures := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var clear_panel: StageClearPanel = main.get_node("UI/StageClearPanel")
	var result_panel: ResultPanel = main.get_node("UI/ResultPanel")
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	presenter.shift_duration = 0.05
	game_manager._on_start_requested()

	stage_manager.get_score_ledger().apply_score_event(stage_manager.get_current_stage().clear_score)
	stage_manager._physics_process(0.1)
	_expect(stage_manager.current_state == StageManager.CLEARED, "Score Clear must wait for a confirmation UI.")
	_expect(clear_panel.visible, "Score Clear must open the Stage Clear panel.")
	var clear_id := clear_panel.get_active_clear_id()
	_expect(not stage_manager.request_next_stage(clear_id + 1), "Wrong clear id must not start Shift.")
	_expect(stage_manager.current_state == StageManager.CLEARED, "Wrong clear id must keep CLEARED locked.")
	_expect(clear_panel.request_next_stage(clear_id), "Matching NEXT STAGE request must be accepted once.")
	_expect(stage_manager.current_state == StageManager.SHIFTING, "Matching confirmation must start Scale Shift.")
	await get_tree().create_timer(0.12).timeout
	_expect(stage_manager.current_stage_index == 1 and stage_manager.current_state == StageManager.PLAYING, "Presentation completion must enter Planetary once.")

	stage_manager._stage_runtime.stage_time_left = 0.0
	stage_manager._physics_process(0.1)
	_expect(stage_manager.current_state == StageManager.FAILED, "Non-final Time Up must finish as FAILED.")
	_expect(result_panel.visible, "Non-final Time Up must open the Result UI instead of leaving a black screen.")
	_expect(not clear_panel.visible, "Failure must not open the Stage Clear panel.")

	if _failures == 0:
		print("S5_G6I_VERIFIED confirmation_gate=true stale_rejected=true failure_result=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S5-G6I verification failed: %s" % message)
