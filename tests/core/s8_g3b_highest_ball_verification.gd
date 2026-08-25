extends Node

const StageRuntime = preload("res://scripts/core/stage_runtime.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")

var _failures := 0


func _ready() -> void:
	var runtime: StageRuntime = StageRuntime.new()
	add_child(runtime)
	var galactic = StageCatalog.new().get_stage(2)
	runtime.enter_stage(galactic)
	runtime.reset_run_statistics()
	runtime.record_highest_ball(0)
	runtime.record_highest_ball(4)
	runtime.record_highest_ball(2)
	_expect(runtime.get_highest_ball_global_level() == 4, "Highest Ball must be monotonic across committed normal Ball creation.")
	runtime.record_highest_ball(14)
	_expect(runtime.get_highest_ball_global_level() == 14, "First Black Hole entity conversion must become the Run highest Ball.")
	runtime.lock_black_hole_finale({"contact_position": Vector2.ZERO, "black_holes": []})
	_expect(int(runtime.get_black_hole_finale_snapshot().get("highest_ball_global_level", -1)) == 14, "Finale snapshot must value-copy the Run highest Ball.")
	runtime.reset_run_statistics()
	_expect(runtime.get_highest_ball_global_level() == -1, "Retry/Main Run statistics reset must clear the previous Run highest Ball.")
	if _failures == 0:
		print("S8_G3B_CORE_VERIFIED highest_ball=committed_monotonic finale_copy=true reset=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G3B Core verification failed: %s" % message)
