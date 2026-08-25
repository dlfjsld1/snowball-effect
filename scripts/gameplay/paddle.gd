class_name Paddle
extends Node2D

const FIRE_FRAME_COUNT := 6
const FIRE_FRAME_WIDTH := 240.0
const FIRE_FRAME_HEIGHT := 16.0
const FIRE_ANIMATION_FPS := 12.0

enum PositionControlSource {
	KEYBOARD,
	MOUSE,
}

enum DashPhase {
	READY,
	ASCENDING,
	RETURNING,
}

@export var play_field_rect := Rect2(500.0, 0.0, 600.0, 900.0)
@export var paddle_width := 168.0
@export var paddle_thickness := 16.0
@export var move_speed := 460.0
@export var rotation_speed_degrees := 150.0
@export var mouse_wheel_step_degrees := 5.0
@export var minimum_reflection_speed := 220.0
@export var minimum_normal_speed := 180.0
@export var maximum_reflection_speed := 900.0
@export var maximum_impact_velocity := 900.0
@export var contact_position_influence := 80.0
@export var paddle_velocity_influence := 0.15
@export var rotation_collision_tip_step := 2.0
@export var separation_epsilon := 0.01
@export var dash_speed := 1200.0
@export var dash_distance := 120.0
@export var dash_cooldown_seconds := 5.0
@export var runtime_start_position := Vector2.ZERO


var linear_velocity := Vector2.ZERO
var angular_velocity := 0.0
var _fire_contact_active := false
var _fire_animation_elapsed := 0.0

var _initial_position := Vector2.ZERO
var _initial_rotation := 0.0
var _previous_position := Vector2.ZERO
var _previous_rotation := 0.0
var _signed_angle_displacement := 0.0
var _has_mouse_target := false
var _mouse_target_x := 0.0
var _position_control_source := PositionControlSource.KEYBOARD
var _pending_wheel_rotation_degrees := 0.0
var _prepared_physics_frame := -1
var _dash_phase := DashPhase.READY
var _dash_origin_y := 0.0
var _dash_target_y := 0.0
var _dash_phase_elapsed := 0.0
var _dash_leg_duration := 0.0
var _dash_cooldown_remaining := 0.0
const DASH_AFTERIMAGE_DURATION := 0.55
var _dash_trail_remaining := 0.0
var _dash_trail_direction := Vector2.DOWN


func _ready() -> void:
	if runtime_start_position != Vector2.ZERO:
		position = runtime_start_position
	_initial_position = position
	_initial_rotation = rotation
	_reset_motion_history()
	_update_dash_visuals()
	_update_fire_visual()


func set_fire_contact_active(active: bool) -> void:
	if active and not _fire_contact_active:
		_fire_animation_elapsed = 0.0
	_fire_contact_active = active
	if not active:
		_fire_animation_elapsed = 0.0
	_update_fire_visual()


func is_fire_contact_active() -> bool:
	return _fire_contact_active


func get_fire_visual_snapshot() -> Dictionary:
	var fire_visual := get_node_or_null("FireVisual") as Sprite2D
	if fire_visual == null:
		return {"visible": false, "frame": -1, "frame_count": FIRE_FRAME_COUNT}
	return {
		"visible": fire_visual.visible,
		"frame": int(roundf(fire_visual.region_rect.position.x / FIRE_FRAME_WIDTH)),
		"frame_count": FIRE_FRAME_COUNT,
	}


