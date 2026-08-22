extends Node

const TEST_DELTA := 0.1
const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")

@onready var paddle: Paddle = preload("res://scenes/gameplay/paddle.tscn").instantiate()
var failures := 0


func _ready() -> void:
	paddle.position = Vector2(400.0, 400.0)
	paddle.play_field_rect = Rect2(0.0, 0.0, 800.0, 600.0)
	add_child(paddle)
	await get_tree().process_frame
	_verify_keyboard_input()
	_verify_bilateral_reflection()
	_verify_translation_sweep_and_impact_cap()
	_verify_mouse_recontact_uses_raw_sweep_velocity()
	_verify_mouse_recontact_releases_simulation_lock()
	_verify_tangential_mouse_sweep_releases_stale_lock()
	_verify_large_overlap_correction()
	_verify_tip_overlap_correction_stays_local()
	_verify_rotation_sweep()
	_verify_angular_contact_velocity()
	if failures == 0:
		print("S1_G2_VERIFIED input=simultaneous bilateral=front_back translation_toi impact_cap=900")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(failures)


func _verify_keyboard_input() -> void:
	var start_x := paddle.position.x
	paddle.apply_input(1.0, 1.0, TEST_DELTA)
	_expect(paddle.position.x > start_x, "D must move while Right rotation is held.")
	_expect(paddle.rotation > 0.0, "Right action must rotate while movement is held.")


func _verify_bilateral_reflection() -> void:
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA)
	var front := paddle.resolve_continuous_ball_collision(Vector2(400.0, 370.0), Vector2(0.0, 300.0), 6.0, TEST_DELTA)
	var back := paddle.resolve_continuous_ball_collision(Vector2(400.0, 430.0), Vector2(0.0, -300.0), 6.0, TEST_DELTA)
	_expect(front.collided and back.collided, "Both Paddle faces must collide.")
	_expect(front.velocity.y < 0.0, "Front face must reflect upward.")
	_expect(back.velocity.y > 0.0, "Back face must reflect downward.")

	paddle.rotation = deg_to_rad(90.0)
	paddle.apply_input(0.0, 0.0, TEST_DELTA)
	var rotated_front := paddle.resolve_continuous_ball_collision(Vector2(370.0, 400.0), Vector2(300.0, 0.0), 6.0, TEST_DELTA)
	var rotated_back := paddle.resolve_continuous_ball_collision(Vector2(430.0, 400.0), Vector2(-300.0, 0.0), 6.0, TEST_DELTA)
	_expect(rotated_front.collided and rotated_back.collided, "Both faces must collide after 90-degree rotation.")
	_expect(rotated_front.velocity.x < 0.0 and rotated_back.velocity.x > 0.0, "Rotated normals must reflect on their respective sides.")

	paddle.rotation = PI
	paddle.apply_input(0.0, 0.0, TEST_DELTA)
	var flipped := paddle.resolve_continuous_ball_collision(Vector2(400.0, 370.0), Vector2(0.0, 300.0), 6.0, TEST_DELTA)
	_expect(flipped.collided and flipped.velocity.y < 0.0, "A 180-degree Paddle must retain bilateral collision.")


func _verify_translation_sweep_and_impact_cap() -> void:
	paddle.position = Vector2(120.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA, 680.0)
	var swept_hit := paddle.resolve_continuous_ball_collision(Vector2(400.0, 400.0), Vector2.ZERO, 2.0, TEST_DELTA)
	_expect(swept_hit.collided, "A fast Paddle translation must sweep-hit a stationary Lv1 ball.")
	_expect(swept_hit.velocity.length() <= paddle.maximum_reflection_speed + 0.01, "Sweep reflection must respect the final ball speed cap.")


