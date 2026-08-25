class_name BallSimulationManager
extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const SpatialGridScript = preload("res://scripts/simulation/spatial_grid.gd")

signal ball_count_changed(active_count: int)
signal cashout_completed(score_amount: float, global_level: int, world_position: Vector2)
signal ball_merged(result_level: int, world_position: Vector2)
signal first_contact_discovered(payload: Dictionary)
signal top_ball_created(global_level: int)
signal black_hole_phase_requested()
signal black_hole_absorbed(score_amount: float, global_level: int, world_position: Vector2)
signal black_hole_finale_started(contact_snapshot: Dictionary)
signal simulation_metrics_updated(metrics: Dictionary)

@export var play_field_rect := Rect2(500.0, 0.0, 600.0, 900.0)
@export_range(0.0, 1.0, 0.01) var wall_restitution := 1.0
@export var base_cashout_score := 1.0
@export var cashout_enabled := true
@export var merge_enabled := true
@export var maximum_ball_runtime_speed := 900.0
@export var stage_base_ball_radius := 4.0
@export_range(1.0, 1024.0, 1.0, "or_greater") var spatial_grid_cell_size := 32.0

const BLACK_HOLE_INFLUENCE_RADIUS := 480.0
const BLACK_HOLE_MAX_PULL_ACCELERATION := 1200.0
const BLACK_HOLE_TOTAL_PULL_CAP := 1500.0
const BLACK_HOLE_MUTUAL_REPULSION_ACCELERATION := 450.0
const BLACK_HOLE_MAX_COUNT := 2
const BLACK_HOLE_EPSILON_SQUARED := 0.0001
const FIRE_ACTIVE_CASHOUT_MULTIPLIER := 10.0
const MAGNET_MAX_NEIGHBORS := 2
const MAGNET_CANDIDATE_SAMPLE_LIMIT := 8
const FIRST_CONTACT_SCHEMA_VERSION := 1
const FIRST_CONTACT_RESUME_PLAYING := &"RESUME_PLAYING"
const FIRST_CONTACT_BLACK_HOLE_PHASE := &"BLACK_HOLE_PHASE"
const FIRST_CONTACT_ROSTER := [
	{
		"stage_index": 0,
		"stage_id": &"ground",
		"global_level": 3,
		"local_level": 3,
		"first_contact_id": &"ground_giant_snowball",
		"handoff_kind": FIRST_CONTACT_RESUME_PLAYING,
	},
	{
		"stage_index": 0,
		"stage_id": &"ground",
		"global_level": 4,
		"local_level": 4,
		"first_contact_id": &"ground_moon",
		"handoff_kind": FIRST_CONTACT_RESUME_PLAYING,
	},
	{
		"stage_index": 1,
		"stage_id": &"planetary",
		"global_level": 8,
		"local_level": 3,
		"first_contact_id": &"planetary_supernova",
		"handoff_kind": FIRST_CONTACT_RESUME_PLAYING,
	},
	{
		"stage_index": 1,
		"stage_id": &"planetary",
		"global_level": 10,
		"local_level": 4,
		"first_contact_id": &"planetary_galaxy",
		"handoff_kind": FIRST_CONTACT_RESUME_PLAYING,
	},
	{
		"stage_index": 2,
		"stage_id": &"galactic",
		"global_level": 13,
		"local_level": 3,
		"first_contact_id": &"galactic_event_horizon",
		"handoff_kind": FIRST_CONTACT_RESUME_PLAYING,
	},
	{
		"stage_index": 2,
		"stage_id": &"galactic",
		"global_level": 14,
		"local_level": 4,
		"first_contact_id": &"galactic_black_hole",
		"handoff_kind": FIRST_CONTACT_BLACK_HOLE_PHASE,
	},
]
const FIRST_CONTACT_PAYLOAD_KEYS := [
	"schema_version",
	"event_id",
	"run_epoch",
	"stage_index",
	"stage_id",
	"global_level",
	"local_level",
	"world_position",
	"first_contact_id",
	"handoff_kind",
	"black_hole_entity_ordinal",
]

var positions := PackedVector2Array()
var previous_positions := PackedVector2Array()
var velocities := PackedVector2Array()
var radii := PackedFloat32Array()
var global_levels := PackedInt32Array()
var special_types := PackedByteArray()
var active_flags := PackedByteArray()
var paddle_contact_locks := PackedByteArray()
var paddle_contact_lock_normals := PackedVector2Array()
var active_indices: Array[int] = []
var free_indices: Array[int] = []
var _paddle_collision_provider: Node
var _ball_catalog = BallCatalogScript.new()
var _spatial_grid = SpatialGridScript.new()
var _stage_ball_levels := PackedInt32Array()
var _stage_index := -1
var _stage_id: StringName = &""
var _stage_base_global_level := 0
var _stage_top_global_level := -1
var _stage_spawn_rate := 0.0
var _stage_black_hole_enabled := false
var _magnet_active := false
var _magnet_influence_radius := 0.0
var _magnet_max_pair_acceleration := 0.0
var _magnet_neighbor_limit := 0
var _magnet_neighbor_scratch: Array[int] = []
var _last_magnet_candidate_count := 0
var _last_magnet_force_application_count := 0
var _last_candidate_count := 0
var _last_grid_cell_count := 0
var _last_merge_count := 0
var _merge_candidate_pairs: Array[Vector2i] = []
var _non_merge_contact_pairs: Array[Vector2i] = []
var _merge_plans: Array[Dictionary] = []
var _consumed_merge_flags := PackedByteArray()
var _pending_cashout_indices: Array[int] = []
var _pending_cashout_positions := PackedVector2Array()
var _black_hole_positions := PackedVector2Array()
var _black_hole_velocities := PackedVector2Array()
var _black_hole_radii := PackedFloat32Array()
var _black_hole_terminal_locked := false
var _black_hole_terminal_snapshot: Dictionary = {}
var _first_contact_active_run_epoch := -1
var _last_first_contact_run_epoch := -1
var _next_first_contact_event_id := 1
var _first_contact_seen_ids: Dictionary = {}
var _render_snapshot_positions := PackedVector2Array()
var _render_snapshot_radii := PackedFloat32Array()
var _render_snapshot_global_levels := PackedInt32Array()
var _render_snapshot_special_types := PackedByteArray()
var _render_snapshot := {
	"positions": _render_snapshot_positions,
	"radii": _render_snapshot_radii,
	"global_levels": _render_snapshot_global_levels,
	"count": 0,
}
var _item_collision_snapshots: Array[Dictionary] = []
var _simulation_metrics := {
	"active_balls": 0,
	"slot_capacity": 0,
	"free_slots": 0,
	"candidate_count": 0,
	"grid_cell_count": 0,
	"grid_bucket_capacity": 0,
	"grid_new_buckets": 0,
	"magnet_candidate_count": 0,
	"magnet_force_applications": 0,
	"merges": 0,
	"black_holes": 0,
}

