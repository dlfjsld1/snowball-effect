extends Node

const SimulationScript = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")
const StageRuntimeScript = preload("res://scripts/core/stage_runtime.gd")

var _failures := 0


func _ready() -> void:
	var catalog = StageCatalogScript.new()
	var ground = catalog.get_stage(0)
	var planetary = catalog.get_stage(1)
	var galactic = catalog.get_stage(2)
	var simulation = SimulationScript.new()
	var stage_runtime = StageRuntimeScript.new()
	add_child(simulation)
	add_child(stage_runtime)
	simulation.set_physics_process(false)

	stage_runtime.apply_stage_definition(ground)
	simulation.apply_stage_definition(ground)
	stage_runtime.apply_active_cashout(25.0, 2)
	simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, simulation.get_runtime_radius_for_level(0), 0)
	stage_runtime.process_tick(100.0, false, [])

	stage_runtime.apply_stage_definition(planetary)
	simulation.apply_stage_definition(planetary)
	var planetary_runtime: Dictionary = stage_runtime.get_stage_snapshot()
	var planetary_simulation: Dictionary = simulation.get_stage_snapshot()
	_expect(planetary_runtime["base_global_level"] == 4 and planetary_runtime["spawn_rate"] == 15.0, "Planetary runtime snapshot must expose its base level and spawn rate.")
	_expect(planetary_simulation["base_global_level"] == 4 and planetary_simulation["spawn_rate"] == 15.0, "Simulation snapshot must expose the applied Planetary data.")
	_expect(stage_runtime.score_ledger.stage_score == 0.0 and stage_runtime.score_ledger.run_score == 25.0, "Stage apply must reset stage score while preserving run score.")
	_expect(is_equal_approx(stage_runtime.stage_time_left, 40.0), "Stage apply must reset time to the new base time.")
	_expect(simulation.get_active_count() == 0 and simulation.get_capacity() == 0, "Stage apply must clear previous simulation arrays.")

	var first_six := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, simulation.get_runtime_radius_for_level(6), 6)
	var second_six := simulation.spawn_ball(Vector2(110.0, 100.0), Vector2.ZERO, simulation.get_runtime_radius_for_level(6), 6)
	_expect(simulation.commit_merge_candidates() == 1, "Planetary Lv6 pair must merge once.")
	_expect(not simulation.is_ball_active(first_six), "First Lv6 input must be consumed.")
	_expect(simulation.get_ball_global_level(second_six) == 8, "Planetary Lv6 must advance to ordered Lv8, not global Lv7.")
	_expect(is_equal_approx(simulation.radii[second_six], 32.0), "Planetary Lv8 output must use local Lv3 radius.")

	simulation.spawn_ball(Vector2(105.0, 100.0), Vector2.ZERO, simulation.get_runtime_radius_for_level(8), 8)
	_expect(simulation.commit_merge_candidates() == 1, "Planetary Lv8 pair must merge once.")
	var level_ten_index := _find_active_level(simulation, 10)
	_expect(level_ten_index >= 0, "Planetary Lv8 must advance to ordered Lv10, not global Lv9.")
	_expect(level_ten_index >= 0 and is_equal_approx(simulation.radii[level_ten_index], 64.0), "Planetary Lv10 output must use local Lv4 radius.")
	_expect(simulation.commit_merge_candidates() == 0, "The current Stage top must not merge beyond its ordered chain.")
	var first_inactive_level := simulation.spawn_ball(Vector2(300.0, 100.0), Vector2.ZERO, 8.0, 7)
	var second_inactive_level := simulation.spawn_ball(Vector2(306.0, 100.0), Vector2.ZERO, 8.0, 7)
	_expect(simulation.commit_merge_candidates() == 0, "Catalog levels outside the current Stage chain must not merge.")
	_expect(simulation.is_ball_active(first_inactive_level) and simulation.is_ball_active(second_inactive_level), "Rejected out-of-chain inputs must remain active.")

	stage_runtime.apply_stage_definition(galactic)
	simulation.apply_stage_definition(galactic)
	var galactic_snapshot: Dictionary = simulation.get_stage_snapshot()
	_expect(simulation.get_active_count() == 0, "A second Stage apply must clear Planetary balls.")
	_expect(galactic_snapshot["base_global_level"] == 10 and galactic_snapshot["spawn_rate"] == 35.0, "Galactic apply must expose base Lv10 and spawn rate 35.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(10), 4.0), "Planetary top Lv10 must rebaseline to Galactic local Lv0 radius.")

	if _failures == 0:
		print("S5_G2_VERIFIED planetary=6-8-10 reset=true spawn=15-35")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S5-G2 verification failed: %s" % message)


func _find_active_level(simulation: BallSimulationManager, global_level: int) -> int:
	for index in simulation.active_indices:
		if simulation.get_ball_global_level(index) == global_level:
			return index
	return -1