func _verify_mouse_recontact_uses_raw_sweep_velocity() -> void:
	# A previous hit may have capped the ball at 900 units/s.  A direct Mouse sweep still
	# has to re-enter it when the real Paddle transform moves faster, rather than leaving
	# the ball inside because the capped impact velocity happens to match the ball speed.
	var short_delta := 1.0 / 60.0
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, short_delta, 440.0)
	var ball_position := Vector2(320.0, 400.0)
	var ball_velocity := Vector2(900.0, 0.0)
	_expect(
		paddle.is_ball_reapproaching(ball_position, ball_velocity, Vector2.RIGHT),
		"A direct Mouse sweep must reopen a locked contact when its real transform catches the ball."
	)
	var recontact := paddle.resolve_continuous_ball_collision(ball_position, ball_velocity, 4.0, short_delta)
	_expect(recontact.collided, "A reapproaching Mouse sweep must not leave a capped-speed ball inside the Paddle.")
	if recontact.collided:
		_expect(paddle.is_ball_separated(recontact.position, 4.0), "Mouse recontact correction must eject the ball outside the Paddle.")


func _verify_mouse_recontact_releases_simulation_lock() -> void:
	var simulation: SimulationManager = SimulationManager.new()
	simulation.play_field_rect = Rect2(0.0, 0.0, 800.0, 600.0)
	simulation.cashout_enabled = false
	simulation.merge_enabled = false
	simulation.set_physics_process(false)
	add_child(simulation)
	simulation.set_paddle_collision_provider(paddle)

	var short_delta := 1.0 / 60.0
	paddle.position = Vector2(120.0, 400.0)
	paddle.rotation = 0.0
	paddle._reset_motion_history()
	var ball_index := simulation.spawn_ball(Vector2(300.0, 400.0), Vector2.ZERO, 4.0, 0)
	paddle.apply_input(0.0, 0.0, short_delta, 400.0)
	paddle._prepared_physics_frame = Engine.get_physics_frames()
	simulation.step_simulation(short_delta)
	_expect(simulation.paddle_contact_locks[ball_index] == 1, "The first sweep must establish a contact lock.")

	# The ball is still inside the current Paddle footprint. A second direct Mouse sweep
	# catches it again; the lock must reopen the continuous query instead of skipping it.
	paddle.apply_input(0.0, 0.0, short_delta, 430.0)
	paddle._prepared_physics_frame = Engine.get_physics_frames()
	simulation.step_simulation(short_delta)
	_expect(
		paddle.is_ball_separated(simulation.positions[ball_index], simulation.radii[ball_index]),
		"A rapid Mouse recontact must eject a previously locked ball instead of letting it pass through the Paddle."
	)
	simulation.queue_free()


func _verify_tangential_mouse_sweep_releases_stale_lock() -> void:
	var simulation: SimulationManager = SimulationManager.new()
	simulation.play_field_rect = Rect2(0.0, 0.0, 800.0, 600.0)
	simulation.cashout_enabled = false
	simulation.merge_enabled = false
	simulation.set_physics_process(false)
	add_child(simulation)
	simulation.set_paddle_collision_provider(paddle)

	var short_delta := 1.0 / 60.0
	paddle.position = Vector2(120.0, 400.0)
	paddle.rotation = 0.0
	paddle._reset_motion_history()
	var ball_index := simulation.spawn_ball(Vector2(400.0, 400.0), Vector2.ZERO, 4.0, 0)
	# Model a previous hit from above. A new horizontal Mouse sweep ends on the Ball,
	# so the old vertical lock normal must not suppress the new continuous collision.
	simulation.paddle_contact_locks[ball_index] = 1
	simulation.paddle_contact_lock_normals[ball_index] = Vector2.UP
	paddle.apply_input(0.0, 0.0, short_delta, 400.0)
	paddle._prepared_physics_frame = Engine.get_physics_frames()
	simulation.step_simulation(short_delta)
	_expect(
		paddle.is_ball_separated(simulation.positions[ball_index], simulation.radii[ball_index]),
		"A tangential direct Mouse sweep must release a stale lock and eject the Ball instead of passing through it."
	)
	simulation.queue_free()


