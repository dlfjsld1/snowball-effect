class_name ItemManager
extends Node

## Optional-item producer boundary for S7-G1C.
##
## The manager receives read-only normal-ball snapshots and a later Integration
## caller supplies Paddle pickup information.  It never mutates simulation,
## score, settlement, or Stage state.

const ItemBallScript = preload("res://scripts/gameplay/item_ball.gd")
const ItemOrbScript = preload("res://scripts/gameplay/item_orb.gd")
const ITEM_DEFINITIONS := [
	preload("res://resources/items/item_blizzard.tres"),
	preload("res://resources/items/item_fire_core.tres"),
	preload("res://resources/items/item_magnet.tres"),
]

signal item_planet_damaged(item_type: StringName, current_hits: int, required_hits: int, world_position: Vector2)
signal item_planet_spawned(item_type: StringName, world_position: Vector2, radius: float)
signal item_planet_broken(item_type: StringName, world_position: Vector2)
signal item_orb_spawned(item_type: StringName, world_position: Vector2)
signal item_collected(item_type: StringName, world_position: Vector2)
signal item_orb_missed(item_type: StringName, world_position: Vector2)
signal active_items_changed(read_only_snapshot: Array)

@export_range(0.0, 3600.0, 0.01, "or_greater") var minimum_spawn_delay := 8.0
@export_range(0.0, 3600.0, 0.01, "or_greater") var maximum_spawn_delay := 18.0

var _random := RandomNumberGenerator.new()
var _stage: StageDefinition
var _play_field_rect := Rect2()
var _local_level_two_radius := 16.0
var _spawn_delay := 0.0
var _stage_elapsed := 0.0
var _spawn_consumed := false
var _item_ball
var _item_orb


func enter_stage(
	definition: StageDefinition,
	play_field_rect: Rect2,
	local_level_two_radius := 16.0,
	spawn_delay_override := -1.0,
	forced_item_type: StringName = &"",
	seed := 0
) -> void:
	assert(definition != null, "ItemManager requires a StageDefinition.")
	assert(play_field_rect.size.x > 0.0 and play_field_rect.size.y > 0.0, "ItemManager requires a valid Play Field rect.")
	assert(definition.local_ball_levels.size() >= 3, "ItemManager requires a Stage with local level 2.")
	_stage = definition
	_play_field_rect = play_field_rect
	_local_level_two_radius = local_level_two_radius
	_stage_elapsed = 0.0
	_spawn_consumed = false
	_item_ball = null
	_item_orb = null
	if seed != 0:
		_random.seed = seed
	else:
		_random.randomize()
	_spawn_delay = spawn_delay_override if spawn_delay_override >= 0.0 else _random.randf_range(minimum_spawn_delay, maximum_spawn_delay)
	if forced_item_type != &"":
		_spawn_item_ball(_get_definition(forced_item_type))
		_spawn_delay = 0.0
		_spawn_consumed = false
	active_items_changed.emit([])


func advance(delta: float) -> void:
	if delta <= 0.0:
		return
	if not _spawn_consumed:
		_stage_elapsed += delta
		if _stage_elapsed >= _spawn_delay:
			_spawn_consumed = true
			if _item_ball == null:
				_spawn_item_ball(_choose_weighted_definition())
	if _item_orb != null:
		_item_orb.advance(delta)
		if _item_orb.world_position.y - _item_orb.radius > _play_field_rect.end.y:
			_resolve_orb_missed()


func process_ball_snapshots(ball_snapshots: Array) -> void:
	if _item_ball == null or _item_ball.is_broken:
		return
	var overlapping_valid_ball_ids: Dictionary = {}
	for snapshot in ball_snapshots:
		if not snapshot is Dictionary:
			continue
		var ball_id: int = snapshot.get("id", -1)
		var global_level: int = snapshot.get("global_level", -1)
		var position: Vector2 = snapshot.get("position", Vector2.ZERO)
		var ball_radius: float = snapshot.get("radius", 0.0)
		if ball_id < 0 or ball_radius <= 0.0 or _local_level_for(global_level) < 2:
			continue
		if position.distance_squared_to(_item_ball.world_position) > pow(ball_radius + _item_ball.radius, 2.0):
			continue
		overlapping_valid_ball_ids[ball_id] = true
		if _item_ball.register_valid_contact(ball_id):
			item_planet_damaged.emit(_item_ball.item_type, _item_ball.current_hits, _item_ball.required_break_hits, _item_ball.world_position)
			if _item_ball.is_broken:
				_break_item_ball()
				break
	if _item_ball != null:
		_item_ball.release_absent_contacts(overlapping_valid_ball_ids)


