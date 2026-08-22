extends Node

const FireCoreScript = preload("res://scripts/gameplay/item_fire_core.gd")
const FireDefinition = preload("res://resources/items/item_fire_core.tres")
const BlizzardDefinition = preload("res://resources/items/item_blizzard.tres")

var _failures := 0
var _window_events: Array[bool] = []


func _ready() -> void:
	var fire_core = FireCoreScript.new()
	add_child(fire_core)
	fire_core.fire_window_changed.connect(func(active: bool): _window_events.append(active))

	_expect(not fire_core.activate(BlizzardDefinition), "Non-Fire definitions must not activate Fire Core.")
	_expect(not fire_core.is_active() and _window_events.is_empty(), "Rejected activation must not change Fire state.")
	_expect(fire_core.activate(FireDefinition), "Fire Core must accept its ItemDefinition.")
	_expect(fire_core.is_active(), "Accepted Fire Core must become active.")
	_expect(is_equal_approx(fire_core.get_cashout_multiplier(), 10.0), "Fire Core must expose the configured x10 multiplier while active.")
	_expect(_window_events == [true], "First activation must open the Fire window exactly once.")

	fire_core.advance(7.9)
	_expect(fire_core.is_active(), "Fire Core must remain active before its 8-second duration ends.")
	_expect(is_equal_approx(fire_core.get_snapshot()["remaining_seconds"], 0.1), "Remaining Fire duration must decrease from data-defined time.")
	fire_core.activate(FireDefinition)
	_expect(_window_events == [true], "Refresh must not reopen an already active Fire window.")
	fire_core.advance(7.99)
	_expect(fire_core.is_active(), "Refresh must restore the full configured duration.")
	fire_core.advance(0.01)
	_expect(not fire_core.is_active() and is_equal_approx(fire_core.get_cashout_multiplier(), 1.0), "Expiry must restore the neutral multiplier.")
	_expect(_window_events == [true, false], "Expiry must close the Fire window exactly once.")

	fire_core.reset_runtime()
	_expect(_window_events == [true, false], "Reset after expiry must not duplicate the close event.")
	fire_core.activate(FireDefinition)
	fire_core.reset_runtime()
	_expect(_window_events == [true, false, true, false], "Reset during Fire must close the window exactly once.")
	_expect(not fire_core.get_snapshot()["active"], "Reset snapshot must report inactive state.")

	if _failures == 0:
		print("S7_G3_IMPLEMENTED duration=8 cashout_multiplier=10 refresh=non_stacking reset=once core_unchanged=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G3 verification failed: %s" % message)
