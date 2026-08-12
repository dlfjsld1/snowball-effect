extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageManager = preload("res://scripts/core/stage_manager.gd")

@onready var simulation: SimulationManager = $BallSimulationManager
@onready var stage_manager: StageManager = $StageManager

var _failures := 0


func _ready() -> void:
	stage_manager.start_run()
	_verify_cashout_recovers_time()
	_verify_time_up_fails()
	_verify_top_ball_clears_and_settles()
	_verify_retry_resets_runtime()
	if _failures == 0:
		print("S3_G5_VERIFIED cashout_recovery=true time_up_failed=true top_clear_settled=true retry_clean=true")
	get_tree().quit(_failures)


func _verify_cashout_recovers_time() -> void:
	stage_manager.start_run()
	stage_manager.get_runtime_snapshot()["stage_time_left"]
	stage_manager._stage_runtime.stage_time_left = 0.03
	simulation.spawn_ball(Vector2(300.0, 610.0), Vector2(0.0, 100.0), 16.0, 3)
	stage_manager._physics_process(0.1)
	_expect(stage_manager.current_state == StageManager.PLAYING, "Same-tick Lv3 Cashout must keep the Stage playing.")
	_expect(stage_manager.get_runtime_snapshot()["stage_time_left"] > 0.0, "Cashout Time Bonus must recover expired time.")


func _verify_time_up_fails() -> void:
	stage_manager.start_run()
	stage_manager._stage_runtime.stage_time_left = 0.03
	stage_manager._physics_process(0.1)
	_expect(stage_manager.current_state == StageManager.FAILED, "Time Up below Ground clear score must fail after settlement.")


func _verify_top_ball_clears_and_settles() -> void:
	stage_manager.start_run()
	simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 16.0, 3)
	simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 16.0, 3)
	stage_manager._physics_process(0.1)
	_expect(stage_manager.current_state == StageManager.CLEARED, "Ground top ball must clear the Stage.")
	_expect(is_equal_approx(stage_manager.get_score_ledger().stage_score, 100000000.0), "Top ball must be included in final settlement exactly once.")
	_expect(simulation.get_active_count() == 0, "Settlement must remove the active snapshot balls.")


func _verify_retry_resets_runtime() -> void:
	stage_manager.start_run()
	_expect(stage_manager.current_state == StageManager.PLAYING, "Retry must restart Ground in PLAYING.")
	_expect(is_equal_approx(stage_manager.get_score_ledger().stage_score, 0.0) and is_equal_approx(stage_manager.get_score_ledger().run_score, 0.0), "Retry must clear prior Stage and Run score.")
	_expect(simulation.get_active_count() == 0, "Retry must clear prior simulation slots.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G5 verification failed: %s" % message)
