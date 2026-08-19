class_name MergeEffect
extends Node2D

@export var lifetime := 0.32

@onready var value_label: Label = $ValueLabel

var _elapsed := 0.0
var _color := Color.WHITE
var _fx_tier := 0


func setup(world_position: Vector2, display_name: String, base_color: Color, fx_tier: int) -> void:
	position = world_position
	_color = base_color
	_fx_tier = fx_tier
	value_label.text = display_name.to_upper()
	value_label.modulate = base_color
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / lifetime, 0.0, 1.0)
	position.y -= 24.0 * delta
	modulate.a = 1.0 - progress
	queue_redraw()
	if progress >= 1.0:
		queue_free()


func _draw() -> void:
	var progress := clampf(_elapsed / lifetime, 0.0, 1.0)
	var radius := 10.0 + float(_fx_tier * 4) + progress * 24.0
	var particle_size := 2.0 + float(_fx_tier)
	for index in range(8):
		var direction := Vector2.RIGHT.rotated(TAU * float(index) / 8.0)
		var particle_position := direction * radius
		draw_rect(Rect2(particle_position - Vector2.ONE * particle_size * 0.5, Vector2.ONE * particle_size), _color)
	draw_arc(Vector2.ZERO, radius * 0.65, 0.0, TAU, 20, _color, 1.0)