func _verify_large_overlap_correction() -> void:
	var large_radius := 64.0
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, 0.001, 680.0)
	var right_sweep := paddle.resolve_continuous_ball_collision(Vector2(550.0, 400.0), Vector2.ZERO, large_radius, 0.001)
	_expect(right_sweep.collided, "A direct Paddle sweep must resolve a deeply overlapping large ball.")
	if right_sweep.collided:
		_expect(right_sweep.normal.x < 0.0 and right_sweep.position.x < paddle.position.x, "A completed rightward sweep must separate the large ball through the nearest final face.")
		_expect(paddle.is_ball_separated(right_sweep.position, large_radius), "Large-ball correction must leave the Paddle before the next tick.")

	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, 0.001, 120.0)
	var left_sweep := paddle.resolve_continuous_ball_collision(Vector2(250.0, 400.0), Vector2.ZERO, large_radius, 0.001)
	_expect(left_sweep.collided, "A reverse direct Paddle sweep must resolve a deeply overlapping large ball.")
	if left_sweep.collided:
		_expect(left_sweep.normal.x > 0.0 and left_sweep.position.x > paddle.position.x, "A completed leftward sweep must separate the large ball through the nearest final face.")
		_expect(paddle.is_ball_separated(left_sweep.position, large_radius), "Reverse large-ball correction must leave the Paddle before the next tick.")

	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = deg_to_rad(90.0)
	paddle.apply_input(0.0, 0.0, 0.001, 680.0)
	var rotated_sweep := paddle.resolve_continuous_ball_collision(Vector2(550.0, 400.0), Vector2.ZERO, large_radius, 0.001)
	_expect(rotated_sweep.collided and paddle.is_ball_separated(rotated_sweep.position, large_radius), "Large-ball correction must also separate at a rotated Paddle orientation.")


func _verify_tip_overlap_correction_stays_local() -> void:
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	var ball_radius := 32.0
	var right_tip_ball := paddle.position + Vector2(paddle.paddle_width * 0.5 + 12.0, 0.0)
	var correction := paddle._resolve_inside_ball_overlap(
		right_tip_ball,
		paddle.position,
		paddle.rotation,
		ball_radius,
		Vector2.LEFT
	)
	_expect(correction.overlapping, "A ball overlapping a Paddle tip must be corrected.")
	if correction.overlapping:
		_expect(correction.normal.x > 0.0, "Right-tip overlap correction must use the contacted right tip, not the opposite end.")
		_expect(correction.corrected_position.x > paddle.position.x, "Right-tip overlap correction must remain on the contacted side of the Paddle.")
		_expect(
			right_tip_ball.distance_to(correction.corrected_position) <= ball_radius + paddle.separation_epsilon,
			"Paddle tip correction must not teleport a ball across the Paddle body."
		)


func _verify_rotation_sweep() -> void:
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA, INF, 90.0)
	var rotation_hits := 0
	for x in range(250, 551, 25):
		for y in range(250, 551, 25):
			var hit := paddle.resolve_continuous_ball_collision(Vector2(x, y), Vector2.ZERO, 2.0, TEST_DELTA)
			if hit.collided:
				rotation_hits += 1
	_expect(rotation_hits > 0, "Adaptive rotation sweep must contact Lv1-sized balls along the swept Paddle arc.")


func _verify_angular_contact_velocity() -> void:
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA, INF, 90.0)
	var center_impact := paddle.get_contact_impact_velocity(paddle.global_position + Vector2(0.0, -paddle.paddle_thickness * 0.5))
	var end_impact := paddle.get_contact_impact_velocity(paddle.global_position + Vector2(paddle.paddle_width * 0.5, 0.0))
	_expect(end_impact.length() > center_impact.length(), "Paddle end contact must have a larger angular contribution than near-center contact.")

	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA, INF, -90.0)
	var reverse_end_impact := paddle.get_contact_impact_velocity(paddle.global_position + Vector2(paddle.paddle_width * 0.5, 0.0))
	_expect(end_impact.y * reverse_end_impact.y < 0.0, "Reversing Paddle rotation must reverse angular impact direction.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error("S1-G2 reflection verification failed: %s" % message)
