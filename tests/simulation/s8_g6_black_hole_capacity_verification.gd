extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const TEST_DELTA := 1.0 / 60.0

@onready var simulation: SimulationManager = $BallSimulationManager

var _failures := 0
var _merged_levels: Array[int] = []
var _first_contact_count := 0
var _phase_request_count := 0
var _absorption_count := 0


func _ready() -> void:
	simulation.set_physics_process(false)
	simulation.ball_merged.connect(_on_ball_merged)
	simulation.first_contact_discovered.connect(_on_first_contact_discovered)
	simulation.black_hole_phase_requested.connect(_on_black_hole_phase_requested)
	simulation.black_hole_absorbed.connect(_on_black_hole_absorbed)
	_verify_empty_capacity_reserves_first_two_pairs()
	_verify_one_existing_entity_reserves_one_pair()
	_verify_full_capacity_preserves_overflow_pair()
	if _failures == 0:
		print("S8_G6_VERIFIED max_black_holes=2 stable_reservation=true overflow_non_merge=true generic_lv14=0")
	get_tree().quit(_failures)


func _verify_empty_capacity_reserves_first_two_pairs() -> void:
	_prepare_galactic_run(101)
	var first_pair := _spawn_event_horizon_pair(Vector2(600.0, 180.0))
	var second_pair := _spawn_event_horizon_pair(Vector2(600.0, 420.0))
	var overflow_pair := _spawn_event_horizon_pair(Vector2(600.0, 660.0))
	_expect(simulation.commit_merge_candidates(TEST_DELTA) == 2, "Three independent Lv13 pairs with no entity must commit only the first two candidates.")
	_expect(simulation.get_black_hole_count() == 2, "The first two stable candidates must reserve both Black Hole slots.")
	_expect(_merged_levels == [14, 14], "Only the two accepted Black Hole candidates may emit ball_merged.")
	_expect(_first_contact_count == 1 and _phase_request_count == 1, "Only the first accepted Black Hole may emit FIRST_CONTACT and phase readiness.")
	_expect(not simulation.is_ball_active(first_pair.x) and not simulation.is_ball_active(second_pair.x), "Accepted source pairs must be consumed only after their slots are reserved.")
	_expect(_pair_remains_active_and_separated(overflow_pair), "The third pair must remain active and be physically separated as non-Merge overflow.")
	_expect(_active_level_count(14) == 0, "Overflow must not create a generic Lv14 normal Ball.")
	_expect(_render_snapshot_has_level(14) == false, "The normal render snapshot must never expose a generic Lv14 overflow Ball.")
	_expect(_absorption_count == 0, "Overflow must not enter a Black Hole absorption path.")


func _verify_one_existing_entity_reserves_one_pair() -> void:
	_prepare_galactic_run(102)
	_spawn_event_horizon_pair(Vector2(600.0, 180.0))
	_expect(simulation.commit_merge_candidates(TEST_DELTA) == 1, "The setup pair must create the first Black Hole.")
	_expect(simulation.get_black_hole_count() == 1, "The setup must leave exactly one existing entity.")
	_reset_signal_counts()
	var accepted_pair := _spawn_event_horizon_pair(Vector2(600.0, 420.0))
	var overflow_pair := _spawn_event_horizon_pair(Vector2(600.0, 660.0))
	_expect(simulation.commit_merge_candidates(TEST_DELTA) == 1, "With one existing entity, only the first of two Lv13 pairs may reserve the final slot.")
	_expect(simulation.get_black_hole_count() == 2, "The accepted pair must create Black Hole #2.")
	_expect(_merged_levels == [14], "The overflow pair must not emit ball_merged.")
	_expect(_first_contact_count == 0 and _phase_request_count == 0, "Black Hole #2 must not repeat FIRST_CONTACT or phase readiness.")
	_expect(not simulation.is_ball_active(accepted_pair.x), "The accepted final-slot pair must be consumed.")
	_expect(_pair_remains_active_and_separated(overflow_pair), "The later same-tick pair must remain as a separated Lv13 pair.")
	_expect(_active_level_count(14) == 0 and not _render_snapshot_has_level(14), "No generic Lv14 normal Ball may exist after the final-slot overflow.")


