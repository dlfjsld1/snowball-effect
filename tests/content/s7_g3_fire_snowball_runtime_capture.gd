extends Node

const MainScene := preload("res://scenes/main/main.tscn")
const CAPTURE_PATH := "res://tmp/s7_g3_fire_snowball_shell_v13_z1_ingame.png"

var _failures := 0


func _ready() -> void:
	var main := MainScene.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var renderer: BallRenderer = main.get_node("PlayField/SimulationMount/BallRenderer")
	game_manager._on_start_requested()
	await get_tree().process_frame
	game_manager.set_physics_process(false)
	simulation.reset_runtime()

	var field := simulation.get_active_play_field_rect()
	var samples := [
		{"level": 0, "radius": 4.0, "position": field.position + Vector2(110.0, 180.0)},
		{"level": 1, "radius": 8.0, "position": field.position + Vector2(250.0, 200.0)},
		{"level": 2, "radius": 16.0, "position": field.position + Vector2(410.0, 225.0)},
		{"level": 3, "radius": 32.0, "position": field.position + Vector2(245.0, 500.0)},
		{"level": 4, "radius": 64.0, "position": field.end - Vector2(145.0, 190.0)},
	]
	for sample in samples:
		simulation.spawn_ball(sample["position"], Vector2.ZERO, sample["radius"], sample["level"], BallSimulationManager.BallSpecialType.FIRE)

	renderer.refresh_render_snapshot()
	await get_tree().process_frame
	await get_tree().process_frame
	var metrics := renderer.get_render_metrics()
	_expect(int(metrics["fire_overlay_count"]) == 5, "All five Ground sizes must use the production Fire overlay batch.")
	var image := get_viewport().get_texture().get_image()
	var absolute_path := ProjectSettings.globalize_path(CAPTURE_PATH)
	var save_error := image.save_png(absolute_path)
	_expect(save_error == OK, "The production Main Fire capture must save successfully.")
	print("S7_G3_FIRE_SNOWBALL_CAPTURE path=%s fire=5 size=%dx%d error=%d" % [absolute_path, image.get_width(), image.get_height(), save_error])
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G3 Fire Snowball capture failed: %s" % message)
