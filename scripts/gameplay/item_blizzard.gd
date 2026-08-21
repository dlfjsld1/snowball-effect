class_name ItemBlizzard
extends Node

## Content-owned runtime state for the Blizzard optional item.
##
## This class never changes GameManager's spawn loop itself. Integration is
## expected to consume `spawn_multiplier_changed` through its narrow spawn
## command, so the optional effect cannot alter score, timer, or simulation.

signal spawn_multiplier_changed(multiplier: float)
signal active_state_changed(read_only_snapshot: Dictionary)

const ITEM_TYPE := &"blizzard"

var _remaining_seconds := 0.0
var _duration_seconds := 0.0
var _spawn_multiplier := 1.0


func activate(definition: ItemDefinition) -> bool:
	if definition == null or definition.item_type != ITEM_TYPE:
		return false
	if definition.duration <= 0.0 or definition.magnitude < 1.0:
		return false
	var was_active := is_active()
	_duration_seconds = definition.duration
	_remaining_seconds = definition.duration
	_spawn_multiplier = definition.magnitude
	if not was_active:
		spawn_multiplier_changed.emit(_spawn_multiplier)
	active_state_changed.emit(get_snapshot())
	return true


func advance(delta: float) -> void:
	if not is_active() or delta <= 0.0:
		return
	_remaining_seconds = maxf(0.0, _remaining_seconds - delta)
	if is_active():
		active_state_changed.emit(get_snapshot())
		return
	_duration_seconds = 0.0
	_spawn_multiplier = 1.0
	spawn_multiplier_changed.emit(1.0)
	active_state_changed.emit(get_snapshot())


func reset_runtime() -> void:
	var was_active := is_active() or not is_equal_approx(_spawn_multiplier, 1.0)
	_remaining_seconds = 0.0
	_duration_seconds = 0.0
	_spawn_multiplier = 1.0
	if was_active:
		spawn_multiplier_changed.emit(1.0)
	active_state_changed.emit(get_snapshot())


func is_active() -> bool:
	return _remaining_seconds > 0.0


func get_spawn_multiplier() -> float:
	return _spawn_multiplier if is_active() else 1.0


func get_snapshot() -> Dictionary:
	return {
		"item_type": ITEM_TYPE,
		"active": is_active(),
		"remaining_seconds": _remaining_seconds,
		"duration_seconds": _duration_seconds,
		"spawn_multiplier": get_spawn_multiplier(),
	}
