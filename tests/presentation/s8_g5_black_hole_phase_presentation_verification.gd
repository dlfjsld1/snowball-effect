extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const STAGE_WORLD_SCENE := preload("res://scenes/backgrounds/stage_world.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const PAUSE_SCENE := preload("res://scenes/ui/pause_menu.tscn")
const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const StageCatalogScript := preload("res://scripts/data/stage_catalog.gd")
const VOID_CATHEDRAL_RESOURCE := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres"
const VOID_CATHEDRAL_PNG := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.png"

class FakeBlackHoleSource:
	extends Node

	signal black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2)
	signal black_hole_finale_locked(result_snapshot: Dictionary)

	var positions := PackedVector2Array([Vector2(610.0, 430.0)])
	var radii := PackedFloat32Array([16.0])

	func get_black_hole_snapshot() -> Dictionary:
		return {
			"count": positions.size(),
			"positions": positions.duplicate(),
			"radii": radii.duplicate(),
		}

	func start_phase(phase_id: int, from_rect: Rect2, to_rect: Rect2) -> void:
		black_hole_phase_started.emit(phase_id, from_rect, to_rect)

	func lock_finale(result_snapshot: Dictionary) -> void:
		black_hole_finale_locked.emit(result_snapshot.duplicate(true))


class MainCutInStub extends Node:
	func play_first_contact_cutin(_payload: Dictionary) -> bool:
		return true


var _phase_completions: Array[int] = []
var _finale_completion_count := 0


