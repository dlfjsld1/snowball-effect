class_name MergeEffect
extends Node2D

const PHASE_INWARD: StringName = &"INWARD"
const PHASE_CORE: StringName = &"CORE"
const PHASE_RESOLVE: StringName = &"RESOLVE"
const PHASE_FINISHED: StringName = &"FINISHED"

const NORMAL_LIFETIME := 0.32
const REDUCED_LIFETIME := 0.18
const INWARD_END := 0.10
const CORE_END := 0.17
const REDUCED_CORE_END := 0.07

const PHOSPHOR_WHITE := Color("f4f5e8")
const ICE_WHITE := Color("c9f3f5")
const MERGE_PINK := Color("ff5b9f")
const PIXEL_SIZE := 2.0

var lifetime := NORMAL_LIFETIME

var _elapsed := 0.0
var _local_level := 0
var _reduced_effects := false
var _accent_color := ICE_WHITE


func setup(world_position: Vector2, base_color: Color, local_level: int, reduced_effects := false) -> void:
	position = world_position.round()
	_local_level = clampi(local_level, 0, 4)
	_accent_color = base_color.lerp(PHOSPHOR_WHITE, 0.30)
	set_reduced_effects(reduced_effects)
	queue_redraw()


func set_reduced_effects(enabled: bool) -> void:
	_reduced_effects = enabled
	lifetime = REDUCED_LIFETIME if enabled else NORMAL_LIFETIME
	queue_redraw()


func get_phase() -> StringName:
	return get_phase_at(_elapsed)


func get_phase_at(elapsed: float) -> StringName:
	if elapsed >= lifetime:
		return PHASE_FINISHED
	if _reduced_effects:
		return PHASE_CORE if elapsed < REDUCED_CORE_END else PHASE_RESOLVE
	if elapsed < INWARD_END:
		return PHASE_INWARD
	if elapsed < CORE_END:
		return PHASE_CORE
	return PHASE_RESOLVE


func get_inward_distance_at(elapsed: float) -> float:
	var progress := clampf(elapsed / INWARD_END, 0.0, 1.0)
	return lerpf(_get_trail_reach(), 3.0, progress)


func get_visual_profile() -> Dictionary:
	return {
		"local_level": _local_level,
		"lifetime": lifetime,
		"reduced_effects": _reduced_effects,
		"trail_count": 0 if _reduced_effects else 2,
		"trail_segments": 0 if _reduced_effects else _get_trail_segment_count(),
		"ring_count": 1,
		"ring_max_radius": _get_ring_max_radius(),
		"ring_segments": _get_ring_segment_count(),
		"resolve_pixels": 0 if _reduced_effects else _get_resolve_pixel_count(),
		"camera_shake": false,
		"text_nodes": 0,
	}


func _process(delta: float) -> void:
	_elapsed = minf(_elapsed + delta, lifetime)
	queue_redraw()
	if _elapsed >= lifetime:
		set_process(false)
		queue_free()


func _draw() -> void:
	match get_phase():
		PHASE_INWARD:
			_draw_inward_trails(clampf(_elapsed / INWARD_END, 0.0, 1.0))
		PHASE_CORE:
			var core_start := 0.0 if _reduced_effects else INWARD_END
			var core_end := REDUCED_CORE_END if _reduced_effects else CORE_END
			_draw_core_flash(inverse_lerp(core_start, core_end, _elapsed))
		PHASE_RESOLVE:
			var resolve_start := REDUCED_CORE_END if _reduced_effects else CORE_END
			_draw_resolve(inverse_lerp(resolve_start, lifetime, _elapsed))


func _draw_inward_trails(progress: float) -> void:
	var remaining := 1.0 - progress
	var head_distance := get_inward_distance_at(_elapsed)
	var segment_count := _get_trail_segment_count()
	var trail_color := MERGE_PINK.lerp(_accent_color, 0.35)
	for side_value in [-1.0, 1.0]:
		var side: float = side_value
		for segment in range(segment_count):
			var trail_offset := float(segment) * 4.0 * remaining
			var x: float = side * (head_distance + trail_offset)
			var curve_sign: float = -side
			var y: float = curve_sign * roundf((2.0 + float(segment * 2)) * remaining)
			_draw_pixel(Vector2(x, y), trail_color)


func _draw_core_flash(progress: float) -> void:
	var pulse := 1.0 - absf(clampf(progress, 0.0, 1.0) * 2.0 - 1.0)
	var half_size := 2.0 + roundf(pulse * (1.0 + float(_local_level) * 0.5))
	var core_size := snappedf(half_size * 2.0, PIXEL_SIZE)
	draw_rect(Rect2(Vector2.ONE * -core_size * 0.5, Vector2.ONE * core_size), PHOSPHOR_WHITE)
	_draw_pixel(Vector2(-core_size * 0.5 - PIXEL_SIZE, 0.0), ICE_WHITE)
	_draw_pixel(Vector2(core_size * 0.5 + PIXEL_SIZE, 0.0), ICE_WHITE)


func _draw_resolve(progress: float) -> void:
	progress = clampf(progress, 0.0, 1.0)
	var opacity := 1.0 - progress
	var radius := lerpf(4.0, _get_ring_max_radius(), sqrt(progress))
	var ring_color := ICE_WHITE.lerp(_accent_color, 0.22)
	ring_color.a = opacity
	_draw_pixel_ring(radius, ring_color)
	if _reduced_effects:
		return
	var pixel_color := _accent_color
	pixel_color.a = opacity
	var pixel_count := _get_resolve_pixel_count()
	for index in range(pixel_count):
		var angle := TAU * (float(index) + 0.25) / float(pixel_count)
		var start_radius := _get_ring_max_radius() * (0.48 + 0.06 * float(index % 2))
		var pixel_radius := lerpf(start_radius, 2.0, progress)
		_draw_pixel(Vector2.RIGHT.rotated(angle) * pixel_radius, pixel_color)


func _draw_pixel_ring(radius: float, color: Color) -> void:
	var segment_count := _get_ring_segment_count()
	for index in range(segment_count):
		var direction := Vector2.RIGHT.rotated(TAU * float(index) / float(segment_count))
		var pixel_position := (direction * radius / PIXEL_SIZE).round() * PIXEL_SIZE
		_draw_pixel(pixel_position, color)


func _draw_pixel(center: Vector2, color: Color) -> void:
	var snapped_center := (center / PIXEL_SIZE).round() * PIXEL_SIZE
	draw_rect(Rect2(snapped_center - Vector2.ONE * PIXEL_SIZE * 0.5, Vector2.ONE * PIXEL_SIZE), color)


func _get_trail_reach() -> float:
	return 12.0 + float(_local_level * 2)


func _get_trail_segment_count() -> int:
	return 3 + (1 if _local_level >= 3 else 0)


func _get_ring_max_radius() -> float:
	var result_radius := 4.0 * pow(2.0, float(_local_level))
	return result_radius + 10.0 + float(_local_level * 2)


func _get_ring_segment_count() -> int:
	return 20 + _local_level * 6


func _get_resolve_pixel_count() -> int:
	return 2 + _local_level
