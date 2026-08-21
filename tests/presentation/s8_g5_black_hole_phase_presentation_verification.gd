extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const STAGE_WORLD_SCENE := preload("res://scenes/backgrounds/stage_world.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const PAUSE_SCENE := preload("res://scenes/ui/pause_menu.tscn")

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
	assert(phase_metrics["horizon_ring_count"] == 1)
	assert(phase_metrics["influence_ring_count"] == 1)
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

	# Reduced effects keeps the state name, exact edge movement, compact core/ring,
	# and finale beats while omitting non-essential trail markers.
	presenter.reset_black_hole_presentation()
	presenter.reduced_effects = true
	assert(presenter.play_black_hole_phase(73, l2_rect, l3_rect))
	assert(presenter.is_black_hole_phase_active())
	var reduced_metrics := presenter.get_black_hole_presentation_metrics()
	assert(reduced_metrics["reduced_effects"])
	assert(reduced_metrics["status_label_visible"])
	assert(reduced_metrics["trail_marker_count"] == 0)
	assert(reduced_metrics["core_count"] == 1 and reduced_metrics["horizon_ring_count"] == 1)
	await _wait_for_phase(presenter)
	assert(presenter.play_black_hole_finale(finale_snapshot))
	assert(presenter.is_black_hole_finale_active())
	await _wait_for_finale(presenter)
	assert(_phase_completions == [41, 41, 73])
	assert(_finale_completion_count == 2)

	print("S8_G5_VERIFIED phase_completions=3 finale_completions=2 field=880_to_1040 symmetric=80 core_ring=true influence=true reduced=true stale_safe=true core_readonly=true")
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


func _on_phase_finished(phase_id: int) -> void:
	_phase_completions.append(phase_id)


func _on_finale_finished() -> void:
	_finale_completion_count += 1
