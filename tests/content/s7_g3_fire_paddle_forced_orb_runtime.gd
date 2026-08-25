extends Node

const CAPTURE_PATH := "res://tmp/s7_g3_fire_paddle_forced_orb_ingame.png"
const FORCED_CYCLES := 3

@onready var main: Node = $Main
@onready var game_manager: GameManager = $Main/GameManager
@onready var stage_manager: StageManager = $Main/StageManager
@onready var item_manager: ItemManager = $Main/ItemManager
@onready var fire_core: ItemFireCore = $Main/ItemFireCore
@onready var simulation: BallSimulationManager = $Main/PlayField/SimulationMount/BallSimulationManager
@onready var paddle: Paddle = $Main/PlayField/PaddleMount/Paddle

var _failures := 0
var _observed_frames: Array[int] = []


func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	game_manager._start_run()
	await get_tree().process_frame

	for cycle in range(FORCED_CYCLES):
		await _run_forced_fire_orb_cycle(cycle)

	if _failures == 0:
		print("S7_G3_FIRE_PADDLE_FORCED_ORB_VERIFIED cycles=%d forced=fire_core frames=%s duration=8 hidden_after_expiry=true capture=%s" % [
			FORCED_CYCLES,
			_observed_frames,
			ProjectSettings.globalize_path(CAPTURE_PATH),
		])
	get_tree().quit(_failures)


func _run_forced_fire_orb_cycle(cycle: int) -> void:
	var stage := stage_manager.get_current_stage()
	_expect(stage != null, "Forced Fire Orb test requires an active Stage.")
	if stage == null:
		return
	var local_level_two: int = stage.local_ball_levels[2]
	item_manager.enter_stage(
		stage,
		simulation.get_active_play_field_rect(),
		simulation.get_runtime_radius_for_level(local_level_two),
		0.0,
		&"fire_core",
		7300 + cycle
	)
	var item_ball := item_manager.get_item_ball_snapshot()
	_expect(item_ball.get("item_type", &"") == &"fire_core", "Item Ball result must be forced to Fire before break.")

	item_manager._break_item_ball()
	var orb := item_manager.get_item_orb_snapshot()
	_expect(orb.get("item_type", &"") == &"fire_core", "Broken forced Item Ball must release a Fire Orb.")
	if orb.is_empty():
		return
	item_manager._item_orb.world_position = paddle.global_position
	_expect(item_manager.try_collect_orb(paddle.global_position, 0.0), "Paddle must collect the forced Fire Orb through the production signal path.")

	# Let the production item CUT-IN emit its activation cue and finish before
	# observing the resumed gameplay Paddle.
	await get_tree().create_timer(2.20).timeout
	_expect(fire_core.is_active() and paddle.is_fire_contact_active(), "Forced Fire Orb collection must open the Fire window.")
	paddle._advance_fire_visual(0.10 + float(cycle) * 0.05)
	var visual := paddle.get_fire_visual_snapshot()
	_expect(bool(visual["visible"]), "Fire Paddle overlay must be visible after forced Fire Orb activation.")
	_expect(int(visual["frame_count"]) == 6, "Fire Paddle overlay must retain all six approved frames.")
	var fire_visual := paddle.get_node("FireVisual") as Sprite2D
	_expect(fire_visual.position.is_equal_approx(Vector2(0.0, -16.0)), "Fire Paddle flames must sit above the Paddle body.")
	_expect(not fire_visual.flip_v, "Fire Paddle flame tongues must retain their upward orientation.")
	_expect(fire_visual.z_index == 2, "Fire Paddle flames must render above the approved Paddle sprite.")
	_observed_frames.append(int(visual["frame"]))

	if cycle == 0:
		await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		var error := image.save_png(ProjectSettings.globalize_path(CAPTURE_PATH))
		_expect(error == OK, "Fire Paddle in-game capture must save successfully.")

	var remaining_seconds := float(fire_core.get_snapshot()["remaining_seconds"])
	_expect(remaining_seconds > 7.0 and remaining_seconds <= 8.0, "Fire window must begin from the data-defined eight-second duration.")
	fire_core.advance(maxf(remaining_seconds - 0.01, 0.0))
	_expect(fire_core.is_active() and bool(paddle.get_fire_visual_snapshot()["visible"]), "Fire Paddle must remain visible before the eight-second deadline.")
	fire_core.advance(0.02)
	_expect(not fire_core.is_active() and not paddle.is_fire_contact_active(), "Fire window must close after eight seconds.")
	_expect(not bool(paddle.get_fire_visual_snapshot()["visible"]), "Fire Paddle overlay must hide immediately after expiry.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G3 forced Fire Orb Paddle verification failed: %s" % message)
