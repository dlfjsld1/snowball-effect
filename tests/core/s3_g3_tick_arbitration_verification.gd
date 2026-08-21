extends Node

const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const StageRuntime = preload("res://scripts/core/stage_runtime.gd")

@onready var stage_runtime: StageRuntime = $StageRuntime

var _failures := 0
var _end_reasons: Array[StringName] = []


func _ready() -> void:
	stage_runtime.end_decision_requested.connect(_on_end_decision_requested)
	_run_verification()


func _run_verification() -> void:
	var catalog = StageCatalog.new()
	var ground = catalog.get_stage(0)

	stage_runtime.enter_stage(ground)
	stage_runtime.stage_time_left = 0.03
	var valid_delta := stage_runtime.get_valid_play_delta(0.1)
	_expect(is_equal_approx(valid_delta, 0.03), "Tick processing must stop at the exact remaining-time boundary.")
	var recovered := stage_runtime.process_tick(valid_delta, false, [{"score_amount": 10.0, "global_level": 3}])
	_expect(recovered == &"", "A pre-deadline Cashout must keep the Stage playing when its Time Bonus is positive.")
	_expect(stage_runtime.stage_time_left > 0.0, "A pre-deadline Cashout bonus must restore remaining Stage time.")
	_expect(_end_reasons.is_empty(), "A valid last-moment Cashout must not request an end decision.")

	stage_runtime.enter_stage(ground)
	stage_runtime.stage_time_left = 5.0
	stage_runtime.score_ledger.apply_score_event(ground.clear_score)
	var score_clear := stage_runtime.process_tick(0.0, false, [])
	_expect(score_clear == &"SCORE_CLEAR", "Reaching clear score must immediately request Score Clear before Time Up.")
	_expect(_end_reasons == [&"SCORE_CLEAR"], "Score Clear must emit exactly once on a fresh Stage.")

	stage_runtime.enter_stage(ground)
	stage_runtime.stage_time_left = 0.03
	var top_ball := stage_runtime.process_tick(stage_runtime.get_valid_play_delta(0.1), true, [])
	_expect(top_ball == &"TIME_UP", "Same-tick Top Ball must use the Time Up route.")
	_expect(_end_reasons == [&"SCORE_CLEAR", &"TIME_UP"], "Top Ball must not emit a separate Clear request.")
	_expect(stage_runtime.process_tick(1.0, false, []) == &"", "End lock must ignore later tick decisions.")
	_expect(_end_reasons.size() == 2, "End decision must remain locked after the first request.")

	stage_runtime.enter_stage(ground)
	stage_runtime.stage_time_left = 0.03
	var time_up := stage_runtime.process_tick(stage_runtime.get_valid_play_delta(0.1), false, [])
	_expect(time_up == &"TIME_UP", "Expired time without Cashout or Top Ball must request Time Up.")
	_expect(_end_reasons == [&"SCORE_CLEAR", &"TIME_UP", &"TIME_UP"], "Time Up must emit once after a fresh stage entry.")
	_expect(stage_runtime.is_current_stage_top_ball(4), "Ground's configured top global level must be recognized.")
	_expect(not stage_runtime.is_current_stage_top_ball(14), "Catalog final level must not override the current Stage top level.")

	if _failures == 0:
		print("S3_G3_VERIFIED deadline_bounded_tick=true predeadline_cashout_recovery=true score_clear_immediate=true time_up_once=true")
	get_tree().quit(_failures)


func _on_end_decision_requested(reason: StringName) -> void:
	_end_reasons.append(reason)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G3 verification failed: %s" % message)