enum BallSpecialType {
	NORMAL,
	FIRE,
}


func _physics_process(delta: float) -> void:
	step_simulation(delta)


func spawn_ball(position: Vector2, velocity := Vector2.ZERO, radius := 6.0, global_level := 0, special_type := BallSpecialType.NORMAL) -> int:
	assert(radius > 0.0, "Ball radius must be positive.")
	assert(global_level >= 0, "Ball global level must not be negative.")
	assert(_ball_catalog.has_definition(global_level), "Ball global level must have a catalog definition.")
	assert(special_type >= BallSpecialType.NORMAL and special_type <= BallSpecialType.FIRE, "Ball special type must be supported.")

	var index: int
	if free_indices.is_empty():
		index = positions.size()
		positions.append(position)
		previous_positions.append(position)
		velocities.append(velocity)
		radii.append(radius)
		global_levels.append(global_level)
		special_types.append(special_type)
		active_flags.append(1)
		paddle_contact_locks.append(0)
		paddle_contact_lock_normals.append(Vector2.ZERO)
	else:
		index = free_indices.pop_back()
		positions[index] = position
		previous_positions[index] = position
		velocities[index] = velocity
		radii[index] = radius
		global_levels[index] = global_level
		special_types[index] = special_type
		active_flags[index] = 1
		paddle_contact_locks[index] = 0
		paddle_contact_lock_normals[index] = Vector2.ZERO

	active_indices.append(index)
	ball_count_changed.emit(active_indices.size())
	return index


func deactivate_ball(index: int) -> bool:
	if not is_ball_active(index):
		return false

	active_flags[index] = 0
	special_types[index] = BallSpecialType.NORMAL
	paddle_contact_locks[index] = 0
	paddle_contact_lock_normals[index] = Vector2.ZERO
	free_indices.append(index)

	var active_position := active_indices.find(index)
	var moved_index: int = active_indices.pop_back()
	if active_position < active_indices.size():
		active_indices[active_position] = moved_index

	ball_count_changed.emit(active_indices.size())
	return true


func is_ball_active(index: int) -> bool:
	return index >= 0 and index < active_flags.size() and active_flags[index] == 1


func get_active_count() -> int:
	return active_indices.size()


func is_ball_fire(index: int) -> bool:
	return is_ball_active(index) and special_types[index] == BallSpecialType.FIRE


func get_capacity() -> int:
	return positions.size()


func configure_stage_ball_levels(ordered_global_levels: PackedInt32Array) -> void:
	_stage_ball_levels = ordered_global_levels.duplicate()
	_stage_top_global_level = _stage_ball_levels[_stage_ball_levels.size() - 1] if not _stage_ball_levels.is_empty() else -1


func apply_stage_definition(definition: StageDefinition) -> void:
	assert(definition != null, "Simulation Stage apply requires a StageDefinition.")
	reset_runtime()
	_stage_index = definition.stage_index
	_stage_id = definition.background_id
	_stage_base_global_level = definition.base_global_level
	_stage_top_global_level = definition.top_global_level
	_stage_spawn_rate = definition.spawn_rate
	_stage_black_hole_enabled = definition.black_hole_enabled
	configure_stage_ball_levels(definition.local_ball_levels)


func get_stage_snapshot() -> Dictionary:
	return {
		"stage_index": _stage_index,
		"stage_id": _stage_id,
		"base_global_level": _stage_base_global_level,
		"top_global_level": _stage_top_global_level,
		"local_ball_levels": _stage_ball_levels.duplicate(),
		"spawn_rate": _stage_spawn_rate,
		"black_hole_enabled": _stage_black_hole_enabled,
	}


func begin_first_contact_run(run_epoch: int) -> bool:
	if run_epoch <= _last_first_contact_run_epoch:
		return false
	_last_first_contact_run_epoch = run_epoch
	_first_contact_active_run_epoch = run_epoch
	_first_contact_seen_ids.clear()
	return true


func invalidate_first_contact_run(run_epoch: int) -> bool:
	if run_epoch != _first_contact_active_run_epoch:
		return false
	_first_contact_active_run_epoch = -1
	_first_contact_seen_ids.clear()
	return true


