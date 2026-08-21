class_name ItemBall
extends RefCounted

## Runtime state for the optional Item Ball.  It deliberately is not a
## simulation ball and never participates in Merge, Cashout, or Settlement.

var item_type: StringName = &""
var world_position := Vector2.ZERO
var radius := 24.0
var required_break_hits := 5
var current_hits := 0
var is_broken := false
var _contacting_ball_ids: Dictionary = {}


func setup(definition, position: Vector2) -> void:
	item_type = definition.item_type
	world_position = position
	radius = definition.planet_radius
	required_break_hits = definition.required_break_hits
	current_hits = 0
	is_broken = false
	_contacting_ball_ids.clear()


func register_valid_contact(ball_id: int) -> bool:
	if is_broken or _contacting_ball_ids.has(ball_id):
		return false
	_contacting_ball_ids[ball_id] = true
	current_hits += 1
	if current_hits >= required_break_hits:
		is_broken = true
	return true


func release_absent_contacts(overlapping_ball_ids: Dictionary) -> void:
	for ball_id in _contacting_ball_ids.keys():
		if not overlapping_ball_ids.has(ball_id):
			_contacting_ball_ids.erase(ball_id)
