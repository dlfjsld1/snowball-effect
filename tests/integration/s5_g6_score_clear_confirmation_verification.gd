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
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	presenter.shift_duration = 0.05
	game_manager._on_start_requested()

	stage_manager.get_score_ledger().apply_score_event(stage_manager.get_current_stage().clear_score)
	stage_manager._physics_process(0.1)
	_expect(stage_manager.current_state == StageManager.SHIFTING, "Score Clear must start Scale Shift without a confirmation UI.")
	await get_tree().create_timer(0.12).timeout
	_expect(stage_manager.current_stage_index == 1 and stage_manager.current_state == StageManager.PLAYING, "Presentation completion must enter Planetary once.")
	stage_manager.current_stage_index = 2
	stage_manager._enter_stage(stage_manager._stage_catalog.get_stage(2))
	stage_manager._stage_runtime.stage_time_left = 0.0
	stage_manager._physics_process(0.1)
	_expect(stage_manager.current_state == StageManager.RUN_ENDED, "Galactic Time Up must not start Score Clear or Scale Shift.")
	_expect(main.get_node("UI/ResultPanel").visible, "Galactic Time Up must open the Result UI.")

	if _failures == 0:
		print("S5_G6I_VERIFIED score_clear_auto_shift=true galactic_no_shift=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S5-G6I verification failed: %s" % message)
