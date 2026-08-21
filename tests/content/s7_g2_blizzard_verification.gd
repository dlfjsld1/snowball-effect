extends Node

const BlizzardScript = preload("res://scripts/gameplay/item_blizzard.gd")
const BlizzardDefinition = preload("res://resources/items/item_blizzard.tres")
const FireDefinition = preload("res://resources/items/item_fire_core.tres")

var _failures := 0
var _multipliers: Array[float] = []


func _ready() -> void:
	var blizzard = BlizzardScript.new()
	add_child(blizzard)
	blizzard.spawn_multiplier_changed.connect(func(multiplier: float): _multipliers.append(multiplier))

	_expect(not blizzard.activate(FireDefinition), "Non-Blizzard definitions must not activate Blizzard.")
	_expect(_multipliers.is_empty() and not blizzard.is_active(), "Rejected activation must not change runtime state.")
	_expect(blizzard.activate(BlizzardDefinition), "Blizzard must accept its ItemDefinition.")
	_expect(blizzard.is_active() and is_equal_approx(blizzard.get_spawn_multiplier(), 3.0), "Blizzard must apply the configured x3 spawn multiplier.")
	_expect(_multipliers == [3.0], "First activation must request x3 exactly once.")

	blizzard.advance(4.9)
	_expect(blizzard.is_active() and is_equal_approx(blizzard.get_snapshot()["remaining_seconds"], 0.1), "Blizzard must remain active before its 5-second duration ends.")
	blizzard.activate(BlizzardDefinition)
	_expect(_multipliers == [3.0], "Refresh must not multiply or reapply an already active Blizzard.")
	blizzard.advance(4.99)
	_expect(blizzard.is_active(), "Refresh must restore the full configured duration.")
	blizzard.advance(0.01)
	_expect(not blizzard.is_active() and is_equal_approx(blizzard.get_spawn_multiplier(), 1.0), "Expiry must restore the normal spawn multiplier.")
	_expect(_multipliers == [3.0, 1.0], "Expiry must restore normal spawning exactly once.")

	blizzard.reset_runtime()
	_expect(_multipliers == [3.0, 1.0], "Reset after expiry must not issue a duplicate restore command.")
	blizzard.activate(BlizzardDefinition)
	blizzard.reset_runtime()
	_expect(_multipliers == [3.0, 1.0, 3.0, 1.0], "Reset during Blizzard must restore normal spawning exactly once.")

	if _failures == 0:
		print("S7_G2_IMPLEMENTED duration=5 spawn_multiplier=3 refresh=non_stacking restore=once")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G2 verification failed: %s" % message)