func _physics_process(delta: float) -> void:
	prepare_physics_transform(delta)
	_advance_fire_visual(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Node2D global mouse coordinates are Canvas/world coordinates, not raw viewport pixels.
		_set_mouse_position_target(get_global_mouse_position().x)
	elif event is InputEventKey and event.pressed and (
		event.is_action_pressed("paddle_move_left") or event.is_action_pressed("paddle_move_right")
	):
		_activate_keyboard_position_control()
	elif event.is_action_pressed("paddle_dash"):
		try_start_dash()
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_pending_wheel_rotation_degrees += mouse_wheel_step_degrees * maxf(event.factor, 1.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_pending_wheel_rotation_degrees -= mouse_wheel_step_degrees * maxf(event.factor, 1.0)


func prepare_physics_transform(delta: float) -> void:
	var frame := Engine.get_physics_frames()
	if _prepared_physics_frame == frame:
		return
	_prepared_physics_frame = frame

	var move_axis := Input.get_axis("paddle_move_left", "paddle_move_right")
	var position_move_axis := move_axis if _position_control_source == PositionControlSource.KEYBOARD else 0.0
	var mouse_target_x := _active_mouse_target_x()
	var wheel_rotation_degrees := _pending_wheel_rotation_degrees
	_pending_wheel_rotation_degrees = 0.0
	apply_input(
		position_move_axis,
		Input.get_axis("paddle_rotate_left", "paddle_rotate_right"),
		delta,
		mouse_target_x,
		wheel_rotation_degrees
	)


func apply_input(
	move_axis: float,
	rotate_axis: float,
	delta: float,
	mouse_target_x: float = INF,
	wheel_rotation_degrees: float = 0.0
) -> void:
	if delta <= 0.0:
		linear_velocity = Vector2.ZERO
		angular_velocity = 0.0
		_signed_angle_displacement = 0.0
		return

	_previous_position = global_position
	_previous_rotation = global_rotation
	_signed_angle_displacement = rotate_axis * deg_to_rad(rotation_speed_degrees) * delta + deg_to_rad(wheel_rotation_degrees)
	rotation = wrapf(rotation + _signed_angle_displacement, -PI, PI)

	if is_zero_approx(move_axis) and is_finite(mouse_target_x):
		# Mouse is a direct logical-X control. Its velocity is derived from this real transform change.
		position.x = mouse_target_x
	else:
		var target_x := position.x + move_axis * move_speed * delta
		position.x = move_toward(position.x, target_x, move_speed * delta)
	_advance_dash(delta)
	_clamp_position_to_play_field()

	linear_velocity = (global_position - _previous_position) / delta
	angular_velocity = _signed_angle_displacement / delta


func get_collision_state() -> Dictionary:
	return {
		"previous_position": _previous_position,
		"previous_rotation": _previous_rotation,
		"position": global_position,
		"rotation": global_rotation,
		"linear_velocity": linear_velocity,
		"angular_velocity": angular_velocity,
		"half_width": paddle_width * 0.5,
		"half_thickness": paddle_thickness * 0.5,
	}


func reset_runtime() -> void:
	position = _initial_position
	rotation = _initial_rotation
	_fire_contact_active = false
	_fire_animation_elapsed = 0.0
	_has_mouse_target = false
	_mouse_target_x = _initial_position.x
	_position_control_source = PositionControlSource.KEYBOARD
	_pending_wheel_rotation_degrees = 0.0
	_prepared_physics_frame = -1
	_dash_phase = DashPhase.READY
	_dash_origin_y = _initial_position.y
	_dash_target_y = _initial_position.y
	_dash_phase_elapsed = 0.0
	_dash_leg_duration = 0.0
	_dash_cooldown_remaining = 0.0
	_dash_trail_remaining = 0.0
	_dash_trail_direction = Vector2.DOWN
	_update_dash_visuals()
	_update_fire_visual()
	_reset_motion_history()


func _advance_fire_visual(delta: float) -> void:
	if not _fire_contact_active or delta <= 0.0:
		return
	_fire_animation_elapsed += delta
	_update_fire_visual()


func _update_fire_visual() -> void:
	var fire_visual := get_node_or_null("FireVisual") as Sprite2D
	if fire_visual == null:
		return
	fire_visual.visible = _fire_contact_active
	var frame := 0
	if _fire_contact_active:
		frame = int(floor(_fire_animation_elapsed * FIRE_ANIMATION_FPS)) % FIRE_FRAME_COUNT
	fire_visual.region_rect = Rect2(
		Vector2(FIRE_FRAME_WIDTH * frame, 0.0),
		Vector2(FIRE_FRAME_WIDTH, FIRE_FRAME_HEIGHT)
	)


func try_start_dash() -> bool:
	if _dash_phase != DashPhase.READY or _dash_cooldown_remaining > 0.0:
		return false
	if dash_speed <= 0.0 or dash_distance <= 0.0:
		return false
	_dash_origin_y = position.y
	_dash_target_y = maxf(_top_limit(), _dash_origin_y - dash_distance)
	if is_equal_approx(_dash_target_y, _dash_origin_y):
		return false
	_dash_phase = DashPhase.ASCENDING
	_dash_phase_elapsed = 0.0
	_dash_leg_duration = absf(_dash_target_y - _dash_origin_y) / dash_speed
	_dash_cooldown_remaining = dash_cooldown_seconds
	_dash_trail_remaining = DASH_AFTERIMAGE_DURATION
	_dash_trail_direction = Vector2.DOWN
	_update_dash_visuals()
	return true


func get_dash_cooldown_remaining() -> float:
	return _dash_cooldown_remaining


func reset_dash_cooldown() -> void:
	_dash_cooldown_remaining = 0.0
	_update_dash_visuals()


func is_dashing() -> bool:
	return _dash_phase != DashPhase.READY


func _advance_dash(delta: float) -> void:
	if _dash_cooldown_remaining > 0.0:
		_dash_cooldown_remaining = maxf(0.0, _dash_cooldown_remaining - delta)
	if _dash_trail_remaining > 0.0:
		_dash_trail_remaining = maxf(0.0, _dash_trail_remaining - delta)
	if _dash_phase == DashPhase.ASCENDING:
		_dash_trail_direction = Vector2.DOWN
		_dash_phase_elapsed += delta
		var ascend_progress := _dash_progress()
		position.y = lerpf(_dash_origin_y, _dash_target_y, _ease_out_sine(ascend_progress))
		if ascend_progress >= 1.0:
			_dash_phase = DashPhase.RETURNING
			_dash_phase_elapsed = 0.0
	elif _dash_phase == DashPhase.RETURNING:
		_dash_trail_direction = Vector2.UP
		_dash_phase_elapsed += delta
		var return_progress := _dash_progress()
		position.y = lerpf(_dash_target_y, _dash_origin_y, _ease_in_out_sine(return_progress))
		if return_progress >= 1.0:
			position.y = _dash_origin_y
			_dash_phase = DashPhase.READY
	_update_dash_visuals()


func _dash_progress() -> float:
	if _dash_leg_duration <= 0.0:
		return 1.0
	return clampf(_dash_phase_elapsed / _dash_leg_duration, 0.0, 1.0)


func _ease_out_sine(value: float) -> float:
	return sin(value * PI * 0.5)


func _ease_in_out_sine(value: float) -> float:
	return -(cos(PI * value) - 1.0) * 0.5


func _update_dash_visuals() -> void:
	var gauge_fill := get_node_or_null("DashGaugeFill") as Polygon2D
	if gauge_fill != null:
		var ratio := 1.0
		if dash_cooldown_seconds > 0.0:
			ratio = clampf(1.0 - _dash_cooldown_remaining / dash_cooldown_seconds, 0.0, 1.0)
		gauge_fill.polygon = PackedVector2Array([
			Vector2(-13.0, -2.0),
			Vector2(-13.0 + 25.0 * ratio, -2.0),
			Vector2(-13.0 + 25.0 * ratio, 2.0),
			Vector2(-13.0, 2.0),
		])
	var visual := get_node_or_null("Visual") as Sprite2D
	if visual == null:
		return
	var ghost_near := get_node_or_null("DashGhostNear") as Sprite2D
	var ghost_mid := get_node_or_null("DashGhostMid") as Sprite2D
	var ghost_far := get_node_or_null("DashGhostFar") as Sprite2D
	if _dash_phase == DashPhase.ASCENDING:
		visual.scale = Vector2(1.08, 0.82)
		visual.modulate = Color(1.32, 1.32, 1.22, 1.0)
		_update_dash_afterimages(ghost_near, ghost_mid, ghost_far, Vector2.DOWN, 1.0)
	elif _dash_phase == DashPhase.RETURNING:
		visual.scale = Vector2(0.94, 1.08)
		visual.modulate = Color(1.16, 1.22, 1.16, 1.0)
		_update_dash_afterimages(ghost_near, ghost_mid, ghost_far, Vector2.UP, 1.0)
	else:
		visual.scale = Vector2.ONE
		visual.modulate = Color.WHITE
		var fade := clampf(_dash_trail_remaining / DASH_AFTERIMAGE_DURATION, 0.0, 1.0)
		if fade > 0.0:
			_update_dash_afterimages(ghost_near, ghost_mid, ghost_far, _dash_trail_direction, fade)
		else:
			_hide_dash_afterimages(ghost_near, ghost_mid, ghost_far)


func _update_dash_afterimages(
	near: Sprite2D,
	mid: Sprite2D,
	far: Sprite2D,
	trail_direction: Vector2,
	intensity: float
) -> void:
	# The Paddle can rotate, but dash travel and its trail are always world-vertical.
	# Child Sprite2D positions are local, so convert the requested world direction
	# back into Paddle-local space before placing the ghosts.
	var local_trail_direction := trail_direction.rotated(-global_rotation)
	if near != null:
		near.visible = true
		near.position = local_trail_direction * 28.0
		near.scale = Vector2(1.02, 0.94)
		near.modulate = Color(0.24, 1.0, 0.60, 0.72 * intensity)
	if mid != null:
		mid.visible = true
		mid.position = local_trail_direction * 56.0
		mid.scale = Vector2(1.0, 0.88)
		mid.modulate = Color(0.20, 0.98, 0.56, 0.48 * intensity)
	if far != null:
		far.visible = true
		far.position = local_trail_direction * 84.0
		far.scale = Vector2(0.98, 0.82)
		far.modulate = Color(0.16, 0.94, 0.50, 0.30 * intensity)


func _hide_dash_afterimages(near: Sprite2D, mid: Sprite2D, far: Sprite2D) -> void:
	if near != null:
		near.visible = false
	if mid != null:
		mid.visible = false
	if far != null:
		far.visible = false


func clamp_to_play_field() -> void:
	_clamp_position_to_play_field()
	if _has_mouse_target:
		_mouse_target_x = clampf(_mouse_target_x, _left_limit(), _right_limit())
	_reset_motion_history()


func resolve_continuous_ball_collision(
	ball_start: Vector2,
	ball_velocity: Vector2,
	ball_radius: float,
	delta: float
) -> Dictionary:
	if delta <= 0.0 or not _is_swept_candidate(ball_start, ball_velocity, ball_radius, delta):
		return _no_collision(ball_start + ball_velocity * delta, ball_velocity)

	var half_extents := Vector2(paddle_width * 0.5 + ball_radius, paddle_thickness * 0.5 + ball_radius)
	var tip_radius := Vector2(paddle_width * 0.5, paddle_thickness * 0.5).length()
	var substeps := maxi(1, ceili(absf(_signed_angle_displacement) * tip_radius / rotation_collision_tip_step))
	var earliest: Dictionary = {}

	for step in range(substeps):
		var start_t := float(step) / float(substeps)
		var end_t := float(step + 1) / float(substeps)
		var midpoint_t := (start_t + end_t) * 0.5
		var paddle_start := _previous_position.lerp(global_position, start_t)
		var paddle_end := _previous_position.lerp(global_position, end_t)
		var sample_rotation := _previous_rotation + _signed_angle_displacement * midpoint_t
		var ball_interval_start := ball_start + ball_velocity * (delta * start_t)
		var ball_interval_end := ball_start + ball_velocity * (delta * end_t)
		var relative_start := (ball_interval_start - paddle_start).rotated(-sample_rotation)
		var relative_end := (ball_interval_end - paddle_end).rotated(-sample_rotation)
		var toi := _segment_expanded_obb_toi(relative_start, relative_end, half_extents)
		if not toi["hit"]:
			continue

		var local_t: float = toi["time"]
		var global_t := lerpf(start_t, end_t, local_t)
		var normal := (toi["normal"] as Vector2).rotated(sample_rotation)
		var ball_at_contact := ball_start + ball_velocity * (delta * global_t)
		var paddle_center := _previous_position.lerp(global_position, global_t)
		var contact_point := ball_at_contact - normal * ball_radius
		var corrected_position := ball_at_contact + normal * separation_epsilon
		if toi["starts_inside"]:
			# A direct Mouse sweep can begin already inside a large ball. Correct against
			# the final Paddle transform so the Paddle cannot move through it again.
			paddle_center = global_position
			sample_rotation = global_rotation
			var penetration := _resolve_inside_ball_overlap(
				ball_at_contact,
				paddle_center,
				sample_rotation,
				ball_radius,
				normal
			)
			if not penetration["overlapping"]:
				continue
			normal = penetration["normal"]
			contact_point = penetration["contact_position"]
			corrected_position = penetration["corrected_position"]
		var impact_velocity := _contact_impact_velocity(contact_point - paddle_center)
		# Contact validity follows the actual swept Paddle transform. The impact cap limits
		# only the energy transferred after a hit; it must not make a fast Mouse sweep look
		# stationary and let a ball remain inside the Paddle.
		var relative_velocity := ball_velocity - _raw_contact_velocity(contact_point - paddle_center)
		if relative_velocity.dot(normal) >= 0.0 and not toi["starts_inside"]:
			continue
		earliest = {
			"time": global_t,
			"normal": normal,
			"ball_position": ball_at_contact,
			"paddle_center": paddle_center,
			"rotation": sample_rotation,
			"contact_position": contact_point,
			"impact_velocity": impact_velocity,
			"corrected_position": corrected_position,
		}
		break

	if earliest.is_empty():
		return _no_collision(ball_start + ball_velocity * delta, ball_velocity)

	var normal: Vector2 = earliest["normal"]
	var impact_velocity: Vector2 = earliest["impact_velocity"]
	var reflected_velocity := _reflect_velocity(
		ball_velocity,
		impact_velocity,
		normal,
		earliest["contact_position"] - earliest["paddle_center"],
		earliest["rotation"]
	)
	var remaining_time: float = delta * (1.0 - earliest["time"])
	var corrected_position: Vector2 = earliest["corrected_position"]
	var resolved_position := corrected_position + reflected_velocity * remaining_time
	# The swept hit can happen early in a large direct Mouse translation. Projecting the
	# reflected Ball through the remaining tick alone can still leave it inside the final
	# Paddle transform, which would preserve the contact lock and look like a pass-through.
	# Correct once against that final transform; this is separation, not a second reflection.
	var final_overlap := _resolve_inside_ball_overlap(
		resolved_position,
		global_position,
		global_rotation,
		ball_radius,
		normal
	)
	if final_overlap["overlapping"]:
		resolved_position = final_overlap["corrected_position"]
	return {
		"collided": true,
		"position": resolved_position,
		"velocity": reflected_velocity,
		"contact_position": earliest["contact_position"],
		"normal": normal,
		"time": earliest["time"],
	}


func is_ball_separated(ball_position: Vector2, ball_radius: float) -> bool:
	return _is_ball_separated_from_transform(ball_position, ball_radius, global_position, global_rotation)


func was_ball_separated_before_current_motion(ball_position: Vector2, ball_radius: float) -> bool:
	return _is_ball_separated_from_transform(ball_position, ball_radius, _previous_position, _previous_rotation)


func _is_ball_separated_from_transform(
	ball_position: Vector2,
	ball_radius: float,
	paddle_center: Vector2,
	paddle_rotation: float
) -> bool:
	var local_position := (ball_position - paddle_center).rotated(-paddle_rotation)
	var closest := Vector2(
		clampf(local_position.x, -paddle_width * 0.5, paddle_width * 0.5),
		clampf(local_position.y, -paddle_thickness * 0.5, paddle_thickness * 0.5)
	)
	return (local_position - closest).length_squared() > pow(ball_radius + separation_epsilon, 2.0)


func is_ball_reapproaching(ball_position: Vector2, ball_velocity: Vector2, contact_normal: Vector2) -> bool:
	if contact_normal.is_zero_approx():
		return false
	return (ball_velocity - _raw_contact_velocity(ball_position - global_position)).dot(contact_normal) < -separation_epsilon


func get_contact_impact_velocity(contact_world_position: Vector2) -> Vector2:
	return _contact_impact_velocity(contact_world_position - global_position)


func _reflect_velocity(
	ball_velocity: Vector2,
	impact_velocity: Vector2,
	normal: Vector2,
	contact_offset: Vector2,
	contact_rotation: float
) -> Vector2:
	var relative_velocity := ball_velocity - impact_velocity
	var reflected_velocity := relative_velocity.bounce(normal) + impact_velocity
	var tangent := Vector2.RIGHT.rotated(contact_rotation)
	var contact_local_x := contact_offset.rotated(-contact_rotation).x
	var contact_ratio := clampf(contact_local_x / (paddle_width * 0.5), -1.0, 1.0)
	reflected_velocity += tangent * contact_ratio * contact_position_influence
	reflected_velocity += impact_velocity * paddle_velocity_influence

	var normal_speed := reflected_velocity.dot(normal)
	if normal_speed < minimum_normal_speed:
		reflected_velocity += normal * (minimum_normal_speed - normal_speed)
	if reflected_velocity.length() < minimum_reflection_speed:
		reflected_velocity = reflected_velocity.normalized() * minimum_reflection_speed
	if reflected_velocity.length() > maximum_reflection_speed:
		reflected_velocity = reflected_velocity.normalized() * maximum_reflection_speed
	return reflected_velocity


func _contact_impact_velocity(contact_offset: Vector2) -> Vector2:
	return _raw_contact_velocity(contact_offset).limit_length(maximum_impact_velocity)


func _raw_contact_velocity(contact_offset: Vector2) -> Vector2:
	var angular_contact_velocity := angular_velocity * Vector2(-contact_offset.y, contact_offset.x)
	return linear_velocity + angular_contact_velocity


func _segment_expanded_obb_toi(start: Vector2, finish: Vector2, half_extents: Vector2) -> Dictionary:
	if absf(start.x) <= half_extents.x and absf(start.y) <= half_extents.y:
		return {
			"hit": true,
			"starts_inside": true,
			"time": 0.0,
			"normal": _inside_normal(start, finish - start, half_extents),
		}

	var direction := finish - start
	var entry_time := -INF
	var exit_time := INF
	var entry_normal := Vector2.ZERO
	for axis in [Vector2.RIGHT, Vector2.DOWN]:
		var coordinate := start.dot(axis)
		var movement := direction.dot(axis)
		var extent := half_extents.x if axis == Vector2.RIGHT else half_extents.y
		if is_zero_approx(movement):
			if absf(coordinate) > extent:
				return {"hit": false}
			continue
		var near_time := (-extent - coordinate) / movement
		var far_time := (extent - coordinate) / movement
		var near_normal: Vector2 = -axis
		if near_time > far_time:
			var swap_time := near_time
			near_time = far_time
			far_time = swap_time
			near_normal = axis
		if near_time > entry_time:
			entry_time = near_time
			entry_normal = near_normal
		exit_time = minf(exit_time, far_time)
		if entry_time > exit_time:
			return {"hit": false}

	if entry_time < 0.0 or entry_time > 1.0:
		return {"hit": false}
	return {"hit": true, "starts_inside": false, "time": entry_time, "normal": entry_normal}


func _resolve_inside_ball_overlap(
	ball_position: Vector2,
	paddle_center: Vector2,
	paddle_rotation: float,
	ball_radius: float,
	preferred_normal: Vector2
) -> Dictionary:
	var half_extents := Vector2(paddle_width * 0.5, paddle_thickness * 0.5)
	var local_ball := (ball_position - paddle_center).rotated(-paddle_rotation)
	var closest_point := Vector2(
		clampf(local_ball.x, -half_extents.x, half_extents.x),
		clampf(local_ball.y, -half_extents.y, half_extents.y)
	)
	var local_delta := local_ball - closest_point
	if not local_delta.is_zero_approx() and local_delta.length_squared() > ball_radius * ball_radius:
		return {"overlapping": false}

	var local_normal: Vector2
	if not local_delta.is_zero_approx():
		# The center is outside the OBB near an edge or tip. Keep the correction on
		# that actual feature; a swept preferred normal may point at the opposite
		# end and otherwise teleport the ball across the full Paddle length.
		local_normal = local_delta.normalized()
	else:
		# The center is inside the OBB, so there is no geometric outside direction.
		# Use the nearest face and reserve motion direction only for exact ties.
		var face_gaps := [
			half_extents.x - local_ball.x,
			half_extents.x + local_ball.x,
			half_extents.y - local_ball.y,
			half_extents.y + local_ball.y,
		]
		var face_normals := [Vector2.RIGHT, Vector2.LEFT, Vector2.DOWN, Vector2.UP]
		var nearest_index := 0
		for index in range(1, face_gaps.size()):
			if face_gaps[index] < face_gaps[nearest_index] - separation_epsilon:
				nearest_index = index
			elif is_equal_approx(face_gaps[index], face_gaps[nearest_index]):
				var local_preferred := preferred_normal.rotated(-paddle_rotation)
				if face_normals[index].dot(local_preferred) > face_normals[nearest_index].dot(local_preferred):
					nearest_index = index
		local_normal = face_normals[nearest_index]
		if absf(local_normal.x) > 0.0:
			closest_point = Vector2(local_normal.x * half_extents.x, local_ball.y)
		else:
			closest_point = Vector2(local_ball.x, local_normal.y * half_extents.y)

	var normal := local_normal.rotated(paddle_rotation)
	var contact_position := paddle_center + closest_point.rotated(paddle_rotation)
	return {
		"overlapping": true,
		"normal": normal,
		"contact_position": contact_position,
		"corrected_position": contact_position + normal * (ball_radius + separation_epsilon),
	}


func _inside_normal(local_position: Vector2, local_velocity: Vector2, half_extents: Vector2) -> Vector2:
	if absf(local_velocity.x) > absf(local_velocity.y):
		return Vector2.LEFT if local_velocity.x > 0.0 else Vector2.RIGHT
	if not is_zero_approx(local_velocity.y):
		return Vector2.UP if local_velocity.y > 0.0 else Vector2.DOWN
	var horizontal_gap := half_extents.x - absf(local_position.x)
	var vertical_gap := half_extents.y - absf(local_position.y)
	if horizontal_gap < vertical_gap:
		return Vector2.RIGHT if local_position.x >= 0.0 else Vector2.LEFT
	return Vector2.DOWN if local_position.y >= 0.0 else Vector2.UP


func _is_swept_candidate(ball_start: Vector2, ball_velocity: Vector2, ball_radius: float, delta: float) -> bool:
	var padding := Vector2.ONE * (Vector2(paddle_width * 0.5, paddle_thickness * 0.5).length() + ball_radius)
	var min_corner := _previous_position.min(global_position) - padding
	var max_corner := _previous_position.max(global_position) + padding
	var ball_end := ball_start + ball_velocity * delta
	var ball_min := ball_start.min(ball_end)
	var ball_max := ball_start.max(ball_end)
	return not (ball_max.x < min_corner.x or ball_min.x > max_corner.x or ball_max.y < min_corner.y or ball_min.y > max_corner.y)


func _left_limit() -> float:
	return play_field_rect.position.x + _horizontal_half_extent()


func _right_limit() -> float:
	return play_field_rect.end.x - _horizontal_half_extent()


func _top_limit() -> float:
	return play_field_rect.position.y + _vertical_half_extent()


func _bottom_limit() -> float:
	return play_field_rect.end.y - _vertical_half_extent()


func _horizontal_half_extent() -> float:
	return absf(cos(rotation)) * paddle_width * 0.5 + absf(sin(rotation)) * paddle_thickness * 0.5


func _vertical_half_extent() -> float:
	return absf(sin(rotation)) * paddle_width * 0.5 + absf(cos(rotation)) * paddle_thickness * 0.5


func _clamp_position_to_play_field() -> void:
	position.x = clampf(position.x, _left_limit(), _right_limit())
	position.y = clampf(position.y, _top_limit(), _bottom_limit())


func _set_mouse_position_target(world_x: float) -> void:
	_mouse_target_x = world_x
	_has_mouse_target = true
	_position_control_source = PositionControlSource.MOUSE


func _activate_keyboard_position_control() -> void:
	_position_control_source = PositionControlSource.KEYBOARD


func _active_mouse_target_x() -> float:
	if _position_control_source == PositionControlSource.MOUSE and _has_mouse_target:
		return _mouse_target_x
	return INF


func _reset_motion_history() -> void:
	_previous_position = global_position
	_previous_rotation = global_rotation
	_signed_angle_displacement = 0.0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0


func _no_collision(ball_position: Vector2, ball_velocity: Vector2) -> Dictionary:
	return {"collided": false, "position": ball_position, "velocity": ball_velocity}