func is_valid_first_contact_payload(payload: Dictionary) -> bool:
	if payload.size() != FIRST_CONTACT_PAYLOAD_KEYS.size():
		return false
	for key in FIRST_CONTACT_PAYLOAD_KEYS:
		if not payload.has(key):
			return false
	if typeof(payload["schema_version"]) != TYPE_INT or payload["schema_version"] != FIRST_CONTACT_SCHEMA_VERSION:
		return false
	if typeof(payload["event_id"]) != TYPE_INT or payload["event_id"] <= 0:
		return false
	if typeof(payload["run_epoch"]) != TYPE_INT or payload["run_epoch"] < 0:
		return false
	if typeof(payload["stage_index"]) != TYPE_INT:
		return false
	if not payload["stage_id"] is StringName or typeof(payload["global_level"]) != TYPE_INT or typeof(payload["local_level"]) != TYPE_INT:
		return false
	if not payload["world_position"] is Vector2 or not payload["first_contact_id"] is StringName or not payload["handoff_kind"] is StringName:
		return false
	if typeof(payload["black_hole_entity_ordinal"]) != TYPE_INT:
		return false
	var roster_entry := _find_first_contact_roster_entry(
		payload["stage_index"],
		payload["stage_id"],
		payload["global_level"],
		payload["local_level"]
	)
	if roster_entry.is_empty():
		return false
	if payload["first_contact_id"] != roster_entry["first_contact_id"] or payload["handoff_kind"] != roster_entry["handoff_kind"]:
		return false
	var expected_black_hole_ordinal := 1 if payload["handoff_kind"] == FIRST_CONTACT_BLACK_HOLE_PHASE else 0
	return payload["black_hole_entity_ordinal"] == expected_black_hole_ordinal


func get_runtime_radius_for_level(global_level: int) -> float:
	var local_level := _stage_ball_levels.find(global_level)
	if local_level >= 0:
		return stage_base_ball_radius * pow(2.0, local_level)
	var definition = _ball_catalog.get_definition(global_level)
	return definition.radius if definition != null else stage_base_ball_radius


func get_ball_global_level(index: int) -> int:
	if not is_ball_active(index):
		return -1
	return global_levels[index]


func get_black_hole_count() -> int:
	return _black_hole_positions.size()


func get_black_hole_position(index := 0) -> Vector2:
	if index < 0 or index >= _black_hole_positions.size():
		return Vector2.ZERO
	return _black_hole_positions[index]


func get_black_hole_snapshot() -> Dictionary:
	return {
		"count": _black_hole_positions.size(),
		"positions": _black_hole_positions.duplicate(),
		"radii": _black_hole_radii.duplicate(),
	}


func is_black_hole_terminal_locked() -> bool:
	return _black_hole_terminal_locked


func get_black_hole_terminal_snapshot() -> Dictionary:
	return _black_hole_terminal_snapshot.duplicate(true)


func get_black_hole_pull(position: Vector2) -> Vector2:
	var total_pull := Vector2.ZERO
	for black_hole_position in _black_hole_positions:
		total_pull += _get_pull_from_source(position, black_hole_position, BLACK_HOLE_MAX_PULL_ACCELERATION)
	return total_pull.limit_length(BLACK_HOLE_TOTAL_PULL_CAP)


func set_magnet_force_command(command: Dictionary) -> bool:
	if not bool(command.get("active", false)):
		_clear_magnet_force_command()
		return true
	if StringName(command.get("item_type", &"")) != &"magnet":
		return false
	var influence_radius := float(command.get("influence_radius", 0.0))
	var max_pair_acceleration := float(command.get("max_pair_acceleration", 0.0))
	var neighbor_limit := int(command.get("neighbor_limit", 0))
	if influence_radius <= 0.0 or max_pair_acceleration <= 0.0 or neighbor_limit < 1 or neighbor_limit > MAGNET_MAX_NEIGHBORS:
		return false
	_magnet_active = true
	_magnet_influence_radius = influence_radius
	_magnet_max_pair_acceleration = max_pair_acceleration
	_magnet_neighbor_limit = neighbor_limit
	return true


func get_magnet_force_metrics() -> Dictionary:
	return {
		"active": _magnet_active,
		"influence_radius": _magnet_influence_radius,
		"max_pair_acceleration": _magnet_max_pair_acceleration,
		"neighbor_limit": _magnet_neighbor_limit,
		"candidate_count": _last_magnet_candidate_count,
		"force_applications": _last_magnet_force_application_count,
	}


func get_merge_candidate_pairs() -> Array[Vector2i]:
	_rebuild_merge_candidate_pairs()
	return _merge_candidate_pairs.duplicate()


func get_non_merge_contact_pairs() -> Array[Vector2i]:
	_rebuild_non_merge_contact_pairs(0.0)
	return _non_merge_contact_pairs.duplicate()


func _rebuild_merge_candidate_pairs() -> Array[Vector2i]:
	_spatial_grid.cell_size = spatial_grid_cell_size
	_spatial_grid.rebuild(positions, radii, global_levels, active_indices)
	_spatial_grid.fill_overlapping_pairs(positions, radii, global_levels, _merge_candidate_pairs)
	_last_candidate_count = _spatial_grid.get_candidate_check_count()
	_last_grid_cell_count = _spatial_grid.get_cell_count()
	return _merge_candidate_pairs


