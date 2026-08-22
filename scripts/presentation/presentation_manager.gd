class_name PresentationManager
extends Control

signal stage_shift_presentation_finished(shift_id: int)
signal visual_field_rect_changed(visual_rect: Rect2)
signal black_hole_phase_presentation_finished(phase_id: int)
signal black_hole_finale_presentation_finished
signal first_contact_cutin_finished(event_id: int, run_epoch: int)

const FirstContactCutInScene := preload("res://scenes/effects/first_contact_cutin.tscn")

@export_range(0.05, 3.0, 0.05) var shift_duration := 0.9
@export_range(0.05, 3.0, 0.05) var black_hole_phase_duration := 0.9
@export_range(0.05, 5.0, 0.05) var black_hole_finale_duration := 1.35
@export var reduced_effects := false

@onready var shift_flash: ColorRect = %ShiftFlash
@onready var shift_label: Label = %ShiftLabel
@onready var black_hole_overlay: BlackHolePhaseEffect = %BlackHoleOverlay

var _frame: GameplayFrame
var _background_manager: BackgroundManager
var _hud: Hud
var _pause_menu: PauseMenu
var _shift_tween: Tween
var _active_shift_id := -1
var _target_profile := 0
var _target_background_id: StringName = &"ground"
var _completed_shift_ids: Dictionary = {}
var _black_hole_simulation_source: Node
var _active_black_hole_phase_id := -1
var _active_black_hole_phase_generation := -1
var _last_completed_black_hole_phase_id := -1
var _completed_black_hole_phase_ids: Dictionary = {}
var _black_hole_phase_tween: Tween
var _black_hole_from_profile := 2
var _black_hole_to_profile := 3
var _black_hole_origin_visual_rect := Rect2()
var _black_hole_finale_active := false
var _black_hole_finale_generation := -1
var _black_hole_finale_completed_generation := -1
var _black_hole_finale_snapshot: Dictionary = {}
var _black_hole_finale_tween: Tween
var _black_hole_run_generation := 0
var _first_contact_cutin_controller: CutInController


func _ready() -> void:
	_frame = get_parent() as GameplayFrame
	_reset_overlay()
	_first_contact_cutin_controller = FirstContactCutInScene.instantiate() as CutInController
	add_child(_first_contact_cutin_controller)
	_first_contact_cutin_controller.cutin_finished.connect(_on_first_contact_cutin_finished)
	call_deferred("_bind_main_black_hole_source")


func configure(background_manager: BackgroundManager, hud: Hud, pause_menu: PauseMenu) -> void:
	_background_manager = background_manager
	_hud = hud
	_pause_menu = pause_menu


func play_first_contact_cutin(payload: Dictionary) -> bool:
	if _first_contact_cutin_controller == null:
		return false
	_first_contact_cutin_controller.set_reduced_effects(reduced_effects)
	_first_contact_cutin_controller.configure_field_visual_rect(_frame.get_field_visual_rect())
	return _first_contact_cutin_controller.play_first_contact_cutin(payload)


func reset_first_contact_cutin(run_epoch: int) -> void:
	if _first_contact_cutin_controller != null:
		_first_contact_cutin_controller.reset_first_contact_cutin(run_epoch)


func get_first_contact_cutin_metrics() -> Dictionary:
	if _first_contact_cutin_controller == null:
		return {}
	return _first_contact_cutin_controller.get_visual_metrics()


func _on_first_contact_cutin_finished(event_id: int, run_epoch: int) -> void:
	first_contact_cutin_finished.emit(event_id, run_epoch)


func configure_black_hole_sources(_event_source: Node, simulation_source: Node) -> void:
	# Compatibility-only read source for Presentation fixtures. Main uses the
	# authoritative GameManager calls and does not route gameplay through here.
	_black_hole_simulation_source = simulation_source
	black_hole_overlay.set_simulation_source(simulation_source)


func _bind_main_black_hole_source() -> void:
	if is_instance_valid(_black_hole_simulation_source) or get_tree().current_scene == null:
		return
	var simulation_source := get_tree().current_scene.get_node_or_null("PlayField/SimulationMount/BallSimulationManager")
	if simulation_source != null:
		configure_black_hole_sources(null, simulation_source)


