class_name CashoutEffect
extends Node2D

const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")

@export_range(0.05, 5.0, 0.01) var lifetime := 0.38

@onready var value_label: Label = $ValueLabel

var _elapsed := 0.0
var _color := Color.WHITE
var _fx_tier := 0


func setup(world_position: Vector2, display_name: String, score_value: float, base_color: Color, fx_tier: int) -> void:
	position = world_position
	_color = base_color
	_fx_tier = fx_tier
	value_label.text = "%s CASHOUT  +%s" % [display_name.to_upper(), ScoreFormatter.format_score(score_value)]
	value_label.modulate = base_color
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / maxf(lifetime, 0.001), 0.0, 1.0)
	position.y += 18.0 * delta
	modulate.a = 1.0 - progress
	queue_redraw()
	if progress >= 1.0:
		queue_free()


func _draw() -> void:
	var progress := clampf(_elapsed / maxf(lifetime, 0.001), 0.0, 1.0)
	var spread := 8.0 + float(_fx_tier * 3) + progress * 18.0
	var particle_size := 2.0 + float(_fx_tier)
	for index in range(6):
		var horizontal := (float(index) - 2.5) * spread * 0.28
		var particle_position := Vector2(horizontal, progress * spread)
		draw_rect(
			Rect2(particle_position - Vector2.ONE * particle_size * 0.5, Vector2.ONE * particle_size),
			_color
		)