func _rebuild_non_merge_contact_pairs(delta: float) -> Array[Vector2i]:
	_spatial_grid.cell_size = spatial_grid_cell_size
	_spatial_grid.rebuild(positions, radii, global_levels, active_indices)
	_spatial_grid.fill_non_merge_contact_pairs(
		previous_positions,
		positions,
		radii,
		global_levels,
		_stage_top_global_level,
		maximum_ball_runtime_speed * maxf(delta, 0.0),
		_non_merge_contact_pairs
	)
	_last_candidate_count = _spatial_grid.get_candidate_check_count()
	_last_grid_cell_count = _spatial_grid.get_cell_count()
	return _non_merge_contact_pairs


func get_spatial_metrics() -> Dictionary:
	return {
		"candidate_count": _last_candidate_count,
		"grid_cell_count": _last_grid_cell_count,
		"grid_bucket_capacity": _spatial_grid.get_allocated_bucket_count(),
		"grid_new_buckets": _spatial_grid.get_new_bucket_count(),
		"magnet_candidate_count": _last_magnet_candidate_count,
		"magnet_force_applications": _last_magnet_force_application_count,
	}


func get_simulation_metrics() -> Dictionary:
	_update_simulation_metrics()
	return _simulation_metrics


func commit_merge_candidates(delta := 0.0) -> int:
	_last_merge_count = 0
	_merge_plans.clear()
	_consumed_merge_flags.resize(positions.size())
	_consumed_merge_flags.fill(0)
	var reserved_black_hole_slots := _black_hole_positions.size()
	var overflow_pairs: Array[Vector2i] = []
	for candidate in _rebuild_merge_candidate_pairs():
		var first_index := candidate.x
		var second_index := candidate.y
		if _consumed_merge_flags[first_index] == 1 or _consumed_merge_flags[second_index] == 1:
			continue
		if not is_ball_active(first_index) or not is_ball_active(second_index):
			continue

		var result_level := _get_next_stage_global_level(global_levels[first_index])
		if result_level < 0:
			continue
		var creates_black_hole := _is_black_hole_merge_result(result_level)
		if creates_black_hole and reserved_black_hole_slots >= BLACK_HOLE_MAX_COUNT:
			overflow_pairs.append(candidate)
			continue
		if creates_black_hole:
			reserved_black_hole_slots += 1

		_consumed_merge_flags[first_index] = 1
		_consumed_merge_flags[second_index] = 1
		_merge_plans.append({
			"first_index": first_index,
			"second_index": second_index,
			"result_level": result_level,
			"position": (positions[first_index] + positions[second_index]) * 0.5,
			"velocity": _get_merge_result_velocity(first_index, second_index),
			"creates_black_hole": creates_black_hole,
			"special_type": BallSpecialType.FIRE if special_types[first_index] == BallSpecialType.FIRE or special_types[second_index] == BallSpecialType.FIRE else BallSpecialType.NORMAL,
		})

	for pair in overflow_pairs:
		if is_ball_active(pair.x) and is_ball_active(pair.y):
			_resolve_non_merge_contact(pair.x, pair.y, delta)

	for plan in _merge_plans:
		deactivate_ball(plan["first_index"])
		deactivate_ball(plan["second_index"])

	for plan in _merge_plans:
		var result_level: int = plan["result_level"]
		var result_position: Vector2 = plan["position"]
		var black_hole_entity_ordinal := 0
		if plan["creates_black_hole"]:
			black_hole_entity_ordinal = _black_hole_positions.size() + 1
			_create_black_hole(result_position, plan["velocity"])
		else:
			spawn_ball(result_position, plan["velocity"], get_runtime_radius_for_level(result_level), result_level, plan["special_type"])
		ball_merged.emit(result_level, result_position)
		_commit_first_contact_discovery(result_level, result_position, black_hole_entity_ordinal)
		if result_level != _stage_top_global_level or not _stage_black_hole_enabled:
			top_ball_created.emit(result_level)

	_last_merge_count = _merge_plans.size()
	return _last_merge_count


func _commit_non_merge_contacts(delta: float) -> void:
	for pair in _rebuild_non_merge_contact_pairs(delta):
		if not is_ball_active(pair.x) or not is_ball_active(pair.y):
			continue
		if global_levels[pair.x] == global_levels[pair.y] and global_levels[pair.x] != _stage_top_global_level:
			continue
		_resolve_non_merge_contact(pair.x, pair.y, delta)


func _resolve_non_merge_contact(first_index: int, second_index: int, delta: float) -> void:
	var first_previous := previous_positions[first_index]
	var second_previous := previous_positions[second_index]
	var first_position := positions[first_index]
	var second_position := positions[second_index]
	var first_motion := first_position - first_previous
	var second_motion := second_position - second_previous
	var relative_start := first_previous - second_previous
	var relative_motion := first_motion - second_motion
	var combined_radius := radii[first_index] + radii[second_index]
	var contact_time := _get_circle_contact_time(relative_start, relative_motion, combined_radius)
	if contact_time < 0.0:
		return

	var first_contact_position := first_previous + first_motion * contact_time
	var second_contact_position := second_previous + second_motion * contact_time
	var normal := (first_contact_position - second_contact_position).normalized()
	if normal.is_zero_approx():
		normal = (velocities[first_index] - velocities[second_index]).normalized()
	if normal.is_zero_approx():
		normal = Vector2.RIGHT

	var relative_velocity := velocities[first_index] - velocities[second_index]
	if relative_velocity.dot(normal) >= 0.0:
		return

	var first_mass := _get_ball_mass(first_index)
	var second_mass := _get_ball_mass(second_index)
	var total_mass := first_mass + second_mass
	if total_mass <= 0.0:
		return
	var normal_speed := relative_velocity.dot(normal)
	velocities[first_index] = (velocities[first_index] - normal * normal_speed * (2.0 * second_mass / total_mass)).limit_length(maximum_ball_runtime_speed)
	velocities[second_index] = (velocities[second_index] + normal * normal_speed * (2.0 * first_mass / total_mass)).limit_length(maximum_ball_runtime_speed)

	var remaining_time := delta * (1.0 - contact_time)
	positions[first_index] = first_contact_position + velocities[first_index] * remaining_time
	positions[second_index] = second_contact_position + velocities[second_index] * remaining_time
	_apply_ball_bounds(first_index)
	_apply_ball_bounds(second_index)
	_separate_non_merge_contact(first_index, second_index, normal, combined_radius)


