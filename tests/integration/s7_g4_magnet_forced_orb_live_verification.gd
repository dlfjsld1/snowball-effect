extends Node

## Controlled live-Main verification for the temporary Magnet-only Orb test.
##
## This deliberately keeps the production Item Ball -> five valid hits -> Orb
## -> collected signal -> Gateway route intact.  Only ItemManager's existing
## forced_item_type test seam selects Magnet for the three test runs.

const TEST_RUNS := 3

@onready var game_manager: GameManager = $Main/GameManager
@onready var stage_manager: StageManager = $Main/StageManager
@onready var item_manager: ItemManager = $Main/ItemManager
@onready var magnet: ItemMagnet = $Main/ItemMagnet
@onready var simulation: BallSimulationManager = $Main/PlayField/SimulationMount/BallSimulationManager

var _failures := 0
var _results: Array[String] = []


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for run_index in TEST_RUNS:
		await _verify_one_live_run(run_index + 1)
	if _failures == 0:
		print("S7_G4_MAGNET_FORCED_ORB_LIVE_VERIFIED runs=%d %s" % [TEST_RUNS, "; ".join(_results)])
	get_tree().quit(_failures)


func _verify_one_live_run(run_number: int) -> void:
	game_manager._start_run()
	await get_tree().process_frame
	# Clear the regular opening spawn before the controlled sample.  This must
	# happen before collection because reset_runtime intentionally neutralizes
	# every optional-item force command.
	simulation.reset_runtime()
	var definition: StageDefinition = stage_manager.get_current_stage()
	_expect(definition != null, "Run %d must enter a playable Stage." % run_number)
	if definition == null:
		return

	# Existing producer test seam: no non-Magnet Item Ball/Orb may be selected.
	item_manager.enter_stage(
		definition,
		simulation.play_field_rect,
		simulation.get_runtime_radius_for_level(definition.local_ball_levels[2]),
		0.0,
		&"magnet",
		1000 + run_number
	)
	item_manager.advance(0.01)
	var planet := item_manager.get_item_ball_snapshot()
	_expect(planet.get("item_type", &"") == &"magnet", "Run %d must spawn only a Magnet Item Ball." % run_number)

	# Five distinct, separated valid contacts are the normal Item Ball break rule.
	for contact_id in range(1, 6):
		item_manager.process_ball_snapshots([_snapshot(contact_id, definition.local_ball_levels[2], planet.position, 16.0)])
		item_manager.process_ball_snapshots([])
	var orb := item_manager.get_item_orb_snapshot()
	_expect(orb.get("item_type", &"") == &"magnet", "Run %d must create only a Magnet Orb after five hits." % run_number)
	_expect(item_manager.try_collect_orb(orb.get("position", Vector2.ZERO), 0.0), "Run %d Magnet Orb must resolve through the real collection signal." % run_number)
	await get_tree().process_frame
	await get_tree().process_frame
	var command := simulation.get_magnet_force_metrics()
	_expect(magnet.is_active() and command.get("active", false), "Run %d collected Magnet Orb must activate the force command." % run_number)

	# Live Main simulation measurement: same-level pair attracts; a different
	# level at the same range is the negative control.
	var level := definition.local_ball_levels[0]
	var left_index := simulation.spawn_ball(Vector2(640.0, 360.0), Vector2.ZERO, 4.0, level)
	var right_index := simulation.spawn_ball(Vector2(700.0, 360.0), Vector2.ZERO, 4.0, level)
	var different_index := simulation.spawn_ball(Vector2(670.0, 440.0), Vector2.ZERO, 4.0, definition.local_ball_levels[1])
	simulation.step_simulation(0.1)
	var left_velocity: Vector2 = simulation.velocities[left_index]
	var right_velocity: Vector2 = simulation.velocities[right_index]
	var different_velocity: Vector2 = simulation.velocities[different_index]
	_expect(left_velocity.x > 0.0 and right_velocity.x < 0.0, "Run %d same-level Balls must accelerate toward each other." % run_number)
	_expect(different_velocity.is_zero_approx(), "Run %d different-level control must receive no Magnet force." % run_number)
	var metrics := simulation.get_magnet_force_metrics()
	_expect(int(metrics.get("force_applications", 0)) >= 2, "Run %d must record live same-level force applications." % run_number)
	_results.append("run%d:%0.2f/%0.2f apps=%d" % [run_number, left_velocity.x, right_velocity.x, int(metrics.get("force_applications", 0))])

	magnet.advance(7.0)
	_expect(not simulation.get_magnet_force_metrics().get("active", true), "Run %d expiry must restore a neutral force command." % run_number)


func _snapshot(id: int, global_level: int, position: Vector2, radius: float) -> Dictionary:
	return {"id": id, "global_level": global_level, "position": position, "radius": radius}


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G4 forced Magnet Orb live verification failed: %s" % message)
