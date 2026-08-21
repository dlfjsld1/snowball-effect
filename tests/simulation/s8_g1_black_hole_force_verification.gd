extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const StageRuntime = preload("res://scripts/core/stage_runtime.gd")
const TEST_DELTA := 1.0 / 60.0

@onready var simulation: SimulationManager = $BallSimulationManager
@onready var stage_runtime: StageRuntime = $StageRuntime

var _failures := 0
var _phase_count := 0
var _runtime_phase_count := 0
var _absorption_count := 0
var _run_end_count := 0


func _ready() -> void:
	var galactic = StageCatalog.new().get_stage(2)
	simulation.apply_stage_definition(galactic)
	stage_runtime.enter_stage(galactic)
	simulation.black_hole_phase_requested.connect(_on_black_hole_phase_requested)
	simulation.black_hole_absorbed.connect(_on_black_hole_absorbed)
	stage_runtime.black_hole_phase_started.connect(_on_black_hole_phase_started)
	stage_runtime.black_hole_run_end_requested.connect(_on_black_hole_run_end_requested)
	_verify_first_conversion_and_absorption()
	_verify_pull_and_bottom_reflection()
	_verify_thousand_ball_force_regression()
	if _failures == 0:
		print("S8_G1_VERIFIED phase=once absorption=score_deducted pull_cap=%s mutual=450 bottom_reflect=true stress=1000" % SimulationManager.BLACK_HOLE_TOTAL_PULL_CAP)
	get_tree().quit(_failures)


