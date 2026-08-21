extends Node

const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageRuntime = preload("res://scripts/core/stage_runtime.gd")

@onready var simulation: SimulationManager = $BallSimulationManager
@onready var stage_runtime: StageRuntime = $StageRuntime

var _failures := 0
var _finale_event_count := 0
var _top_ball_event_count := 0


func _ready() -> void:
	var galactic = StageCatalog.new().get_stage(2)
	simulation.apply_stage_definition(galactic)
	stage_runtime.enter_stage(galactic)
	stage_runtime.reset_run_statistics()
	stage_runtime.record_run_merge()
	stage_runtime.record_run_merge()
	stage_runtime.advance_run_time(766.9)
	stage_runtime.enter_stage(galactic)
	_expect(stage_runtime.get_run_statistics()["merge_count"] == 2, "Stage entry must preserve Run Merge count.")
	_expect(is_equal_approx(stage_runtime.get_run_statistics()["run_time_seconds"], 766.9), "Stage entry must preserve Run Time.")
	stage_runtime.score_ledger.apply_score_event(123.0)
	simulation.black_hole_finale_started.connect(_on_black_hole_finale_started)
	simulation.top_ball_created.connect(_on_top_ball_created)
	_create_two_black_holes()
	_verify_terminal_contact_lock()
	if _failures == 0:
		print("S8_G2_VERIFIED terminal=once snapshot=read_only normal_commit=stopped shift=none")
	get_tree().quit(_failures)


func _create_two_black_holes() -> void:
	var radius := simulation.get_runtime_radius_for_level(13)
	simulation.spawn_ball(Vector2(700.0, 300.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(710.0, 300.0), Vector2.ZERO, radius, 13)
	_expect(simulation.commit_merge_candidates() == 1, "First Event Horizon pair must create the first Black Hole.")
	simulation.spawn_ball(Vector2(900.0, 300.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(910.0, 300.0), Vector2.ZERO, radius, 13)
	_expect(simulation.commit_merge_candidates() == 1, "Second Event Horizon pair must create the second Black Hole.")
	_expect(simulation.get_black_hole_count() == 2, "Two Black Holes must exist before terminal contact.")
	_expect(not simulation.is_black_hole_terminal_locked(), "Creating the second Black Hole alone must not end the run.")
	_expect(_top_ball_event_count == 0, "Galactic Black Hole creation must not request a regular Stage Clear.")


func _verify_terminal_contact_lock() -> void:
	simulation._black_hole_positions[0] = Vector2(700.0, 300.0)
	simulation._black_hole_positions[1] = Vector2(760.0, 300.0)
	simulation._black_hole_velocities[0] = Vector2(600.0, 0.0)
	simulation._black_hole_velocities[1] = Vector2(-600.0, 0.0)
	var normal_first := simulation.spawn_ball(Vector2(800.0, 400.0), Vector2.ZERO, 4.0, 10)
	var normal_second := simulation.spawn_ball(Vector2(806.0, 400.0), Vector2.ZERO, 4.0, 10)
	simulation.step_simulation(0.1)
	_expect(simulation.is_black_hole_terminal_locked(), "A sufficiently strong Black Hole collision must lock terminal runtime.")
	_expect(_finale_event_count == 1, "Terminal contact must publish exactly one finale event.")
	_expect(stage_runtime.is_black_hole_finale_locked(), "StageRuntime must lock the supplied finale result once.")
	var result_snapshot := stage_runtime.get_black_hole_finale_snapshot()
	_expect(result_snapshot["run_score"] == 123.0 and result_snapshot["stage_score"] == 123.0, "Finale snapshot must preserve the final score before UI presentation.")
	_expect(result_snapshot["optional_stats"]["merge_count"] == 2, "Finale snapshot must preserve the cumulative Run Merge count.")
	_expect(is_equal_approx(result_snapshot["optional_stats"]["run_time_seconds"], 766.9), "Finale snapshot must preserve active Run Time.")
	_expect(result_snapshot.has("contact_position") and result_snapshot["black_holes"].size() == 2, "Finale snapshot must expose both Black Hole contact states read-only.")
	_expect(simulation.is_ball_active(normal_first) and simulation.is_ball_active(normal_second), "Terminal lock must stop ordinary Merge/Cashout commits in the contact tick.")
	simulation.step_simulation(1.0 / 60.0)
	_expect(_finale_event_count == 1, "Repeated ticks after terminal lock must not create another finale event.")
	_expect(simulation.is_ball_active(normal_first) and simulation.is_ball_active(normal_second), "Terminal lock must keep later ordinary simulation commits stopped.")
	_expect(_top_ball_event_count == 0, "Terminal contact must not request an additional Stage Shift.")


func _on_black_hole_finale_started(contact_snapshot: Dictionary) -> void:
	_finale_event_count += 1
	stage_runtime.lock_black_hole_finale(contact_snapshot)


func _on_top_ball_created(_global_level: int) -> void:
	_top_ball_event_count += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G2 verification failed: %s" % message)
