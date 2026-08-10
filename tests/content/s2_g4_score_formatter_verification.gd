extends Node

const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")

var _failures := 0


func _ready() -> void:
	_expect_format(0.0, "0")
	_expect_format(999.0, "999")
	_expect_format(1000.0, "1K")
	_expect_format(1234.0, "1.23K")
	_expect_format(999999.0, "1M")
	_expect_format(12500000.0, "12.5M")
	_expect_format(50000000000.0, "50B")
	_expect_format(10000000000000.0, "10T")
	_expect_format(999999999999999.0, "1.00e+15")
	_expect_format(1.0e36, "1.00e+36")
	_expect_format(-1234.0, "-1.23K")
	_expect_format(NAN, "0")
	_expect_format(INF, "∞")
	_expect_format(-INF, "-∞")

	if _failures == 0:
		print("S2_G4_VERIFIED boundaries=14 suffixes=KMBT scientific=1e36")
	get_tree().quit(_failures)


func _expect_format(value: float, expected: String) -> void:
	_expect(ScoreFormatter.format_score(value) == expected, "Expected %s for %s, got %s." % [expected, value, ScoreFormatter.format_score(value)])


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S2-G4 verification failed: %s" % message)
