extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const StageCatalogScript := preload("res://scripts/data/stage_catalog.gd")

var _failures := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var gateway: ItemEffectGateway = main.get_node("ItemEffectGateway")
	var blizzard: Node = main.get_node("ItemBlizzard")
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	game_manager._on_start_requested()

	_expect(_spawn_snapshot_matches(game_manager, 6.0, 1.0, 6.0), "Ground must begin at its base spawn rate.")
	var ignored_event := gateway.queue_item_collected(&"magnet", Vector2.ZERO)
	_expect(game_manager.skip_item_cutin(ignored_event), "Gateway must still commit non-Blizzard items once.")
	_expect(_spawn_snapshot_matches(game_manager, 6.0, 1.0, 6.0), "Non-Blizzard activation must not change spawn rate.")

	var event_id := gateway.queue_item_collected(&"blizzard", Vector2.ZERO)
	_expect(game_manager.skip_item_cutin(event_id), "Matching Blizzard skip fallback must commit once.")
	_expect(blizzard.is_active() and _spawn_snapshot_matches(game_manager, 6.0, 3.0, 18.0), "Blizzard activation must apply exactly x3 to Ground spawning.")
	var before_spawn := simulation.get_active_count()
	game_manager._physics_process(1.0 / 6.0)
	_expect(simulation.get_active_count() == before_spawn + 3, "Spawn loop must consume the effective x3 rate.")

	game_manager._on_stage_changed(StageCatalogScript.new().get_stage(1))
	_expect(_spawn_snapshot_matches(game_manager, 15.0, 3.0, 45.0), "Stage base-rate change must preserve active Blizzard multiplier.")
	blizzard.advance(5.0)
	_expect(not blizzard.is_active() and _spawn_snapshot_matches(game_manager, 15.0, 1.0, 15.0), "Blizzard expiry must restore the current Stage base rate once.")

	var retry_event := gateway.queue_item_collected(&"blizzard", Vector2.ZERO)
	_expect(game_manager.skip_item_cutin(retry_event), "Second Blizzard activation must commit once.")
	game_manager._on_retry_requested()
	_expect(_spawn_snapshot_matches(game_manager, 6.0, 1.0, 6.0), "Retry must reset Blizzard and restore Ground base spawning.")
	game_manager._on_main_menu_requested()
	_expect(_spawn_snapshot_matches(game_manager, 6.0, 1.0, 6.0), "Main reset must leave no stale Blizzard multiplier.")

	if _failures == 0:
		print("S7_G1_BLIZZARD_WIRING_VERIFIED activation=once spawn_x3=true stage_rebase=true expiry_retry_main_reset=true")
	get_tree().quit(_failures)


func _spawn_snapshot_matches(game_manager: GameManager, base_rate: float, multiplier: float, effective_rate: float) -> bool:
	var snapshot := game_manager.get_runtime_snapshot()
	return is_equal_approx(float(snapshot["base_stage_spawn_rate"]), base_rate) \
		and is_equal_approx(float(snapshot["spawn_rate_multiplier"]), multiplier) \
		and is_equal_approx(float(snapshot["effective_spawn_rate"]), effective_rate)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G1 Blizzard wiring verification failed: %s" % message)
