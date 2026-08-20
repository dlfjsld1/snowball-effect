class_name PresentationManager
extends Control

signal stage_shift_presentation_finished(shift_id: int)
signal black_hole_phase_presentation_finished(phase_id: int)
signal black_hole_finale_presentation_finished(phase_id: int)

@export_range(0.05, 3.0, 0.05) var shift_duration := 0.9
@export_range(0.05, 3.0, 0.05) var black_hole_phase_duration := 0.8
@export_range(0.05, 3.0, 0.05) var black_hole_finale_duration := 1.15
@export var reduced_effects := false

@onready var shift_flash: ColorRect = %ShiftFlash
@onready var shift_label: Label = %ShiftLabel
@onready var black_hole_effect: BlackHolePhaseEffect = %BlackHolePhaseEffect
@onready var black_hole_phase_label: Label = %BlackHolePhaseLabel

var _frame: GameplayFrame
var _background_manager: BackgroundManager
var _hud: Hud
var _pause_menu: PauseMenu
var _shift_tween: Tween
var _active_shift_id := -1
var _target_profile := 0
var _target_background_id: StringName = &"ground"
var _completed_shift_ids: Dictionary = {}
var _black_hole_event_source: Node
var _black_hole_tween: Tween
var _active_black_hole_phase_id := -1
var _completed_black_hole_phase_ids: Dictionary = {}
var _completed_black_hole_finale_ids: Dictionary = {}
var _last_completed_black_hole_phase_id := -1
var _black_hole_run_generation := 0
var _black_hole_finale_active := false
var _black_hole_finale_ui_hidden := false
var _black_hole_from_profile := 2
var _black_hole_to_profile := 3
var _black_hole_from_rect := Rect2()
var _black_hole_to_rect := Rect2()


func _ready() -> void:
	_frame = get_parent() as GameplayFrame
	_reset_overlay()


func configure(background_manager: BackgroundManager, hud: Hud, pause_menu: PauseMenu) -> void:
	_background_manager = background_manager
	_hud = hud
	_pause_menu = pause_menu


func configure_black_hole_sources(event_source: Node, simulation_source: Node) -> void:
	_disconnect_black_hole_event_source()
	_black_hole_event_source = event_source
	black_hole_effect.set_simulation_source(simulation_source)
	if not is_instance_valid(_black_hole_event_source):
		return
	if _black_hole_event_source.has_signal("black_hole_phase_started"):
		_black_hole_event_source.black_hole_phase_started.connect(_on_black_hole_phase_started)
	if _black_hole_event_source.has_signal("black_hole_finale_locked"):
		_black_hole_event_source.black_hole_finale_locked.connect(_on_black_hole_finale_locked)


func apply_stage(definition: StageDefinition) -> void:
	if definition == null:
		return
	if _active_shift_id != -1:
		_cancel_active_shift()
	var profile := clampi(definition.stage_index, 0, 2)
	if profile < 2 and (_last_completed_black_hole_phase_id != -1 or _active_black_hole_phase_id != -1 or _black_hole_finale_active):
		reset_black_hole_presentation()
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


