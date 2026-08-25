extends Node

const STEP := 0.05

var failures := 0
var paddle: Paddle


func _ready() -> void:
	paddle = preload("res://scenes/gameplay/paddle.tscn").instantiate()
	paddle.position = Vector2(400.0, 400.0)
	paddle.play_field_rect = Rect2(0.0, 0.0, 800.0, 600.0)
	add_child(paddle)
	await get_tree().process_frame
	_verify_vertical_dash_and_return()
	_verify_cooldown()
	if failures == 0:
		print("S1_G2A_DASH_VERIFIED vertical=true return_speed=true cooldown=5 no_gauge=true")
	get_tree().quit(failures)


func _verify_vertical_dash_and_return() -> void:
	var origin := paddle.position
	_expect(paddle.try_start_dash(), "Dash must start when ready.")
	paddle.apply_input(0.0, 0.0, STEP)
	_expect(paddle.position.y < origin.y, "Dash must move upward in world coordinates.")
	_expect(is_equal_approx(paddle.position.x, origin.x), "Dash must not follow Paddle rotation or alter X.")
	_expect((paddle.get_node("DashGhostNear") as Sprite2D).visible, "Ascending dash must show a near afterimage.")
	_expect((paddle.get_node("DashGhostMid") as Sprite2D).visible, "Ascending dash must show a middle afterimage.")
	_expect((paddle.get_node("DashGhostFar") as Sprite2D).visible, "Ascending dash must show a far afterimage.")
	paddle.apply_input(0.0, 0.0, STEP)
	_expect(is_equal_approx(paddle.position.y, origin.y - paddle.dash_distance), "Dash must reach its configured upward distance.")
	paddle.apply_input(0.0, 0.0, STEP)
	paddle.apply_input(0.0, 0.0, STEP)
	paddle.apply_input(0.0, 0.0, STEP)
	paddle.apply_input(0.0, 0.0, STEP)
	_expect(is_equal_approx(paddle.position.y, origin.y), "Dash must return to its origin.")
	_expect(not paddle.is_dashing(), "Dash must finish after the return motion.")
	_expect((paddle.get_node("DashGhostNear") as Sprite2D).visible, "Dash afterimage must persist briefly after returning.")
	_expect((paddle.get_node("DashGhostMid") as Sprite2D).visible, "Dash middle afterimage must persist briefly after returning.")
	var gauge_fill := paddle.get_node("DashGaugeFill") as Polygon2D
	_expect(is_equal_approx(gauge_fill.polygon[1].x, -13.0), "Dash must empty the center bar at cooldown start.")


func _verify_cooldown() -> void:
	_expect(not paddle.try_start_dash(), "Dash must reject activation during cooldown.")
	paddle.reset_dash_cooldown()
	_expect(is_zero_approx(paddle.get_dash_cooldown_remaining()), "Explicit cooldown reset must make dash ready immediately.")
	var reset_gauge_fill := paddle.get_node("DashGaugeFill") as Polygon2D
	_expect(is_equal_approx(reset_gauge_fill.polygon[1].x, 12.0), "Cooldown reset must refill the center bar immediately.")
	_expect(paddle.try_start_dash(), "Dash must reactivate immediately after cooldown reset.")
	paddle.reset_runtime()
	_expect(paddle.try_start_dash(), "Dash must start again after runtime reset.")
	for _index in range(96):
		paddle.apply_input(0.0, 0.0, STEP)
	_expect(is_zero_approx(paddle.get_dash_cooldown_remaining()), "Cooldown must expire after five seconds.")
	var gauge_fill := paddle.get_node("DashGaugeFill") as Polygon2D
	_expect(is_equal_approx(gauge_fill.polygon[1].x, 12.0), "Center bar must refill over the cooldown.")
	_expect(paddle.try_start_dash(), "Dash must reactivate after cooldown.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	failures += 1
	push_error("S1-G2A dash verification failed: %s" % message)
