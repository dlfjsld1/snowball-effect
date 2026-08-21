class_name ItemOrb
extends RefCounted

## A collected or missed Orb is terminal.  It does not activate an effect;
## S7-G1 owns the later CUT-IN and activation handoff.

var item_type: StringName = &""
var world_position := Vector2.ZERO
var velocity := Vector2.ZERO
var radius := 16.0
var resolved := false


func setup(type: StringName, position: Vector2, orb_radius: float, orb_speed: float) -> void:
	item_type = type
	world_position = position
	radius = orb_radius
	velocity = Vector2.DOWN * orb_speed
	resolved = false


func advance(delta: float) -> void:
	if not resolved and delta > 0.0:
		world_position += velocity * delta