func _ready() -> void:
	var source := FakeBlackHoleSource.new()
	add_child(source)
	var background: BackgroundManager = STAGE_WORLD_SCENE.instantiate()
	add_child(background)
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	add_child(frame)
	var hud: Hud = HUD_SCENE.instantiate()
	add_child(hud)
	var pause_menu: PauseMenu = PAUSE_SCENE.instantiate()
	add_child(pause_menu)
	await get_tree().process_frame

	var presenter: PresentationManager = frame.get_node("PresentationManager")
	var black_hole_effect := presenter.get_node("BlackHoleOverlay")
	assert(black_hole_effect is BlackHolePhaseEffect, "The active frame must mount the S8-G5 renderer.")
	presenter.black_hole_phase_duration = 0.08
	presenter.black_hole_finale_duration = 0.12
	presenter.configure(background, hud, pause_menu)
	presenter.configure_black_hole_sources(source, source)
	presenter.black_hole_phase_presentation_finished.connect(_on_phase_finished)
	presenter.black_hole_finale_presentation_finished.connect(_on_finale_finished)

	var galactic := StageDefinition.new()
	galactic.stage_index = 2
	galactic.display_name = "Galactic"
	galactic.background_id = &"galactic"
	presenter.apply_stage(galactic)
	hud._on_stage_changed(galactic)
	hud.visible = true
	pause_menu.visible = true

	var l2_rect := frame.get_field_rect_for_profile(2)
	var l3_rect := frame.get_field_rect_for_profile(3)
	assert(is_equal_approx(l2_rect.size.x, 880.0))
	assert(is_equal_approx(l3_rect.size.x, 1040.0))
	assert(is_equal_approx(l3_rect.position.x - l2_rect.position.x, -80.0))
	assert(is_equal_approx(l3_rect.end.x - l2_rect.end.x, 80.0))
	var l2_stage_label_x := hud.stage_name_label.position.x
	var source_positions_before := source.positions.duplicate()

	assert(presenter.play_black_hole_phase(41, l2_rect, l3_rect))
	assert(presenter.is_black_hole_phase_active())
	assert(frame.profile_index == 2, "The logical frame profile must remain L2 until Presentation finishes.")
	var phase_metrics := presenter.get_black_hole_presentation_metrics()
	assert(phase_metrics == black_hole_effect.get_visual_metrics().merged({
		"active_phase_id": 41,
		"last_completed_phase_id": -1,
		"run_generation": 0,
		"status_label_visible": true,
		"status_label": "GRAVITY ANOMALY // L3 FIELD",
		"hud_visible": true,
	}, true), "Presentation metrics must come from the mounted S8-G5 renderer.")
	assert(phase_metrics["visible"])
	assert(phase_metrics["black_hole_count"] == 1)
	assert(phase_metrics["core_count"] == 1)
	assert(phase_metrics["horizon_ring_count"] == 0)
	assert(phase_metrics["influence_ring_count"] == 0)
	assert(phase_metrics["orbit_square_count"] == 0)
	assert(phase_metrics["lensing_arc_count"] == 2)
	assert(phase_metrics["trail_stroke_count"] == 2)
	assert(phase_metrics["status_label_visible"])
	assert(String(phase_metrics["status_label"]).contains("GRAVITY ANOMALY"))
	await _wait_for_phase(presenter)

	assert(frame.profile_index == 3)
	assert(_phase_completions == [41])
	assert(hud.visible, "Gameplay HUD must remain active after the non-terminal phase transition.")
	assert(hud.stage_name_label.text == "STAGE GALACTIC")
	var completed_metrics := presenter.get_black_hole_presentation_metrics()
	var completed_field_rect: Rect2 = completed_metrics["field_rect"]
	assert(is_equal_approx(completed_field_rect.size.x, 1040.0))
	assert(is_equal_approx(float(completed_metrics["field_expansion_width"]), 160.0))
	assert(is_equal_approx(hud.stage_name_label.position.x - l2_stage_label_x, -80.0))
	assert(is_equal_approx(frame.get_visual_left_wing_rect().size.x, 200.0))
	assert(is_equal_approx(frame.get_visual_right_wing_rect().size.x, 200.0))
	assert(source.positions == source_positions_before, "Presentation must not mutate the Core Black Hole snapshot.")

	assert(not presenter.play_black_hole_phase(41, l2_rect, l3_rect))
	assert(not presenter.play_black_hole_phase(40, l2_rect, l3_rect))
	await get_tree().process_frame
	assert(_phase_completions == [41], "Duplicate/stale phase IDs must not be reused as completion.")

	var finale_snapshot := _make_finale_snapshot()
	assert(presenter.play_black_hole_finale(finale_snapshot))
	assert(presenter.is_black_hole_finale_active())
	var finale_metrics := presenter.get_black_hole_presentation_metrics()
	assert(finale_metrics["finale_active"])
	assert(finale_metrics["black_hole_count"] == 2)
	await _wait_for_finale(presenter)
	assert(_finale_completion_count == 1)
	assert(not hud.visible and not pause_menu.visible, "Finale must remove gameplay HUD/UI before the Result handoff.")
	assert(not presenter.play_black_hole_finale(finale_snapshot))
	await get_tree().process_frame
	assert(_finale_completion_count == 1, "Duplicate terminal snapshots must not replay the finale.")

	# A reset increments the internal run generation. An old callback with the same
	# phase ID cannot complete a new Run's pending phase.
	presenter.reset_black_hole_presentation()
	presenter.reduced_effects = false
	presenter.black_hole_phase_duration = 0.24
	assert(presenter.play_black_hole_phase(41, l2_rect, l3_rect))
	assert(presenter.is_black_hole_phase_active())
	presenter.reset_black_hole_presentation()
	presenter.black_hole_phase_duration = 0.05
	assert(presenter.play_black_hole_phase(41, l2_rect, l3_rect))
	await _wait_for_phase(presenter)
	var stale_timeout := Time.get_ticks_msec() + 320
	while Time.get_ticks_msec() < stale_timeout:
		await get_tree().process_frame
	assert(_phase_completions == [41, 41], "A canceled prior-Run tween must not emit into a reused phase ID.")

	# Reduced effects keeps the state name, exact edge movement, compact core/arcs,
	# and finale beats while omitting the movement trail.
	presenter.reset_black_hole_presentation()
	presenter.reduced_effects = true
	assert(presenter.play_black_hole_phase(73, l2_rect, l3_rect))
	assert(presenter.is_black_hole_phase_active())
	var reduced_metrics := presenter.get_black_hole_presentation_metrics()
	assert(reduced_metrics["reduced_effects"])
	assert(reduced_metrics["status_label_visible"])
	assert(reduced_metrics["trail_marker_count"] == 0 and reduced_metrics["trail_stroke_count"] == 0)
	assert(reduced_metrics["core_count"] == 1 and reduced_metrics["lensing_arc_count"] == 2)
	await _wait_for_phase(presenter)
	assert(presenter.play_black_hole_finale(finale_snapshot))
	assert(presenter.is_black_hole_finale_active())
	await _wait_for_finale(presenter)
	assert(_phase_completions == [41, 41, 73])
	assert(_finale_completion_count == 2)
	await _verify_main_final_phase_visual()

	print("S8_G5_VERIFIED phase_completions=3 finale_completions=2 field=880_to_1040 symmetric=80 void_cathedral_main=true misleading_cues=0 reduced=true stale_safe=true core_readonly=true")
	get_tree().quit()


func _make_finale_snapshot() -> Dictionary:
	return {
		"contact_position": Vector2(800.0, 430.0),
		"black_holes": [
			{"position": Vector2(760.0, 430.0), "velocity": Vector2(90.0, 0.0), "radius": 16.0},
			{"position": Vector2(840.0, 430.0), "velocity": Vector2(-90.0, 0.0), "radius": 16.0},
		],
		"stage_index": 2,
		"stage_score": 1.0e43,
		"run_score": 1.0e50,
	}


func _wait_for_phase(presenter: PresentationManager) -> void:
	var timeout_at := Time.get_ticks_msec() + 1500
	while presenter.is_black_hole_phase_active() and Time.get_ticks_msec() < timeout_at:
		await get_tree().process_frame
	assert(not presenter.is_black_hole_phase_active(), "Black Hole phase Presentation timed out.")


func _wait_for_finale(presenter: PresentationManager) -> void:
	var timeout_at := Time.get_ticks_msec() + 1500
	while presenter.is_black_hole_finale_active() and Time.get_ticks_msec() < timeout_at:
		await get_tree().process_frame
	assert(not presenter.is_black_hole_finale_active(), "Black Hole finale Presentation timed out.")


