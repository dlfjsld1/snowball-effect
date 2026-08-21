extends Node

const ItemEffectGatewayScript = preload("res://scripts/core/item_effect_gateway.gd")

var _cutin_requests := 0
var _activation_requests := 0


func _ready() -> void:
	var gateway = ItemEffectGatewayScript.new()
	add_child(gateway)
	gateway.item_cutin_requested.connect(func(_event_id, _item_type, _position): _cutin_requests += 1)
	gateway.item_effect_activation_requested.connect(func(_event_id, _item_type, _position): _activation_requests += 1)

	var collected_event := gateway.queue_item_collected(&"fire_core", Vector2(100.0, 200.0))
	_expect(collected_event > 0 and _cutin_requests == 1, "Collection must request exactly one CUT-IN.")
	_expect(_activation_requests == 0, "Collection alone must not activate an effect.")
	_expect(not gateway.accept_cutin_activation_cue(collected_event + 100), "Unknown cue must be rejected.")
	_expect(gateway.accept_cutin_activation_cue(collected_event), "Matching CUT-IN cue must activate once.")
	_expect(_activation_requests == 1, "Matching cue must emit one activation request.")
	_expect(not gateway.skip_cutin(collected_event), "Duplicate cue or skip must not activate twice.")

	var skipped_event := gateway.queue_item_collected(&"blizzard", Vector2(300.0, 400.0))
	_expect(gateway.skip_cutin(skipped_event), "Explicit CUT-IN skip must use the safe one-time activation path.")
	_expect(_activation_requests == 2, "Skipped CUT-IN must still activate exactly once.")

	gateway.reset_runtime()
	var reset_event := gateway.queue_item_collected(&"magnet", Vector2(500.0, 600.0))
	_expect(not gateway.accept_cutin_activation_cue(skipped_event), "Reset must reject stale CUT-IN cues.")
	_expect(gateway.accept_cutin_activation_cue(reset_event), "Current post-reset cue must still activate.")
	if _activation_requests == 3:
		print("S7_G1_GATEWAY_VERIFIED collection=cue_only activation=once skip_fallback=once reset_stale_rejected=true")
		get_tree().quit(0)
	get_tree().quit(1)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	push_error(message)
	get_tree().quit(1)
