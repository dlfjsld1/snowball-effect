extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const BALL_COUNT := 100
const TEST_DELTA := 1.0 / 60.0
const LV1_RADIUS := 4.0
const LV1_SPAWN_SPEED := 160.0

@onready var simulation: SimulationManager = $BallSimulationManager

var _failures := 0


func _ready() -> void:
	_run_verification()


func _run_verification() -> void:
	var left_index: int = simulation.spawn_ball(Vector2(1.0, 100.0), Vector2(-120.0, 0.0), LV1_RADIUS)
	var right_index: int = simulation.spawn_ball(Vector2(799.0, 100.0), Vector2(120.0, 0.0), LV1_RADIUS)
	var top_index: int = simulation.spawn_ball(Vector2(400.0, 1.0), Vector2(0.0, -120.0), LV1_RADIUS)
	var constant_velocity := Vector2(0.0, LV1_SPAWN_SPEED)
	var constant_probe_index: int = simulation.spawn_ball(Vector2(400.0, 100.0), constant_velocity, LV1_RADIUS)
	for index in range(4, BALL_COUNT):
		var x := 40.0 + float(index % 90) * 8.0
		var y := 80.0 + float(index / 10) * 12.0
		simulation.spawn_ball(Vector2(x, y), Vector2.ZERO, LV1_RADIUS)

	_expect(simulation.get_active_count() == BALL_COUNT, "100 balls must be active after spawn.")
	_expect(simulation.get_capacity() == BALL_COUNT, "Initial capacity must match spawned balls.")
	_expect(simulation.free_indices.is_empty(), "No free slot should remain after initial spawn.")

	simulation.step_simulation(TEST_DELTA)
	_expect(is_equal_approx(simulation.radii[constant_probe_index], LV1_RADIUS), "Lv1 visual and collision radius must start at 4 logical units.")
	_expect(is_equal_approx(simulation.velocities[constant_probe_index].length(), LV1_SPAWN_SPEED), "Lv1 Spawn speed tuning must be 160 world units/s.")
	_expect(simulation.velocities[constant_probe_index].is_equal_approx(constant_velocity), "Free-flight velocity must remain unchanged without an interaction.")
	_expect(
		simulation.positions[constant_probe_index].is_equal_approx(Vector2(400.0, 100.0) + constant_velocity * TEST_DELTA),
		"Free-flight position must advance only by its current velocity."
	)
	_expect(simulation.positions[left_index].x >= LV1_RADIUS, "Left wall must clamp the ball inside the field.")
	_expect(simulation.velocities[left_index].x > 0.0, "Left wall must reflect velocity to the right.")
	_expect(simulation.positions[right_index].x <= 800.0 - LV1_RADIUS, "Right wall must clamp the ball inside the field.")
	_expect(simulation.velocities[right_index].x < 0.0, "Right wall must reflect velocity to the left.")
	_expect(simulation.positions[top_index].y >= LV1_RADIUS, "Top wall must clamp the ball inside the field.")
	_expect(simulation.velocities[top_index].y > 0.0, "Top wall must reflect velocity downward.")

	var released_index := 50
	_expect(simulation.deactivate_ball(released_index), "An active ball must deactivate successfully.")
	_expect(simulation.get_active_count() == BALL_COUNT - 1, "Deactivate must reduce active count once.")
	_expect(simulation.free_indices.back() == released_index, "Deactivated slot must enter the free list.")
	var reused_index: int = simulation.spawn_ball(Vector2(400.0, 120.0), Vector2.ZERO, LV1_RADIUS)
	_expect(reused_index == released_index, "Spawn must reuse the most recently released slot.")
	_expect(simulation.get_capacity() == BALL_COUNT, "Slot reuse must not grow capacity.")

	for _step in range(600):
		simulation.step_simulation(TEST_DELTA)

	var snapshot: Dictionary = simulation.get_render_snapshot()
	_expect(snapshot["count"] == BALL_COUNT, "Render snapshot must include every active ball.")
	_expect(snapshot["positions"].size() == BALL_COUNT, "Snapshot positions must match active count.")
	_expect(snapshot["radii"].size() == BALL_COUNT, "Snapshot radii must match active count.")
	_expect(_arrays_have_equal_capacity(), "All structure-of-arrays buffers must share capacity.")
	_expect(_all_active_values_are_finite(), "Active positions and velocities must remain finite.")

	if _failures == 0:
		print("S1_G1_VERIFIED active=%d capacity=%d reused_slot=%d" % [simulation.get_active_count(), simulation.get_capacity(), reused_index])
	get_tree().quit(_failures)


func _arrays_have_equal_capacity() -> bool:
	var capacity: int = simulation.get_capacity()
	return (
		simulation.velocities.size() == capacity
		and simulation.radii.size() == capacity
		and simulation.global_levels.size() == capacity
		and simulation.active_flags.size() == capacity
	)


func _all_active_values_are_finite() -> bool:
	for index in simulation.active_indices:
		if not simulation.positions[index].is_finite() or not simulation.velocities[index].is_finite():
			return false
	return true


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S1-G1 verification failed: %s" % message)
