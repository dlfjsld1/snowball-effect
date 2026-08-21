extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")
const TitleScreenScript = preload("res://scripts/ui/title_screen.gd")
const ResultPanelScript = preload("res://scripts/ui/result_panel.gd")


class CutInStub extends Node:
	var requests: Array[Dictionary] = []

	func play_first_contact_cutin(payload: Dictionary) -> bool:
		requests.append(payload.duplicate(true))
		return true


var _failures := 0
var _phase_ids: Array[int] = []
var _terminal_snapshots: Array[Dictionary] = []


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var paddle: Paddle = main.get_node("PlayField/PaddleMount/Paddle")
	var gameplay_frame: GameplayFrame = main.get_node("UI/GameplayFrame")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var title_screen: TitleScreenScript = main.get_node("UI/TitleScreen")
	var result_panel: ResultPanelScript = main.get_node("UI/ResultPanel")
	var cutin_stub := CutInStub.new()
	add_child(cutin_stub)
	game_manager.set_first_contact_cutin_consumer_for_verification(cutin_stub)
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	presenter.black_hole_phase_duration = 0.05
	presenter.black_hole_finale_duration = 0.05
	game_manager.black_hole_phase_started.connect(_on_phase_started)
	game_manager.terminal_result_available.connect(_on_terminal_result_available)
	_verify_initial_title_flow(game_manager, stage_manager, simulation, title_screen)

	var galactic := StageCatalogScript.new().get_stage(2) as StageDefinition
	stage_manager.current_stage_index = 2
	stage_manager._enter_stage(galactic)
	await _verify_phase_mediation(game_manager, stage_manager, simulation, paddle, gameplay_frame, presenter)
	await _verify_finale_lock_and_resets(game_manager, stage_manager, simulation, title_screen, result_panel, presenter)

	if _failures == 0:
		print("S8_G4_INTEGRATION_VERIFIED phase_presentation=true finale_handoff=true reset_safe=true")
	get_tree().quit(_failures)


func _verify_initial_title_flow(game_manager: GameManager, stage_manager: StageManager, simulation: BallSimulationManager, title_screen: TitleScreenScript) -> void:
	_expect(title_screen.visible, "Main must reveal Title before starting a run.")
	_expect(stage_manager.current_state == StageManager.READY, "Main must remain READY while Title is waiting for input.")
	_expect(simulation.get_active_count() == 0, "Main must not spawn gameplay balls before Start Run.")
	title_screen.start_button.pressed.emit()
	_expect(stage_manager.current_state == StageManager.PLAYING, "Title Start must begin Ground gameplay.")
	_expect(not title_screen.visible, "Title must hide after Start Run.")
	_expect(simulation.get_active_count() == 1, "Start Run must spawn the initial Ground ball exactly once.")


