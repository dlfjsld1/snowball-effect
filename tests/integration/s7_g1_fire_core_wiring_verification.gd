extends Node

const FIRE_DURATION := 8.0

@onready var main: Node = $Main
@onready var game_manager: GameManager = $Main/GameManager
@onready var gateway: ItemEffectGateway = $Main/ItemEffectGateway
@onready var fire_core: ItemFireCore = $Main/ItemFireCore
@onready var paddle: Paddle = $Main/PlayField/PaddleMount/Paddle

var _cutin_requests := 0
var _activation_requests := 0
var _failures := 0


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	game_manager.item_cutin_requested.connect(_on_item_cutin_requested)
	game_manager.item_effect_activation_requested.connect(_on_item_effect_activation_requested)

	var event_id := gateway.queue_item_collected(&"fire_core", Vector2(800.0, 400.0))
	_expect(event_id > 0 and _cutin_requests == 1, "Fire Orb collection must request one CUT-IN before activation.")
	_expect(not fire_core.is_active() and not paddle.is_fire_contact_active(), "Collection alone must not open the Fire Paddle window.")
	await get_tree().process_frame
	_expect(_activation_requests == 1, "Fire without a CUT-IN producer must use the gateway fallback exactly once.")
	_expect(fire_core.is_active() and paddle.is_fire_contact_active(), "Fire activation must open both the Fire state and Paddle contact window.")
	_expect(is_equal_approx(fire_core.get_cashout_multiplier(), 10.0), "Fire runtime state must retain the definition's x10 multiplier.")
	_expect(not gateway.accept_cutin_activation_cue(event_id), "The fallback activation must reject a later duplicate cue.")

	fire_core.advance(FIRE_DURATION)
	_expect(not fire_core.is_active() and not paddle.is_fire_contact_active(), "Fire expiry must close the Paddle contact window.")

	game_manager._start_run()
	_expect(not fire_core.is_active() and not paddle.is_fire_contact_active(), "Retry/fresh run must reset Fire runtime and Paddle state.")

	if _failures == 0:
		print("S7_G1_FIRE_WIRING_VERIFIED cue_then_fallback=true fire_window=true duration=8 reset=clean")
	get_tree().quit(_failures)


func _on_item_cutin_requested(_event_id: int, _item_type: StringName, _world_position: Vector2) -> void:
	_cutin_requests += 1


func _on_item_effect_activation_requested(_event_id: int, _item_type: StringName, _world_position: Vector2) -> void:
	_activation_requests += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G1 Fire Core wiring verification failed: %s" % message)
