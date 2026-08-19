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
			return sign + _format_scientific(absolute_value)
		scaled_value = rounded_value / 1000.0
		suffix_index += 1
		decimal_places = _decimal_places_for(scaled_value)
		rounded_value = _round_to_places(scaled_value, decimal_places)

	return sign + _format_decimal(rounded_value, decimal_places) + _SUFFIXES[suffix_index]


## Result-terminal formatting. Values beyond reliable integer precision are
## expanded from the same three-significant-digit scientific representation
## used by the compact formatter, avoiding meaningless float noise digits.
static func format_score_full(value: float) -> String:
	if is_nan(value):
		return "0"
	if is_inf(value):
		return "-∞" if value < 0.0 else "∞"

	var sign := "-" if value < 0.0 else ""
	var absolute_value := absf(value)
	var integer_text: String
	if absolute_value < 1.0e15:
		integer_text = str(int(round(absolute_value)))
	else:
		integer_text = _expand_scientific_integer(_format_scientific(absolute_value))
	return sign + _add_group_separators(integer_text)


static func _format_scientific(value: float) -> String:
	var exponent := int(floor(log(value) / log(10.0)))
	var mantissa := value / pow(10.0, exponent)
	while mantissa >= 10.0:
		mantissa /= 10.0
		exponent += 1
	while mantissa < 1.0:
		mantissa *= 10.0
		exponent -= 1

	var rounded_mantissa := _round_to_places(mantissa, 2)
	if rounded_mantissa >= 10.0:
		rounded_mantissa = 1.0
		exponent += 1

	return _format_fixed_two_decimals(rounded_mantissa) + "e" + ("+" if exponent >= 0 else "") + str(exponent)


static func _expand_scientific_integer(scientific: String) -> String:
	var exponent_marker := scientific.find("e")
	if exponent_marker == -1:
		return scientific
	var mantissa := scientific.substr(0, exponent_marker)
	var exponent := int(scientific.substr(exponent_marker + 1))
	var decimal_marker := mantissa.find(".")
	var fractional_digits := 0
	if decimal_marker != -1:
		fractional_digits = mantissa.length() - decimal_marker - 1
		mantissa = mantissa.replace(".", "")
	var trailing_zero_count := maxi(exponent - fractional_digits, 0)
	return mantissa + "0".repeat(trailing_zero_count)


static func _add_group_separators(integer_text: String) -> String:
	var grouped := ""
	var first_group_size := integer_text.length() % 3
	if first_group_size == 0:
		first_group_size = 3
	grouped = integer_text.substr(0, first_group_size)
	var cursor := first_group_size
	while cursor < integer_text.length():
		grouped += "," + integer_text.substr(cursor, 3)
		cursor += 3
	return grouped


static func _format_fixed_two_decimals(value: float) -> String:
	var formatted := String.num(value, 2)
	var decimal_index := formatted.find(".")
	if decimal_index == -1:
		return formatted + ".00"
	if formatted.length() - decimal_index == 2:
		return formatted + "0"
	return formatted


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
	var formatted := String.num(value, decimal_places)
	return formatted.rstrip("0").rstrip(".")
