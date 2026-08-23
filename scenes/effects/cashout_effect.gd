class_name CashoutEffect
extends Node2D

const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")

const OUTLINE_COLOR := Color("1f244b")
const POSITION_PADDING := 8.0
const VALUE_GAP := 8.0
const DRIFT_SPEED := 18.0
const LOCAL_LEVEL_FONT_SIZES := [18, 19, 20, 21, 22]
const LOCAL_LEVEL_FONT_COLORS := [
	Color("f4f5e8"),
	Color("c9f3f5"),
	Color("f6e79c"),
	Color("48ddec"),
	Color("ffc857"),
]
const LOCAL_LEVEL_OUTLINE_SIZES := [3, 3, 3, 4, 4]
const LOCAL_LEVEL_SHADOW_OFFSETS := [2, 2, 2, 2, 3]

@export_range(0.05, 5.0, 0.01) var lifetime := 0.38

@onready var value_label: Label = $ValueLabel

var _elapsed := 0.0
var _local_level := 0
var _motion_position := Vector2.ZERO
var _popup_bounds := Rect2()
var _reduced_effects := false


func setup(
	world_position: Vector2,
	_display_name: String,
	score_value: float,
	_base_color: Color,
	local_level: int,
	popup_bounds := Rect2(),
	reduced_effects := false
) -> void:
	_elapsed = 0.0
	modulate = Color.WHITE
	_local_level = _normalize_local_level(local_level)
	_popup_bounds = popup_bounds if popup_bounds.has_area() else get_viewport_rect()
	_reduced_effects = reduced_effects
	value_label.text = ScoreFormatter.format_score_full(score_value).replace(",", "")
	value_label.modulate = Color.WHITE
	_apply_local_level_style()
	_resize_value_label()
	_motion_position = _clamp_initial_position(world_position.round())
	position = _motion_position
	queue_redraw()


func set_reduced_effects(enabled: bool) -> void:
	_reduced_effects = enabled
	queue_redraw()


func is_reduced_effects() -> bool:
	return _reduced_effects


func get_value_rect() -> Rect2:
	return Rect2(position + value_label.position, value_label.size)


func get_visual_profile() -> Dictionary:
	return {
		"text": value_label.text,
		"local_level": _local_level,
		"font_size": value_label.get_theme_font_size("font_size"),
		"font_color": value_label.get_theme_color("font_color"),
		"outline_color": value_label.get_theme_color("font_outline_color"),
		"outline_size": value_label.get_theme_constant("outline_size"),
		"shadow_offset": Vector2i(
			value_label.get_theme_constant("shadow_offset_x"),
			value_label.get_theme_constant("shadow_offset_y")
		),
		"lifetime": lifetime,
		"reduced_effects": _reduced_effects,
		"value_rect": get_value_rect(),
	}


func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / maxf(lifetime, 0.001), 0.0, 1.0)
	_motion_position.y += DRIFT_SPEED * delta
	position = _motion_position.round()
	modulate.a = 1.0 - progress
	queue_redraw()
	if progress >= 1.0:
		queue_free()


func _draw() -> void:
	if _reduced_effects:
		return
	var progress := clampf(_elapsed / maxf(lifetime, 0.001), 0.0, 1.0)
	var spread := 8.0 + float(_local_level * 3) + progress * 18.0
	var particle_size := roundf(2.0 + float(_local_level))
	for index in range(6):
		var horizontal := roundf((float(index) - 2.5) * spread * 0.28)
		var particle_position := Vector2(horizontal, roundf(progress * spread))
		draw_rect(
			Rect2(
				(particle_position - Vector2.ONE * particle_size * 0.5).round(),
				Vector2.ONE * particle_size
			),
			LOCAL_LEVEL_FONT_COLORS[_local_level]
		)


func _apply_local_level_style() -> void:
	value_label.add_theme_font_size_override("font_size", LOCAL_LEVEL_FONT_SIZES[_local_level])
	value_label.add_theme_color_override("font_color", LOCAL_LEVEL_FONT_COLORS[_local_level])
	value_label.add_theme_color_override("font_outline_color", OUTLINE_COLOR)
	value_label.add_theme_color_override("font_shadow_color", OUTLINE_COLOR)
	value_label.add_theme_constant_override("outline_size", LOCAL_LEVEL_OUTLINE_SIZES[_local_level])
	var shadow_offset: int = LOCAL_LEVEL_SHADOW_OFFSETS[_local_level]
	value_label.add_theme_constant_override("shadow_offset_x", shadow_offset)
	value_label.add_theme_constant_override("shadow_offset_y", shadow_offset)


func _resize_value_label() -> void:
	var font := value_label.get_theme_font("font")
	var font_size := value_label.get_theme_font_size("font_size")
	var measured_size := font.get_string_size(value_label.text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var label_size := Vector2(ceilf(measured_size.x), ceilf(font.get_height(font_size)))
	value_label.size = label_size
	value_label.position = Vector2(-floorf(label_size.x * 0.5), -label_size.y - VALUE_GAP)


func _clamp_initial_position(requested_position: Vector2) -> Vector2:
	var inner_bounds := _popup_bounds.grow(-POSITION_PADDING)
	if not inner_bounds.has_area():
		inner_bounds = _popup_bounds
	var label_start := value_label.position
	var label_end := value_label.position + value_label.size
	var maximum_drift := ceilf(DRIFT_SPEED * lifetime)
	var minimum_x := inner_bounds.position.x - label_start.x
	var maximum_x := inner_bounds.end.x - label_end.x
	var minimum_y := inner_bounds.position.y - label_start.y
	var maximum_y := inner_bounds.end.y - label_end.y - maximum_drift
	return Vector2(
		_clamp_axis(requested_position.x, minimum_x, maximum_x),
		_clamp_axis(requested_position.y, minimum_y, maximum_y)
	).round()


func _clamp_axis(value: float, minimum_value: float, maximum_value: float) -> float:
	if minimum_value <= maximum_value:
		return clampf(value, ceilf(minimum_value), floorf(maximum_value))
	return roundf((minimum_value + maximum_value) * 0.5)


func _normalize_local_level(local_level: int) -> int:
	return local_level if local_level >= 0 and local_level < LOCAL_LEVEL_FONT_SIZES.size() else 0
