class_name BlackHolePhaseEffect
extends Control

const VIEWPORT_SIZE := Vector2(1600.0, 900.0)
const DEFAULT_INFLUENCE_RADIUS := 300.0
const BLACK_HOLE_TEXTURE: CanvasTexture = preload("res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres")
const CORE_COLOR := Color("02040b")
const HORIZON_COLOR := Color("74fff0")
const FIELD_COLOR := Color("35d8cf")
const TRAIL_COLOR := Color("7a42b8")
const EXPLOSION_COLOR := Color("d8fff7")

var _simulation_source: Node
var _phase_active := false
var _finale_active := false
var _reduced_effects := false
var _phase_progress := 0.0
var _finale_progress := 0.0
var _elapsed := 0.0
var _field_rect := Rect2(Vector2(360.0, 50.0), Vector2(880.0, 818.0))
var _origin_field_rect := Rect2()
var _positions := PackedVector2Array()
var _radii := PackedFloat32Array()
var _previous_positions := PackedVector2Array()
var _trail_directions := PackedVector2Array()
var _finale_snapshot: Dictionary = {}


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false
	set_process(false)


func set_simulation_source(source: Node) -> void:
	_simulation_source = source
	_refresh_snapshot()


func begin_phase(reduced_effects: bool) -> void:
	_phase_active = true
	_finale_active = false
	_reduced_effects = reduced_effects
	_phase_progress = 0.0
	_finale_progress = 0.0
	_elapsed = 0.0
	_finale_snapshot.clear()
	_origin_field_rect = Rect2()
	_previous_positions.clear()
	_trail_directions.clear()
	visible = true
	set_process(true)
	_refresh_snapshot()
	queue_redraw()


func set_phase_progress(progress: float, visual_field_rect: Rect2) -> void:
	_phase_progress = clampf(progress, 0.0, 1.0)
	_field_rect = visual_field_rect
	if _origin_field_rect.size.x <= 0.0 or _phase_progress <= 0.001:
		_origin_field_rect = visual_field_rect
	queue_redraw()


func complete_phase() -> void:
	_phase_progress = 1.0
	queue_redraw()


func begin_finale(result_snapshot: Dictionary, reduced_effects: bool) -> void:
	_phase_active = false
	_finale_active = true
	_reduced_effects = reduced_effects
	_finale_progress = 0.0
	_elapsed = 0.0
	_finale_snapshot = result_snapshot.duplicate(true)
	_load_finale_snapshot()
	visible = true
	set_process(true)
	queue_redraw()


func set_finale_progress(progress: float) -> void:
	_finale_progress = clampf(progress, 0.0, 1.0)
	queue_redraw()


func finish_finale() -> void:
	_finale_active = false
	visible = false
	set_process(false)
	queue_redraw()


func reset_effect() -> void:
	_phase_active = false
	_finale_active = false
	_phase_progress = 0.0
	_finale_progress = 0.0
	_elapsed = 0.0
	_positions.clear()
	_radii.clear()
	_previous_positions.clear()
	_trail_directions.clear()
	_finale_snapshot.clear()
	_origin_field_rect = Rect2()
	visible = false
	set_process(false)
	queue_redraw()


func get_visual_metrics() -> Dictionary:
	return {
		"visible": visible,
		"phase_active": _phase_active,
		"finale_active": _finale_active,
		"black_hole_count": _positions.size(),
		"core_count": _positions.size(),
		"horizon_ring_count": _positions.size(),
		"influence_ring_count": _positions.size() if _phase_active else 0,
		"trail_marker_count": 0 if _reduced_effects else _positions.size() * 4,
		"reduced_effects": _reduced_effects,
		"phase_progress": _phase_progress,
		"finale_progress": _finale_progress,
		"field_rect": _field_rect,
		"field_expansion_width": maxf(_field_rect.size.x - _origin_field_rect.size.x, 0.0),
		"black_hole_visual_resource": BLACK_HOLE_TEXTURE.resource_path,
	}


func get_black_hole_visual_texture() -> Texture2D:
	return BLACK_HOLE_TEXTURE


func get_black_hole_draw_texture() -> Texture2D:
	return BLACK_HOLE_TEXTURE.diffuse_texture


func _process(delta: float) -> void:
	_elapsed += delta
	if _phase_active:
		_refresh_snapshot()
	queue_redraw()


func _draw() -> void:
	if _finale_active:
		_draw_finale()
		return
	if not _phase_active:
		return

	_draw_field_expansion_fill()
	_draw_field_boundaries()
	for index in range(_positions.size()):
		_draw_gameplay_black_hole(index)


func _refresh_snapshot() -> void:
	if not is_instance_valid(_simulation_source) or not _simulation_source.has_method("get_black_hole_snapshot"):
		return
	var snapshot: Dictionary = _simulation_source.get_black_hole_snapshot()
	var next_positions: PackedVector2Array = snapshot.get("positions", PackedVector2Array())
	var next_radii: PackedFloat32Array = snapshot.get("radii", PackedFloat32Array())
	_update_motion_directions(next_positions)
	_positions = next_positions.duplicate()
	_radii = next_radii.duplicate()


