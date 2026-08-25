extends Node

const ITEM_TYPES := [&"blizzard", &"fire_core", &"magnet"]

@onready var game_manager: GameManager = $Main/GameManager
@onready var stage_manager: StageManager = $Main/StageManager
@onready var item_manager: ItemManager = $Main/ItemManager
@onready var item_visual: ItemBlizzardVisual = $Main/PlayField/ItemBlizzardVisual
@onready var blizzard: ItemBlizzard = $Main/ItemBlizzard
@onready var fire_core: ItemFireCore = $Main/ItemFireCore
@onready var magnet: ItemMagnet = $Main/ItemMagnet
@onready var simulation: BallSimulationManager = $Main/PlayField/SimulationMount/BallSimulationManager

var _failures := 0


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	for index in ITEM_TYPES.size():
		await _verify_item_orb(ITEM_TYPES[index], index + 1)
	for index in ITEM_TYPES.size():
		await _verify_missed_item_orb(ITEM_TYPES[index], index + 101)
	if _failures == 0:
		print("S7_G1_THREE_ITEM_ORBS_LIVE_VERIFIED types=blizzard/fire_core/magnet hits=5 visible=true falling=true collect=true miss_cleanup=true activation=matching")
	get_tree().quit(_failures)


func _verify_item_orb(item_type: StringName, seed_offset: int) -> void:
	game_manager._start_run()
	await get_tree().process_frame
	var stage: StageDefinition = stage_manager.get_current_stage()
	item_manager.enter_stage(
		stage,
		simulation.play_field_rect,
		simulation.get_runtime_radius_for_level(stage.local_ball_levels[2]),
		0.0,
		item_type,
		7100 + seed_offset
	)
	item_manager.advance(0.01)
	var planet := item_manager.get_item_ball_snapshot()
	_expect(planet.get("item_type", &"") == item_type, "%s Item Ball must be selected by the verification seam." % item_type)
	for hit_id in range(1, 6):
		item_manager.process_ball_snapshots([{
			"id": hit_id,
			"global_level": stage.local_ball_levels[2],
			"position": planet.get("position", Vector2.ZERO),
			"radius": 16.0,
		}])
		item_manager.process_ball_snapshots([])
	var orb := item_manager.get_item_orb_snapshot()
	var visual := item_visual.get_visual_snapshot()
	_expect(orb.get("item_type", &"") == item_type, "%s fifth hit must create the matching data Orb." % item_type)
	_expect(visual.get("orb_visible", false) and visual.get("orb_type", &"") == item_type, "%s data Orb must have a matching visible world Orb." % item_type)
	var initial_y := float(visual.get("orb_position", Vector2.ZERO).y)
	item_manager.advance(0.1)
	item_visual._physics_process(0.1)
	_expect(float(item_visual.get_visual_snapshot().get("orb_position", Vector2.ZERO).y) > initial_y, "%s visible Orb must move downward with its producer." % item_type)
	var moved_orb := item_manager.get_item_orb_snapshot()
	_expect(item_manager.try_collect_orb(moved_orb.get("position", Vector2.ZERO), 0.0), "%s Orb must collect through the producer API." % item_type)
	_expect(not item_visual.get_visual_snapshot().get("orb_visible", true), "%s collect signal must remove the visible Orb." % item_type)
	# The visible item CUT-IN emits its activation cue after the enter phase.
	# Wait real runtime time instead of assuming a fixed number of frames.
	await get_tree().create_timer(0.5).timeout
	_expect(_matching_effect_is_active(item_type), "%s collection must activate only its matching effect." % item_type)


func _matching_effect_is_active(item_type: StringName) -> bool:
	if item_type == &"blizzard":
		return blizzard.is_active() and not fire_core.is_active() and not magnet.is_active()
	if item_type == &"fire_core":
		return not blizzard.is_active() and fire_core.is_active() and not magnet.is_active()
	return not blizzard.is_active() and not fire_core.is_active() and magnet.is_active()


func _verify_missed_item_orb(item_type: StringName, seed_offset: int) -> void:
	game_manager._start_run()
	await get_tree().process_frame
	var stage: StageDefinition = stage_manager.get_current_stage()
	item_manager.enter_stage(
		stage,
		simulation.play_field_rect,
		simulation.get_runtime_radius_for_level(stage.local_ball_levels[2]),
		0.0,
		item_type,
		7100 + seed_offset
	)
	item_manager.advance(0.01)
	var planet := item_manager.get_item_ball_snapshot()
	for hit_id in range(21, 26):
		item_manager.process_ball_snapshots([{
			"id": hit_id,
			"global_level": stage.local_ball_levels[2],
			"position": planet.get("position", Vector2.ZERO),
			"radius": 16.0,
		}])
		item_manager.process_ball_snapshots([])
	_expect(item_visual.get_visual_snapshot().get("orb_visible", false), "%s miss fixture must begin with a visible Orb." % item_type)
	item_manager.advance(4.0)
	_expect(item_manager.get_item_orb_snapshot().is_empty(), "%s Orb must resolve after crossing the open bottom." % item_type)
	_expect(not item_visual.get_visual_snapshot().get("orb_visible", true), "%s miss signal must remove the visible Orb." % item_type)
	_expect(not blizzard.is_active() and not fire_core.is_active() and not magnet.is_active(), "%s missed Orb must not activate any item effect." % item_type)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G1V three Item Orb live verification failed: %s" % message)
