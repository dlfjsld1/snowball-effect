class_name ItemFireCore
extends Node

## Content-owned runtime state for the Fire Core optional item.
##
## This component only owns the timed Fire window and its data-defined
## multiplier. It never changes ball flags, score ledgers, Time Bonus, or
## Settlement. Core/Integration must consume the read-only state through a
## separate narrow contract.

signal fire_window_changed(active: bool)
signal active_state_changed(read_only_snapshot: Dictionary)

const ITEM_TYPE := &"fire_core"

var _remaining_seconds := 0.0
var _duration_seconds := 0.0
var _cashout_multiplier := 1.0


func activate(definition: ItemDefinition) -> bool:
	if definition == null or definition.item_type != ITEM_TYPE:
		return false
	if definition.duration <= 0.0 or definition.magnitude < 1.0:
		return false
	var was_active := is_active()
	_duration_seconds = definition.duration
	_remaining_seconds = definition.duration
	_cashout_multiplier = definition.magnitude
	if not was_active:
		fire_window_changed.emit(true)
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
	_cashout_multiplier = 1.0
	fire_window_changed.emit(false)
	active_state_changed.emit(get_snapshot())


func reset_runtime() -> void:
	var was_active := is_active() or not is_equal_approx(_cashout_multiplier, 1.0)
	_remaining_seconds = 0.0
	_duration_seconds = 0.0
	_cashout_multiplier = 1.0
	if was_active:
		fire_window_changed.emit(false)
	active_state_changed.emit(get_snapshot())


func is_active() -> bool:
	return _remaining_seconds > 0.0


func get_cashout_multiplier() -> float:
	return _cashout_multiplier if is_active() else 1.0


func get_snapshot() -> Dictionary:
	return {
		"item_type": ITEM_TYPE,
		"active": is_active(),
		"remaining_seconds": _remaining_seconds,
		"duration_seconds": _duration_seconds,
		"cashout_multiplier": get_cashout_multiplier(),
	}
