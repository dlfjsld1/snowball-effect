extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const StageCatalogScript := preload("res://scripts/data/stage_catalog.gd")


class CutInStub extends Node:
	var requests: Array[Dictionary] = []
	var resets: Array[int] = []
	var accept_requests := true

	func play_first_contact_cutin(payload: Dictionary) -> bool:
		if not accept_requests:
			return false
		requests.append(payload.duplicate(true))
		return true

	func reset_first_contact_cutin(run_epoch: int) -> void:
		resets.append(run_epoch)


var _failures := 0
var _phase_count := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var paddle: Paddle = main.get_node("PlayField/PaddleMount/Paddle")
	var cutin_stub := CutInStub.new()
	add_child(cutin_stub)
	game_manager.set_first_contact_cutin_consumer_for_verification(cutin_stub)
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	stage_manager.black_hole_phase_started.connect(_on_black_hole_phase_started)
	game_manager._on_start_requested()

	await _verify_normal_fifo_and_pause(game_manager, stage_manager, simulation, paddle, cutin_stub)
	await _verify_terminal_arbitration(game_manager, stage_manager, cutin_stub)
	await _verify_black_hole_handoff(game_manager, stage_manager, cutin_stub)
	await _verify_retry_and_main_reset(game_manager, stage_manager, cutin_stub)

	if _failures == 0:
		print("S6_G2I_VERIFIED fifo=true pause=true stale_rejected=true black_hole_gate=true reset=true")
	get_tree().quit(_failures)


func _verify_normal_fifo_and_pause(
	game_manager: GameManager,
	stage_manager: StageManager,
	simulation: BallSimulationManager,
	paddle: Paddle,
	cutin_stub: CutInStub
) -> void:
	var epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	var giant := _payload(epoch, 101, 0, &"ground", 3, 3, &"ground_giant_snowball", &"RESUME_PLAYING", 0)
	var moon := _payload(epoch, 102, 0, &"ground", 4, 4, &"ground_moon", &"RESUME_PLAYING", 0)
	_expect(game_manager.accept_first_contact_discovery(giant), "Current valid discovery must be accepted.")
	_expect(game_manager.accept_first_contact_discovery(moon), "Distinct valid discovery must append to FIFO.")
	_expect(not game_manager.accept_first_contact_discovery(giant), "Duplicate event must be rejected.")
	await get_tree().process_frame
	_expect(cutin_stub.requests.size() == 1 and int(cutin_stub.requests[0]["event_id"]) == 101, "Only FIFO head may request visible CUT-IN.")
	_expect(stage_manager.is_first_contact_pause_locked(), "Pause lock must be acquired before visible CUT-IN.")
	_expect(not paddle.is_physics_processing(), "CUT-IN pause must stop Paddle physics.")
	var run_time_before: float = stage_manager.get_runtime_snapshot()["run_time_seconds"]
	stage_manager._physics_process(1.0)
	_expect(is_equal_approx(stage_manager.get_runtime_snapshot()["run_time_seconds"], run_time_before), "CUT-IN pause must stop Stage timer/simulation commits.")
	_expect(not game_manager.accept_first_contact_cutin_finished(102, epoch), "Non-head completion must be rejected.")
	_expect(not game_manager.accept_first_contact_cutin_finished(101, epoch + 1), "Wrong epoch completion must be rejected.")
	_expect(game_manager.accept_first_contact_cutin_finished(101, epoch), "Matching head completion must be accepted.")
	await get_tree().process_frame
	_expect(cutin_stub.requests.size() == 2 and int(cutin_stub.requests[1]["event_id"]) == 102, "Next FIFO event must start without a gameplay resume gap.")
	_expect(stage_manager.is_first_contact_pause_locked(), "FIFO continuation must preserve the pause lock.")
	_expect(game_manager.accept_first_contact_cutin_finished(102, epoch), "Second matching completion must be accepted.")
	_expect(not stage_manager.is_first_contact_pause_locked() and paddle.is_physics_processing(), "Final normal completion must resume the same PLAYING state.")
	_expect(simulation.is_valid_first_contact_payload(giant), "Fixture payload must remain v1-valid.")


