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
	var recovered := stage_runtime.process_tick(0.1, false, [{"score_amount": 10.0, "global_level": 3}])
	_expect(recovered == &"", "Same-tick Cashout must cancel Time Up when time becomes positive.")
	_expect(stage_runtime.stage_time_left > 0.0, "Cashout bonus must restore remaining time after the tick decrement.")
	_expect(_end_reasons.is_empty(), "Recovered time must not request an end decision.")

	stage_runtime.enter_stage(ground)
	stage_runtime.stage_time_left = 0.03
	var top_ball := stage_runtime.process_tick(0.1, true, [])
	_expect(top_ball == &"TOP_BALL_CLEAR", "Top Ball must take priority over expired time in the same tick.")
	_expect(_end_reasons == [&"TOP_BALL_CLEAR"], "Top Ball end request must emit once.")
	_expect(stage_runtime.process_tick(1.0, false, []) == &"", "End lock must ignore later tick decisions.")
	_expect(_end_reasons.size() == 1, "End decision must remain locked after the first request.")

	stage_runtime.enter_stage(ground)
	stage_runtime.stage_time_left = 0.03
	var time_up := stage_runtime.process_tick(0.1, false, [])
	_expect(time_up == &"TIME_UP", "Expired time without Cashout or Top Ball must request Time Up.")
	_expect(_end_reasons == [&"TOP_BALL_CLEAR", &"TIME_UP"], "Time Up must emit once after a fresh stage entry.")
	_expect(stage_runtime.is_current_stage_top_ball(4), "Ground's configured top global level must be recognized.")
	_expect(not stage_runtime.is_current_stage_top_ball(14), "Catalog final level must not override the current Stage top level.")

	if _failures == 0:
		print("S3_G3_VERIFIED cashout_recovery=true top_ball_priority=true end_lock=true")
	get_tree().quit(_failures)


func _on_end_decision_requested(reason: StringName) -> void:
	_end_reasons.append(reason)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G3 verification failed: %s" % message)
