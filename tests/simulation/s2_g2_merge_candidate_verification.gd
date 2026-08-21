extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")

@onready var simulation: SimulationManager = $BallSimulationManager

var _failures := 0


func _ready() -> void:
	simulation.configure_stage_ball_levels(PackedInt32Array([0, 1, 2]))
	var first_index := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0)
	var second_index := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 0)
	var different_level_index := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 1)
	var third_index := simulation.spawn_ball(Vector2(103.0, 106.0), Vector2.ZERO, 4.0, 0)
	var far_index := simulation.spawn_ball(Vector2(300.0, 300.0), Vector2.ZERO, 4.0, 0)

	_expect(simulation.get_ball_global_level(first_index) == 0, "Spawned balls must retain their global level in the SoA state.")
	_expect(simulation.get_ball_global_level(different_level_index) == 1, "Different global levels must remain queryable.")

	var candidates := simulation.get_merge_candidate_pairs()
	_expect(candidates == [Vector2i(first_index, second_index), Vector2i(first_index, third_index), Vector2i(second_index, third_index)], "Overlapping same-level pairs must be returned in deterministic index order.")
	_expect(not candidates.has(Vector2i(first_index, different_level_index)), "Overlapping balls with different global levels must not become merge candidates.")
	_expect(not candidates.any(func(pair: Vector2i) -> bool: return pair.x == far_index or pair.y == far_index), "Separated balls must not become merge candidates.")
	_expect(simulation.get_merge_candidate_pairs() == candidates, "Repeated candidate queries must be deterministic without mutating simulation state.")

	var top_index := simulation.spawn_ball(Vector2(500.0, 100.0), Vector2.ZERO, 16.0, 2)
	var lower_index := simulation.spawn_ball(Vector2(518.0, 100.0), Vector2.ZERO, 4.0, 0)
	var second_top_index := simulation.spawn_ball(Vector2(530.0, 100.0), Vector2.ZERO, 16.0, 2)
	var contacts := simulation.get_non_merge_contact_pairs()
	_expect(contacts.has(Vector2i(first_index, different_level_index)), "Overlapping ordinary different-level Balls must be contact candidates.")
	_expect(contacts.has(Vector2i(top_index, lower_index)), "The Stage top ball must query overlapping lower-level Balls as contact candidates.")
	_expect(contacts.has(Vector2i(top_index, second_top_index)), "Two Stage top balls must query each other as one contact candidate.")

	_expect(simulation.deactivate_ball(second_index), "Candidate removal setup must deactivate an active ball.")
	var after_deactivate := simulation.get_merge_candidate_pairs()
	_expect(not after_deactivate.any(func(pair: Vector2i) -> bool: return pair.x == second_index or pair.y == second_index), "Inactive balls must no longer appear in candidate pairs.")
	_expect(after_deactivate.has(Vector2i(first_index, third_index)), "Remaining same-level overlaps must remain merge candidates.")

	if _failures == 0:
		print("S2_G2_VERIFIED candidates=%d non_merge_contact=true deterministic=true merge_commit=absent" % candidates.size())
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S2-G2 verification failed: %s" % message)
