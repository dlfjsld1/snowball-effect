class_name BallSimulationManager
extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const SpatialGridScript = preload("res://scripts/simulation/spatial_grid.gd")

signal ball_count_changed(active_count: int)
signal cashout_completed(score_amount: float, global_level: int, world_position: Vector2)
signal ball_merged(result_level: int, world_position: Vector2)
signal top_ball_created(global_level: int)
signal simulation_metrics_updated(metrics: Dictionary)

@export var play_field_rect := Rect2(500.0, 0.0, 600.0, 900.0)
@export_range(0.0, 1.0, 0.01) var wall_restitution := 1.0
@export var base_cashout_score := 1.0
@export var cashout_enabled := true
@export var merge_enabled := true
@export var maximum_ball_runtime_speed := 900.0
@export var stage_base_ball_radius := 4.0
@export_range(1.0, 1024.0, 1.0, "or_greater") var spatial_grid_cell_size := 32.0

var positions := PackedVector2Array()
var velocities := PackedVector2Array()
var radii := PackedFloat32Array()
var global_levels := PackedInt32Array()
var active_flags := PackedByteArray()
var paddle_contact_locks := PackedByteArray()
var active_indices: Array[int] = []
var free_indices: Array[int] = []
var _paddle_collision_provider: Node
var _ball_catalog = BallCatalogScript.new()
var _spatial_grid = SpatialGridScript.new()
var _stage_ball_levels := PackedInt32Array()
var _last_candidate_count := 0
var _last_grid_cell_count := 0
var _last_merge_count := 0
var _merge_candidate_pairs: Array[Vector2i] = []
var _merge_plans: Array[Dictionary] = []
var _consumed_merge_flags := PackedByteArray()
var _pending_cashout_indices: Array[int] = []
var _pending_cashout_positions := PackedVector2Array()
var _render_snapshot_positions := PackedVector2Array()
var _render_snapshot_radii := PackedFloat32Array()
var _render_snapshot := {
	"positions": _render_snapshot_positions,
	"radii": _render_snapshot_radii,
	"count": 0,
}
var _simulation_metrics := {
	"active_balls": 0,
	"slot_capacity": 0,
	"free_slots": 0,
	"candidate_count": 0,
	"grid_cell_count": 0,
	"grid_bucket_capacity": 0,
	"grid_new_buckets": 0,
	"merges": 0,
}


func _physics_process(delta: float) -> void:
	step_simulation(delta)


func spawn_ball(position: Vector2, velocity := Vector2.ZERO, radius := 6.0, global_level := 0) -> int:
	assert(radius > 0.0, "Ball radius must be positive.")
	assert(global_level >= 0, "Ball global level must not be negative.")
	assert(_ball_catalog.has_definition(global_level), "Ball global level must have a catalog definition.")

	var index: int
	if free_indices.is_empty():
		index = positions.size()
		positions.append(position)
		velocities.append(velocity)
		radii.append(radius)
		global_levels.append(global_level)
		active_flags.append(1)
		paddle_contact_locks.append(0)
	else:
		index = free_indices.pop_back()
		positions[index] = position
		velocities[index] = velocity
		radii[index] = radius
		global_levels[index] = global_level
		active_flags[index] = 1
		paddle_contact_locks[index] = 0

	active_indices.append(index)
	ball_count_changed.emit(active_indices.size())
	return index


func deactivate_ball(index: int) -> bool:
	if not is_ball_active(index):
		return false

	active_flags[index] = 0
	paddle_contact_locks[index] = 0
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


func get_capacity() -> int:
	return positions.size()


func configure_stage_ball_levels(ordered_global_levels: PackedInt32Array) -> void:
	_stage_ball_levels = ordered_global_levels.duplicate()


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


func get_merge_candidate_pairs() -> Array[Vector2i]:
	_rebuild_merge_candidate_pairs()
	return _merge_candidate_pairs.duplicate()


func _rebuild_merge_candidate_pairs() -> Array[Vector2i]:
	_spatial_grid.cell_size = spatial_grid_cell_size
	_spatial_grid.rebuild(positions, radii, global_levels, active_indices)
	_spatial_grid.fill_overlapping_pairs(positions, radii, global_levels, _merge_candidate_pairs)
	_last_candidate_count = _spatial_grid.get_candidate_check_count()
	_last_grid_cell_count = _spatial_grid.get_cell_count()
	return _merge_candidate_pairs


func get_spatial_metrics() -> Dictionary:
	return {
		"candidate_count": _last_candidate_count,
		"grid_cell_count": _last_grid_cell_count,
		"grid_bucket_capacity": _spatial_grid.get_allocated_bucket_count(),
		"grid_new_buckets": _spatial_grid.get_new_bucket_count(),
	}


func get_simulation_metrics() -> Dictionary:
	_update_simulation_metrics()
	return _simulation_metrics