func _verify_main_final_phase_visual() -> void:
	var main := MAIN_SCENE.instantiate()
	get_tree().root.add_child(main)
	get_tree().current_scene = main
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var simulation: BallSimulationManager = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var renderer: BallRenderer = main.get_node("PlayField/SimulationMount/BallRenderer")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var overlay: BlackHolePhaseEffect = presenter.get_node("BlackHoleOverlay")
	var title_screen: TitleScreen = main.get_node("UI/TitleScreen")
	var cutin_stub := MainCutInStub.new()
	add_child(cutin_stub)
	game_manager.set_first_contact_cutin_consumer_for_verification(cutin_stub)
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	presenter.black_hole_phase_duration = 0.05
	presenter.black_hole_finale_duration = 0.5
	title_screen.start_button.pressed.emit()

	var galactic := StageCatalogScript.new().get_stage(2) as StageDefinition
	stage_manager.current_stage_index = 2
	stage_manager._enter_stage(galactic)
	var radius := simulation.get_runtime_radius_for_level(13)
	simulation.spawn_ball(Vector2(760.0, 320.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(764.0, 320.0), Vector2.ZERO, radius, 13)
	stage_manager._stage_runtime.stage_time_left = 5.0
	stage_manager._physics_process(0.1)
	await get_tree().process_frame

	var runtime := game_manager.get_runtime_snapshot()
	var event_id := int(runtime["first_contact_active_event_id"])
	var run_epoch := int(runtime["first_contact_run_epoch"])
	assert(event_id > 0, "Actual Main merge must issue FIRST CONTACT before the final-phase handoff.")
	assert(game_manager.accept_first_contact_cutin_finished(event_id, run_epoch))
	await get_tree().process_frame
	renderer.refresh_render_snapshot()

	var texture := overlay.get_black_hole_visual_texture()
	var draw_texture := overlay.get_black_hole_draw_texture()
	var black_hole_snapshot := simulation.get_black_hole_snapshot()
	var renderer_metrics := renderer.get_render_metrics()
	assert(texture != null and texture.resource_path == VOID_CATHEDRAL_RESOURCE, "Actual Main BlackHoleOverlay must own the approved C runtime resource.")
	assert(draw_texture != null and draw_texture.resource_path == VOID_CATHEDRAL_PNG, "Actual Main custom draw must sample the approved C diffuse PNG.")
	assert(overlay.get_visual_metrics()["black_hole_visual_resource"] == VOID_CATHEDRAL_RESOURCE)
	assert(presenter.is_black_hole_phase_active() and overlay.visible, "Actual Main must render the approved resource through the active final-phase overlay.")
	assert(overlay.get_visual_metrics()["black_hole_count"] == 1, "Actual Main overlay must consume the moving Black Hole snapshot before the visual assertion.")
	assert(black_hole_snapshot["positions"].size() == 1 and renderer_metrics["black_hole_count"] == 1)
	assert(renderer_metrics["standard_ball_count"] == 0 and renderer_metrics["special_fallback_count"] == 0, "Lv14 must hand off to the moving Black Hole entity instead of a catalog-only standard Ball.")
	assert(is_equal_approx(black_hole_snapshot["radii"][0], simulation.get_runtime_radius_for_level(12)), "Presentation wiring must not change the local-Lv2 moving footprint.")

	await _wait_for_phase(presenter)
	await get_tree().process_frame
	simulation.spawn_ball(Vector2(900.0, 430.0), Vector2.ZERO, radius, 13)
	simulation.spawn_ball(Vector2(904.0, 430.0), Vector2.ZERO, radius, 13)
	assert(simulation.commit_merge_candidates() == 1, "Actual Main must create the second Black Hole before terminal contact.")
	simulation._black_hole_positions[0] = Vector2(760.0, 430.0)
	simulation._black_hole_positions[1] = Vector2(840.0, 430.0)
	simulation._black_hole_velocities[0] = Vector2(600.0, 0.0)
	simulation._black_hole_velocities[1] = Vector2(-600.0, 0.0)
	simulation.step_simulation(0.1)
	await get_tree().process_frame
	renderer.refresh_render_snapshot()
	assert(simulation.is_black_hole_terminal_locked(), "Actual Main must lock the terminal snapshot when the two Black Holes contact.")
	assert(presenter.is_black_hole_finale_active(), "Actual Main must start the finale overlay from the terminal snapshot.")
	assert(overlay.get_visual_metrics()["black_hole_count"] == 2, "The finale overlay must own exactly the two terminal Black Hole visuals.")
	assert(renderer.get_render_metrics()["black_hole_count"] == 0, "The base renderer must hide terminal Black Holes while the finale overlay owns them.")

	get_tree().current_scene = self
	main.queue_free()
	cutin_stub.queue_free()
	await get_tree().process_frame


func _on_phase_finished(phase_id: int) -> void:
	_phase_completions.append(phase_id)


func _on_finale_finished() -> void:
	_finale_completion_count += 1