func _update_motion_directions(next_positions: PackedVector2Array) -> void:
	while _previous_positions.size() < next_positions.size():
		_previous_positions.append(next_positions[_previous_positions.size()])
		_trail_directions.append(Vector2.LEFT)
	for index in range(next_positions.size()):
		var displacement := next_positions[index] - _previous_positions[index]
		if displacement.length_squared() > 0.0625:
			_trail_directions[index] = -displacement.normalized()
		_previous_positions[index] = next_positions[index]
	_previous_positions.resize(next_positions.size())
	_trail_directions.resize(next_positions.size())


func _load_finale_snapshot() -> void:
	_positions.clear()
	_radii.clear()
	var black_holes_value = _finale_snapshot.get("black_holes", [])
	if black_holes_value is not Array:
		return
	var black_holes: Array = black_holes_value
	for entry_value in black_holes:
		if entry_value is not Dictionary:
			continue
		var entry: Dictionary = entry_value
		_positions.append(entry.get("position", Vector2.ZERO))
		_radii.append(maxf(float(entry.get("radius", 16.0)), 1.0))


func _draw_gameplay_black_hole(index: int) -> void:
	var center := _positions[index]
	var gameplay_radius := _radii[index] if index < _radii.size() else 16.0
	var core_radius := maxf(gameplay_radius, 16.0)
	var horizon_radius := core_radius + 5.0
	var collapse_scale := lerpf(2.0, 1.0, _ease_out_cubic(minf(_phase_progress * 1.8, 1.0)))
	var horizon_alpha := lerpf(0.4, 1.0, minf(_phase_progress * 2.4, 1.0))

	_draw_dashed_ring(center, DEFAULT_INFLUENCE_RADIUS, FIELD_COLOR, 0.22 if not _reduced_effects else 0.38, 20, 0.22)
	_draw_near_field(center, horizon_radius)
	if not _reduced_effects:
		_draw_motion_trail(index, center, horizon_radius)

	_draw_void_cathedral(center, core_radius, horizon_alpha, collapse_scale)
	draw_arc(center, horizon_radius * collapse_scale + 5.0, -1.1 + _elapsed, 1.25 + _elapsed, 18, FIELD_COLOR * Color(1.0, 1.0, 1.0, 0.65), 2.0, false)
	_draw_orbit_pixels(center, horizon_radius + 9.0, index)


func _draw_void_cathedral(center: Vector2, core_radius: float, alpha: float, scale: float = 1.0) -> void:
	var matte_radius := (core_radius + 5.0) * scale
	var visual_radius := (core_radius + 8.0) * scale
	draw_circle(center, matte_radius, CORE_COLOR * Color(1.0, 1.0, 1.0, alpha))
	draw_texture_rect(
		BLACK_HOLE_TEXTURE.diffuse_texture,
		Rect2(center - Vector2.ONE * visual_radius, Vector2.ONE * visual_radius * 2.0),
		false,
		Color(1.0, 1.0, 1.0, alpha)
	)


func _draw_field_expansion_fill() -> void:
	if _origin_field_rect.size.x <= 0.0 or _phase_progress >= 1.0:
		return
	var backdrop_color := Color(0.09, 0.12, 0.18, 0.96)
	if _field_rect.position.x < _origin_field_rect.position.x:
		draw_rect(Rect2(
			Vector2(_field_rect.position.x, _field_rect.position.y),
			Vector2(_origin_field_rect.position.x - _field_rect.position.x, _field_rect.size.y)
		), backdrop_color)
	if _field_rect.end.x > _origin_field_rect.end.x:
		draw_rect(Rect2(
			Vector2(_origin_field_rect.end.x, _field_rect.position.y),
			Vector2(_field_rect.end.x - _origin_field_rect.end.x, _field_rect.size.y)
		), backdrop_color)


func _draw_field_boundaries() -> void:
	var alpha := 0.18 if not _reduced_effects else 0.52
	var left_x := _field_rect.position.x
	var right_x := _field_rect.end.x
	draw_line(Vector2(left_x, _field_rect.position.y), Vector2(left_x, _field_rect.end.y), FIELD_COLOR * Color(1.0, 1.0, 1.0, alpha), 2.0)
	draw_line(Vector2(right_x, _field_rect.position.y), Vector2(right_x, _field_rect.end.y), FIELD_COLOR * Color(1.0, 1.0, 1.0, alpha), 2.0)
	for y in [_field_rect.position.y + 16.0, _field_rect.end.y - 18.0]:
		draw_rect(Rect2(Vector2(left_x, y), Vector2(12.0, 4.0)), FIELD_COLOR * Color(1.0, 1.0, 1.0, alpha))
		draw_rect(Rect2(Vector2(right_x - 12.0, y), Vector2(12.0, 4.0)), FIELD_COLOR * Color(1.0, 1.0, 1.0, alpha))


