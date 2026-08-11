extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")

@onready var simulation: SimulationManager = $BallSimulationManager

var _failures := 0


func _ready() -> void:
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

	_expect(simulation.deactivate_ball(second_index), "Candidate removal setup must deactivate an active ball.")
	var after_deactivate := simulation.get_merge_candidate_pairs()
	_expect(after_deactivate == [Vector2i(first_index, third_index)], "Inactive balls must no longer appear in candidate pairs.")

	if _failures == 0:
		print("S2_G2_VERIFIED candidates=%d deterministic=true merge_commit=absent" % candidates.size())
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S2-G2 verification failed: %s" % message)
