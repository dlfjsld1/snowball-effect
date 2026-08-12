extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")

@onready var simulation: SimulationManager = $BallSimulationManager

var _failures := 0
var _metric_signal_count := 0


func _ready() -> void:
	simulation.simulation_metrics_updated.connect(_on_simulation_metrics_updated)
	_verify_slot_reuse()
	_verify_grid_bucket_reuse()
	_verify_logic_fx_separation()

	if _failures == 0:
		print("S4_G2_VERIFIED slot_reuse=true grid_buffers=stable logical_nodes=0 metrics_signal=true")
	get_tree().quit(_failures)


func _verify_slot_reuse() -> void:
	simulation.reset_runtime()
	const BALL_COUNT := 256
	var first_generation: Array[int] = []
	for index in range(BALL_COUNT):
		first_generation.append(simulation.spawn_ball(Vector2(index * 12.0, 100.0), Vector2.ZERO, 4.0, index % 5))
	for index in first_generation:
		simulation.deactivate_ball(index)
	for index in range(BALL_COUNT):
		simulation.spawn_ball(Vector2(index * 12.0, 200.0), Vector2.ZERO, 4.0, index % 5)

	var metrics := simulation.get_simulation_metrics()
	_expect(simulation.get_capacity() == BALL_COUNT, "Respawn must reuse inactive slots before growing SoA capacity.")
	_expect(metrics["active_balls"] == BALL_COUNT and metrics["free_slots"] == 0, "Slot metrics must match the reused active pool.")


func _verify_grid_bucket_reuse() -> void:
	simulation.reset_runtime()
	for index in range(300):
		simulation.spawn_ball(Vector2(float(index % 30) * 40.0, float(index / 30) * 40.0), Vector2.ZERO, 4.0, index % 5)
	simulation.step_simulation(1.0 / 60.0)
	var warmed_metrics := simulation.get_spatial_metrics()
	for iteration in range(120):
		simulation.step_simulation(1.0 / 60.0)
	var repeated_metrics := simulation.get_spatial_metrics()

	_expect(warmed_metrics["grid_bucket_capacity"] == repeated_metrics["grid_bucket_capacity"], "Stable occupancy must reuse existing grid cell arrays.")
	_expect(repeated_metrics["grid_new_buckets"] == 0, "A warmed grid must allocate no new cell bucket on repeated queries.")


func _verify_logic_fx_separation() -> void:
	_metric_signal_count = 0
	var child_count_before := simulation.get_child_count()
	simulation.step_simulation(1.0 / 60.0)
	var metrics := simulation.get_simulation_metrics()
	_expect(simulation.get_child_count() == child_count_before, "Logical balls must not create per-ball Nodes or FX children.")
	_expect(_metric_signal_count == 1, "Physics step must publish one read-only metrics update.")
	_expect(metrics["slot_capacity"] == 300, "Metrics must expose stable SoA slot capacity.")


func _on_simulation_metrics_updated(_metrics: Dictionary) -> void:
	_metric_signal_count += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S4-G2 verification failed: %s" % message)
