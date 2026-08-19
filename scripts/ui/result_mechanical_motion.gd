class_name ResultMechanicalMotion
extends Control

## Result-only decorative motion. It never writes gameplay state.

const DESIGN_SIZE := Vector2(1672.0, 941.0)
const LEFT_TUBE := Rect2(173.0, 302.0, 43.0, 145.0)
const RIGHT_TUBE := Rect2(1385.0, 302.0, 43.0, 145.0)
const LEFT_GAUGE_CENTER := Vector2(194.0, 493.0)
const RIGHT_GAUGE_CENTER := Vector2(1406.0, 493.0)

var _left_bubbles: Array[Dictionary] = []
var _right_bubbles: Array[Dictionary] = []
var _elapsed := 0.0
var _left_phase := 0.0
var _right_phase := 1.7
var _retry_button_face := PackedVector2Array([
	Vector2(466.0, 776.0), Vector2(772.0, 776.0),
	Vector2(784.0, 788.0), Vector2(784.0, 846.0),
	Vector2(772.0, 858.0), Vector2(466.0, 858.0),
	Vector2(454.0, 846.0), Vector2(454.0, 788.0),
])
var _main_button_face := PackedVector2Array([
	Vector2(906.0, 776.0), Vector2(1202.0, 776.0),
	Vector2(1214.0, 788.0), Vector2(1214.0, 846.0),
	Vector2(1202.0, 858.0), Vector2(906.0, 858.0),
	Vector2(894.0, 846.0), Vector2(894.0, 788.0),
])
var _retry_hovered := false
var _main_hovered := false
var _retry_held := false
var _main_held := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(_sync_processing)
	_left_bubbles = _make_bubbles(7, LEFT_TUBE, 0.0)
	_right_bubbles = _make_bubbles(8, RIGHT_TUBE, 0.43)
	_bind_button_feedback(get_node("../RetryButton") as Button, true)
	_bind_button_feedback(get_node("../MainButton") as Button, false)
	_sync_processing()


func _process(delta: float) -> void:
	_elapsed += delta
	_advance_bubbles(_left_bubbles, LEFT_TUBE, delta)
	_advance_bubbles(_right_bubbles, RIGHT_TUBE, delta)
	queue_redraw()


func _draw() -> void:
	var transform_scale := size / DESIGN_SIZE
	draw_set_transform(Vector2.ZERO, 0.0, transform_scale)
	_draw_bubbles(_left_bubbles)
	_draw_bubbles(_right_bubbles)
	_draw_full_gauge_needle(LEFT_GAUGE_CENTER, _left_gauge_angle())
	_draw_full_gauge_needle(RIGHT_GAUGE_CENTER, _right_gauge_angle())
	if _retry_hovered:
		_draw_pressed_face(_retry_button_face, _retry_held)
	if _main_hovered:
		_draw_pressed_face(_main_button_face, _main_held)


func _bind_button_feedback(button: Button, is_retry: bool) -> void:
	button.mouse_entered.connect(func() -> void:
		if is_retry:
			_retry_hovered = true
		else:
			_main_hovered = true
		queue_redraw()
	)
	button.mouse_exited.connect(func() -> void:
		if is_retry:
			_retry_hovered = false
			_retry_held = false
		else:
			_main_hovered = false
			_main_held = false
		queue_redraw()
	)
	button.button_down.connect(func() -> void:
		if is_retry:
			_retry_held = true
		else:
			_main_held = true
		queue_redraw()
	)
	button.button_up.connect(func() -> void:
		if is_retry:
			_retry_held = false
		else:
			_main_held = false
		queue_redraw()
	)


func _draw_pressed_face(points: PackedVector2Array, held: bool) -> void:
	var fill_alpha := 0.18 if held else 0.1
	draw_colored_polygon(points, Color(0.015, 0.055, 0.035, fill_alpha))


func _sync_processing() -> void:
	set_process(is_visible_in_tree())


func _make_bubbles(count: int, tube: Rect2, phase_offset: float) -> Array[Dictionary]:
	var bubbles: Array[Dictionary] = []
	for index in count:
		bubbles.append({
			"position": Vector2(
				tube.position.x + 8.0 + fmod(float(index) * 13.0, tube.size.x - 16.0),
				tube.end.y - fmod(float(index) * 29.0 + phase_offset * tube.size.y, tube.size.y)
			),
			"speed": 24.0 + float((index * 11) % 25),
			"radius": 2.0 + float(index % 3),
			"phase": phase_offset + float(index) * 0.83,
		})
	return bubbles


func _advance_bubbles(bubbles: Array[Dictionary], tube: Rect2, delta: float) -> void:
	for bubble in bubbles:
		var position: Vector2 = bubble["position"]
		position.y -= float(bubble["speed"]) * delta
		position.x += sin(_elapsed * 2.4 + float(bubble["phase"])) * 3.5 * delta
		if position.y < tube.position.y + 7.0:
			position.y = tube.end.y - 6.0
			position.x = randf_range(tube.position.x + 8.0, tube.end.x - 8.0)
		bubble["position"] = position


func _draw_bubbles(bubbles: Array[Dictionary]) -> void:
	for bubble in bubbles:
		var position: Vector2 = bubble["position"]
		var radius: float = bubble["radius"]
		draw_circle(position.floor(), radius + 1.0, Color(0.17, 0.38, 0.16, 0.8), false, 1.0, false)
		draw_circle(position.floor(), radius, Color(0.72, 0.95, 0.42, 0.75), false, 1.0, false)


func _left_gauge_angle() -> float:
	return -14.0 + sin(_elapsed * 7.1 + _left_phase) * 3.5 + sin(_elapsed * 2.3) * 1.7


func _right_gauge_angle() -> float:
	return -13.0 + sin(_elapsed * 6.4 + _right_phase) * 4.2 + sin(_elapsed * 1.9 + 0.7) * 1.4


func _draw_full_gauge_needle(center: Vector2, angle_degrees: float) -> void:
	var endpoint := center + Vector2.RIGHT.rotated(deg_to_rad(angle_degrees)) * 27.0
	draw_line(center, endpoint, Color("f6d27a"), 4.0, false)
	draw_circle(center, 4.0, Color("8e4d3c"), true, -1.0, false)
	draw_circle(center, 2.0, Color("f2c66e"), true, -1.0, false)
