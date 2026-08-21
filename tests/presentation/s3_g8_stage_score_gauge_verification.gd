extends Node

const GaugeScript = preload("res://scripts/ui/stage_score_gauge.gd")

var _failures := 0


func _ready() -> void:
	var gauge: StageScoreGauge = GaugeScript.new()
	add_child(gauge)

	gauge.set_score_progress(0.0, 100.0)
	_expect(gauge.visible and gauge.get_filled_cell_count() == 0, "A fresh Stage must show no filled gauge cells.")

	gauge.set_score_progress(70.0, 100.0)
	_expect(gauge.visible and gauge.get_filled_cell_count() == 14, "70 percent must display exactly 14 of 20 cells.")
	_expect(is_equal_approx(gauge.get_progress(), 0.7), "Gauge progress must retain the score ratio.")

	gauge.set_score_progress(500.0, 100.0)
	_expect(gauge.get_filled_cell_count() == 20 and is_equal_approx(gauge.get_progress(), 1.0), "Score overflow must cap at all 20 cells.")

	gauge.set_score_progress(-10.0, 100.0)
	_expect(gauge.get_filled_cell_count() == 0 and is_equal_approx(gauge.get_progress(), 0.0), "Score decreases must clamp to an empty gauge.")

	gauge.set_score_progress(10.0, 0.0)
	_expect(not gauge.visible and gauge.get_filled_cell_count() == 0, "Galactic without a clear target must hide the gauge.")

	gauge.reset_gauge()
	_expect(gauge.visible and gauge.get_filled_cell_count() == 0, "HUD reset must restore an empty visible gauge.")

	if _failures == 0:
		print("S3_G8_VERIFIED cells=20 progress=70pct_14cells reset=true galactic_hidden=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G8 verification failed: %s" % message)