func _get_circle_contact_time(relative_start: Vector2, relative_motion: Vector2, combined_radius: float) -> float:
	var start_distance_squared := relative_start.length_squared()
	var combined_radius_squared := combined_radius * combined_radius
	if start_distance_squared <= combined_radius_squared:
		return 0.0
	var motion_length_squared := relative_motion.length_squared()
	if motion_length_squared <= 0.000001:
		return -1.0
	var b := 2.0 * relative_start.dot(relative_motion)
	var c := start_distance_squared - combined_radius_squared
	var discriminant := b * b - 4.0 * motion_length_squared * c
	if discriminant < 0.0:
		return -1.0
	var contact_time := (-b - sqrt(discriminant)) / (2.0 * motion_length_squared)
	return contact_time if contact_time >= 0.0 and contact_time <= 1.0 else -1.0


func _get_ball_mass(index: int) -> float:
	var definition = _ball_catalog.get_definition(global_levels[index])
	return definition.mass if definition != null else 1.0


func _separate_non_merge_contact(first_index: int, second_index: int, normal: Vector2, combined_radius: float) -> void:
	var distance := positions[first_index].distance_to(positions[second_index])
	var penetration := combined_radius - distance
	if penetration <= 0.0:
		return
	var separation_normal := normal
	if distance > 0.0001:
		separation_normal = (positions[first_index] - positions[second_index]) / distance
	var first_mass := _get_ball_mass(first_index)
	var second_mass := _get_ball_mass(second_index)
	var total_mass := first_mass + second_mass
	if total_mass <= 0.0:
		return
	var correction := separation_normal * (penetration + 0.01)
	positions[first_index] += correction * (second_mass / total_mass)
	positions[second_index] -= correction * (first_mass / total_mass)
	_apply_ball_bounds(first_index)
	_apply_ball_bounds(second_index)


func _apply_ball_bounds(index: int) -> void:
	var position := positions[index]
	var velocity := velocities[index]
	var radius := radii[index]
	var left_bound := play_field_rect.position.x + radius
	var right_bound := play_field_rect.end.x - radius
	var top_bound := play_field_rect.position.y + radius
	if position.x < left_bound:
		position.x = left_bound
		velocity.x = absf(velocity.x) * wall_restitution
	elif position.x > right_bound:
		position.x = right_bound
		velocity.x = -absf(velocity.x) * wall_restitution
	if position.y < top_bound:
		position.y = top_bound
		velocity.y = absf(velocity.y) * wall_restitution
	positions[index] = position
	velocities[index] = velocity


func _get_next_stage_global_level(global_level: int) -> int:
	var local_level := _stage_ball_levels.find(global_level)
	if local_level < 0 or local_level + 1 >= _stage_ball_levels.size():
		return -1
	var result_level := _stage_ball_levels[local_level + 1]
	return result_level if _ball_catalog.has_definition(result_level) else -1


func _commit_first_contact_discovery(result_level: int, world_position: Vector2, black_hole_entity_ordinal: int) -> void:
	if _first_contact_active_run_epoch < 0:
		return
	var local_level := _stage_ball_levels.find(result_level)
	var roster_entry := _find_first_contact_roster_entry(_stage_index, _stage_id, result_level, local_level)
	if roster_entry.is_empty():
		return
	var first_contact_id: StringName = roster_entry["first_contact_id"]
	if _first_contact_seen_ids.has(first_contact_id):
		return
	if roster_entry["handoff_kind"] == FIRST_CONTACT_BLACK_HOLE_PHASE and black_hole_entity_ordinal != 1:
		return
	var payload := {
		"schema_version": FIRST_CONTACT_SCHEMA_VERSION,
		"event_id": _next_first_contact_event_id,
		"run_epoch": _first_contact_active_run_epoch,
		"stage_index": _stage_index,
		"stage_id": _stage_id,
		"global_level": result_level,
		"local_level": local_level,
		"world_position": world_position,
		"first_contact_id": first_contact_id,
		"handoff_kind": roster_entry["handoff_kind"],
		"black_hole_entity_ordinal": black_hole_entity_ordinal,
	}
	if not is_valid_first_contact_payload(payload):
		push_error("FIRST_CONTACT producer rejected an invalid internal payload.")
		return
	_first_contact_seen_ids[first_contact_id] = true
	_next_first_contact_event_id += 1
	first_contact_discovered.emit(payload.duplicate(true))


func _find_first_contact_roster_entry(stage_index: int, stage_id: StringName, global_level: int, local_level: int) -> Dictionary:
	for entry in FIRST_CONTACT_ROSTER:
		if entry["stage_index"] == stage_index and entry["stage_id"] == stage_id and entry["global_level"] == global_level and entry["local_level"] == local_level:
			return entry
	return {}


