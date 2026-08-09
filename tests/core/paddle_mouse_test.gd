extends Node

const TEST_DELTA := 0.1

var failures := 0
var paddle: Paddle


func _ready() -> void:
	paddle = preload("res://scenes/gameplay/paddle.tscn").instantiate()
	paddle.position = Vector2(400.0, 400.0)
	paddle.play_field_rect = Rect2(0.0, 0.0, 800.0, 600.0)
	add_child(paddle)
	await get_tree().process_frame
	_verify_mouse_direct_motion()
	_verify_position_input_arbitration()
	_verify_shared_angle_state_and_angular_velocity()
	_verify_mouse_hit_velocity()
	if failures == 0:
		print("S1_G2_MOUSE_VERIFIED direct_motion=clamped shared_angle=wheel transform_velocity=impact")
	await get_tree().create_timer(1.0).timeout
	get_tree().quit(failures)


func _verify_mouse_direct_motion() -> void:
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA, 420.0)
	var near_velocity := paddle.linear_velocity.x
	_expect(is_equal_approx(paddle.position.x, 420.0), "Mouse X must apply directly to Paddle logical X.")
	_expect(near_velocity > 0.0, "Direct mouse movement must produce measured transform velocity.")

	paddle.position = Vector2(400.0, 400.0)
	paddle.apply_input(0.0, 0.0, TEST_DELTA, 800.0)
	_expect(is_equal_approx(paddle.position.x, 680.0), "Direct mouse X must clamp against the rotated Paddle field extent.")
	_expect(paddle.linear_velocity.x > paddle.move_speed, "Direct mouse movement must not use a tracking speed cap.")


func _verify_position_input_arbitration() -> void:
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle._set_mouse_position_target(600.0)
	paddle.apply_input(0.0, 0.0, TEST_DELTA, paddle._active_mouse_target_x())
	_expect(is_equal_approx(paddle.position.x, 600.0), "Actual mouse motion must activate direct mouse position control.")

	paddle._activate_keyboard_position_control()
	paddle.apply_input(-1.0, 0.0, TEST_DELTA, paddle._active_mouse_target_x())
	var keyboard_release_position := paddle.position.x
	paddle.apply_input(0.0, 0.0, TEST_DELTA, paddle._active_mouse_target_x())
	_expect(is_equal_approx(paddle.position.x, keyboard_release_position), "Keyboard release must retain Paddle position instead of snapping to stale mouse X.")

	paddle._set_mouse_position_target(520.0)
	paddle.apply_input(0.0, 0.0, TEST_DELTA, paddle._active_mouse_target_x())
	_expect(is_equal_approx(paddle.position.x, 520.0), "Only a later real mouse motion may reactivate direct mouse control.")


func _verify_shared_angle_state_and_angular_velocity() -> void:
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA, INF, paddle.mouse_wheel_step_degrees)
	_expect(paddle.rotation > 0.0 and paddle.angular_velocity > 0.0, "Wheel up must change shared angle and signed angular velocity.")
	paddle.apply_input(0.0, 0.0, TEST_DELTA, INF, -paddle.mouse_wheel_step_degrees * 2.0)
	_expect(paddle.rotation < 0.0 and paddle.angular_velocity < 0.0, "Wheel down must change the same shared angle in reverse.")
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA, INF, 365.0)
	_expect(is_equal_approx(paddle.rotation, deg_to_rad(5.0)), "Wheel rotation must continue past 360 degrees without an angle clamp.")


func _verify_mouse_hit_velocity() -> void:
	paddle.position = Vector2(400.0, 400.0)
	paddle.rotation = 0.0
	paddle.apply_input(0.0, 0.0, TEST_DELTA, 420.0)
	var slow_hit := paddle.resolve_continuous_ball_collision(Vector2(420.0, 370.0), Vector2(0.0, 300.0), 6.0, TEST_DELTA)
	paddle.position = Vector2(400.0, 400.0)
	paddle.apply_input(0.0, 0.0, TEST_DELTA, 800.0)
	var fast_hit := paddle.resolve_continuous_ball_collision(Vector2(680.0, 370.0), Vector2(0.0, 300.0), 6.0, TEST_DELTA)
	_expect(slow_hit.collided and fast_hit.collided, "Mouse-driven Paddle hits must collide.")
	_expect(fast_hit.velocity.x > slow_hit.velocity.x, "Reflection must use actual transform velocity after its impact cap.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error("S1-G2 mouse verification failed: %s" % message)
