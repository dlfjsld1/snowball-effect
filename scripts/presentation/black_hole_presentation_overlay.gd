class_name BlackHolePresentationOverlay
extends Control

signal finale_visual_finished

var _mode: StringName = &"idle"
var _elapsed := 0.0
var _duration := 1.0
var _contact_position := Vector2(800.0, 450.0)
var _black_hole_positions: Array[Vector2] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false


func begin_phase() -> void:
	_mode = &"phase"
	_elapsed = 0.0
	_duration = 1.0
	visible = true
	queue_redraw()


func hold_phase() -> void:
	if _mode == &"phase":
		_mode = &"phase_hold"
		queue_redraw()


func begin_finale(result_snapshot: Dictionary, duration: float) -> void:
	_mode = &"finale"
	_elapsed = 0.0
	_duration = maxf(duration, 0.05)
	_contact_position = result_snapshot.get("contact_position", Vector2(800.0, 450.0))
	_black_hole_positions.clear()
	var raw_black_holes = result_snapshot.get("black_holes", [])
	if raw_black_holes is Array:
		for black_hole in raw_black_holes:
			if black_hole is Dictionary and black_hole.get("position", null) is Vector2:
				_black_hole_positions.append(black_hole["position"])
	while _black_hole_positions.size() < 2:
		var direction := -1.0 if _black_hole_positions.is_empty() else 1.0
		_black_hole_positions.append(_contact_position + Vector2(80.0 * direction, 0.0))
	visible = true
	queue_redraw()


func reset_overlay() -> void:
	_mode = &"idle"
	_elapsed = 0.0
	_black_hole_positions.clear()
	visible = false
	queue_redraw()


func is_finale_active() -> bool:
	return _mode == &"finale"


func _process(delta: float) -> void:
	if _mode == &"idle":
		return
	_elapsed += delta
	queue_redraw()
	if _mode == &"finale" and _elapsed >= _duration:
		_mode = &"idle"
		visible = false
		finale_visual_finished.emit()


func _draw() -> void:
	if _mode == &"idle":
		return
	if _mode == &"phase" or _mode == &"phase_hold":
		_draw_phase_overlay()
		return
	_draw_finale_overlay()


func _draw_phase_overlay() -> void:
	var pulse := 0.5 + sin(_elapsed * 8.0) * 0.5
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.03, 0.01, 0.12, 0.17 + pulse * 0.10))
	var center := size * 0.5
	for ring_index in range(4):
		var radius := 80.0 + ring_index * 42.0 + pulse * 10.0
		var color := Color(0.32, 0.84, 0.88, 0.34 - ring_index * 0.055)
		draw_arc(center, radius, _elapsed * (1.4 + ring_index * 0.25), TAU + _elapsed * (1.4 + ring_index * 0.25), 48, color, 2.0)
	draw_circle(center, 54.0 + pulse * 6.0, Color(0.01, 0.0, 0.04, 0.88))
	draw_arc(center, 61.0, -_elapsed * 3.0, TAU - _elapsed * 3.0, 48, Color(0.96, 0.72, 0.30, 0.75), 3.0)


func _draw_finale_overlay() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var center := _contact_position
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.015, 0.0, 0.04, 0.38 + progress * 0.42))
	for index in range(_black_hole_positions.size()):
		var source := _black_hole_positions[index]
		var orbit_angle := progress * TAU * 2.5 + float(index) * PI
		var orbit_radius := lerpf(source.distance_to(center), 10.0, progress)
		var position := center + Vector2.from_angle(orbit_angle) * orbit_radius
		draw_line(source, position, Color(0.42, 0.88, 1.0, 0.25), 3.0)
		draw_circle(position, lerpf(34.0, 8.0, progress), Color(0.0, 0.0, 0.015, 0.96))
		draw_arc(position, lerpf(42.0, 12.0, progress), orbit_angle, orbit_angle + TAU * 0.78, 32, Color(0.95, 0.68, 0.25, 0.85), 3.0)
	var burst := sin(progress * PI)
	if burst > 0.0:
		draw_circle(center, 30.0 + burst * 190.0, Color(0.55, 0.94, 1.0, burst * 0.18))
		draw_arc(center, 56.0 + burst * 230.0, 0.0, TAU, 64, Color(1.0, 0.82, 0.38, burst), 5.0)