func commit_merge_candidates() -> int:
	_last_merge_count = 0
	_merge_plans.clear()
	_consumed_merge_flags.resize(positions.size())
	_consumed_merge_flags.fill(0)
	for candidate in _rebuild_merge_candidate_pairs():
		var first_index := candidate.x
		var second_index := candidate.y
		if _consumed_merge_flags[first_index] == 1 or _consumed_merge_flags[second_index] == 1:
			continue
		if not is_ball_active(first_index) or not is_ball_active(second_index):
			continue

		var result_level := global_levels[first_index] + 1
		if not _ball_catalog.has_definition(result_level):
			continue

		_consumed_merge_flags[first_index] = 1
		_consumed_merge_flags[second_index] = 1
		_merge_plans.append({
			"first_index": first_index,
			"second_index": second_index,
			"result_level": result_level,
			"position": (positions[first_index] + positions[second_index]) * 0.5,
			"velocity": _get_merge_result_velocity(first_index, second_index),
		})

	for plan in _merge_plans:
		deactivate_ball(plan["first_index"])
		deactivate_ball(plan["second_index"])

	for plan in _merge_plans:
		var result_level: int = plan["result_level"]
		var result_position: Vector2 = plan["position"]
		spawn_ball(result_position, plan["velocity"], get_runtime_radius_for_level(result_level), result_level)
		ball_merged.emit(result_level, result_position)
		top_ball_created.emit(result_level)

	_last_merge_count = _merge_plans.size()
	return _last_merge_count


func set_paddle_collision_provider(provider: Node) -> void:
	assert(provider == null or provider.has_method("resolve_continuous_ball_collision"), "Paddle provider must expose resolve_continuous_ball_collision().")
	_paddle_collision_provider = provider


func reset_runtime() -> void:
	positions.clear()
	velocities.clear()
	radii.clear()
	global_levels.clear()
	active_flags.clear()
	paddle_contact_locks.clear()
	active_indices.clear()
	free_indices.clear()
	_last_candidate_count = 0
	_last_grid_cell_count = 0
	_last_merge_count = 0
	_merge_candidate_pairs.clear()
	_merge_plans.clear()
	_consumed_merge_flags.clear()
	_pending_cashout_indices.clear()
	_pending_cashout_positions.clear()
	_render_snapshot_positions.clear()
	_render_snapshot_radii.clear()
	_update_simulation_metrics()
	ball_count_changed.emit(0)


func step_simulation(delta: float) -> void:
	if delta <= 0.0:
		return
	if is_instance_valid(_paddle_collision_provider) and _paddle_collision_provider.has_method("prepare_physics_transform"):
		# Simulation runs before the sibling Paddle node in Main, so it prepares the shared transform once.
		_paddle_collision_provider.prepare_physics_transform(delta)

	for index in active_indices:
		var velocity := velocities[index]
		var position := positions[index]
		var radius := radii[index]

		if is_instance_valid(_paddle_collision_provider):
			if paddle_contact_locks[index] == 1 and _paddle_collision_provider.is_ball_separated(position, radius):
				paddle_contact_locks[index] = 0
			if paddle_contact_locks[index] == 0:
				var collision: Dictionary = _paddle_collision_provider.resolve_continuous_ball_collision(position, velocity, radius, delta)
				position = collision["position"]
				velocity = collision["velocity"]
				if collision["collided"]:
					paddle_contact_locks[index] = 1
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

	if merge_enabled:
		commit_merge_candidates()
	else:
		_rebuild_merge_candidate_pairs()
		_last_merge_count = 0

	_pending_cashout_indices.clear()
	_pending_cashout_positions.clear()
	if cashout_enabled:
		for index in active_indices:
			if positions[index].y - radii[index] > play_field_rect.end.y:
				_pending_cashout_indices.append(index)
				_pending_cashout_positions.append(positions[index])

	for cashout_index in range(_pending_cashout_indices.size()):
		var ball_index := _pending_cashout_indices[cashout_index]
		if deactivate_ball(ball_index):
			var global_level := global_levels[ball_index]
			var definition = _ball_catalog.get_definition(global_level)
			cashout_completed.emit(definition.score_value, global_level, _pending_cashout_positions[cashout_index])

	_update_simulation_metrics()
	simulation_metrics_updated.emit(_simulation_metrics)


func get_render_snapshot() -> Dictionary:
	var active_count := active_indices.size()
	_render_snapshot_positions.resize(active_count)
	_render_snapshot_radii.resize(active_count)

	for snapshot_index in range(active_count):
		var ball_index := active_indices[snapshot_index]
		_render_snapshot_positions[snapshot_index] = positions[ball_index]
		_render_snapshot_radii[snapshot_index] = radii[ball_index]

	_render_snapshot["positions"] = _render_snapshot_positions
	_render_snapshot["radii"] = _render_snapshot_radii
	_render_snapshot["count"] = active_count
	return _render_snapshot


func _update_simulation_metrics() -> void:
	_simulation_metrics["active_balls"] = active_indices.size()
	_simulation_metrics["slot_capacity"] = positions.size()
	_simulation_metrics["free_slots"] = free_indices.size()
	_simulation_metrics["candidate_count"] = _last_candidate_count
	_simulation_metrics["grid_cell_count"] = _last_grid_cell_count
	_simulation_metrics["grid_bucket_capacity"] = _spatial_grid.get_allocated_bucket_count()
	_simulation_metrics["grid_new_buckets"] = _spatial_grid.get_new_bucket_count()
	_simulation_metrics["merges"] = _last_merge_count


func _get_merge_result_velocity(first_index: int, second_index: int) -> Vector2:
	var first_mass: float = _ball_catalog.get_definition(global_levels[first_index]).mass
	var second_mass: float = _ball_catalog.get_definition(global_levels[second_index]).mass
	var total_mass := first_mass + second_mass
	var result_velocity := (velocities[first_index] + velocities[second_index]) * 0.5
	if total_mass > 0.0:
		result_velocity = (velocities[first_index] * first_mass + velocities[second_index] * second_mass) / total_mass
	return result_velocity.limit_length(maximum_ball_runtime_speed)