func _verify_full_capacity_preserves_overflow_pair() -> void:
	_prepare_galactic_run(103)
	_spawn_event_horizon_pair(Vector2(600.0, 180.0))
	_expect(simulation.commit_merge_candidates(TEST_DELTA) == 1, "The first setup pair must create Black Hole #1.")
	_spawn_event_horizon_pair(Vector2(600.0, 420.0))
	_expect(simulation.commit_merge_candidates(TEST_DELTA) == 1, "The second setup pair must create Black Hole #2.")
	_reset_signal_counts()
	var overflow_pair := _spawn_event_horizon_pair(Vector2(600.0, 660.0))
	_expect(simulation.commit_merge_candidates(TEST_DELTA) == 0, "A full Black Hole capacity must reject the Lv13 pair before it is consumed.")
	_expect(simulation.get_black_hole_count() == 2, "Capacity overflow must never create a third moving Black Hole.")
	_expect(_merged_levels.is_empty() and _first_contact_count == 0 and _phase_request_count == 0, "A rejected pair must emit no merge, discovery, or phase event.")
	_expect(_pair_remains_active_and_separated(overflow_pair), "A full-capacity pair must stay active and use non-Merge separation.")
	_expect(_active_level_count(14) == 0 and not _render_snapshot_has_level(14), "Full-capacity overflow must not create a generic Lv14 render or Cashout candidate.")
	_expect(_absorption_count == 0, "Full-capacity overflow must not become an absorption input.")


func _prepare_galactic_run(run_epoch: int) -> void:
	simulation.apply_stage_definition(StageCatalog.new().get_stage(2))
	_expect(simulation.begin_first_contact_run(run_epoch), "Each focused case must start a fresh FIRST_CONTACT run epoch.")
	_reset_signal_counts()


func _spawn_event_horizon_pair(center: Vector2) -> Vector2i:
	var radius := simulation.get_runtime_radius_for_level(13)
	var first_index := simulation.spawn_ball(center, Vector2(120.0, 0.0), radius, 13)
	var second_index := simulation.spawn_ball(center + Vector2(radius * 1.875, 0.0), Vector2(-120.0, 0.0), radius, 13)
	return Vector2i(first_index, second_index)


func _pair_remains_active_and_separated(pair: Vector2i) -> bool:
	if not simulation.is_ball_active(pair.x) or not simulation.is_ball_active(pair.y):
		return false
	if simulation.get_ball_global_level(pair.x) != 13 or simulation.get_ball_global_level(pair.y) != 13:
		return false
	var combined_radius := simulation.radii[pair.x] + simulation.radii[pair.y]
	var distance := simulation.positions[pair.x].distance_to(simulation.positions[pair.y])
	var relative_velocity := simulation.velocities[pair.x] - simulation.velocities[pair.y]
	var normal := (simulation.positions[pair.x] - simulation.positions[pair.y]).normalized()
	return distance >= combined_radius - 0.01 and relative_velocity.dot(normal) >= -0.01


func _active_level_count(global_level: int) -> int:
	var count := 0
	for index in simulation.active_indices:
		if simulation.get_ball_global_level(index) == global_level:
			count += 1
	return count


func _render_snapshot_has_level(global_level: int) -> bool:
	var snapshot := simulation.get_render_snapshot()
	for level in snapshot["global_levels"]:
		if level == global_level:
			return true
	return false


func _reset_signal_counts() -> void:
	_merged_levels.clear()
	_first_contact_count = 0
	_phase_request_count = 0
	_absorption_count = 0


func _on_ball_merged(result_level: int, _world_position: Vector2) -> void:
	_merged_levels.append(result_level)


func _on_first_contact_discovered(_payload: Dictionary) -> void:
	_first_contact_count += 1


func _on_black_hole_phase_requested() -> void:
	_phase_request_count += 1


func _on_black_hole_absorbed(_score_amount: float, _global_level: int, _world_position: Vector2) -> void:
	_absorption_count += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G6 verification failed: %s" % message)
