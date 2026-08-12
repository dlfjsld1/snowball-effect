extends Node

const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const StageRuntime = preload("res://scripts/core/stage_runtime.gd")

@onready var stage_runtime: StageRuntime = $StageRuntime

var _failures := 0
var _score_signal_count := 0
var _time_signal_count := 0


func _ready() -> void:
	stage_runtime.score_changed.connect(_on_score_changed)
	stage_runtime.stage_time_changed.connect(_on_stage_time_changed)
	_run_verification()


func _run_verification() -> void:
	var catalog = StageCatalog.new()
	var ground = catalog.get_stage(0)
	var planetary = catalog.get_stage(1)

	stage_runtime.enter_stage(ground)
	_expect(is_equal_approx(stage_runtime.score_ledger.stage_score, 0.0), "Entering a stage must reset the stage score.")
	_expect(is_equal_approx(stage_runtime.score_ledger.run_score, 0.0), "Entering the first stage must preserve the current run score.")
	_expect(is_equal_approx(stage_runtime.stage_time_left, 45.0), "Entering Ground must set its data-defined base time.")

	var ground_bonus := stage_runtime.apply_active_cashout(10.0, 2)
	_expect(is_equal_approx(ground_bonus, 0.5), "Ground global Lv2 must use local Lv2's Time Bonus.")
	_expect(is_equal_approx(stage_runtime.score_ledger.stage_score, 10.0), "Cashout must add its amount once to stage score.")
	_expect(is_equal_approx(stage_runtime.score_ledger.run_score, 10.0), "Cashout must add the same amount once to run score.")
	_expect(is_equal_approx(stage_runtime.stage_time_left, 45.5), "Cashout must add its local Time Bonus to stage time.")

	stage_runtime.enter_stage(planetary)
	_expect(is_equal_approx(stage_runtime.score_ledger.stage_score, 0.0), "Next stage entry must reset only stage score.")
	_expect(is_equal_approx(stage_runtime.score_ledger.run_score, 10.0), "Next stage entry must preserve accumulated run score.")
	_expect(is_equal_approx(stage_runtime.stage_time_left, 40.0), "Next stage entry must reset time to the next data-defined base time.")

	var planetary_bonus := stage_runtime.apply_active_cashout(25.0, 8)
	_expect(is_equal_approx(planetary_bonus, 1.0), "Noncontiguous global Lv8 must resolve to Planetary local Lv3.")
	_expect(is_equal_approx(stage_runtime.score_ledger.stage_score, 25.0), "Second stage Cashout must start a new stage subtotal.")
	_expect(is_equal_approx(stage_runtime.score_ledger.run_score, 35.0), "Run score must accumulate each event without stage-end re-addition.")
	_expect(is_equal_approx(stage_runtime.stage_time_left, 41.0), "Planetary local Lv3 must add its time bonus once.")

	stage_runtime.enter_stage(ground)
	_expect(is_equal_approx(stage_runtime.score_ledger.stage_score, 0.0), "Subsequent entry must clear the prior stage subtotal.")
	_expect(is_equal_approx(stage_runtime.score_ledger.run_score, 35.0), "Stage transition must not re-add or clear run score.")
	_expect(_score_signal_count == 5, "Stage entry and each score event must publish score changes exactly once.")
	_expect(_time_signal_count == 5, "Stage entry and each Cashout time change must publish once.")

	if _failures == 0:
		print("S3_G2_VERIFIED ground_bonus=0.5 planetary_bonus=1.0 stage_reset=clean run_score=35")
	get_tree().quit(_failures)


func _on_score_changed(_stage_score: float, _run_score: float) -> void:
	_score_signal_count += 1


func _on_stage_time_changed(_time_left: float) -> void:
	_time_signal_count += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G2 verification failed: %s" % message)
