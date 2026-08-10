class_name ScoreFormatter
extends RefCounted

## Pure score-display formatting. Score ownership and arithmetic stay in Core.

const _SUFFIXES := ["", "K", "M", "B", "T"]


static func format_score(value: float) -> String:
	if is_nan(value):
		return "0"
	if is_inf(value):
		return "-∞" if value < 0.0 else "∞"

	var sign := "-" if value < 0.0 else ""
	var absolute_value := absf(value)
	if absolute_value < 1000.0:
		return sign + str(int(round(absolute_value)))

	var suffix_index := 0
	var scaled_value := absolute_value
	while scaled_value >= 1000.0 and suffix_index < _SUFFIXES.size() - 1:
		scaled_value /= 1000.0
		suffix_index += 1

	var decimal_places := _decimal_places_for(scaled_value)
	var rounded_value := _round_to_places(scaled_value, decimal_places)
	if rounded_value >= 1000.0:
		if suffix_index >= _SUFFIXES.size() - 1:
			return sign + "%.2e" % absolute_value
		scaled_value = rounded_value / 1000.0
		suffix_index += 1
		decimal_places = _decimal_places_for(scaled_value)
		rounded_value = _round_to_places(scaled_value, decimal_places)

	return sign + _format_decimal(rounded_value, decimal_places) + _SUFFIXES[suffix_index]


static func _decimal_places_for(value: float) -> int:
	if value >= 100.0:
		return 0
	if value >= 10.0:
		return 1
	return 2


static func _round_to_places(value: float, decimal_places: int) -> float:
	var multiplier := pow(10.0, decimal_places)
	return round(value * multiplier) / multiplier


static func _format_decimal(value: float, decimal_places: int) -> String:
	if decimal_places == 0:
		return str(int(value))
	var formatted := "%.1f" % value if decimal_places == 1 else "%.2f" % value
	return formatted.rstrip("0").rstrip(".")
