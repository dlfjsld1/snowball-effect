extends Node

const MAIN_SCENE = preload("res://scenes/main/main.tscn")
const ReleaseTelemetryRecorderScript = preload("res://tests/release/s9_g1_release_telemetry_recorder.gd")

var _stage_manager: StageManager
var _simulation: BallSimulationManager
var _recorder
var _has_active_stage := false
var _pending_terminal_reason: StringName = &""
var _pending_end_time := -1.0
var _run_number := 0
var _stage_run_time_start := 0.0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	_stage_manager = main.get_node("StageManager") as StageManager
	_simulation = main.get_node("PlayField/SimulationMount/BallSimulationManager") as BallSimulationManager
	_stage_manager.stage_changed.connect(_on_stage_changed)
	_stage_manager.stage_state_changed.connect(_on_stage_state_changed)
	_stage_manager.stage_run_ended.connect(_on_stage_run_ended)
	_simulation.cashout_completed.connect(_on_cashout_completed)
	_simulation.simulation_metrics_updated.connect(_on_simulation_metrics_updated)
	print("S9_G1_TELEMETRY_READY mode=observer result_ui=unchanged debug_clear=excluded")


func _on_stage_changed(definition: StageDefinition) -> void:
	if _has_active_stage:
		_emit_stage_sample()
	_run_number += 1 if definition.stage_index == 0 else 0
	_recorder = ReleaseTelemetryRecorderScript.new()
	_recorder.begin_stage(definition, _current_stage_time())
	_stage_run_time_start = _current_run_time()
	_pending_terminal_reason = &""
	_pending_end_time = -1.0
	_has_active_stage = true
	print("S9_G1_TELEMETRY_STAGE_STARTED run=%d stage=%s" % [_run_number, definition.display_name])


func _on_stage_state_changed(state: StringName) -> void:
	match state:
		StageManager.CLEAR_LOCKED:
			_pending_terminal_reason = &"SCORE_CLEAR"
			_capture_pending_end_time()
		StageManager.TIME_UP_LOCKED:
			_pending_terminal_reason = &"TIME_UP"
			_capture_pending_end_time()
		StageManager.FAILED:
			_pending_terminal_reason = &"FAILED"
			_capture_pending_end_time()
		StageManager.RUN_ENDED:
			if _pending_terminal_reason == &"":
				_pending_terminal_reason = &"RUN_ENDED"
			_capture_pending_end_time()
			_emit_stage_sample()
		StageManager.READY:
			if _has_active_stage:
				_pending_terminal_reason = &"MAIN_MENU"
				_emit_stage_sample()


func _on_stage_run_ended(_result_snapshot: Dictionary) -> void:
	if _pending_terminal_reason == &"":
		_pending_terminal_reason = &"RUN_ENDED"
	_emit_stage_sample()


func _on_cashout_completed(_score_amount: float, global_level: int, _world_position: Vector2) -> void:
	if _has_active_stage and not _recorder.record_cashout(global_level):
		push_error("S9-G1 telemetry rejected a Cashout global level outside the active Stage chain.")


func _on_simulation_metrics_updated(metrics: Dictionary) -> void:
	if _has_active_stage:
		_recorder.record_metrics(metrics)


func _emit_stage_sample() -> void:
	if not _has_active_stage:
		return
	var terminal_reason := _pending_terminal_reason if _pending_terminal_reason != &"" else &"INTERRUPTED"
	_recorder.set_playing_dwell(maxf(_current_run_time() - _stage_run_time_start, 0.0))
	var end_time := _pending_end_time if _pending_end_time >= 0.0 else _current_stage_time()
	_recorder.finish_stage(end_time, terminal_reason)
	print("S9_G1_TELEMETRY_SAMPLE " + JSON.stringify(_recorder.get_sample()))
	_has_active_stage = false


func _current_stage_time() -> float:
	if _stage_manager == null:
		return 0.0
	return float(_stage_manager.get_runtime_snapshot().get("stage_time_left", 0.0))


func _current_run_time() -> float:
	if _stage_manager == null:
		return 0.0
	return float(_stage_manager.get_runtime_snapshot().get("run_time_seconds", 0.0))


func _capture_pending_end_time() -> void:
	if _pending_end_time < 0.0:
		_pending_end_time = _current_stage_time()