func _draw_near_field(center: Vector2, horizon_radius: float) -> void:
	var rotation := _elapsed * (0.35 if _reduced_effects else 0.9)
	for band in range(2):
		var radius := horizon_radius + 12.0 + float(band) * 9.0
		var alpha := 0.32 - float(band) * 0.09
		draw_arc(center, radius, rotation + float(band) * 1.4, rotation + 2.2 + float(band) * 1.4, 16, TRAIL_COLOR * Color(1.0, 1.0, 1.0, alpha), 2.0, false)


func _draw_motion_trail(index: int, center: Vector2, horizon_radius: float) -> void:
	if index >= _trail_directions.size():
		return
	var direction := _trail_directions[index]
	for marker in range(4):
		var distance := horizon_radius + 11.0 + float(marker) * 8.0
		var marker_position := center + direction * distance
		var size := 5.0 if marker < 2 else 3.0
		var alpha := 0.65 - float(marker) * 0.12
		draw_rect(Rect2(marker_position - Vector2.ONE * size * 0.5, Vector2.ONE * size), TRAIL_COLOR * Color(1.0, 1.0, 1.0, alpha))


func _draw_orbit_pixels(center: Vector2, radius: float, seed: int) -> void:
	var count := 4 if _reduced_effects else 8
	for marker in range(count):
		var angle := _elapsed * (0.7 + float(seed) * 0.11) + TAU * float(marker) / float(count)
		var marker_position := center + Vector2.from_angle(angle) * (radius + float(marker % 2) * 5.0)
		var color := HORIZON_COLOR if marker % 2 == 0 else TRAIL_COLOR
		draw_rect(Rect2(marker_position - Vector2.ONE * 2.0, Vector2.ONE * 4.0), color * Color(1.0, 1.0, 1.0, 0.72))


func _draw_dashed_ring(center: Vector2, radius: float, color: Color, alpha: float, segment_count: int, fill_ratio: float) -> void:
	for segment in range(segment_count):
		var start := TAU * float(segment) / float(segment_count) + _elapsed * 0.08
		var finish := start + TAU / float(segment_count) * fill_ratio
		draw_arc(center, radius, start, finish, 3, color * Color(1.0, 1.0, 1.0, alpha), 2.0, false)


func _draw_finale() -> void:
	if _positions.size() < 2:
		return
	var contact_center: Vector2 = _finale_snapshot.get("contact_position", (_positions[0] + _positions[1]) * 0.5)
	var orbit_progress := clampf(_finale_progress / 0.64, 0.0, 1.0)
	var explosion_progress := clampf((_finale_progress - 0.58) / 0.42, 0.0, 1.0)
	var source_axis := _positions[0] - contact_center
	if source_axis.length_squared() < 1.0:
		source_axis = Vector2.RIGHT * 74.0
	var start_radius := maxf(source_axis.length(), 74.0)
	var orbit_radius := lerpf(start_radius, 7.0, orbit_progress * orbit_progress)
	var orbit_angle := source_axis.angle() + orbit_progress * TAU * (1.25 if _reduced_effects else 2.25)
	var first_center := contact_center + Vector2.from_angle(orbit_angle) * orbit_radius
	var second_center := contact_center - Vector2.from_angle(orbit_angle) * orbit_radius
	var core_alpha := 1.0 - explosion_progress

	if core_alpha > 0.01:
		_draw_finale_core(first_center, _radii[0], core_alpha, orbit_progress)
		_draw_finale_core(second_center, _radii[1], core_alpha, orbit_progress)
		draw_arc(contact_center, orbit_radius, 0.0, TAU, 36, TRAIL_COLOR * Color(1.0, 1.0, 1.0, 0.42 * core_alpha), 2.0, false)
	if explosion_progress > 0.0:
		_draw_pixel_explosion(contact_center, explosion_progress)


func _draw_finale_core(center: Vector2, radius: float, alpha: float, orbit_progress: float) -> void:
	var core_radius := maxf(radius, 16.0) * lerpf(1.0, 0.72, orbit_progress)
	_draw_void_cathedral(center, core_radius, alpha)


func _draw_pixel_explosion(center: Vector2, progress: float) -> void:
	var eased := _ease_out_cubic(progress)
	var flash_radius := lerpf(8.0, 150.0 if _reduced_effects else 260.0, eased)
	draw_arc(center, flash_radius, 0.0, TAU, 48, HORIZON_COLOR * Color(1.0, 1.0, 1.0, 1.0 - progress), 6.0, false)
	var ray_count := 16 if _reduced_effects else 28
	for ray in range(ray_count):
		var angle := TAU * float(ray) / float(ray_count)
		var distance := flash_radius * (0.38 + float((ray * 7) % 11) / 16.0)
		var pixel_position := center + Vector2.from_angle(angle) * distance
		var size := 8.0 if ray % 3 == 0 else 4.0
		var color := EXPLOSION_COLOR if ray % 2 == 0 else TRAIL_COLOR
		draw_rect(Rect2(pixel_position - Vector2.ONE * size * 0.5, Vector2.ONE * size), color * Color(1.0, 1.0, 1.0, 1.0 - progress * 0.72))


func _ease_out_cubic(value: float) -> float:
	var inverse := 1.0 - clampf(value, 0.0, 1.0)
	return 1.0 - inverse * inverse * inverse