func apply_stage(definition: StageDefinition) -> void:
	if definition == null:
		return
	if _active_shift_id != -1:
		_cancel_active_shift()
	var profile := clampi(definition.stage_index, 0, 2)
	if profile < 2 and (_active_black_hole_phase_id != -1 or _last_completed_black_hole_phase_id != -1 or _black_hole_finale_active):
		reset_black_hole_presentation()
	_frame.set_profile(profile)
	visual_field_rect_changed.emit(_frame.get_field_visual_rect())
	_apply_dependent_layout()
	if _background_manager != null:
		_background_manager.set_background(definition.background_id)


func play_stage_shift(next_definition: StageDefinition, shift_id: int) -> void:
	if next_definition == null or shift_id < 0 or _active_shift_id != -1 or _completed_shift_ids.has(shift_id):
		return

	_active_shift_id = shift_id
	_target_profile = clampi(next_definition.stage_index, 0, 2)
	_target_background_id = next_definition.background_id
	shift_label.text = "SCALE SHIFT"
	shift_label.visible = true
	shift_label.modulate.a = 0.0
	shift_flash.color.a = 0.0

	if _background_manager != null:
		_background_manager.transition_to(_target_background_id, shift_duration * 0.78)

	_shift_tween = create_tween()
	_shift_tween.tween_property(shift_flash, "color:a", 0.22, shift_duration * 0.14)
	_shift_tween.parallel().tween_property(shift_label, "modulate:a", 1.0, shift_duration * 0.14)
	_shift_tween.tween_method(
		_apply_shift_progress.bind(_frame.profile_index, _target_profile),
		0.0,
		1.0,
		shift_duration * 0.64
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_shift_tween.parallel().tween_property(shift_flash, "color:a", 0.08, shift_duration * 0.64)
	_shift_tween.tween_property(shift_flash, "color:a", 0.0, shift_duration * 0.22)
	_shift_tween.parallel().tween_property(shift_label, "modulate:a", 0.0, shift_duration * 0.22)
	_shift_tween.tween_callback(_finish_shift.bind(shift_id))


func is_shift_active() -> bool:
	return _active_shift_id != -1


func play_black_hole_phase(phase_id: int, from_rect: Rect2, to_rect: Rect2) -> bool:
	if phase_id < 0 or from_rect.size.x <= 0.0 or to_rect.size.x <= 0.0:
		return false
	if _active_black_hole_phase_id != -1 or _black_hole_finale_active:
		return false
	if _last_completed_black_hole_phase_id != -1 or _completed_black_hole_phase_ids.has(phase_id):
		return false

	_cancel_black_hole_phase()
	_active_black_hole_phase_id = phase_id
	_active_black_hole_phase_generation = _black_hole_run_generation
	_black_hole_from_profile = _find_profile_for_field_width(from_rect.size.x)
	_black_hole_to_profile = _find_profile_for_field_width(to_rect.size.x)
	_black_hole_origin_visual_rect = _frame.get_field_visual_rect_for_profile(_black_hole_from_profile)
	black_hole_overlay.modulate = Color(1.0, 1.0, 1.0, 0.78 if reduced_effects else 1.0)
	black_hole_overlay.begin_phase(reduced_effects)
	black_hole_overlay.set_phase_progress(0.0, _black_hole_origin_visual_rect)
	shift_label.text = "GRAVITY ANOMALY // L3 FIELD"
	shift_label.visible = true
	shift_label.modulate.a = 1.0 if reduced_effects else 0.0
	shift_flash.color = Color(0.18, 0.04, 0.38, 0.0)
	var generation := _black_hole_run_generation
	var duration := 0.18 if reduced_effects else black_hole_phase_duration
	_black_hole_phase_tween = create_tween()
	_black_hole_phase_tween.tween_property(shift_flash, "color:a", 0.32, duration * 0.18)
	if not reduced_effects:
		_black_hole_phase_tween.parallel().tween_property(shift_label, "modulate:a", 1.0, duration * 0.18)
	_black_hole_phase_tween.tween_method(
		_apply_black_hole_phase_progress.bind(generation, phase_id, _black_hole_from_profile, _black_hole_to_profile),
		0.0,
		1.0,
		duration * 0.64
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_black_hole_phase_tween.parallel().tween_property(shift_flash, "color:a", 0.12, duration * 0.64)
	_black_hole_phase_tween.tween_property(shift_label, "modulate:a", 0.0, duration * 0.18)
	_black_hole_phase_tween.parallel().tween_property(shift_flash, "color:a", 0.0, duration * 0.18)
	_black_hole_phase_tween.tween_callback(_finish_black_hole_phase.bind(generation, phase_id))
	return true


func play_black_hole_finale(result_snapshot: Dictionary, phase_id := -1) -> bool:
	var resolved_phase_id := _last_completed_black_hole_phase_id if phase_id < 0 else phase_id
	if result_snapshot.is_empty() or resolved_phase_id < 0 or resolved_phase_id != _last_completed_black_hole_phase_id:
		return false
	if _black_hole_finale_active or _black_hole_finale_completed_generation == _black_hole_run_generation:
		return false

	_cancel_black_hole_phase()
	_black_hole_finale_active = true
	_black_hole_finale_generation = _black_hole_run_generation
	_black_hole_finale_snapshot = result_snapshot.duplicate(true)
	if _hud != null:
		_hud.visible = false
	if _pause_menu != null:
		_pause_menu.visible = false
	black_hole_overlay.modulate = Color(1.0, 1.0, 1.0, 0.82 if reduced_effects else 1.0)
	var duration := 0.34 if reduced_effects else black_hole_finale_duration
	black_hole_overlay.begin_finale(_black_hole_finale_snapshot, reduced_effects)
	var generation := _black_hole_run_generation
	_black_hole_finale_tween = create_tween()
	_black_hole_finale_tween.tween_method(
		_apply_black_hole_finale_progress.bind(generation),
		0.0,
		1.0,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_black_hole_finale_tween.tween_callback(_on_black_hole_finale_visual_finished.bind(generation))
	return true


func reset_black_hole_presentation() -> void:
	_black_hole_run_generation += 1
	_cancel_black_hole_phase()
	_cancel_black_hole_finale()
	_active_black_hole_phase_id = -1
	_active_black_hole_phase_generation = -1
	_last_completed_black_hole_phase_id = -1
	_completed_black_hole_phase_ids.clear()
	_black_hole_finale_active = false
	_black_hole_finale_generation = -1
	_black_hole_finale_completed_generation = -1
	_black_hole_finale_snapshot.clear()
	_black_hole_origin_visual_rect = Rect2()
	black_hole_overlay.modulate = Color.WHITE
	black_hole_overlay.reset_effect()
	if _hud != null:
		_hud.visible = true
		_hud.modulate = Color.WHITE
	if _pause_menu != null:
		_pause_menu.visible = true
		_pause_menu.modulate = Color.WHITE


func is_black_hole_phase_active() -> bool:
	return _active_black_hole_phase_id != -1


func is_black_hole_finale_active() -> bool:
	return _black_hole_finale_active


func get_black_hole_presentation_metrics() -> Dictionary:
	var metrics := black_hole_overlay.get_visual_metrics()
	metrics.merge({
		"active_phase_id": _active_black_hole_phase_id,
		"last_completed_phase_id": _last_completed_black_hole_phase_id,
		"run_generation": _black_hole_run_generation,
		"status_label_visible": shift_label.visible,
		"status_label": shift_label.text,
		"hud_visible": _hud.visible if _hud != null else false,
	}, true)
	return metrics


func _apply_shift_progress(progress: float, from_profile: int, to_profile: int) -> void:
	_frame.apply_visual_profile_lerp(from_profile, to_profile, progress)
	visual_field_rect_changed.emit(_frame.get_field_visual_rect_lerp(from_profile, to_profile, progress))
	_apply_dependent_layout()


func _finish_shift(shift_id: int) -> void:
	if shift_id != _active_shift_id:
		return
	_frame.set_profile(_target_profile)
	visual_field_rect_changed.emit(_frame.get_field_visual_rect())
	_apply_dependent_layout()
	_completed_shift_ids[shift_id] = true
	_active_shift_id = -1
	_shift_tween = null
	_reset_overlay()
	stage_shift_presentation_finished.emit(shift_id)


func _apply_black_hole_phase_progress(progress: float, generation: int, phase_id: int, from_profile: int, to_profile: int) -> void:
	if generation != _black_hole_run_generation or phase_id != _active_black_hole_phase_id:
		return
	_frame.apply_visual_profile_lerp(from_profile, to_profile, progress)
	var visual_rect := _frame.get_field_visual_rect_lerp(from_profile, to_profile, progress)
	black_hole_overlay.set_phase_progress(progress, visual_rect)
	visual_field_rect_changed.emit(visual_rect)
	_apply_dependent_layout()


func _finish_black_hole_phase(generation: int, phase_id: int) -> void:
	if generation != _black_hole_run_generation or generation != _active_black_hole_phase_generation or phase_id != _active_black_hole_phase_id:
		return
	_frame.set_profile(_black_hole_to_profile)
	visual_field_rect_changed.emit(_frame.get_field_visual_rect())
	_apply_dependent_layout()
	black_hole_overlay.complete_phase()
	_completed_black_hole_phase_ids[phase_id] = generation
	_last_completed_black_hole_phase_id = phase_id
	_active_black_hole_phase_id = -1
	_active_black_hole_phase_generation = -1
	_black_hole_phase_tween = null
	_reset_overlay()
	black_hole_phase_presentation_finished.emit(phase_id)


func _apply_black_hole_finale_progress(progress: float, generation: int) -> void:
	if not _black_hole_finale_active or generation != _black_hole_run_generation or generation != _black_hole_finale_generation:
		return
	black_hole_overlay.set_finale_progress(progress)


func _on_black_hole_finale_visual_finished(generation: int) -> void:
	if not _black_hole_finale_active or generation != _black_hole_run_generation or generation != _black_hole_finale_generation:
		return
	_black_hole_finale_tween = null
	black_hole_overlay.finish_finale()
	_black_hole_finale_active = false
	_black_hole_finale_completed_generation = _black_hole_run_generation
	_black_hole_finale_generation = -1
	black_hole_finale_presentation_finished.emit()


func _find_profile_for_field_width(width: float) -> int:
	var closest_profile := 0
	var closest_distance := INF
	for profile in range(GameplayFrame.FIELD_WIDTHS.size()):
		var distance := absf(GameplayFrame.FIELD_WIDTHS[profile] - width)
		if distance < closest_distance:
			closest_distance = distance
			closest_profile = profile
	return closest_profile


func _cancel_active_shift() -> void:
	if _shift_tween != null and _shift_tween.is_valid():
		_shift_tween.kill()
	_shift_tween = null
	_active_shift_id = -1
	_reset_overlay()


func _cancel_black_hole_phase() -> void:
	if _black_hole_phase_tween != null and _black_hole_phase_tween.is_valid():
		_black_hole_phase_tween.kill()
	_black_hole_phase_tween = null
	_active_black_hole_phase_id = -1
	_active_black_hole_phase_generation = -1
	black_hole_overlay.reset_effect()
	_reset_overlay()


func _cancel_black_hole_finale() -> void:
	if _black_hole_finale_tween != null and _black_hole_finale_tween.is_valid():
		_black_hole_finale_tween.kill()
	_black_hole_finale_tween = null
	black_hole_overlay.reset_effect()


func _apply_dependent_layout() -> void:
	if _hud != null:
		_hud.apply_frame_layout(_frame.get_visual_left_wing_rect(), _frame.get_visual_right_wing_rect())
	if _pause_menu != null:
		_pause_menu.apply_frame_layout(_frame.get_visual_right_bottom_panel_rect())


func _reset_overlay() -> void:
	shift_flash.color = Color(0.37, 0.68, 0.48, 0.0)
	shift_label.visible = false
	shift_label.modulate.a = 0.0
	shift_label.text = "SCALE SHIFT"