func _verify_terminal_arbitration(game_manager: GameManager, stage_manager: StageManager, cutin_stub: CutInStub) -> void:
	var epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	var payload := _payload(epoch, 103, 0, &"ground", 3, 3, &"ground_giant_snowball", &"RESUME_PLAYING", 0)
	_expect(game_manager.accept_first_contact_discovery(payload), "Discovery may arrive before same-tick terminal resolution.")
	stage_manager._stage_runtime.stage_time_left = 0.0
	stage_manager._physics_process(0.1)
	await get_tree().process_frame
	_expect(stage_manager.current_state == StageManager.FAILED, "Time Up must remain authoritative over queued CUT-IN.")
	_expect(cutin_stub.requests.size() == 2, "Terminal resolution must discard queued CUT-IN before visible call.")


func _verify_black_hole_handoff(game_manager: GameManager, stage_manager: StageManager, cutin_stub: CutInStub) -> void:
	game_manager._on_start_requested()
	stage_manager.current_stage_index = 2
	stage_manager._enter_stage(StageCatalogScript.new().get_stage(2))
	var epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	var black_hole := _payload(epoch, 201, 2, &"galactic", 14, 4, &"galactic_black_hole", &"BLACK_HOLE_PHASE", 1)
	_expect(game_manager.accept_first_contact_discovery(black_hole), "First Black Hole discovery must be accepted.")
	game_manager._on_black_hole_phase_requested()
	await get_tree().process_frame
	_expect(cutin_stub.requests.size() == 3 and int(cutin_stub.requests[2]["event_id"]) == 201, "Black Hole CUT-IN must be requested before phase start.")
	_expect(_phase_count == 0 and stage_manager.get_runtime_snapshot()["pending_black_hole_phase_id"] == -1, "CUT-IN completion must gate Phase ID issuance.")
	_expect(game_manager.accept_first_contact_cutin_finished(201, epoch), "Matching Black Hole CUT-IN completion must be accepted.")
	_expect(stage_manager.current_state == StageManager.BLACK_HOLE_PHASE_LOCKED and _phase_count == 1, "Matching completion must start exactly one Black Hole phase without PLAYING resume.")
	_expect(not game_manager.accept_first_contact_cutin_finished(201, epoch), "Duplicate Black Hole completion must be rejected.")


func _verify_retry_and_main_reset(game_manager: GameManager, stage_manager: StageManager, cutin_stub: CutInStub) -> void:
	var old_epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	game_manager._on_retry_requested()
	var fresh_epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	_expect(fresh_epoch > old_epoch and stage_manager.current_state == StageManager.PLAYING, "Retry must open a fresh FIRST_CONTACT epoch.")
	_expect(not game_manager.accept_first_contact_cutin_finished(201, old_epoch), "Retry must reject stale completion from the old epoch.")
	game_manager._on_main_menu_requested()
	_expect(int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"]) == -1, "Main must invalidate the active FIRST_CONTACT epoch.")
	_expect(cutin_stub.resets.size() >= 2, "Retry/Main must request stale Presentation cleanup.")


func _payload(
	run_epoch: int,
	event_id: int,
	stage_index: int,
	stage_id: StringName,
	global_level: int,
	local_level: int,
	first_contact_id: StringName,
	handoff_kind: StringName,
	black_hole_entity_ordinal: int
) -> Dictionary:
	return {
		"schema_version": 1,
		"event_id": event_id,
		"run_epoch": run_epoch,
		"stage_index": stage_index,
		"stage_id": stage_id,
		"global_level": global_level,
		"local_level": local_level,
		"world_position": Vector2(800.0, 320.0),
		"first_contact_id": first_contact_id,
		"handoff_kind": handoff_kind,
		"black_hole_entity_ordinal": black_hole_entity_ordinal,
	}


func _on_black_hole_phase_started(_phase_id: int, _from_rect: Rect2, _to_rect: Rect2) -> void:
	_phase_count += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G2I verification failed: %s" % message)
