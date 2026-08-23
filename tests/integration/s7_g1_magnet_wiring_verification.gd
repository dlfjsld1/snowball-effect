extends Node

const MAGNET_DURATION := 7.0

@onready var game_manager: GameManager = $Main/GameManager
@onready var gateway: ItemEffectGateway = $Main/ItemEffectGateway
@onready var magnet: ItemMagnet = $Main/ItemMagnet
@onready var simulation: BallSimulationManager = $Main/PlayField/SimulationMount/BallSimulationManager

var _cutin_requests := 0
var _activation_requests := 0
var _failures := 0


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	game_manager.item_cutin_requested.connect(_on_item_cutin_requested)
	game_manager.item_effect_activation_requested.connect(_on_item_effect_activation_requested)

	var event_id := gateway.queue_item_collected(&"magnet", Vector2(800.0, 400.0))
	_expect(event_id > 0 and _cutin_requests == 1, "Magnet Orb collection must request one CUT-IN before activation.")
	_expect(not magnet.is_active() and not simulation.get_magnet_force_metrics()["active"], "Collection alone must not enable Magnet force.")
	await get_tree().process_frame
	var active_metrics := simulation.get_magnet_force_metrics()
	_expect(_activation_requests == 1, "Magnet without a CUT-IN producer must use the gateway fallback exactly once.")
	_expect(magnet.is_active() and active_metrics["active"], "Gateway activation must relay the Magnet command to Core.")
	_expect(is_equal_approx(active_metrics["influence_radius"], 96.0) and is_equal_approx(active_metrics["max_pair_acceleration"], 120.0), "The Core command must preserve Magnet tuning data.")
	_expect(active_metrics["neighbor_limit"] == 2, "The Core command must preserve the two-neighbour bound.")
	_expect(not gateway.accept_cutin_activation_cue(event_id), "The fallback activation must reject a later duplicate cue.")

	magnet.advance(MAGNET_DURATION)
	_expect(not magnet.is_active() and not simulation.get_magnet_force_metrics()["active"], "Magnet expiry must clear the Core force command.")

	game_manager._start_run()
	_expect(not magnet.is_active() and not simulation.get_magnet_force_metrics()["active"], "Retry/fresh run must reset Magnet runtime and Core command.")

	if _failures == 0:
		print("S7_G1_MAGNET_WIRING_VERIFIED cue_then_fallback=true command=true duration=7 reset=clean")
	get_tree().quit(_failures)


func _on_item_cutin_requested(_event_id: int, _item_type: StringName, _world_position: Vector2) -> void:
	_cutin_requests += 1


func _on_item_effect_activation_requested(_event_id: int, _item_type: StringName, _world_position: Vector2) -> void:
	_activation_requests += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G1 Magnet wiring verification failed: %s" % message)
