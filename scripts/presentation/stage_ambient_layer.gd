class_name StageAmbientLayer
extends Node2D

const VIEWPORT_SIZE := Vector2(1600.0, 900.0)
const GROUND: StringName = &"ground"
const PLANETARY: StringName = &"planetary"
const GALACTIC: StringName = &"galactic"

var stage_id: StringName = GROUND
var _positions := PackedVector2Array()
var _speeds := PackedFloat32Array()
var _phases := PackedFloat32Array()
var _time := 0.0


func _ready() -> void:
	configure(stage_id)


func configure(value: StringName) -> void:
	stage_id = value if value in [GROUND, PLANETARY, GALACTIC] else GROUND
	_time = 0.0
	_positions.clear()
	_speeds.clear()
	_phases.clear()

	var count := 48 if stage_id == GROUND else (28 if stage_id == PLANETARY else 44)
	var random := RandomNumberGenerator.new()
	random.seed = 4107 + int(stage_id == PLANETARY) * 101 + int(stage_id == GALACTIC) * 211
	for _index in range(count):
		_positions.append(Vector2(random.randf_range(0.0, VIEWPORT_SIZE.x), random.randf_range(0.0, VIEWPORT_SIZE.y)))
		_speeds.append(random.randf_range(18.0, 44.0))
		_phases.append(random.randf_range(0.0, TAU))
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if stage_id == GROUND:
		for index in range(_positions.size()):
			var position := _positions[index]
			position += Vector2(_speeds[index] * 0.16, _speeds[index]) * delta
			if position.y > VIEWPORT_SIZE.y:
				position.y = -4.0
			if position.x > VIEWPORT_SIZE.x:
				position.x = 0.0
			_positions[index] = position
	queue_redraw()


func _draw() -> void:
	if stage_id == GROUND:
		_draw_snow()
	else:
		_draw_twinkles()


func _draw_snow() -> void:
	for index in range(_positions.size()):
		var size := 2.0 if index % 4 != 0 else 4.0
		var color := Color("98d8b1") if index % 3 != 0 else Color("ecf2cb")
		draw_rect(Rect2(_positions[index], Vector2(size, size)), color)


func _draw_twinkles() -> void:
	for index in range(_positions.size()):
		var pulse := 0.35 + 0.65 * (sin(_time * (1.2 + float(index % 5) * 0.17) + _phases[index]) * 0.5 + 0.5)
		var size := 2.0 if pulse < 0.72 else 4.0
		var color := Color("d8d5ff") if stage_id == GALACTIC else Color("dcdcdc")
		if stage_id == GALACTIC and index % 3 == 0:
			color = Color("5fd0c4")
		color.a = pulse
		draw_rect(Rect2(_positions[index], Vector2(size, size)), color)
