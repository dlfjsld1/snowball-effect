class_name PresentationManager
extends Control

signal stage_shift_presentation_finished(shift_id: int)
signal visual_field_rect_changed(visual_rect: Rect2)
signal black_hole_phase_presentation_finished(phase_id: int)
signal black_hole_finale_presentation_finished

@export_range(0.05, 3.0, 0.05) var shift_duration := 0.9
@export_range(0.05, 3.0, 0.05) var black_hole_phase_duration := 0.9
@export_range(0.05, 5.0, 0.05) var black_hole_finale_duration := 1.35

@onready var shift_flash: ColorRect = %ShiftFlash
@onready var shift_label: Label = %ShiftLabel
@onready var black_hole_overlay: BlackHolePresentationOverlay = %BlackHoleOverlay

var _frame: GameplayFrame
var _background_manager: BackgroundManager
var _hud: Hud
var _pause_menu: PauseMenu
var _shift_tween: Tween
var _active_shift_id := -1
var _target_profile := 0
var _target_background_id: StringName = &"ground"
var _completed_shift_ids: Dictionary = {}
var _active_black_hole_phase_id := -1
var _completed_black_hole_phase_ids: Dictionary = {}
var _black_hole_phase_tween: Tween
var _black_hole_finale_active := false


func _ready() -> void:
	_frame = get_parent() as GameplayFrame
	black_hole_overlay.finale_visual_finished.connect(_on_black_hole_finale_visual_finished)
	_reset_overlay()


func configure(background_manager: BackgroundManager, hud: Hud, pause_menu: PauseMenu) -> void:
	_background_manager = background_manager
	_hud = hud
	_pause_menu = pause_menu


func apply_stage(definition: StageDefinition) -> void:
	if definition == null:
		return
	if _active_shift_id != -1:
		_cancel_active_shift()
	var profile := clampi(definition.stage_index, 0, 2)
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
	if _active_black_hole_phase_id != -1 or _completed_black_hole_phase_ids.has(phase_id):
		return false
	_active_black_hole_phase_id = phase_id
	black_hole_overlay.begin_phase()
	shift_label.text = "GRAVITY ANOMALY // L3 FIELD"
	shift_label.visible = true
	shift_label.modulate.a = 0.0
	shift_flash.color = Color(0.18, 0.04, 0.38, 0.0)
	var from_profile := _frame.profile_index
	var to_profile := 3
	_black_hole_phase_tween = create_tween()
	_black_hole_phase_tween.tween_property(shift_flash, "color:a", 0.32, black_hole_phase_duration * 0.18)
	_black_hole_phase_tween.parallel().tween_property(shift_label, "modulate:a", 1.0, black_hole_phase_duration * 0.18)
	_black_hole_phase_tween.tween_method(
		_apply_black_hole_phase_progress.bind(from_profile, to_profile),
		0.0,
		1.0,
		black_hole_phase_duration * 0.64
	).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_black_hole_phase_tween.parallel().tween_property(shift_flash, "color:a", 0.12, black_hole_phase_duration * 0.64)
	_black_hole_phase_tween.tween_property(shift_label, "modulate:a", 0.0, black_hole_phase_duration * 0.18)
	_black_hole_phase_tween.parallel().tween_property(shift_flash, "color:a", 0.0, black_hole_phase_duration * 0.18)
	_black_hole_phase_tween.tween_callback(_finish_black_hole_phase.bind(phase_id))
	return true


func play_black_hole_finale(result_snapshot: Dictionary) -> bool:
	if _black_hole_finale_active or result_snapshot.is_empty():
		return false
	_cancel_black_hole_phase()
	_black_hole_finale_active = true
	if _hud != null:
		_hud.visible = false
	if _pause_menu != null:
		_pause_menu.visible = false
	black_hole_overlay.begin_finale(result_snapshot, black_hole_finale_duration)
	return true


func reset_black_hole_presentation() -> void:
	_cancel_black_hole_phase()
	_black_hole_finale_active = false
	_completed_black_hole_phase_ids.clear()
	black_hole_overlay.reset_overlay()


func is_black_hole_phase_active() -> bool:
	return _active_black_hole_phase_id != -1


func is_black_hole_finale_active() -> bool:
	return _black_hole_finale_active


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


func _apply_black_hole_phase_progress(progress: float, from_profile: int, to_profile: int) -> void:
	_frame.apply_visual_profile_lerp(from_profile, to_profile, progress)
	visual_field_rect_changed.emit(_frame.get_field_visual_rect_lerp(from_profile, to_profile, progress))
	_apply_dependent_layout()


func _finish_black_hole_phase(phase_id: int) -> void:
	if phase_id != _active_black_hole_phase_id:
		return
	_frame.set_profile(3)
	visual_field_rect_changed.emit(_frame.get_field_visual_rect())
	_apply_dependent_layout()
	black_hole_overlay.hold_phase()
	_completed_black_hole_phase_ids[phase_id] = true
	_active_black_hole_phase_id = -1
	_black_hole_phase_tween = null
	_reset_overlay()
	black_hole_phase_presentation_finished.emit(phase_id)


func _on_black_hole_finale_visual_finished() -> void:
	if not _black_hole_finale_active:
		return
	_black_hole_finale_active = false
	black_hole_finale_presentation_finished.emit()


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
	_reset_overlay()


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
