class_name ItemEffectGateway
extends Node

## Integration boundary between the Item Ball/Orb producer and future item
## effects.  Collection only requests a CUT-IN; an explicit cue or skip is the
## sole path that can commit one effect request.

signal item_cutin_requested(event_id: int, item_type: StringName, world_position: Vector2)
signal item_effect_activation_requested(event_id: int, item_type: StringName, world_position: Vector2)

var _next_event_id := 1
var _pending_events: Dictionary = {}
var _activated_event_ids: Dictionary = {}


func queue_item_collected(item_type: StringName, world_position: Vector2) -> int:
	if item_type == &"":
		return -1
	var event_id := _next_event_id
	_next_event_id += 1
	_pending_events[event_id] = {
		"item_type": item_type,
		"world_position": world_position,
	}
	item_cutin_requested.emit(event_id, item_type, world_position)
	return event_id


func accept_cutin_activation_cue(event_id: int) -> bool:
	return _commit_activation(event_id)


func skip_cutin(event_id: int) -> bool:
	return _commit_activation(event_id)


func reset_runtime() -> void:
	_pending_events.clear()
	_activated_event_ids.clear()


func get_pending_event_snapshot(event_id: int) -> Dictionary:
	if not _pending_events.has(event_id):
		return {}
	return (_pending_events[event_id] as Dictionary).duplicate(true)


func _commit_activation(event_id: int) -> bool:
	if event_id < 0 or _activated_event_ids.has(event_id) or not _pending_events.has(event_id):
		return false
	var event: Dictionary = _pending_events[event_id]
	_pending_events.erase(event_id)
	_activated_event_ids[event_id] = true
	item_effect_activation_requested.emit(event_id, event["item_type"], event["world_position"])
	return true