func try_collect_orb(paddle_world_position: Vector2, pickup_radius: float) -> bool:
	if _item_orb == null or _item_orb.resolved or pickup_radius < 0.0:
		return false
	if paddle_world_position.distance_squared_to(_item_orb.world_position) > pow(pickup_radius + _item_orb.radius, 2.0):
		return false
	_item_orb.resolved = true
	var item_type: StringName = _item_orb.item_type
	var world_position: Vector2 = _item_orb.world_position
	_item_orb = null
	item_collected.emit(item_type, world_position)
	return true


func reset_runtime() -> void:
	_stage = null
	_item_ball = null
	_item_orb = null
	_spawn_consumed = false
	_stage_elapsed = 0.0
	active_items_changed.emit([])


func get_item_ball_snapshot() -> Dictionary:
	if _item_ball == null:
		return {}
	return {
		"item_type": _item_ball.item_type,
		"position": _item_ball.world_position,
		"radius": _item_ball.radius,
		"current_hits": _item_ball.current_hits,
		"required_hits": _item_ball.required_break_hits,
	}


func get_item_orb_snapshot() -> Dictionary:
	if _item_orb == null:
		return {}
	return {
		"item_type": _item_orb.item_type,
		"position": _item_orb.world_position,
		"radius": _item_orb.radius,
		"velocity": _item_orb.velocity,
	}


func _spawn_item_ball(definition) -> void:
	assert(definition != null, "ItemManager requires a valid ItemDefinition.")
	var horizontal_margin: float = definition.planet_radius
	var min_x: float = _play_field_rect.position.x + horizontal_margin
	var max_x: float = _play_field_rect.end.x - horizontal_margin
	var position := Vector2(_random.randf_range(min_x, max_x), _play_field_rect.position.y + _play_field_rect.size.y * 0.3)
	_item_ball = ItemBallScript.new()
	_item_ball.setup(definition, position)
	item_planet_spawned.emit(_item_ball.item_type, _item_ball.world_position, _item_ball.radius)


func _break_item_ball() -> void:
	var broken_ball = _item_ball
	_item_ball = null
	item_planet_broken.emit(broken_ball.item_type, broken_ball.world_position)
	_item_orb = ItemOrbScript.new()
	var definition = _get_definition(broken_ball.item_type)
	_item_orb.setup(broken_ball.item_type, broken_ball.world_position, _local_level_two_radius, definition.orb_speed)
	item_orb_spawned.emit(broken_ball.item_type, broken_ball.world_position)


func _resolve_orb_missed() -> void:
	var item_type: StringName = _item_orb.item_type
	var world_position: Vector2 = _item_orb.world_position
	_item_orb.resolved = true
	_item_orb = null
	item_orb_missed.emit(item_type, world_position)


func _local_level_for(global_level: int) -> int:
	return _stage.local_ball_levels.find(global_level) if _stage != null else -1


func _get_definition(item_type: StringName):
	for definition in ITEM_DEFINITIONS:
		if definition.item_type == item_type:
			return definition
	return null


func _choose_weighted_definition():
	var total_weight := 0.0
	for definition in ITEM_DEFINITIONS:
		total_weight += definition.spawn_weight
	assert(total_weight > 0.0, "Item definitions require a positive total spawn weight.")
	var selection := _random.randf() * total_weight
	for definition in ITEM_DEFINITIONS:
		selection -= definition.spawn_weight
		if selection <= 0.0:
			return definition
	return ITEM_DEFINITIONS.back()
