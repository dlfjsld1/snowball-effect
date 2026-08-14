class_name PresentationManager
extends Control

signal stage_shift_presentation_finished(shift_id: int)

@export_range(0.05, 3.0, 0.05) var shift_duration := 0.9

@onready var shift_flash: ColorRect = %ShiftFlash
@onready var shift_label: Label = %ShiftLabel

var _frame: GameplayFrame
var _background_manager: BackgroundManager
var _hud: Hud
var _pause_menu: PauseMenu
var _shift_tween: Tween
var _active_shift_id := -1
var _target_profile := 0
var _target_background_id: StringName = &"ground"
var _completed_shift_ids: Dictionary = {}


func _ready() -> void:
	_frame = get_parent() as GameplayFrame
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


func _apply_shift_progress(progress: float, from_profile: int, to_profile: int) -> void:
	_frame.apply_visual_profile_lerp(from_profile, to_profile, progress)
	_apply_dependent_layout()


func _finish_shift(shift_id: int) -> void:
	if shift_id != _active_shift_id:
		return
	_frame.set_profile(_target_profile)
	_apply_dependent_layout()
	_completed_shift_ids[shift_id] = true
	_active_shift_id = -1
	_shift_tween = null
	_reset_overlay()
	stage_shift_presentation_finished.emit(shift_id)


func _cancel_active_shift() -> void:
	if _shift_tween != null and _shift_tween.is_valid():
		_shift_tween.kill()
	_shift_tween = null
	_active_shift_id = -1
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
