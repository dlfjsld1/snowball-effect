extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")

var _failures := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var renderer: BallRenderer = main.get_node("PlayField/SimulationMount/BallRenderer")
	var result_panel: ResultPanel = main.get_node("UI/ResultPanel")
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)

	game_manager._start_run()
	var galactic := StageCatalogScript.new().get_stage(2) as StageDefinition
	stage_manager.current_stage_index = 2
	stage_manager._enter_stage(galactic)
	stage_manager._stage_runtime.score_ledger.apply_score_event(100.0)
	stage_manager._stage_runtime._black_hole_phase_run_score_baseline = 100.0
	stage_manager._stage_runtime._black_hole_phase_baseline_captured = true
	simulation._create_black_hole(Vector2(800.0, 360.0), Vector2.ZERO)
	renderer.refresh_render_snapshot()
	_expect(renderer.get_render_metrics()["black_hole_count"] == 1, "The fixture must begin with one rendered Black Hole.")

	for absorption_index in range(4):
		stage_manager._stage_runtime.apply_black_hole_absorption(1000000.0)
	_expect(is_equal_approx(stage_manager._stage_runtime.score_ledger.run_score, 100.0), "Grace-period absorption burst must not end the Run.")

	stage_manager._stage_runtime.advance_run_time(StageRuntime.BLACK_HOLE_ABSORPTION_GRACE_SECONDS)
	for damage_window in range(10):
		stage_manager._stage_runtime.apply_black_hole_absorption(1000000.0)
		if damage_window < 9:
			stage_manager._stage_runtime.advance_run_time(StageRuntime.BLACK_HOLE_ABSORPTION_WINDOW_SECONDS)

	await get_tree().process_frame
	renderer.refresh_render_snapshot()
	_expect(stage_manager.current_state == StageManager.FAILED, "Repeated Black Hole penalties must end the Run at zero score.")
	_expect(result_panel.visible, "Zero-score Run End must show the Result panel.")
	_expect(is_zero_approx(float(result_panel.get_result_snapshot().get("run_score", -1.0))), "The Result snapshot must preserve the terminal zero score.")
	_expect(simulation.get_black_hole_count() == 0, "Run End handoff must clear Black Hole gameplay entities.")
	_expect(renderer.get_render_metrics()["black_hole_count"] == 0, "No Black Hole may remain rendered behind the Result panel.")

	if _failures == 0:
		print("S8_G4_SCORE_DEPLETION_RESULT_CLEANUP_VERIFIED result=true score=0 black_holes=0")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G4 score-depletion Result cleanup verification failed: %s" % message)
