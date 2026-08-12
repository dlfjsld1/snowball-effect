extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")

@onready var simulation: SimulationManager = $BallSimulationManager

var _failures := 0


func _ready() -> void:
	_verify_level_aware_neighbors()
	_verify_large_ball_search_range()
	_verify_sparse_candidate_reduction()

	if _failures == 0:
		print("S4_G1_VERIFIED level_aware=true adjacent_only=true large_radius=true no_full_scan=true")
	get_tree().quit(_failures)


func _verify_level_aware_neighbors() -> void:
	simulation.reset_runtime()
	var first := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0)
	var second := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 0)
	var third := simulation.spawn_ball(Vector2(103.0, 106.0), Vector2.ZERO, 4.0, 0)
	var different_level := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 1)
	var far := simulation.spawn_ball(Vector2(300.0, 300.0), Vector2.ZERO, 4.0, 0)

	var pairs := simulation.get_merge_candidate_pairs()
	_expect(pairs == [Vector2i(first, second), Vector2i(first, third), Vector2i(second, third)], "Grid must preserve deterministic same-level overlap results.")
	_expect(not pairs.any(func(pair: Vector2i) -> bool: return pair.x == different_level or pair.y == different_level), "Different levels must stay in separate grid buckets.")
	_expect(not pairs.any(func(pair: Vector2i) -> bool: return pair.x == far or pair.y == far), "Distant cells must not produce overlap pairs.")


func _verify_large_ball_search_range() -> void:
	simulation.reset_runtime()
	var first := simulation.spawn_ball(Vector2(100.0, 200.0), Vector2.ZERO, 64.0, 4)
	var second := simulation.spawn_ball(Vector2(220.0, 200.0), Vector2.ZERO, 64.0, 4)
	var pairs := simulation.get_merge_candidate_pairs()
	_expect(pairs == [Vector2i(first, second)], "Large balls must search beyond one neighboring cell when their radius requires it.")


func _verify_sparse_candidate_reduction() -> void:
	simulation.reset_runtime()
	const BALL_COUNT := 200
	for index in range(BALL_COUNT):
		simulation.spawn_ball(Vector2(float(index) * 96.0, float(index % 5) * 96.0), Vector2.ZERO, 4.0, 0)

	var pairs := simulation.get_merge_candidate_pairs()
	var metrics := simulation.get_spatial_metrics()
	var full_pair_count := BALL_COUNT * (BALL_COUNT - 1) / 2
	_expect(pairs.is_empty(), "Sparse balls must not overlap.")
	_expect(metrics["candidate_count"] < full_pair_count / 20, "Spatial query must avoid the all-pairs release path.")
	_expect(metrics["grid_cell_count"] == BALL_COUNT, "Separated balls must occupy distinct level-aware cells.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S4-G1 verification failed: %s" % message)
