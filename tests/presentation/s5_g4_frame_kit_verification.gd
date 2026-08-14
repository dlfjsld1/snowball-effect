extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const EXPECTED_FIELD_WIDTHS := [560.0, 720.0, 880.0, 1040.0]
const EXPECTED_FIELD_X := [520.0, 440.0, 360.0, 280.0]
const EXPECTED_RIG_X := [258.0, 178.0, 98.0, 18.0]
const EXPECTED_RIGHT_WING_X := [1142.0, 1222.0, 1302.0, 1382.0]
const SIMULATION_SCRIPT := preload("res://scripts/simulation/ball_simulation_manager.gd")


func _ready() -> void:
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	add_child(frame)

	for profile in range(4):
		frame.set_profile(profile)
		var field := frame.get_field_rect()
		var rig := frame.get_rig_rect()
		var left_wing := frame.get_left_wing_rect()
		var right_wing := frame.get_right_wing_rect()

		assert(is_equal_approx(field.position.x, EXPECTED_FIELD_X[profile]))
		assert(is_equal_approx(field.size.x, EXPECTED_FIELD_WIDTHS[profile]))
		assert(is_equal_approx(field.position.y, 50.0))
		assert(is_equal_approx(field.size.y, 800.0))
		assert(is_equal_approx(field.get_center().x, 800.0))
		assert(is_equal_approx(rig.position.x, EXPECTED_RIG_X[profile]))
		assert(is_equal_approx(rig.get_center().x, 800.0))
		assert(rig.position.y == 0.0 and rig.end.y == 900.0)
		assert(left_wing.size == Vector2(200.0, 900.0))
		assert(is_equal_approx(right_wing.position.x, EXPECTED_RIGHT_WING_X[profile]))
		assert(right_wing.size == Vector2(200.0, 900.0))
		assert(frame.get_profile_id() == StringName("L%d" % profile))
		assert(frame.get_field_visual_rect() == field)
		assert(frame.get_field_bezel_rect().position.y == 0.0)
		assert(frame.get_field_bezel_rect().end.y == 900.0)
		assert(frame.get_right_bottom_panel_rect().end.y == 900.0)
		assert(frame.get_node("CrtShells/RightCrtGroup/PauseShell").position.y == 796.0)
		assert(frame.get_cashout_line_y() == 850.0)
		assert(frame.get_spawn_safe_y(4.0) == 66.0)

	assert((frame.get_node("CrtShells/LeftCrtGroup/GenealogyShell") as TextureRect).texture.resource_path.contains("paper8_lab_v2/runtime"))
	assert((frame.get_node("CrtShells/RightCrtGroup/ScoreShell") as TextureRect).texture.resource_path.contains("paper8_lab_v2/runtime"))
	assert((frame.get_node("CrtShells/RightCrtGroup/ItemShell") as TextureRect).texture.resource_path.contains("paper8_lab_v2/runtime"))
	assert((frame.get_node("CrtShells/RightCrtGroup/PauseShell") as TextureRect).texture.resource_path.contains("paper8_lab_v2/runtime"))
	_verify_ball_visibility_bounds(frame.get_field_rect())
	print("S5-G4 frame kit verification passed: 4 profiles, full-height Paper-8 frame, pixel-derived field bounds")
	get_tree().quit()


func _verify_ball_visibility_bounds(field: Rect2) -> void:
	var simulation: BallSimulationManager = SIMULATION_SCRIPT.new()
	simulation.play_field_rect = field
	simulation.merge_enabled = false
	add_child(simulation)

	var radius := 4.0
	var ball_index := simulation.spawn_ball(Vector2(field.get_center().x, field.end.y + radius), Vector2.ZERO, radius, 0)
	simulation.step_simulation(0.001)
	assert(simulation.is_ball_active(ball_index), "A ball remains visible until its top pixel clears the lower frame opening.")
	simulation.positions[ball_index].y += 1.0
	simulation.step_simulation(0.001)
	assert(not simulation.is_ball_active(ball_index), "A ball cashes out immediately after fully clearing the lower frame opening.")

	var reflected_index := simulation.spawn_ball(
		Vector2(field.position.x + radius - 1.0, field.position.y + radius - 1.0),
		Vector2(-10.0, -10.0),
		radius,
		0
	)
	simulation.step_simulation(0.001)
	assert(simulation.positions[reflected_index].x == field.position.x + radius)
	assert(simulation.positions[reflected_index].y == field.position.y + radius)
	assert(simulation.velocities[reflected_index].x > 0.0 and simulation.velocities[reflected_index].y > 0.0)