func set_paddle_collision_provider(provider: Node) -> void:
	assert(provider == null or provider.has_method("resolve_continuous_ball_collision"), "Paddle provider must expose resolve_continuous_ball_collision().")
	_paddle_collision_provider = provider


func reset_runtime() -> void:
	positions.clear()
	previous_positions.clear()
	velocities.clear()
	radii.clear()
	global_levels.clear()
	active_flags.clear()
	paddle_contact_locks.clear()
	paddle_contact_lock_normals.clear()
	special_types.clear()
	active_indices.clear()
	free_indices.clear()
	_clear_magnet_force_command()
	_last_candidate_count = 0
	_last_grid_cell_count = 0
	_last_magnet_candidate_count = 0
	_last_magnet_force_application_count = 0
	_last_merge_count = 0
	_merge_candidate_pairs.clear()
	_non_merge_contact_pairs.clear()
	_merge_plans.clear()
	_consumed_merge_flags.clear()
	_pending_cashout_indices.clear()
	_pending_cashout_positions.clear()
	_black_hole_positions.clear()
	_black_hole_velocities.clear()
	_black_hole_radii.clear()
	_black_hole_terminal_locked = false
	_black_hole_terminal_snapshot.clear()
	_render_snapshot_positions.clear()
	_render_snapshot_radii.clear()
	_render_snapshot_global_levels.clear()
	_render_snapshot_special_types.clear()
	_update_simulation_metrics()
	ball_count_changed.emit(0)


func _apply_magnet_force(delta: float) -> void:
	_last_magnet_candidate_count = 0
	_last_magnet_force_application_count = 0
	if not _magnet_active or _magnet_influence_radius <= 0.0 or _magnet_max_pair_acceleration <= 0.0 or _magnet_neighbor_limit < 1:
		return

	_spatial_grid.cell_size = spatial_grid_cell_size
	_spatial_grid.rebuild(positions, radii, global_levels, active_indices)
	_last_grid_cell_count = _spatial_grid.get_cell_count()
	for index in active_indices:
		var inspected := _spatial_grid.fill_same_level_magnet_neighbors(
			positions,
			index,
			global_levels[index],
			_magnet_influence_radius,
			_magnet_neighbor_limit,
			MAGNET_CANDIDATE_SAMPLE_LIMIT,
			_magnet_neighbor_scratch
		)
		_last_magnet_candidate_count += inspected
		var total_acceleration := Vector2.ZERO
		for neighbor_index in _magnet_neighbor_scratch:
			var offset := positions[neighbor_index] - positions[index]
			var distance := offset.length()
			if distance <= 0.0001 or distance >= _magnet_influence_radius:
				continue
			var falloff := 1.0 - distance / _magnet_influence_radius
			total_acceleration += offset / distance * (_magnet_max_pair_acceleration * falloff)
			_last_magnet_force_application_count += 1
		velocities[index] = (velocities[index] + total_acceleration.limit_length(_magnet_max_pair_acceleration * _magnet_neighbor_limit) * delta).limit_length(maximum_ball_runtime_speed)


func _clear_magnet_force_command() -> void:
	_magnet_active = false
	_magnet_influence_radius = 0.0
	_magnet_max_pair_acceleration = 0.0
	_magnet_neighbor_limit = 0
	_magnet_neighbor_scratch.clear()


func step_simulation(delta: float) -> void:
	if delta <= 0.0:
		return
	if is_instance_valid(_paddle_collision_provider) and _paddle_collision_provider.has_method("prepare_physics_transform"):
		# Simulation runs before the sibling Paddle node in Main, so it prepares the shared transform once.
		_paddle_collision_provider.prepare_physics_transform(delta)
	_step_black_holes(delta)
	if _black_hole_terminal_locked:
		_update_simulation_metrics()
		simulation_metrics_updated.emit(_simulation_metrics)
		return

	for index in active_indices:
		previous_positions[index] = positions[index]
	_apply_magnet_force(delta)

	for index in active_indices:
		var velocity := velocities[index]
		var position := positions[index]
		var radius := radii[index]
		velocity = (velocity + get_black_hole_pull(position) * delta).limit_length(maximum_ball_runtime_speed)

		if is_instance_valid(_paddle_collision_provider):
			if paddle_contact_locks[index] == 1:
				var lock_normal := paddle_contact_lock_normals[index]
				# A contact lock only covers an uninterrupted contact. If the Ball was already
				# outside the Paddle at this tick's previous transform, a direct Mouse sweep
				# is a new collision and must not be skipped because its old normal was tangential.
				if _paddle_collision_provider.was_ball_separated_before_current_motion(position, radius) or _paddle_collision_provider.is_ball_separated(position, radius) or _paddle_collision_provider.is_ball_reapproaching(position, velocity, lock_normal):
					paddle_contact_locks[index] = 0
					paddle_contact_lock_normals[index] = Vector2.ZERO
			if paddle_contact_locks[index] == 0:
				var collision: Dictionary = _paddle_collision_provider.resolve_continuous_ball_collision(position, velocity, radius, delta)
				position = collision["position"]
				velocity = collision["velocity"]
				if collision["collided"]:
					paddle_contact_locks[index] = 1
					paddle_contact_lock_normals[index] = collision["normal"]
					if _paddle_collision_provider.has_method("is_fire_contact_active") and _paddle_collision_provider.is_fire_contact_active():
						special_types[index] = BallSpecialType.FIRE
			else:
				position += velocity * delta
		else:
			position += velocity * delta

		var left_bound := play_field_rect.position.x + radius
		var right_bound := play_field_rect.end.x - radius
		var top_bound := play_field_rect.position.y + radius
		if position.x < left_bound:
			position.x = left_bound
			velocity.x = absf(velocity.x) * wall_restitution
		elif position.x > right_bound:
			position.x = right_bound
			velocity.x = -absf(velocity.x) * wall_restitution
		if position.y < top_bound:
			position.y = top_bound
			velocity.y = absf(velocity.y) * wall_restitution

		positions[index] = position
		velocities[index] = velocity

	_commit_black_hole_absorptions()

	if merge_enabled:
		commit_merge_candidates(delta)
	else:
		_rebuild_merge_candidate_pairs()
		_last_merge_count = 0
	_commit_non_merge_contacts(delta)

	_pending_cashout_indices.clear()
	_pending_cashout_positions.clear()
	if cashout_enabled:
		for index in active_indices:
			if positions[index].y - radii[index] > play_field_rect.end.y:
				_pending_cashout_indices.append(index)
				_pending_cashout_positions.append(positions[index])

	for cashout_index in range(_pending_cashout_indices.size()):
		var ball_index := _pending_cashout_indices[cashout_index]
		var was_fire := special_types[ball_index] == BallSpecialType.FIRE
		if deactivate_ball(ball_index):
			var global_level := global_levels[ball_index]
			var definition = _ball_catalog.get_definition(global_level)
			var cashout_score: float = definition.score_value
			if was_fire:
				cashout_score *= FIRE_ACTIVE_CASHOUT_MULTIPLIER
			cashout_completed.emit(cashout_score, global_level, _pending_cashout_positions[cashout_index])

	_update_simulation_metrics()
	simulation_metrics_updated.emit(_simulation_metrics)


