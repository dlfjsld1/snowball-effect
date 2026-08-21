extends Node

const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")
const ReleaseTelemetryRecorderScript = preload("res://tests/release/s9_g1_release_telemetry_recorder.gd")

var _failures := 0


func _ready() -> void:
	var catalog = StageCatalogScript.new()
	var ground = catalog.get_stage(0)
	var planetary = catalog.get_stage(1)
	var recorder = ReleaseTelemetryRecorderScript.new()

	recorder.begin_stage(ground, 45.0)
	recorder.observe_state(&"PLAYING", 10.0)
	recorder.record_cashout(2)
	recorder.record_metrics({"active_balls": 120, "candidate_count": 44, "grid_cell_count": 36})
	recorder.observe_state(&"SHIFTING", 2.0)
	recorder.observe_state(&"PLAYING", 5.0)
	recorder.observe_state(&"PAUSED", 4.0)
	recorder.finish_stage(30.0, &"SCORE_CLEAR")

	var ground_sample := recorder.get_sample()
	_expect(is_equal_approx(ground_sample["playing_dwell_seconds"], 15.0), "Only PLAYING time may contribute to Stage dwell.")
	_expect(ground_sample["cashouts_total"] == 1, "Cashout total must record each observed Active Cashout once.")
	_expect(ground_sample["cashouts_by_local_level"] == [0, 0, 1, 0, 0], "Ground global Lv2 must map to local Lv2.")
	_expect(is_equal_approx(ground_sample["time_bonus_total_seconds"], 0.5), "Ground local Lv2 must use its data-defined 0.5 second Time Bonus.")
	_expect(ground_sample["active_ball_peak"] == 120 and ground_sample["candidate_peak"] == 44 and ground_sample["grid_cell_peak"] == 36, "Metric peaks must preserve the largest read-only simulation values.")
	_expect(ground_sample["terminal_reason"] == &"SCORE_CLEAR", "Terminal reason must remain observational data.")

	recorder.begin_stage(planetary, 40.0)
	recorder.observe_state(&"PLAYING", 3.0)
	recorder.record_cashout(8)
	recorder.finish_stage(38.0, &"TIME_UP")
	var planetary_sample := recorder.get_sample()
	_expect(planetary_sample["cashouts_by_local_level"] == [0, 0, 0, 1, 0], "Planetary global Lv8 must map to local Lv3, not its global ID.")
	_expect(is_equal_approx(planetary_sample["time_bonus_total_seconds"], 1.0), "Planetary local Lv3 must use its data-defined 1.0 second Time Bonus.")
	_expect(not recorder.record_cashout(7), "A global level outside the current Stage chain must be rejected as telemetry data corruption.")

	if _failures == 0:
		print("S9_G1_TELEMETRY_VERIFIED dwell_playing_only=true local_level_lookup=true metric_peaks=true no_fabricated_runtime_measurements=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S9-G1 telemetry verification failed: %s" % message)
