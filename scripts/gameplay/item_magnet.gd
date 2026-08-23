class_name ItemMagnet
extends Node

## Content-owned runtime command for the Magnet optional item.
##
## This class deliberately does not inspect balls or apply forces. The Core
## consumer owns the spatial-grid query and applies this bounded command to at
## most `neighbor_limit` same-level neighbours per ball. Keeping the command
## here makes duration/tuning/reset data-owned while preserving the simulation
## loop and its no-O(N²) contract.

signal force_command_changed(read_only_command: Dictionary)
signal active_state_changed(read_only_snapshot: Dictionary)

const ITEM_TYPE := &"magnet"

var _remaining_seconds := 0.0
var _duration_seconds := 0.0
var _influence_radius := 0.0
var _max_pair_acceleration := 0.0
var _neighbor_limit := 1


func activate(definition: ItemDefinition) -> bool:
	if definition == null or definition.item_type != ITEM_TYPE:
		return false
	if definition.duration <= 0.0 \
		or definition.magnet_influence_radius <= 0.0 \
		or definition.magnet_max_pair_acceleration <= 0.0 \
		or definition.magnet_neighbor_limit < 1 \
		or definition.magnet_neighbor_limit > 2:
		return false
	_duration_seconds = definition.duration
	_remaining_seconds = definition.duration
	_influence_radius = definition.magnet_influence_radius
	_max_pair_acceleration = definition.magnet_max_pair_acceleration
	_neighbor_limit = definition.magnet_neighbor_limit
	_emit_current_state()
	return true


func advance(delta: float) -> void:
	if not is_active() or delta <= 0.0:
		return
	_remaining_seconds = maxf(0.0, _remaining_seconds - delta)
	if is_active():
		active_state_changed.emit(get_snapshot())
		return
	_clear_command()


func reset_runtime() -> void:
	if not is_active() and is_zero_approx(_influence_radius) and is_zero_approx(_max_pair_acceleration):
		return
	_remaining_seconds = 0.0
	_duration_seconds = 0.0
	_clear_command()


func is_active() -> bool:
	return _remaining_seconds > 0.0


func get_force_command() -> Dictionary:
	return {
		"item_type": ITEM_TYPE,
		"active": is_active(),
		"influence_radius": _influence_radius if is_active() else 0.0,
		"max_pair_acceleration": _max_pair_acceleration if is_active() else 0.0,
		"neighbor_limit": _neighbor_limit if is_active() else 0,
	}


func get_snapshot() -> Dictionary:
	var snapshot := get_force_command()
	snapshot["remaining_seconds"] = _remaining_seconds
	snapshot["duration_seconds"] = _duration_seconds
	return snapshot


func _clear_command() -> void:
	_influence_radius = 0.0
	_max_pair_acceleration = 0.0
	_neighbor_limit = 1
	force_command_changed.emit(get_force_command())
	active_state_changed.emit(get_snapshot())


func _emit_current_state() -> void:
	force_command_changed.emit(get_force_command())
	active_state_changed.emit(get_snapshot())
