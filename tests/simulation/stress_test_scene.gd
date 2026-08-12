extends Node2D

const WARMUP_FRAMES := 30
const SAMPLE_FRAMES := 180
const FIXED_DELTA := 1.0 / 60.0
const SCENARIOS := [
	{"balls": 100, "merge": false},
	{"balls": 500, "merge": false},
	{"balls": 1000, "merge": false},
	{"balls": 1000, "merge": true},
]

@onready var simulation: BallSimulationManager = $BallSimulationManager
@onready var result_label: Label = $ResultLabel

var _scenario_index := -1
var _scenario_frame := 0
var _sample_elapsed := 0.0
var _sample_physics_usec := 0
var _minimum_fps := INF
var _candidate_total := 0
var _merge_total := 0
var _max_active := 0
var _memory_start := 0.0
var _bucket_capacity_start := 0
var _results: Array[Dictionary] = []
var _completed := false


func _ready() -> void:
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	_start_next_scenario()


func _process(delta: float) -> void:
	if _completed:
		return

	var physics_started := Time.get_ticks_usec()
	simulation.step_simulation(FIXED_DELTA)
	var physics_elapsed := Time.get_ticks_usec() - physics_started
	_scenario_frame += 1

	if _scenario_frame > WARMUP_FRAMES:
		var metrics := simulation.get_simulation_metrics()
		_sample_elapsed += delta
		_sample_physics_usec += physics_elapsed
		_minimum_fps = minf(_minimum_fps, 1.0 / maxf(delta, 0.000001))
		_candidate_total += metrics["candidate_count"]
		_merge_total += metrics["merges"]
		_max_active = maxi(_max_active, metrics["active_balls"])

	if _scenario_frame >= WARMUP_FRAMES + SAMPLE_FRAMES:
		_finish_scenario()
		_start_next_scenario()


func get_results() -> Array[Dictionary]:
	return _results.duplicate(true)


func is_completed() -> bool:
	return _completed


func _start_next_scenario() -> void:
	_scenario_index += 1
	if _scenario_index >= SCENARIOS.size():
		_completed = true
		_show_results()
		return

	var scenario: Dictionary = SCENARIOS[_scenario_index]
	simulation.reset_runtime()
	simulation.merge_enabled = scenario["merge"]
	simulation.cashout_enabled = false
	if scenario["merge"]:
		simulation.configure_stage_ball_levels(PackedInt32Array([10, 11, 12, 13, 14]))
	else:
		simulation.configure_stage_ball_levels(PackedInt32Array([0, 1, 2, 3, 4]))
	_spawn_stress_balls(scenario["balls"])
	_scenario_frame = 0
	_sample_elapsed = 0.0
	_sample_physics_usec = 0
	_minimum_fps = INF
	_candidate_total = 0
	_merge_total = 0
	_max_active = simulation.get_active_count()
	_memory_start = Performance.get_monitor(Performance.MEMORY_STATIC)
	_bucket_capacity_start = simulation.get_spatial_metrics()["grid_bucket_capacity"]
	result_label.text = "STRESS %d BALLS  MERGE %s\nWARMING UP..." % [scenario["balls"], "ON" if scenario["merge"] else "OFF"]


func _finish_scenario() -> void:
	var scenario: Dictionary = SCENARIOS[_scenario_index]
	var average_fps := SAMPLE_FRAMES / maxf(_sample_elapsed, 0.000001)
	var average_physics_ms := float(_sample_physics_usec) / float(SAMPLE_FRAMES) / 1000.0
	var metrics := simulation.get_simulation_metrics()
	_results.append({
		"balls": scenario["balls"],
		"merge_enabled": scenario["merge"],
		"average_fps": average_fps,
		"minimum_fps": _minimum_fps,
		"average_physics_ms": average_physics_ms,
		"average_candidate_checks": float(_candidate_total) / float(SAMPLE_FRAMES),
		"average_merges": float(_merge_total) / float(SAMPLE_FRAMES),
		"max_active_balls": _max_active,
		"memory_delta_bytes": Performance.get_monitor(Performance.MEMORY_STATIC) - _memory_start,
		"grid_bucket_growth": metrics["grid_bucket_capacity"] - _bucket_capacity_start,
	})


func _spawn_stress_balls(count: int) -> void:
	const COLUMNS := 40
	for index in range(count):
		var column := index % COLUMNS
		var row := index / COLUMNS
		var position := Vector2(520.0 + column * 14.0, 30.0 + row * 24.0)
		var direction := Vector2(-1.0 if index % 2 == 0 else 1.0, -1.0 if index % 3 == 0 else 1.0)
		var velocity := direction.normalized() * (20.0 + float(index % 7))
		var global_level := (13 if index % 5 == 0 else 14) if simulation.merge_enabled else index % 5
		simulation.spawn_ball(position, velocity, 4.0, global_level)


func _show_results() -> void:
	var lines := PackedStringArray(["S4-G3 STRESS COMPLETE"])
	for result in _results:
		lines.append("%4d MERGE %-3s  AVG %5.1f  MIN %5.1f  PHY %5.2fms  CAND %6.1f  MEM %+.0f" % [
			result["balls"],
			"ON" if result["merge_enabled"] else "OFF",
			result["average_fps"],
			result["minimum_fps"],
			result["average_physics_ms"],
			result["average_candidate_checks"],
			result["memory_delta_bytes"],
		])
	result_label.text = "\n".join(lines)
	print("S4_G3_RESULTS %s" % JSON.stringify(_results))
