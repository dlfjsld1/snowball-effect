extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")

@onready var simulation: SimulationManager = $BallSimulationManager

var _events: Array[Dictionary] = []
var _merge_event_count := 0
var _signal_trace: Array[StringName] = []
var _black_hole_phase_requests := 0
var _failures := 0


func _ready() -> void:
	simulation.set_physics_process(false)
	simulation.first_contact_discovered.connect(_on_first_contact_discovered)
	simulation.ball_merged.connect(_on_ball_merged)
	simulation.black_hole_phase_requested.connect(_on_black_hole_phase_requested)
	_verify_exact_once_stage_preserve_and_black_hole_handoff()
	_verify_invalidation_and_fresh_run_order()
	_verify_payload_rejection()
	if _failures == 0:
		print("S3_G9_VERIFIED identities=6 exact_once=true stage_preserve=true run_reset=true deterministic_order=true")
	get_tree().quit(_failures)


func _verify_exact_once_stage_preserve_and_black_hole_handoff() -> void:
	_expect(simulation.begin_first_contact_run(41), "A new run epoch must open FIRST_CONTACT discovery.")
	_expect(not simulation.begin_first_contact_run(41), "The same run epoch must not reopen discovery.")
	_expect(not simulation.begin_first_contact_run(40), "A smaller run epoch must not reopen discovery.")

	_apply_stage(0)
	_expect(_commit_pair(2, Vector2(120.0, 120.0)) == 1, "Ground Lv2 pair must commit Giant Snowball.")
	_apply_stage(0)
	_expect(_commit_pair(3, Vector2(160.0, 120.0)) == 1, "Ground Lv3 pair must commit Moon.")
	_apply_stage(0)
	_expect(_commit_pair(2, Vector2(200.0, 120.0)) == 1, "A duplicate Ground Giant merge must still commit normally.")
	_expect(_events.size() == 2, "Stage reset must preserve the current Run seen set.")

	_apply_stage(1)
	simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, simulation.get_runtime_radius_for_level(4), 4)
	_expect(_events.size() == 2, "Planetary local Lv0 Moon direct spawn must not emit discovery.")
	_apply_stage(1)
	_expect(_commit_pair(6, Vector2(240.0, 120.0)) == 1, "Planetary Lv2 pair must commit Supernova.")
	_apply_stage(1)
	_expect(_commit_pair(8, Vector2(280.0, 120.0)) == 1, "Planetary Lv3 pair must commit Galaxy.")
	_apply_stage(1)
	_expect(_commit_pair(10, Vector2(320.0, 120.0)) == 0, "Out-of-chain Planetary top-level pair must not merge.")

	_apply_stage(2)
	_expect(_commit_pair(12, Vector2(360.0, 120.0)) == 1, "Galactic Lv2 pair must commit Event Horizon.")
	_apply_stage(2)
	_expect(_commit_pair(13, Vector2(400.0, 120.0)) == 1, "Galactic Lv3 pair must commit first Black Hole.")
	_expect(simulation.get_black_hole_count() == 1, "First Galactic Lv14 must commit one Black Hole entity.")
	_expect(_black_hole_phase_requests == 1, "First Black Hole may issue only the existing readiness request, not start Phase here.")
	_expect(_events.size() == 6, "Only the six approved identities must emit in one Run.")
	_expect(_signal_trace[0] == &"ball_merged" and _signal_trace[1] == &"first_contact_discovered", "FIRST_CONTACT must follow its committed ball_merged signal.")

	var expected_ids := [
		&"ground_giant_snowball",
		&"ground_moon",
		&"planetary_supernova",
		&"planetary_galaxy",
		&"galactic_event_horizon",
		&"galactic_black_hole",
	]
	for index in expected_ids.size():
		var payload := _events[index]
		_expect(payload["first_contact_id"] == expected_ids[index], "Discovery identities must follow committed Merge order.")
		_expect(payload["event_id"] == index + 1, "FIRST_CONTACT event IDs must be process-lifetime monotonic.")
		_expect(payload["run_epoch"] == 41, "Current Run payload must retain its run epoch.")
		_expect(simulation.is_valid_first_contact_payload(payload), "Every producer payload must satisfy v1 schema and roster validation.")
	_expect(_events[5]["handoff_kind"] == &"BLACK_HOLE_PHASE", "First Black Hole discovery must request the Black Hole handoff.")
	_expect(_events[5]["black_hole_entity_ordinal"] == 1, "First Black Hole payload must identify its committed first entity.")