func _verify_phase_mediation(game_manager: GameManager, stage_manager: StageManager, simulation: BallSimulationManager, paddle: Paddle, gameplay_frame: GameplayFrame, presenter: PresentationManager) -> void:
	var radius := simulation.get_runtime_radius_for_level(13)
	simulation.spawn_ball(Vector2(760.0, 320.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(764.0, 320.0), Vector2.ZERO, radius, 13)
	stage_manager._stage_runtime.stage_time_left = 5.0
	stage_manager._physics_process(0.1)
	await get_tree().process_frame
	var cutin_snapshot := game_manager.get_runtime_snapshot()
	var event_id := int(cutin_snapshot["first_contact_active_event_id"])
	var run_epoch := int(cutin_snapshot["first_contact_run_epoch"])
	_expect(event_id > 0 and bool(cutin_snapshot["first_contact_pause_locked"]), "First Black Hole CUT-IN must lock gameplay before Phase issuance.")
	_expect(_phase_ids.is_empty(), "Black Hole Phase must wait for matching CUT-IN completion.")
	_expect(game_manager.accept_first_contact_cutin_finished(event_id, run_epoch), "Matching Black Hole CUT-IN completion must be accepted.")
	_expect(stage_manager.current_state == StageManager.BLACK_HOLE_PHASE_LOCKED, "Phase start must lock gameplay.")
	var locked_run_time: float = stage_manager.get_runtime_snapshot()["run_time_seconds"]
	stage_manager._physics_process(2.0)
	_expect(is_equal_approx(stage_manager.get_runtime_snapshot()["run_time_seconds"], locked_run_time), "Black Hole Phase lock must not add Run Time.")
	_expect(_phase_ids.size() == 1, "Phase start must publish one phase id.")
	var phase_id := _phase_ids[0]
	_expect(not game_manager.accept_black_hole_phase_presentation_finished(phase_id + 1), "Stale phase completion must be rejected.")
	_expect(stage_manager.current_state == StageManager.BLACK_HOLE_PHASE_LOCKED, "Stale completion must keep gameplay locked.")
	_expect(presenter.is_black_hole_phase_active(), "The actual Presentation producer must own the pending phase completion.")
	await _wait_until(func() -> bool: return stage_manager.current_state == StageManager.PLAYING)
	_expect(stage_manager.current_state == StageManager.PLAYING, "Matching completion must resume Galactic gameplay.")
	_expect(is_equal_approx(simulation.play_field_rect.size.x, 1040.0), "Matching completion must activate the L3 logical rect.")
	_expect(gameplay_frame.get_profile_id() == &"L3", "Black Hole gameplay resume must switch the visible frame to the L3 profile.")
	_expect(paddle.play_field_rect == gameplay_frame.get_field_rect(), "Paddle bounds must match the L3 visible frame profile.")
	_expect(not game_manager.accept_black_hole_phase_presentation_finished(phase_id), "Duplicate phase completion must be rejected.")


func _verify_finale_lock_and_resets(game_manager: GameManager, stage_manager: StageManager, simulation: BallSimulationManager, title_screen: TitleScreenScript, result_panel: ResultPanelScript, presenter: PresentationManager) -> void:
	var contact_snapshot := {
		"contact_position": Vector2(800.0, 420.0),
		"black_holes": [{"position": Vector2(780.0, 420.0)}, {"position": Vector2(820.0, 420.0)}],
	}
	simulation.black_hole_finale_started.emit(contact_snapshot)
	_expect(stage_manager.current_state == StageManager.RUN_ENDED, "Finale contact must lock Run End.")
	_expect(_terminal_snapshots.is_empty() and not result_panel.visible, "Result must wait for the actual finale presentation.")
	_expect(presenter.is_black_hole_finale_active(), "Finale must be owned by the Presentation overlay before Result appears.")
	await _wait_until(func() -> bool: return result_panel.visible)
	_expect(_terminal_snapshots.size() == 1, "Terminal result must publish exactly once after the finale overlay.")
	_expect(game_manager.get_terminal_result_snapshot().get("run_score", -1.0) >= 0.0, "Terminal snapshot must include the final run score.")
	var result_stats: Dictionary = game_manager.get_terminal_result_snapshot().get("optional_stats", {})
	_expect(int(result_stats.get("merge_count", -1)) == 1, "Terminal snapshot must include the successful Black Hole-producing Merge.")
	_expect(float(result_stats.get("run_time_seconds", -1.0)) >= 0.1, "Terminal snapshot must include accumulated PLAYING time.")
	_expect(result_panel.visible and result_panel.get_result_snapshot() == game_manager.get_terminal_result_snapshot(), "Finale snapshot must be shown by the mounted Result Panel.")
	simulation.black_hole_finale_started.emit(contact_snapshot)
	_expect(_terminal_snapshots.size() == 1, "Duplicate finale contacts must not republish a result.")
	stage_manager._physics_process(1.0)
	_expect(stage_manager.current_state == StageManager.RUN_ENDED, "Terminal lock must block later gameplay commits.")

	result_panel.retry_button.pressed.emit()
	_expect(stage_manager.current_state == StageManager.PLAYING, "Retry must restart Ground gameplay.")
	_expect(stage_manager.current_stage_index == 0, "Retry must return to Ground.")
	_expect(game_manager.get_terminal_result_snapshot().is_empty(), "Retry must clear the terminal snapshot.")
	var reset_snapshot := stage_manager.get_runtime_snapshot()
	_expect(reset_snapshot["run_merge_count"] == 0 and is_zero_approx(reset_snapshot["run_time_seconds"]), "Retry must reset Run Merge count and Run Time.")

	result_panel.show_result({"run_score": 0.0})
	result_panel.main_menu_button.pressed.emit()
	_expect(stage_manager.current_state == StageManager.READY, "Main menu request must end the active run safely.")
	_expect(simulation.get_active_count() == 0, "Main menu request must clear active simulation state.")
	_expect(title_screen.visible and not result_panel.visible, "Main menu request must replace Result with Title.")
	title_screen.start_button.pressed.emit()
	_expect(stage_manager.current_state == StageManager.PLAYING and not title_screen.visible, "Title Start must begin a fresh gameplay run.")
	_expect(not presenter.is_black_hole_phase_active() and not presenter.is_black_hole_finale_active(), "Fresh runs must reset Presentation terminal locks.")


func _wait_until(predicate: Callable) -> void:
	var timeout_at := Time.get_ticks_msec() + 1000
	while not predicate.call() and Time.get_ticks_msec() < timeout_at:
		await get_tree().process_frame
	_expect(predicate.call(), "Timed out waiting for the integrated Presentation handoff.")


func _on_phase_started(phase_id: int, _from_rect: Rect2, _to_rect: Rect2) -> void:
	_phase_ids.append(phase_id)


func _on_terminal_result_available(result_snapshot: Dictionary) -> void:
	_terminal_snapshots.append(result_snapshot.duplicate(true))


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G4 integration verification failed: %s" % message)
