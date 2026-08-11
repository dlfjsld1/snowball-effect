extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")

@onready var simulation: SimulationManager = $BallSimulationManager

var _merged_events: Array[Dictionary] = []
var _top_levels: Array[int] = []
var _failures := 0


func _ready() -> void:
	simulation.ball_merged.connect(_on_ball_merged)
	simulation.top_ball_created.connect(_on_top_ball_created)
	_verify_deterministic_merge_commit()
	_verify_catalog_top_event()
	if _failures == 0:
		print("S2_G3_VERIFIED pairs=deterministic one_consume_per_tick=true top_event=true")
	get_tree().quit(_failures)


func _verify_deterministic_merge_commit() -> void:
	var first_index := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2(100.0, 0.0), 4.0, 0)
	var second_index := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2(0.0, 100.0), 4.0, 0)
	var third_index := simulation.spawn_ball(Vector2(103.0, 106.0), Vector2(-80.0, 0.0), 4.0, 0)
	var level_one_index := simulation.spawn_ball(Vector2(103.0, 103.0), Vector2.ZERO, 8.0, 1)
	var mismatched_index := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 2)
	var active_before_merge := simulation.get_active_count()

	_expect(simulation.commit_merge_candidates() == 1, "Three same-level overlaps must commit exactly one deterministic pair.")
	_expect(simulation.get_active_count() == active_before_merge - 1, "One merge must remove two inputs and create one output.")
	_expect(not simulation.is_ball_active(first_index), "The first selected input slot must deactivate before output allocation.")
	_expect(simulation.get_ball_global_level(second_index) == 1, "The reused second input slot must now hold the Lv1 output.")
	_expect(simulation.is_ball_active(third_index), "A third overlapping input must remain for a later tick.")
	_expect(simulation.is_ball_active(level_one_index), "An existing next-level ball must not merge with the new result in the same tick.")
	_expect(simulation.is_ball_active(mismatched_index), "Different-level balls must remain active.")
	_expect(_merged_events.size() == 1, "One committed pair must emit one merge event.")

	var merged_index := _find_active_index_for_level(1, level_one_index)
	_expect(merged_index >= 0, "Lv0 pair must create one Lv1 output.")
	if merged_index >= 0:
		_expect(simulation.positions[merged_index].is_equal_approx(Vector2(103.0, 100.0)), "Merge output must use the midpoint of its two inputs.")
		_expect(simulation.velocities[merged_index].is_equal_approx(Vector2(50.0, 50.0)), "Equal-mass inputs must produce their velocity average.")
		_expect(is_equal_approx(simulation.radii[merged_index], 8.0), "Merge output must use the next BallDefinition radius.")

	_expect(simulation.commit_merge_candidates() == 1, "The next tick may merge the deferred Lv1 pair exactly once.")
	_expect(_merged_events.size() == 2, "The deferred merge must emit exactly one additional event.")
	_expect(_find_active_index_for_level(2, -1) >= 0, "Deferred Lv1 merge must create Lv2 on the next commit.")

	var fast_first := simulation.spawn_ball(Vector2(400.0, 100.0), Vector2(2000.0, 0.0), 4.0, 0)
	var fast_second := simulation.spawn_ball(Vector2(406.0, 100.0), Vector2(2000.0, 0.0), 4.0, 0)
	_expect(simulation.commit_merge_candidates() >= 1, "A valid fast pair must still commit.")
	var capped_index := _find_active_index_for_level(1, level_one_index)
	_expect(capped_index >= 0 and simulation.velocities[capped_index].length() <= simulation.maximum_ball_runtime_speed + 0.01, "Merge output velocity must respect the runtime speed cap.")


func _verify_catalog_top_event() -> void:
	simulation.reset_runtime()
	_merged_events.clear()
	_top_levels.clear()
	var first_index := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 13)
	var second_index := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 13)
	var max_first := simulation.spawn_ball(Vector2(300.0, 100.0), Vector2.ZERO, 4.0, 14)
	var max_second := simulation.spawn_ball(Vector2(306.0, 100.0), Vector2.ZERO, 4.0, 14)
	var active_before_merge := simulation.get_active_count()

	_expect(simulation.commit_merge_candidates() == 1, "Only a pair with a defined result level may merge.")
	_expect(simulation.get_active_count() == active_before_merge - 1, "Catalog-top merge must remove two inputs and create one output.")
	_expect(not simulation.is_ball_active(first_index), "The first catalog-top input slot must deactivate before output allocation.")
	_expect(simulation.get_ball_global_level(second_index) == 14, "The reused second input slot must now hold the highest catalog output.")
	_expect(simulation.is_ball_active(max_first) and simulation.is_ball_active(max_second), "Pairs without a next definition must remain active.")
	_expect(_top_levels == [14], "Creating the highest catalog level must emit top_ball_created once.")


func _find_active_index_for_level(global_level: int, excluded_index: int) -> int:
	for index in simulation.active_indices:
		if index != excluded_index and simulation.get_ball_global_level(index) == global_level:
			return index
	return -1


func _on_ball_merged(result_level: int, world_position: Vector2) -> void:
	_merged_events.append({"level": result_level, "position": world_position})


func _on_top_ball_created(global_level: int) -> void:
	_top_levels.append(global_level)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S2-G3 verification failed: %s" % message)
