extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const Ledger = preload("res://scripts/core/score_ledger.gd")

@onready var simulation: SimulationManager = $BallSimulationManager
@onready var ledger: Ledger = $ScoreLedger

var _cashout_count := 0
var _failures := 0


func _ready() -> void:
	simulation.cashout_completed.connect(_on_cashout_completed)
	simulation.cashout_completed.connect(ledger.apply_score_event)
	_run_verification()


func _run_verification() -> void:
	var kept_index := simulation.spawn_ball(Vector2(200.0, 100.0), Vector2.ZERO, 4.0)
	var cashout_index := simulation.spawn_ball(Vector2(300.0, 610.0), Vector2(0.0, 100.0), 4.0)
	simulation.step_simulation(0.1)

	_expect(simulation.is_ball_active(kept_index), "Ball inside the field must remain active.")
	_expect(simulation.positions[kept_index].is_equal_approx(Vector2(200.0, 100.0)), "An untouched ball must not acquire downward motion before Cashout.")
	_expect(not simulation.is_ball_active(cashout_index), "Ball past the ScoreZone must deactivate.")
	_expect(_cashout_count == 1, "One crossing must emit one cashout event.")
	_expect(ledger.stage_score == 1.0, "Cashout must add score once to stage score.")
	_expect(ledger.run_score == 1.0, "Cashout must add the same score once to run score.")
	_expect(simulation.free_indices.back() == cashout_index, "Cashout slot must enter the free list.")

	simulation.step_simulation(0.1)
	_expect(_cashout_count == 1, "An inactive ball must not cash out again.")
	_expect(ledger.stage_score == 1.0 and ledger.run_score == 1.0, "Repeated ticks must not duplicate score.")

	var reused_index := simulation.spawn_ball(Vector2(300.0, 100.0), Vector2.ZERO, 4.0)
	_expect(reused_index == cashout_index, "Spawn must reuse the cashout slot.")
	simulation.reset_runtime()
	ledger.reset_runtime()
	_expect(simulation.get_active_count() == 0 and simulation.get_capacity() == 0, "Simulation reset must clear arrays and slots.")
	_expect(ledger.stage_score == 0.0 and ledger.run_score == 0.0, "Ledger reset must clear both scores.")

	if _failures == 0:
		print("S1_G3_VERIFIED cashouts=%d stage_score=1 run_score=1 reused_slot=%d reset=clean" % [_cashout_count, reused_index])
	get_tree().quit(_failures)


func _on_cashout_completed(_score_amount: float, local_level: int, _world_position: Vector2) -> void:
	_cashout_count += 1
	_expect(local_level == 0, "S1 cashout local level must be zero.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S1-G3 verification failed: %s" % message)