func _verify_first_conversion_and_absorption() -> void:
	var absorbed_definition = simulation._ball_catalog.get_definition(10)
	var starting_score: float = absorbed_definition.score_value * 8.0
	stage_runtime.score_ledger.apply_score_event(starting_score)
	var radius := simulation.get_runtime_radius_for_level(13)
	simulation.spawn_ball(Vector2(700.0, 300.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(710.0, 300.0), Vector2.ZERO, radius, 13)
	_expect(simulation.commit_merge_candidates() == 1, "Two Event Horizons must commit one Black Hole conversion.")
	_expect(simulation.get_black_hole_count() == 1, "First Lv14 must become one Black Hole runtime entity.")
	_expect(simulation.get_active_count() == 0, "Converted Black Hole must not remain in the normal Ball slot set.")
	_expect(_phase_count == 1, "First Black Hole must request exactly one Galactic phase transition.")
	_expect(_runtime_phase_count == 1, "StageRuntime must publish the Black Hole phase signal once.")
	_expect(is_equal_approx(stage_runtime.get_black_hole_phase_run_score_baseline(), starting_score), "First Black Hole appearance must capture the Run Score penalty baseline once.")

	var absorb_index := simulation.spawn_ball(simulation.get_black_hole_position(), Vector2.ZERO, simulation.get_runtime_radius_for_level(10), 10)
	simulation.step_simulation(TEST_DELTA)
	_expect(not simulation.is_ball_active(absorb_index), "Local Lv0 Ball in actual Black Hole contact must be absorbed.")
	_expect(_absorption_count == 1, "Absorption must emit exactly one penalty event.")
	var expected_low_penalty: float = absorbed_definition.score_value * StageRuntime.BLACK_HOLE_ABSORPTION_SCORE_RATIO
	_expect(is_equal_approx(stage_runtime.score_ledger.stage_score, starting_score - expected_low_penalty), "Local Lv0 absorption must deduct 12.5% of its Cashout value.")
	_expect(is_equal_approx(stage_runtime.score_ledger.run_score, starting_score - expected_low_penalty), "A single low Ball absorption must not erase the whole Run Score.")
	_expect(_run_end_count == 0, "The first low Ball absorption must not immediately end a funded Run.")

	var cap: float = starting_score * StageRuntime.BLACK_HOLE_ABSORPTION_BASELINE_CAP_RATIO
	var high_cashout_score := 1.0e50
	_expect(is_equal_approx(stage_runtime.calculate_black_hole_absorption_penalty(high_cashout_score), cap), "A high-value absorbed Ball must cap at 25% of the phase-entry Run Score.")
	for _hit in range(4):
		stage_runtime.apply_black_hole_absorption(high_cashout_score)
	_expect(is_equal_approx(stage_runtime.score_ledger.stage_score, 0.0), "Repeated capped absorption must clamp Stage score at zero.")
	_expect(is_equal_approx(stage_runtime.score_ledger.run_score, 0.0), "Repeated capped absorption must still be able to deplete Run Score.")
	_expect(_run_end_count == 1, "Run score depletion must request Black Hole Run End exactly once.")


func _verify_pull_and_bottom_reflection() -> void:
	var radius := simulation.get_runtime_radius_for_level(13)
	simulation.spawn_ball(Vector2(900.0, 300.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(910.0, 300.0), Vector2.ZERO, radius, 13)
	_expect(simulation.commit_merge_candidates() == 1, "Second Event Horizon pair must create the second Black Hole.")
	_expect(simulation.get_black_hole_count() == 2, "Two Black Holes must coexist without generic Merge.")
	var long_range_pull := simulation.get_black_hole_pull(simulation.get_black_hole_position(0) + Vector2(300.0, 0.0))
	_expect(long_range_pull.length() > 0.0, "The tuned Black Hole pull must visibly influence Balls 300 logical units away.")
	var combined_pull := simulation.get_black_hole_pull(Vector2(800.0, 300.0))
	_expect(combined_pull.length() <= SimulationManager.BLACK_HOLE_TOTAL_PULL_CAP + 0.01, "Multi-source ordinary Ball pull must use the configured single cap.")
	var first_before := simulation.get_black_hole_position(0)
	var second_before := simulation.get_black_hole_position(1)
	simulation.step_simulation(0.25)
	_expect(simulation.get_black_hole_position(0).distance_to(simulation.get_black_hole_position(1)) < first_before.distance_to(second_before), "Black Holes must receive mutual pull toward each other.")
	simulation._black_hole_positions[0] = Vector2(700.0, simulation.play_field_rect.end.y - simulation._black_hole_radii[0] - 1.0)
	simulation._black_hole_velocities[0] = Vector2(0.0, 300.0)
	simulation.step_simulation(0.1)
	_expect(simulation.get_black_hole_position(0).y <= simulation.play_field_rect.end.y - simulation._black_hole_radii[0] + 0.01, "Black Hole must reflect from the bottom instead of Cashout.")
	_expect(simulation._black_hole_velocities[0].y < 0.0, "Bottom reflection must reverse Black Hole vertical velocity.")


func _verify_thousand_ball_force_regression() -> void:
	simulation.reset_runtime()
	simulation.apply_stage_definition(StageCatalog.new().get_stage(2))
	simulation.merge_enabled = false
	simulation.cashout_enabled = false
	simulation._create_black_hole(Vector2(800.0, 450.0), Vector2.ZERO)
	for index in range(1000):
		var column := index % 40
		var row := index / 40
		simulation.spawn_ball(Vector2(520.0 + column * 14.0, 30.0 + row * 24.0), Vector2(40.0, 20.0), 4.0, 13)
	var started_usec := Time.get_ticks_usec()
	for _frame in range(120):
		simulation.step_simulation(TEST_DELTA)
	var average_ms := float(Time.get_ticks_usec() - started_usec) / 120000.0
	_expect(simulation.get_active_count() == 1000, "Force-only stress must retain all 1,000 normal Balls.")
	_expect(average_ms < 16.0, "1,000 Ball Black Hole force regression must remain below the 60 FPS physics budget.")
	print("S8_G1_STRESS active=1000 average_physics_ms=%.3f" % average_ms)


func _on_black_hole_phase_requested() -> void:
	_phase_count += 1
	stage_runtime.begin_black_hole_phase(Rect2(500.0, 0.0, 920.0, 900.0), Rect2(420.0, 0.0, 1080.0, 900.0))


func _on_black_hole_phase_started(_phase_id: int, _from_rect: Rect2, _to_rect: Rect2) -> void:
	_runtime_phase_count += 1


func _on_black_hole_absorbed(score_amount: float, _global_level: int, _world_position: Vector2) -> void:
	_absorption_count += 1
	stage_runtime.apply_black_hole_absorption(score_amount)


func _on_black_hole_run_end_requested() -> void:
	_run_end_count += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G1 verification failed: %s" % message)
