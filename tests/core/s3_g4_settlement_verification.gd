extends Node

const Ledger = preload("res://scripts/core/score_ledger.gd")
const SettlementService = preload("res://scripts/core/settlement_service.gd")

@onready var ledger: Ledger = $ScoreLedger
@onready var settlement_service: SettlementService = $SettlementService

var _failures := 0
var _started_amounts: Array[float] = []
var _finished_amounts: Array[float] = []


func _ready() -> void:
	settlement_service.configure(ledger)
	settlement_service.final_settlement_started.connect(_on_settlement_started)
	settlement_service.final_settlement_finished.connect(_on_settlement_finished)
	_run_verification()


func _run_verification() -> void:
	ledger.apply_score_event(10.0)
	var snapshot: Array[Dictionary] = [
		{"global_level": 0, "cashout_modifier": 10.0, "score_amount": 999999.0},
		{"global_level": 1, "cashout_modifier": 10.0, "score_amount": 999999.0},
		{"global_level": 4, "cashout_modifier": 10.0, "score_amount": 999999.0},
	]
	var settlement_amount := settlement_service.settle(snapshot)
	_expect(is_equal_approx(settlement_amount, 100000101.0), "Settlement must sum only BallDefinition base scores, including the top ball.")
	_expect(is_equal_approx(ledger.stage_score, 100000111.0), "Settlement must add its base amount once to stage score.")
	_expect(is_equal_approx(ledger.run_score, 100000111.0), "Settlement must add its base amount once to run score.")
	_expect(_started_amounts == [100000101.0] and _finished_amounts == [100000101.0], "Settlement lifecycle signals must emit the amount once.")

	snapshot.append({"global_level": 14})
	var duplicate_amount := settlement_service.settle(snapshot)
	_expect(is_equal_approx(duplicate_amount, 0.0), "Repeated settlement must be idempotent.")
	_expect(is_equal_approx(ledger.stage_score, 100000111.0) and is_equal_approx(ledger.run_score, 100000111.0), "Repeated settlement must not add score.")
	_expect(_started_amounts.size() == 1 and _finished_amounts.size() == 1, "Repeated settlement must not re-emit lifecycle signals.")

	settlement_service.reset_for_stage()
	var next_stage_amount := settlement_service.settle([{"global_level": 0}])
	_expect(is_equal_approx(next_stage_amount, 1.0), "Stage reset must allow exactly one new settlement.")
	_expect(is_equal_approx(ledger.run_score, 100000112.0), "New stage settlement must add only its new base amount, not a stage subtotal.")

	if _failures == 0:
		print("S3_G4_VERIFIED base_only=true top_included=true idempotent=true")
	get_tree().quit(_failures)


func _on_settlement_started(amount: float) -> void:
	_started_amounts.append(amount)


func _on_settlement_finished(amount: float) -> void:
	_finished_amounts.append(amount)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G4 verification failed: %s" % message)