func _verify_invalidation_and_fresh_run_order() -> void:
	_expect(not simulation.invalidate_first_contact_run(40), "Wrong or stale invalidation must leave the current Run active.")
	_expect(simulation.invalidate_first_contact_run(41), "Matching invalidation must close the current Run.")
	_apply_stage(0)
	_expect(_commit_pair(2, Vector2(120.0, 180.0)) == 1, "A merge after invalidation remains valid gameplay.")
	_expect(_events.size() == 6, "Invalidated Run must not emit discovery.")
	_expect(simulation.begin_first_contact_run(42), "A fresh larger run epoch must reopen discovery.")
	_apply_stage(0)
	_spawn_pair(2, Vector2(120.0, 220.0))
	_spawn_pair(3, Vector2(420.0, 220.0))
	_expect(simulation.commit_merge_candidates() == 2, "Two independent pairs must commit in one deterministic Merge tick.")
	_expect(_events.size() == 8, "Fresh Run must allow identities to be discovered again.")
	_expect(_events[6]["first_contact_id"] == &"ground_giant_snowball", "Same-tick earliest pair must receive the first new event ID.")
	_expect(_events[7]["first_contact_id"] == &"ground_moon", "Same-tick later pair must receive the next event ID.")
	_expect(_events[6]["event_id"] == 7 and _events[7]["event_id"] == 8, "New Run must not reset process-lifetime FIRST_CONTACT event IDs.")
	_expect(_events[6]["run_epoch"] == 42 and _events[7]["run_epoch"] == 42, "Fresh Run discoveries must use the fresh epoch.")


func _verify_payload_rejection() -> void:
	var invalid_schema := _events[0].duplicate(true)
	invalid_schema["schema_version"] = 2
	_expect(not simulation.is_valid_first_contact_payload(invalid_schema), "Unknown payload schema must be rejected.")
	var invalid_position := _events[0].duplicate(true)
	invalid_position["world_position"] = "not-a-vector"
	_expect(not simulation.is_valid_first_contact_payload(invalid_position), "Payload type mismatch must be rejected.")
	var invalid_level := _events[0].duplicate(true)
	invalid_level["global_level"] = 4
	_expect(not simulation.is_valid_first_contact_payload(invalid_level), "Roster and level mismatch must be rejected.")


func _apply_stage(stage_index: int) -> void:
	var definition = StageCatalog.new().get_stage(stage_index)
	simulation.apply_stage_definition(definition)


func _commit_pair(level: int, position: Vector2) -> int:
	_spawn_pair(level, position)
	return simulation.commit_merge_candidates()


func _spawn_pair(level: int, position: Vector2) -> void:
	var radius := simulation.get_runtime_radius_for_level(level)
	simulation.spawn_ball(position, Vector2.ZERO, radius, level)
	simulation.spawn_ball(position + Vector2(1.0, 0.0), Vector2.ZERO, radius, level)


func _on_first_contact_discovered(payload: Dictionary) -> void:
	_signal_trace.append(&"first_contact_discovered")
	_events.append(payload.duplicate(true))


func _on_ball_merged(_result_level: int, _world_position: Vector2) -> void:
	_signal_trace.append(&"ball_merged")
	_merge_event_count += 1


func _on_black_hole_phase_requested() -> void:
	_black_hole_phase_requests += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G9 verification failed: %s" % message)