func get_render_snapshot() -> Dictionary:
	var active_count := active_indices.size()
	_render_snapshot_positions.resize(active_count)
	_render_snapshot_radii.resize(active_count)
	_render_snapshot_global_levels.resize(active_count)
	_render_snapshot_special_types.resize(active_count)

	for snapshot_index in range(active_count):
		var ball_index := active_indices[snapshot_index]
		_render_snapshot_positions[snapshot_index] = positions[ball_index]
		_render_snapshot_radii[snapshot_index] = radii[ball_index]
		_render_snapshot_global_levels[snapshot_index] = global_levels[ball_index]
		_render_snapshot_special_types[snapshot_index] = special_types[ball_index]

	_render_snapshot["positions"] = _render_snapshot_positions
	_render_snapshot["radii"] = _render_snapshot_radii
	_render_snapshot["global_levels"] = _render_snapshot_global_levels
	_render_snapshot["special_types"] = _render_snapshot_special_types
	_render_snapshot["count"] = active_count
	return _render_snapshot


func get_active_play_field_rect() -> Rect2:
	return play_field_rect


func get_active_item_collision_snapshots() -> Array[Dictionary]:
	_item_collision_snapshots.clear()
	for ball_index in active_indices:
		_item_collision_snapshots.append({
			"id": ball_index,
			"global_level": global_levels[ball_index],
			"position": positions[ball_index],
			"radius": radii[ball_index],
		})
	return _item_collision_snapshots


func _update_simulation_metrics() -> void:
	_simulation_metrics["active_balls"] = active_indices.size()
	_simulation_metrics["slot_capacity"] = positions.size()
	_simulation_metrics["free_slots"] = free_indices.size()
	_simulation_metrics["candidate_count"] = _last_candidate_count
	_simulation_metrics["grid_cell_count"] = _last_grid_cell_count
	_simulation_metrics["grid_bucket_capacity"] = _spatial_grid.get_allocated_bucket_count()
	_simulation_metrics["grid_new_buckets"] = _spatial_grid.get_new_bucket_count()
	_simulation_metrics["magnet_candidate_count"] = _last_magnet_candidate_count
	_simulation_metrics["magnet_force_applications"] = _last_magnet_force_application_count
	_simulation_metrics["merges"] = _last_merge_count
	_simulation_metrics["black_holes"] = _black_hole_positions.size()


func _get_merge_result_velocity(first_index: int, second_index: int) -> Vector2:
	var first_mass: float = _ball_catalog.get_definition(global_levels[first_index]).mass
	var second_mass: float = _ball_catalog.get_definition(global_levels[second_index]).mass
	var total_mass := first_mass + second_mass
	var result_velocity := (velocities[first_index] + velocities[second_index]) * 0.5
	if total_mass > 0.0:
		result_velocity = (velocities[first_index] * first_mass + velocities[second_index] * second_mass) / total_mass
	return result_velocity.limit_length(maximum_ball_runtime_speed)


func _is_black_hole_merge_result(result_level: int) -> bool:
	return _stage_black_hole_enabled and result_level == _stage_top_global_level


func _create_black_hole(position: Vector2, velocity: Vector2) -> void:
	var was_empty := _black_hole_positions.is_empty()
	var footprint_level := _stage_ball_levels[2] if _stage_ball_levels.size() > 2 else _stage_base_global_level
	_black_hole_positions.append(position)
	_black_hole_velocities.append(velocity.limit_length(maximum_ball_runtime_speed))
	_black_hole_radii.append(get_runtime_radius_for_level(footprint_level))
	if was_empty:
		black_hole_phase_requested.emit()


