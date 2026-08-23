extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const MAGNET_COMMAND := {
	"item_type": &"magnet",
	"active": true,
	"influence_radius": 96.0,
	"max_pair_acceleration": 120.0,
	"neighbor_limit": 2,
}

@onready var simulation: SimulationManager = $BallSimulationManager

var _failures := 0


func _ready() -> void:
	_verify_bounded_same_level_attraction()
	_verify_invalid_or_neutral_commands()
	_verify_one_thousand_ball_candidate_bound()
	if _failures == 0:
		print("S7_G4_CORE_VERIFIED same_level=true max_neighbors=2 sample_cap=8 acceleration_cap=120 candidates_bounded=true")
	get_tree().quit(_failures)


func _prepare_simulation() -> void:
	simulation.reset_runtime()
	simulation.play_field_rect = Rect2(0.0, 0.0, 20000.0, 20000.0)
	simulation.cashout_enabled = false
	simulation.merge_enabled = false
	simulation.configure_stage_ball_levels(PackedInt32Array([0, 1, 2]))


func _verify_bounded_same_level_attraction() -> void:
	_prepare_simulation()
	var left_index := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0)
	var right_index := simulation.spawn_ball(Vector2(160.0, 100.0), Vector2.ZERO, 4.0, 0)
	var different_level_index := simulation.spawn_ball(Vector2(120.0, 100.0), Vector2.ZERO, 4.0, 1)
	_expect(simulation.set_magnet_force_command(MAGNET_COMMAND), "A valid data command must enable the Core Magnet consumer.")
	simulation.step_simulation(0.1)
	_expect(simulation.velocities[left_index].x > 0.0, "A same-level neighbor to the right must pull the left Ball rightward.")
	_expect(simulation.velocities[right_index].x < 0.0, "A same-level neighbor to the left must pull the right Ball leftward.")
	_expect(simulation.velocities[different_level_index].is_zero_approx(), "Different-level Balls must not receive Magnet force.")
	var metrics := simulation.get_magnet_force_metrics()
	_expect(metrics["force_applications"] <= simulation.get_active_count() * 2, "Magnet must apply force to at most two neighbours per Ball.")
	_expect(metrics["candidate_count"] <= simulation.get_active_count() * 8, "Magnet candidate scan must stay bounded per Ball.")


func _verify_invalid_or_neutral_commands() -> void:
	_prepare_simulation()
	var invalid_neighbor_command := MAGNET_COMMAND.duplicate(true)
	invalid_neighbor_command["neighbor_limit"] = 3
	_expect(not simulation.set_magnet_force_command(invalid_neighbor_command), "Core must reject commands above the two-neighbour contract.")
	_expect(not simulation.get_magnet_force_metrics()["active"], "Rejected command must not enable Magnet state.")
	_expect(simulation.set_magnet_force_command({"active": false}), "A neutral command must be accepted for expiry/reset.")
	_expect(not simulation.get_magnet_force_metrics()["active"], "Neutral command must clear Magnet state.")


func _verify_one_thousand_ball_candidate_bound() -> void:
	_prepare_simulation()
	for index in range(1000):
		var column := index % 40
		var row := index / 40
		simulation.spawn_ball(Vector2(100.0 + column * 120.0, 100.0 + row * 120.0), Vector2.ZERO, 4.0, 0)
	_expect(simulation.set_magnet_force_command(MAGNET_COMMAND), "Stress fixture must enable the valid Magnet command.")
	simulation.step_simulation(1.0 / 60.0)
	var metrics := simulation.get_magnet_force_metrics()
	_expect(metrics["candidate_count"] <= 8000, "1,000 Ball Magnet query must retain the eight-candidate per-Ball bound.")
	_expect(metrics["force_applications"] == 0, "Sparse out-of-range Balls must not receive Magnet acceleration.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G4 Magnet Core verification failed: %s" % message)
