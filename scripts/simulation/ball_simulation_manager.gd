class_name BallSimulationManager
extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")

signal ball_count_changed(active_count: int)
signal cashout_completed(score_amount: float, global_level: int, world_position: Vector2)
signal ball_merged(result_level: int, world_position: Vector2)
signal top_ball_created(global_level: int)

@export var play_field_rect := Rect2(500.0, 0.0, 600.0, 900.0)
@export_range(0.0, 1.0, 0.01) var wall_restitution := 1.0
@export var base_cashout_score := 1.0
@export var cashout_enabled := true
@export var maximum_ball_runtime_speed := 900.0

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


func get_ball_global_level(index: int) -> int:
	if not is_ball_active(index):
		return -1
	return global_levels[index]


func get_merge_candidate_pairs() -> Array[Vector2i]:
	var candidates: Array[Vector2i] = []
	var sorted_indices: Array[int] = active_indices.duplicate()
	sorted_indices.sort()

	for first_position in range(sorted_indices.size()):
		var first_index := sorted_indices[first_position]
		var first_level := global_levels[first_index]
		for second_position in range(first_position + 1, sorted_indices.size()):
			var second_index := sorted_indices[second_position]
			if first_level != global_levels[second_index]:
				continue

			var combined_radius := radii[first_index] + radii[second_index]
			if positions[first_index].distance_squared_to(positions[second_index]) <= combined_radius * combined_radius:
				candidates.append(Vector2i(first_index, second_index))

	return candidates


func commit_merge_candidates() -> int:
	var merge_plans: Array[Dictionary] = []
	var consumed_indices := {}
	for candidate in get_merge_candidate_pairs():
		var first_index := candidate.x
		var second_index := candidate.y
		if consumed_indices.has(first_index) or consumed_indices.has(second_index):
			continue
		if not is_ball_active(first_index) or not is_ball_active(second_index):
			continue

		var result_level := global_levels[first_index] + 1
		if not _ball_catalog.has_definition(result_level):
			continue

		consumed_indices[first_index] = true
		consumed_indices[second_index] = true
		merge_plans.append({
			"first_index": first_index,
			"second_index": second_index,
			"result_level": result_level,
			"position": (positions[first_index] + positions[second_index]) * 0.5,
			"velocity": _get_merge_result_velocity(first_index, second_index),
		})

	for plan in merge_plans:
		deactivate_ball(plan["first_index"])
		deactivate_ball(plan["second_index"])

	for plan in merge_plans:
		var result_level: int = plan["result_level"]
		var result_definition = _ball_catalog.get_definition(result_level)
		var result_position: Vector2 = plan["position"]
		spawn_ball(result_position, plan["velocity"], result_definition.radius, result_level)
		ball_merged.emit(result_level, result_position)
		top_ball_created.emit(result_level)

	return merge_plans.size()


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

	commit_merge_candidates()

	var pending_cashouts: Array[Dictionary] = []
	if cashout_enabled:
		for index in active_indices:
			if positions[index].y - radii[index] > play_field_rect.end.y:
				pending_cashouts.append({"index": index, "position": positions[index]})

	for cashout in pending_cashouts:
		var ball_index: int = cashout["index"]
		if deactivate_ball(ball_index):
			var global_level := global_levels[ball_index]
			var definition = _ball_catalog.get_definition(global_level)
			cashout_completed.emit(definition.score_value, global_level, cashout["position"])


func get_render_snapshot() -> Dictionary:
	var snapshot_positions := PackedVector2Array()
	var snapshot_radii := PackedFloat32Array()
	var active_count := active_indices.size()
	snapshot_positions.resize(active_count)
	snapshot_radii.resize(active_count)

	for snapshot_index in range(active_count):
		var ball_index := active_indices[snapshot_index]
		snapshot_positions[snapshot_index] = positions[ball_index]
		snapshot_radii[snapshot_index] = radii[ball_index]

	return {
		"positions": snapshot_positions,
		"radii": snapshot_radii,
		"count": active_count,
	}


func _get_merge_result_velocity(first_index: int, second_index: int) -> Vector2:
	var first_mass: float = _ball_catalog.get_definition(global_levels[first_index]).mass
	var second_mass: float = _ball_catalog.get_definition(global_levels[second_index]).mass
	var total_mass := first_mass + second_mass
	var result_velocity := (velocities[first_index] + velocities[second_index]) * 0.5
	if total_mass > 0.0:
		result_velocity = (velocities[first_index] * first_mass + velocities[second_index] * second_mass) / total_mass
	return result_velocity.limit_length(maximum_ball_runtime_speed)
