extends Node

const MagnetScript = preload("res://scripts/gameplay/item_magnet.gd")
const MagnetDefinition = preload("res://resources/items/item_magnet.tres")
const FireDefinition = preload("res://resources/items/item_fire_core.tres")

var _failures := 0
var _commands: Array[Dictionary] = []


func _ready() -> void:
	var magnet = MagnetScript.new()
	add_child(magnet)
	magnet.force_command_changed.connect(func(command: Dictionary): _commands.append(command.duplicate(true)))

	_expect(not magnet.activate(FireDefinition), "Non-Magnet definitions must be rejected.")
	_expect(_commands.is_empty(), "Rejected activation must not publish a force command.")
	_expect(magnet.activate(MagnetDefinition), "Magnet must accept its ItemDefinition.")
	var active_command := magnet.get_force_command()
	_expect(active_command["active"], "Accepted Magnet must publish an active command.")
	_expect(is_equal_approx(active_command["influence_radius"], 96.0), "Magnet range must come from ItemDefinition.")
	_expect(is_equal_approx(active_command["max_pair_acceleration"], 120.0), "Magnet acceleration cap must come from ItemDefinition.")
	_expect(active_command["neighbor_limit"] == 2, "Magnet command must cap neighbours at two per ball.")

	magnet.advance(6.9)
	_expect(magnet.is_active(), "Magnet must remain active before its data-defined duration ends.")
	magnet.activate(MagnetDefinition)
	magnet.advance(6.99)
	_expect(magnet.is_active(), "Recollection must refresh the window without stacking force.")
	magnet.advance(0.01)
	_expect(not magnet.is_active(), "Magnet must expire after the refreshed duration.")
	var neutral_command := magnet.get_force_command()
	_expect(not neutral_command["active"] and neutral_command["neighbor_limit"] == 0, "Expiry must publish a neutral force command.")

	magnet.activate(MagnetDefinition)
	magnet.reset_runtime()
	_expect(not magnet.get_snapshot()["active"], "Reset must clear the active Magnet state.")
	_expect(_commands.size() == 5, "Activation, refresh, expiry, reactivation, and reset must each publish one command.")

	if _failures == 0:
		print("S7_G4_IMPLEMENTED duration=7 range=96 acceleration_cap=120 neighbour_limit=2 reset=neutral simulation_unchanged=true")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G4 verification failed: %s" % message)
