class_name BallSimulationManager
extends Node

signal ball_count_changed(active_count: int)
signal cashout_completed(score_amount: float, local_level: int, world_position: Vector2)

@export var play_field_rect := Rect2(500.0, 0.0, 600.0, 900.0)
@export_range(0.0, 1.0, 0.01) var wall_restitution := 1.0
@export var base_cashout_score := 1.0
@export var cashout_enabled := true

var positions := PackedVector2Array()
var velocities := PackedVector2Array()
var radii := PackedFloat32Array()
var active_flags := PackedByteArray()
var paddle_contact_locks := PackedByteArray()
var active_indices: Array[int] = []
var free_indices: Array[int] = []
var _paddle_collision_provider: Node


func _physics_process(delta: float) -> void:
	step_simulation(delta)


func spawn_ball(position: Vector2, velocity := Vector2.ZERO, radius := 6.0) -> int:
	assert(radius > 0.0, "Ball radius must be positive.")

	var index: int
	if free_indices.is_empty():
		index = positions.size()
		positions.append(position)
		velocities.append(velocity)
		radii.append(radius)
		active_flags.append(1)
		paddle_contact_locks.append(0)
	else:
		index = free_indices.pop_back()
		positions[index] = position
		velocities[index] = velocity
		radii[index] = radius
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


func set_paddle_collision_provider(provider: Node) -> void:
	assert(provider == null or provider.has_method("resolve_continuous_ball_collision"), "Paddle provider must expose resolve_continuous_ball_collision().")
	_paddle_collision_provider = provider


func reset_runtime() -> void:
	positions.clear()
	velocities.clear()
	radii.clear()
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

	var pending_cashouts: Array[Dictionary] = []
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
		if cashout_enabled and position.y - radius > play_field_rect.end.y:
			pending_cashouts.append({"index": index, "position": position})

	for cashout in pending_cashouts:
		var ball_index: int = cashout["index"]
		if deactivate_ball(ball_index):
			cashout_completed.emit(base_cashout_score, 0, cashout["position"])


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
