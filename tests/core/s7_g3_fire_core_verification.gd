extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const PaddleScene = preload("res://scenes/gameplay/paddle.tscn")

const FIELD := Rect2(0.0, 0.0, 800.0, 600.0)
const TEST_DELTA := 0.1

@onready var simulation: SimulationManager = $BallSimulationManager

var paddle: Paddle
var _cashout_scores: Array[float] = []
var _cashout_levels: Array[int] = []
var _failures := 0


func _ready() -> void:
	paddle = PaddleScene.instantiate()
	paddle.position = Vector2(400.0, 400.0)
	paddle.play_field_rect = FIELD
	add_child(paddle)
	await get_tree().process_frame
	simulation.set_paddle_collision_provider(paddle)
	simulation.cashout_completed.connect(_on_cashout_completed)

	_verify_fire_requires_an_active_paddle_contact()
	_verify_fire_merge_inheritance()
	_verify_fire_active_cashout_multiplier()
	_verify_fire_state_clears_on_slot_reuse_and_reset()

	if _failures == 0:
		print("S7_G3_CORE_VERIFIED contact=true merge_or=true active_cashout_multiplier=10 reset=true")
	get_tree().quit(_failures)


func _prepare_clean_simulation() -> void:
	simulation.reset_runtime()
	simulation.play_field_rect = FIELD
	simulation.cashout_enabled = true
	simulation.merge_enabled = true
	simulation.configure_stage_ball_levels(PackedInt32Array([0, 1, 2]))
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.set_fire_contact_active(false)
	paddle._reset_motion_history()


func _verify_fire_requires_an_active_paddle_contact() -> void:
	_prepare_clean_simulation()
	paddle.set_fire_contact_active(true)
	var fire_index := simulation.spawn_ball(Vector2(400.0, 370.0), Vector2(0.0, 300.0), 4.0, 0)
	simulation.step_simulation(TEST_DELTA)
	_expect(simulation.is_ball_fire(fire_index), "A committed Paddle collision during the Fire window must mark the Ball Fire.")

	_prepare_clean_simulation()
	var normal_index := simulation.spawn_ball(Vector2(400.0, 370.0), Vector2(0.0, 300.0), 4.0, 0)
	simulation.step_simulation(TEST_DELTA)
	_expect(not simulation.is_ball_fire(normal_index), "The same Paddle collision outside the Fire window must keep the Ball Normal.")


func _verify_fire_merge_inheritance() -> void:
	_prepare_clean_simulation()
	var fire_index := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0, SimulationManager.BallSpecialType.FIRE)
	var normal_index := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 0)
	_expect(simulation.commit_merge_candidates() == 1, "Fire + Normal overlap must commit one same-level Merge.")
	_expect(not simulation.is_ball_active(fire_index), "Fire Merge must consume its first input.")
	_expect(simulation.is_ball_active(normal_index) and simulation.get_ball_global_level(normal_index) == 1, "Merge output must reuse the second slot at the next level.")
	_expect(simulation.is_ball_fire(normal_index), "Fire + Normal result must inherit Fire.")

	_prepare_clean_simulation()
	var first_fire := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0, SimulationManager.BallSpecialType.FIRE)
	var second_fire := simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 0, SimulationManager.BallSpecialType.FIRE)
	_expect(simulation.commit_merge_candidates() == 1, "Fire + Fire overlap must commit one same-level Merge.")
	_expect(not simulation.is_ball_active(first_fire), "Fire + Fire Merge must consume its first input.")
	_expect(simulation.is_ball_active(second_fire) and simulation.is_ball_fire(second_fire), "Fire + Fire result must remain Fire.")


func _verify_fire_active_cashout_multiplier() -> void:
	_prepare_clean_simulation()
	_cashout_scores.clear()
	_cashout_levels.clear()
	var fire_index := simulation.spawn_ball(Vector2(200.0, 610.0), Vector2.ZERO, 4.0, 1, SimulationManager.BallSpecialType.FIRE)
	simulation.step_simulation(1.0 / 60.0)
	_expect(not simulation.is_ball_active(fire_index), "A Fire Ball below the open lower boundary must Active Cashout once.")
	_expect(_cashout_scores.size() == 1 and _cashout_levels == [1], "Fire Active Cashout must report the original Ball level exactly once.")
	_expect(_cashout_scores.size() == 1 and is_equal_approx(_cashout_scores[0], 1000.0), "Lv1 Fire Active Cashout must emit base score 100 multiplied by 10.")

	_prepare_clean_simulation()
	_cashout_scores.clear()
	var normal_index := simulation.spawn_ball(Vector2(200.0, 610.0), Vector2.ZERO, 4.0, 1)
	simulation.step_simulation(1.0 / 60.0)
	_expect(not simulation.is_ball_active(normal_index), "A Normal Ball below the lower boundary must Active Cashout once.")
	_expect(_cashout_scores.size() == 1 and is_equal_approx(_cashout_scores[0], 100.0), "Normal Active Cashout must preserve the base score.")


func _verify_fire_state_clears_on_slot_reuse_and_reset() -> void:
	_prepare_clean_simulation()
	var fire_index := simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0, SimulationManager.BallSpecialType.FIRE)
	_expect(simulation.deactivate_ball(fire_index), "A Fire Ball must deactivate for slot-reuse coverage.")
	var reused_index := simulation.spawn_ball(Vector2(120.0, 100.0), Vector2.ZERO, 4.0, 0)
	_expect(reused_index == fire_index and not simulation.is_ball_fire(reused_index), "A reused slot must not leak Fire state into a Normal spawn.")
	paddle.set_fire_contact_active(true)
	simulation.reset_runtime()
	paddle.reset_runtime()
	_expect(simulation.get_active_count() == 0 and not paddle.is_fire_contact_active(), "Retry/reset must clear Ball and Paddle Fire state.")


func _on_cashout_completed(score_amount: float, global_level: int, _world_position: Vector2) -> void:
	_cashout_scores.append(score_amount)
	_cashout_levels.append(global_level)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G3 Fire Core verification failed: %s" % message)