func _step_black_holes(delta: float) -> void:
	if _black_hole_terminal_locked:
		return
	var previous_positions := _black_hole_positions.duplicate()
	var next_velocities := PackedVector2Array()
	var next_positions := PackedVector2Array()
	for index in range(_black_hole_positions.size()):
		var velocity := _black_hole_velocities[index]
		var position := previous_positions[index]
		for other_index in range(_black_hole_positions.size()):
			if other_index != index:
				velocity -= _get_pull_from_source(position, previous_positions[other_index], BLACK_HOLE_MUTUAL_REPULSION_ACCELERATION) * delta
		velocity = velocity.limit_length(maximum_ball_runtime_speed)
		if is_instance_valid(_paddle_collision_provider):
			var collision: Dictionary = _paddle_collision_provider.resolve_continuous_ball_collision(
				position,
				velocity,
				_black_hole_radii[index],
				delta
			)
			position = collision["position"]
			velocity = collision["velocity"]
		else:
			position += velocity * delta
		next_velocities.append(velocity)
		next_positions.append(position)

	if _black_hole_positions.size() == BLACK_HOLE_MAX_COUNT:
		var contact_time := _get_black_hole_contact_time(previous_positions[0], next_velocities[0], previous_positions[1], next_velocities[1], _black_hole_radii[0] + _black_hole_radii[1], delta)
		if contact_time >= 0.0:
			_lock_black_hole_terminal(previous_positions, next_velocities, contact_time)
			return

	for index in range(_black_hole_positions.size()):
		var velocity := next_velocities[index]
		var position := next_positions[index]
		var radius := _black_hole_radii[index]
		var left_bound := play_field_rect.position.x + radius
		var right_bound := play_field_rect.end.x - radius
		var top_bound := play_field_rect.position.y + radius
		var bottom_bound := play_field_rect.end.y - radius
		if position.x < left_bound:
			position.x = left_bound
			velocity.x = absf(velocity.x) * wall_restitution
		elif position.x > right_bound:
			position.x = right_bound
			velocity.x = -absf(velocity.x) * wall_restitution
		if position.y < top_bound:
			position.y = top_bound
			velocity.y = absf(velocity.y) * wall_restitution
		elif position.y > bottom_bound:
			position.y = bottom_bound
			velocity.y = -absf(velocity.y) * wall_restitution
		_black_hole_positions[index] = position
		_black_hole_velocities[index] = velocity


func _get_black_hole_contact_time(first_position: Vector2, first_velocity: Vector2, second_position: Vector2, second_velocity: Vector2, contact_radius: float, delta: float) -> float:
	var relative_position := first_position - second_position
	var relative_velocity := first_velocity - second_velocity
	var overlap := relative_position.length_squared() - contact_radius * contact_radius
	if overlap <= 0.0:
		return 0.0
	var velocity_length_squared := relative_velocity.length_squared()
	if velocity_length_squared <= BLACK_HOLE_EPSILON_SQUARED:
		return -1.0
	var b := 2.0 * relative_position.dot(relative_velocity)
	var discriminant := b * b - 4.0 * velocity_length_squared * overlap
	if discriminant < 0.0:
		return -1.0
	var time := (-b - sqrt(discriminant)) / (2.0 * velocity_length_squared)
	return time if time >= 0.0 and time <= delta else -1.0


func _lock_black_hole_terminal(previous_positions: PackedVector2Array, next_velocities: PackedVector2Array, contact_time: float) -> void:
	if _black_hole_terminal_locked:
		return
	_black_hole_terminal_locked = true
	var first_position := previous_positions[0] + next_velocities[0] * contact_time
	var second_position := previous_positions[1] + next_velocities[1] * contact_time
	_black_hole_positions[0] = first_position
	_black_hole_positions[1] = second_position
	_black_hole_velocities[0] = next_velocities[0]
	_black_hole_velocities[1] = next_velocities[1]
	_black_hole_terminal_snapshot = {
		"contact_position": (first_position + second_position) * 0.5,
		"black_holes": [
			{"position": first_position, "velocity": next_velocities[0], "radius": _black_hole_radii[0]},
			{"position": second_position, "velocity": next_velocities[1], "radius": _black_hole_radii[1]},
		],
	}
	black_hole_finale_started.emit(get_black_hole_terminal_snapshot())


func _get_pull_from_source(position: Vector2, source_position: Vector2, maximum_acceleration: float) -> Vector2:
	var offset := source_position - position
	var distance_squared := offset.length_squared()
	if distance_squared <= BLACK_HOLE_EPSILON_SQUARED:
		return Vector2.ZERO
	var distance := sqrt(distance_squared)
	if distance >= BLACK_HOLE_INFLUENCE_RADIUS:
		return Vector2.ZERO
	var falloff := pow(1.0 - distance / BLACK_HOLE_INFLUENCE_RADIUS, 2.0)
	return offset / distance * maximum_acceleration * falloff


func _commit_black_hole_absorptions() -> void:
	if _black_hole_positions.is_empty():
		return
	var absorbed_indices: Array[int] = []
	for index in active_indices:
		for black_hole_index in range(_black_hole_positions.size()):
			var contact_radius := radii[index] + _black_hole_radii[black_hole_index]
			if positions[index].distance_squared_to(_black_hole_positions[black_hole_index]) <= contact_radius * contact_radius:
				absorbed_indices.append(index)
				break
	for index in absorbed_indices:
		if deactivate_ball(index):
			var global_level := global_levels[index]
			var definition = _ball_catalog.get_definition(global_level)
			black_hole_absorbed.emit(definition.score_value, global_level, positions[index])