func play_black_hole_phase(phase_id: int, from_rect: Rect2, to_rect: Rect2) -> bool:
	if phase_id < 0 or _active_black_hole_phase_id != -1 or _black_hole_finale_active:
		return false
	if _last_completed_black_hole_phase_id != -1 or _completed_black_hole_phase_ids.has(phase_id):
		return false
	if from_rect.size.x <= 0.0 or from_rect.size.y <= 0.0 or to_rect.size.x <= from_rect.size.x or to_rect.size.y <= 0.0:
		return false

	_cancel_black_hole_tween()
	_active_black_hole_phase_id = phase_id
	_black_hole_from_rect = from_rect
	_black_hole_to_rect = to_rect
	_black_hole_from_profile = _find_profile_for_field_width(from_rect.size.x)
	_black_hole_to_profile = _find_profile_for_field_width(to_rect.size.x)
	black_hole_effect.begin_phase(reduced_effects)
	black_hole_effect.set_phase_progress(0.0, from_rect)
	black_hole_phase_label.text = "BLACK HOLE PHASE  //  FIELD %d > %d" % [roundi(from_rect.size.x), roundi(to_rect.size.x)]
	black_hole_phase_label.visible = true
	black_hole_phase_label.modulate.a = 1.0 if reduced_effects else 0.0
	var generation := _black_hole_run_generation
	var duration := 0.18 if reduced_effects else black_hole_phase_duration
	_black_hole_tween = create_tween()
	_black_hole_tween.set_parallel(true)
	_black_hole_tween.tween_method(
		_apply_black_hole_phase_progress.bind(generation, phase_id),
		0.0,
		1.0,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	if not reduced_effects:
		_black_hole_tween.tween_property(black_hole_phase_label, "modulate:a", 1.0, minf(duration * 0.3, 0.24))
	_black_hole_tween.chain().tween_callback(_finish_black_hole_phase.bind(generation, phase_id))
	return true


func play_black_hole_finale(result_snapshot: Dictionary, phase_id := -1) -> bool:
	var resolved_phase_id := _last_completed_black_hole_phase_id if phase_id < 0 else phase_id
	if result_snapshot.is_empty() or resolved_phase_id < 0 or resolved_phase_id != _last_completed_black_hole_phase_id:
		return false
	if _black_hole_finale_active or _completed_black_hole_finale_ids.has(resolved_phase_id):
		return false
	var black_holes_value = result_snapshot.get("black_holes", [])
	if black_holes_value is not Array or (black_holes_value as Array).size() < 2:
		return false

	_cancel_black_hole_tween()
	_black_hole_finale_active = true
	_black_hole_finale_ui_hidden = false
	black_hole_effect.begin_finale(result_snapshot, reduced_effects)
	black_hole_phase_label.text = "FINAL CONTACT  //  ORBIT LOCK"
	black_hole_phase_label.visible = true
	black_hole_phase_label.modulate.a = 1.0
	var generation := _black_hole_run_generation
	var duration := 0.34 if reduced_effects else black_hole_finale_duration
	_black_hole_tween = create_tween()
	_black_hole_tween.tween_method(
		_apply_black_hole_finale_progress.bind(generation, resolved_phase_id),
		0.0,
		1.0,
		duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_black_hole_tween.tween_callback(_finish_black_hole_finale.bind(generation, resolved_phase_id))
	return true


func reset_black_hole_presentation() -> void:
	_black_hole_run_generation += 1
	_cancel_black_hole_tween()
	_active_black_hole_phase_id = -1
	_last_completed_black_hole_phase_id = -1
	_black_hole_finale_active = false
	_black_hole_finale_ui_hidden = false
	_completed_black_hole_phase_ids.clear()
	_completed_black_hole_finale_ids.clear()
	_black_hole_from_rect = Rect2()
	_black_hole_to_rect = Rect2()
	black_hole_effect.reset_effect()
	black_hole_phase_label.visible = false
	black_hole_phase_label.modulate.a = 0.0
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
	var metrics := black_hole_effect.get_visual_metrics()
	metrics["active_phase_id"] = _active_black_hole_phase_id
	metrics["last_completed_phase_id"] = _last_completed_black_hole_phase_id
	metrics["run_generation"] = _black_hole_run_generation
	metrics["status_label_visible"] = black_hole_phase_label.visible
	metrics["status_label"] = black_hole_phase_label.text
	metrics["hud_visible"] = _hud.visible if _hud != null else false
	return metrics


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


func _apply_black_hole_phase_progress(progress: float, generation: int, phase_id: int) -> void:
	if generation != _black_hole_run_generation or phase_id != _active_black_hole_phase_id:
		return
	_frame.apply_visual_profile_lerp(_black_hole_from_profile, _black_hole_to_profile, progress)
	_apply_dependent_layout()
	var visual_rect := Rect2(
		_black_hole_from_rect.position.lerp(_black_hole_to_rect.position, progress),
		_black_hole_from_rect.size.lerp(_black_hole_to_rect.size, progress)
	)
	black_hole_effect.set_phase_progress(progress, visual_rect)


func _finish_black_hole_phase(generation: int, phase_id: int) -> void:
	if generation != _black_hole_run_generation or phase_id != _active_black_hole_phase_id:
		return
	_frame.set_profile(_black_hole_to_profile)
	_apply_dependent_layout()
	black_hole_effect.set_phase_progress(1.0, _black_hole_to_rect)
	black_hole_effect.complete_phase()
	_completed_black_hole_phase_ids[phase_id] = generation
	_last_completed_black_hole_phase_id = phase_id
	_active_black_hole_phase_id = -1
	_black_hole_tween = null
	black_hole_phase_label.text = "BLACK HOLE PHASE  //  FIELD %d" % roundi(_black_hole_to_rect.size.x)
	black_hole_phase_label.modulate.a = 0.82
	black_hole_phase_presentation_finished.emit(phase_id)


func _apply_black_hole_finale_progress(progress: float, generation: int, phase_id: int) -> void:
	if generation != _black_hole_run_generation or phase_id != _last_completed_black_hole_phase_id or not _black_hole_finale_active:
		return
	black_hole_effect.set_finale_progress(progress)
	if progress >= 0.58 and not _black_hole_finale_ui_hidden:
		_black_hole_finale_ui_hidden = true
		black_hole_phase_label.text = "EVENT HORIZON COLLAPSE"
		if _hud != null:
			_hud.visible = false
		if _pause_menu != null:
			_pause_menu.visible = false


func _finish_black_hole_finale(generation: int, phase_id: int) -> void:
	if generation != _black_hole_run_generation or phase_id != _last_completed_black_hole_phase_id or not _black_hole_finale_active:
		return
	if not _black_hole_finale_ui_hidden:
		_apply_black_hole_finale_progress(1.0, generation, phase_id)
	_completed_black_hole_finale_ids[phase_id] = generation
	_black_hole_finale_active = false
	_black_hole_tween = null
	black_hole_effect.finish_finale()
	black_hole_phase_label.visible = false
	black_hole_phase_label.modulate.a = 0.0
	black_hole_finale_presentation_finished.emit(phase_id)


func _find_profile_for_field_width(width: float) -> int:
	var closest_profile := 0
	var closest_distance := INF
	for profile in range(GameplayFrame.FIELD_WIDTHS.size()):
		var distance := absf(GameplayFrame.FIELD_WIDTHS[profile] - width)
		if distance < closest_distance:
			closest_distance = distance
			closest_profile = profile
	return closest_profile


func _on_black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2) -> void:
	play_black_hole_phase(phase_id, from_rect, to_rect)


func _on_black_hole_finale_locked(result_snapshot: Dictionary) -> void:
	play_black_hole_finale(result_snapshot)


func _cancel_active_shift() -> void:
	if _shift_tween != null and _shift_tween.is_valid():
		_shift_tween.kill()
	_shift_tween = null
	_active_shift_id = -1
	_reset_overlay()


func _cancel_black_hole_tween() -> void:
	if _black_hole_tween != null and _black_hole_tween.is_valid():
		_black_hole_tween.kill()
	_black_hole_tween = null


func _disconnect_black_hole_event_source() -> void:
	if not is_instance_valid(_black_hole_event_source):
		_black_hole_event_source = null
		return
	if _black_hole_event_source.has_signal("black_hole_phase_started") and _black_hole_event_source.black_hole_phase_started.is_connected(_on_black_hole_phase_started):
		_black_hole_event_source.black_hole_phase_started.disconnect(_on_black_hole_phase_started)
	if _black_hole_event_source.has_signal("black_hole_finale_locked") and _black_hole_event_source.black_hole_finale_locked.is_connected(_on_black_hole_finale_locked):
		_black_hole_event_source.black_hole_finale_locked.disconnect(_on_black_hole_finale_locked)
	_black_hole_event_source = null


func _apply_dependent_layout() -> void:
	if _hud != null:
		_hud.apply_frame_layout(_frame.get_visual_left_wing_rect(), _frame.get_visual_right_wing_rect())
	if _pause_menu != null:
		_pause_menu.apply_frame_layout(_frame.get_visual_right_bottom_panel_rect())


func _reset_overlay() -> void:
	shift_flash.color = Color(0.37, 0.68, 0.48, 0.0)
	shift_label.visible = false
	shift_label.modulate.a = 0.0


func _exit_tree() -> void:
	_disconnect_black_hole_event_source()
