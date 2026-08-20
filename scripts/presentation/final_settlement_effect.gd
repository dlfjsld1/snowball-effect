class_name FinalSettlementEffect
extends Node2D

signal finished

const MAX_VISUAL_SAMPLES := 64
const PIXELS_PER_SAMPLE := 4

@export_range(0.1, 1.0, 0.01) var duration := 0.5

var _elapsed := 0.0
var _finished := false
var _target := Vector2.ZERO
var _positions := PackedVector2Array()
var _radii := PackedFloat32Array()
var _colors := PackedColorArray()


func setup(snapshot: Dictionary, target_position: Vector2, colors: PackedColorArray = PackedColorArray()) -> void:
	_target = target_position
	var source_positions: PackedVector2Array = snapshot.get("positions", PackedVector2Array())
	var source_radii: PackedFloat32Array = snapshot.get("radii", PackedFloat32Array())
	var source_count := mini(int(snapshot.get("count", source_positions.size())), source_positions.size())
	var sample_count := mini(source_count, MAX_VISUAL_SAMPLES)
	_positions.resize(sample_count)
	_radii.resize(sample_count)
	_colors.resize(sample_count)
	for sample_index in range(sample_count):
		var source_index := int(floor(float(sample_index) * float(source_count) / maxf(float(sample_count), 1.0)))
		_positions[sample_index] = source_positions[source_index]
		_radii[sample_index] = source_radii[source_index] if source_index < source_radii.size() else 4.0
		_colors[sample_index] = colors[source_index] if source_index < colors.size() else Color("b6cf8e")
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()
	if _elapsed >= duration and not _finished:
		_finished = true
		finished.emit()
		queue_free()


func _draw() -> void:
	var overall := clampf(_elapsed / maxf(duration, 0.001), 0.0, 1.0)
	for sample_index in range(_positions.size()):
		var stagger := (float(sample_index % 8) / 7.0) * 0.12
		var progress := clampf((overall - stagger) / 0.88, 0.0, 1.0)
		var eased := 1.0 - pow(1.0 - progress, 3.0)
		var center := _positions[sample_index].lerp(_target, eased)
		var source_size := clampf(_radii[sample_index] * 0.18, 2.0, 6.0)
		var pixel_size := maxf(2.0, source_size * (1.0 - progress * 0.55))
		var spread := lerpf(maxf(_radii[sample_index] * 0.32, 4.0), 1.0, progress)
		var color := _colors[sample_index].lerp(Color("f6e79c"), progress * 0.65)
		color.a = 1.0 - smoothstep(0.82, 1.0, progress)
		for pixel_index in range(PIXELS_PER_SAMPLE):
			var angle := TAU * float(pixel_index) / float(PIXELS_PER_SAMPLE) + float(sample_index % 3) * 0.35
			var pixel_position := center + Vector2.from_angle(angle) * spread
			draw_rect(Rect2(pixel_position - Vector2.ONE * pixel_size * 0.5, Vector2.ONE * pixel_size), color)


func get_visual_sample_count() -> int:
	return _positions.size()


func get_progress() -> float:
	return clampf(_elapsed / maxf(duration, 0.001), 0.0, 1.0)
