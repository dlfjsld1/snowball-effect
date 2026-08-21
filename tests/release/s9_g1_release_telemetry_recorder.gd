extends RefCounted

var _stage: StageDefinition
var _sample := {}


func begin_stage(definition: StageDefinition, start_time: float) -> void:
	assert(definition != null, "Release telemetry requires a StageDefinition.")
	_stage = definition
	_sample = {
		"stage_index": definition.stage_index,
		"stage_name": definition.display_name,
		"start_time": start_time,
		"end_time": start_time,
		"playing_dwell_seconds": 0.0,
		"cashouts_total": 0,
		"cashouts_by_local_level": [0, 0, 0, 0, 0],
		"time_bonus_total_seconds": 0.0,
		"active_ball_peak": 0,
		"candidate_peak": 0,
		"grid_cell_peak": 0,
		"terminal_reason": &"",
	}


func observe_state(state: StringName, delta: float) -> void:
	assert(delta >= 0.0, "Telemetry delta must not be negative.")
	if state == &"PLAYING":
		_sample["playing_dwell_seconds"] += delta


func set_playing_dwell(seconds: float) -> void:
	assert(seconds >= 0.0, "Telemetry dwell must not be negative.")
	_sample["playing_dwell_seconds"] = seconds


func record_cashout(global_level: int) -> bool:
	var local_level := _stage.local_ball_levels.find(global_level)
	if local_level < 0 or local_level >= _stage.time_bonus_by_local_level.size():
		return false
	_sample["cashouts_total"] += 1
	_sample["cashouts_by_local_level"][local_level] += 1
	_sample["time_bonus_total_seconds"] += _stage.time_bonus_by_local_level[local_level]
	return true


func record_metrics(metrics: Dictionary) -> void:
	_sample["active_ball_peak"] = maxi(_sample["active_ball_peak"], int(metrics.get("active_balls", 0)))
	_sample["candidate_peak"] = maxi(_sample["candidate_peak"], int(metrics.get("candidate_count", 0)))
	_sample["grid_cell_peak"] = maxi(_sample["grid_cell_peak"], int(metrics.get("grid_cell_count", 0)))


func finish_stage(end_time: float, terminal_reason: StringName) -> void:
	_sample["end_time"] = end_time
	_sample["terminal_reason"] = terminal_reason


func get_sample() -> Dictionary:
	return _sample.duplicate(true)
