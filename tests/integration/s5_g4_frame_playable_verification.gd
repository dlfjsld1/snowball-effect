extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const STAGE_CATALOG := preload("res://scripts/data/stage_catalog.gd")

var _failures := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var paddle: Paddle = main.get_node("PlayField/PaddleMount/Paddle")
	var frame: GameplayFrame = main.get_node("UI/GameplayFrame")
	var backdrop: Polygon2D = main.get_node("PlayField/Backdrop")
	var hud: Hud = main.get_node("UI/HUDMount/HUD")
	var pause_menu: PauseMenu = main.get_node("UI/PauseMenu")

	_verify_profile(0, Rect2(520.0, 50.0, 560.0, 768.0), game_manager, simulation, paddle, frame, backdrop, hud, pause_menu)
	_verify_profile(1, Rect2(440.0, 50.0, 720.0, 768.0), game_manager, simulation, paddle, frame, backdrop, hud, pause_menu)
	_verify_profile(2, Rect2(360.0, 50.0, 880.0, 768.0), game_manager, simulation, paddle, frame, backdrop, hud, pause_menu)

	if _failures == 0:
		print("S5_G4_FRAME_PLAYABLE_VERIFIED profiles=3 physics_bounds=true hud_crt=true")
	get_tree().quit(_failures)


func _verify_profile(
	profile_index: int,
	expected_field: Rect2,
	game_manager: GameManager,
	simulation: BallSimulationManager,
	paddle: Paddle,
	frame: GameplayFrame,
	backdrop: Polygon2D,
	hud: Hud,
	pause_menu: PauseMenu
) -> void:
	var definition: StageDefinition = STAGE_CATALOG.new().get_stage(profile_index)
	paddle.position.x = expected_field.end.x + paddle.paddle_width
	game_manager._on_stage_changed(definition)
	_expect(frame.profile_index == profile_index, "Frame profile must follow the Stage index.")
	_expect(frame.get_field_rect() == expected_field, "Frame field rect must match the approved profile.")
	_expect(simulation.play_field_rect == expected_field, "Simulation bounds must match the visible frame opening.")
	_expect(paddle.play_field_rect == expected_field, "Paddle clamp must match the visible frame opening.")
	_expect(paddle.position.x <= expected_field.end.x - paddle.paddle_width * 0.5, "Paddle must remain fully inside the visible field after a Stage frame change.")
	paddle.rotation = deg_to_rad(45.0)
	paddle.clamp_to_play_field()
	var vertical_extent := absf(sin(paddle.rotation)) * paddle.paddle_width * 0.5 + absf(cos(paddle.rotation)) * paddle.paddle_thickness * 0.5
	_expect(paddle.position.y + vertical_extent <= expected_field.end.y + 0.01, "A rotated Paddle must remain above the reduced logical field bottom and its UI housing.")
	_expect(backdrop.polygon[0] == expected_field.position and backdrop.polygon[2] == frame.get_field_visual_rect().end, "Backdrop must include the open-bottom Cashout corridor.")
	_expect(hud.stage_name_label.position.x == frame.get_left_wing_rect().position.x + 44.0, "Stage HUD must stay inside the left CRT wing.")
	_expect(hud.stage_score_label.position.x == frame.get_right_wing_rect().position.x + 44.0, "Score HUD must stay inside the right CRT wing.")
	_expect(pause_menu.get_node("Buttons").position == frame.get_right_bottom_panel_rect().position + Vector2(16.0, 16.0), "Pause controls must stay inside the aligned lower-right CRT.")
	_expect(pause_menu.pause_button.flat and pause_menu.retry_button.flat, "Pause controls must preserve the CRT glass color instead of drawing opaque button panels.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S5-G4 frame playable verification failed: %s" % message)
