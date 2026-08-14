extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var _failures := 0
var _stage_entries: Array[String] = []
var _shift_completions := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var background: BackgroundManager = main.get_node("StageWorld/BackgroundManager")
	var frame: GameplayFrame = main.get_node("UI/GameplayFrame")
	var hud: Hud = main.get_node("UI/HUDMount/HUD")

	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	presenter.shift_duration = 0.05
	stage_manager.stage_changed.connect(_record_stage_entry)
	presenter.stage_shift_presentation_finished.connect(_count_shift_completion)

	_verify_stage_entry(stage_manager, simulation, background, frame, hud, 0, &"ground", "GROUND", 6.0)
	var run_before_ground_clear := stage_manager.get_score_ledger().run_score
	simulation.reset_runtime()
	var ground_radius := simulation.get_runtime_radius_for_level(3)
	simulation.spawn_ball(Vector2(700.0, 240.0), Vector2.ZERO, ground_radius, 3)
	simulation.spawn_ball(Vector2(704.0, 240.0), Vector2.ZERO, ground_radius, 3)
	stage_manager._physics_process(0.1)
	_expect(stage_manager.current_state == StageManager.SHIFTING, "Ground Top Ball must enter SHIFTING.")
	var ground_stage_time: float = stage_manager.get_runtime_snapshot()["stage_time_left"]
	await get_tree().create_timer(0.12).timeout

	_verify_stage_entry(stage_manager, simulation, background, frame, hud, 1, &"planetary", "PLANETARY", 15.0)
	_expect(is_equal_approx(stage_manager.get_score_ledger().stage_score, 0.0), "Planetary Stage score must reset.")
	_expect(stage_manager.get_score_ledger().run_score > run_before_ground_clear, "Run score must preserve Ground settlement.")
	var run_after_ground := stage_manager.get_score_ledger().run_score

	var planetary_time_before_cashout: float = stage_manager.get_runtime_snapshot()["stage_time_left"]
	var planetary_field := simulation.play_field_rect
	var supernova_radius := simulation.get_runtime_radius_for_level(8)
	for offset in range(4):
		simulation.spawn_ball(
			Vector2(planetary_field.position.x + 80.0 + offset * 80.0, planetary_field.end.y + supernova_radius + 1.0),
			Vector2.ZERO,
			supernova_radius,
			8
		)
	stage_manager._physics_process(0.02)
	var planetary_time_after_cashout: float = stage_manager.get_runtime_snapshot()["stage_time_left"]
	var cashout_time_gain := planetary_time_after_cashout - (planetary_time_before_cashout - 0.02)
	_expect(is_equal_approx(cashout_time_gain, 4.0), "Four local Lv3 Cashouts must grant 4.0 seconds total.")
	_expect(stage_manager.current_state == StageManager.PLAYING, "Cashout time recovery must keep Planetary PLAYING.")
	_expect(stage_manager.get_score_ledger().stage_score >= stage_manager.get_current_stage().clear_score, "Planetary Cashouts must reach clear score.")
	_expect(stage_manager.debug_force_score_clear(), "Debug Score Clear must finish Planetary through the Time Up route.")
	_expect(stage_manager.current_state == StageManager.SHIFTING, "Planetary Time Up Score Clear must enter SHIFTING.")
	await get_tree().create_timer(0.12).timeout

	_verify_stage_entry(stage_manager, simulation, background, frame, hud, 2, &"galactic", "GALACTIC", 35.0)
	_expect(is_equal_approx(stage_manager.get_score_ledger().stage_score, 0.0), "Galactic Stage score must reset.")
	_expect(stage_manager.get_score_ledger().run_score > run_after_ground, "Run score must preserve Planetary Cashouts.")
	_expect(_shift_completions == 2, "Exactly two Scale Shift presentations must complete.")

	game_manager._on_retry_requested()
	_verify_stage_entry(stage_manager, simulation, background, frame, hud, 0, &"ground", "GROUND", 6.0)
	_expect(is_equal_approx(stage_manager.get_score_ledger().stage_score, 0.0), "Retry must reset Stage score.")
	_expect(is_equal_approx(stage_manager.get_score_ledger().run_score, 0.0), "Retry must reset Run score.")
	_expect(stage_manager.current_state == StageManager.PLAYING, "Retry must resume Ground gameplay.")
	_expect(_stage_entries == ["Planetary", "Galactic", "Ground"], "Stage entry order must be Planetary, Galactic, then retry Ground.")
	var debug_top_ball_event := InputEventKey.new()
	debug_top_ball_event.physical_keycode = KEY_F6
	debug_top_ball_event.pressed = true
	game_manager._unhandled_key_input(debug_top_ball_event)
	_expect(stage_manager.current_state == StageManager.SHIFTING, "F6 must invoke the Debug Top Ball Clear route.")

	if _failures == 0:
		print(
			"S5_G5_THREE_STAGE_VERIFIED route=top_ball+score_clear shifts=2 retry=ground "
			+ "ground_stage_time=%.2f planetary_cashout_time_gain=%.2f" % [ground_stage_time, cashout_time_gain]
		)
	get_tree().quit(_failures)


func _verify_stage_entry(
	stage_manager: StageManager,
	simulation: BallSimulationManager,
	background: BackgroundManager,
	frame: GameplayFrame,
	hud: Hud,
	expected_index: int,
	expected_background: StringName,
	expected_name: String,
	expected_spawn_rate: float
) -> void:
	var definition := stage_manager.get_current_stage()
	var simulation_snapshot := simulation.get_stage_snapshot()
	_expect(stage_manager.current_stage_index == expected_index, "Unexpected Stage index.")
	_expect(definition != null and definition.stage_index == expected_index, "Stage definition must match the manager index.")
	_expect(simulation_snapshot["stage_index"] == expected_index, "Simulation Stage snapshot must be re-baselined.")
	_expect(simulation_snapshot["base_global_level"] == definition.base_global_level, "Simulation base level must match Stage data.")
	_expect(simulation_snapshot["top_global_level"] == definition.top_global_level, "Simulation top level must match Stage data.")
	_expect(is_equal_approx(simulation_snapshot["spawn_rate"], expected_spawn_rate), "Simulation spawn rate snapshot must match Stage data.")
	_expect(background.current_background_id == expected_background, "Stage background must match Stage data.")
	_expect(frame.profile_index == expected_index, "Frame profile must match Stage index.")
	_expect(hud.stage_name_label.text == "STAGE %s" % expected_name, "HUD Stage label must update with the Stage.")
	_expect(hud.genealogy_slots[0].text != "", "HUD genealogy must reveal the base ball.")
	for slot_index in range(1, hud.genealogy_slots.size()):
		_expect(hud.genealogy_slots[slot_index].text == "", "HUD genealogy must reset to one revealed ball.")


func _record_stage_entry(definition: StageDefinition) -> void:
	_stage_entries.append(definition.display_name)


func _count_shift_completion(_shift_id: int) -> void:
	_shift_completions += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S5-G5 verification failed: %s" % message)
