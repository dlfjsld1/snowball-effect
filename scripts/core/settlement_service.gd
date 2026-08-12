class_name SettlementService
extends Node

const BallCatalog = preload("res://scripts/data/ball_catalog.gd")
const Ledger = preload("res://scripts/core/score_ledger.gd")

signal final_settlement_started(amount: float)
signal final_settlement_finished(amount: float)

var settlement_applied := false

var _score_ledger: Ledger
var _ball_catalog = BallCatalog.new()


func configure(score_ledger: Ledger) -> void:
	assert(score_ledger != null, "SettlementService requires a ScoreLedger.")
	_score_ledger = score_ledger


func reset_for_stage() -> void:
	settlement_applied = false


func settle(snapshot: Array[Dictionary]) -> float:
	assert(_score_ledger != null, "SettlementService must be configured before settling.")
	if settlement_applied:
		return 0.0

	settlement_applied = true
	var settlement_amount := _calculate_base_score(snapshot.duplicate(true))
	final_settlement_started.emit(settlement_amount)
	_score_ledger.apply_score_event(settlement_amount)
	final_settlement_finished.emit(settlement_amount)
	return settlement_amount


func _calculate_base_score(snapshot: Array[Dictionary]) -> float:
	var settlement_amount := 0.0
	for ball in snapshot:
		assert(ball.has("global_level"), "Settlement snapshot entries require a global_level.")
		var definition = _ball_catalog.get_definition(ball["global_level"])
		assert(definition != null, "Settlement snapshot global level must exist in BallCatalog.")
		settlement_amount += definition.score_value
	return settlement_amount
