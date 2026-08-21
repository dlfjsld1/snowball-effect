class_name StageClearPanel
extends Control

## Request-only Presentation for a completed non-final Score Clear.
## It owns a copied display snapshot and never reads or mutates gameplay nodes.

const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")
const NO_CLEAR_ID := -1

signal next_stage_requested(clear_id: int)

@onready var panel_surface: Control = %PanelSurface
@onready var celebration_lights: Control = %CelebrationLights
@onready var stage_identity_label: Label = %StageIdentityLabel
@onready var stage_score_value: Label = %StageScoreValue
@onready var run_score_value: Label = %RunScoreValue
@onready var next_stage_button: Button = %NextStageButton

var _clear_snapshot: Dictionary = {}
var _active_clear_id := NO_CLEAR_ID
var _last_seen_clear_id := NO_CLEAR_ID
var _request_emitted := false
var _reduced_effects := false
var _open_tween: Tween
var _effect_elapsed := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	next_stage_button.pressed.connect(_on_next_stage_pressed)
	set_process(false)


func _process(delta: float) -> void:
	if _reduced_effects or not visible:
		return
	_effect_elapsed += delta
	celebration_lights.modulate.a = 0.72 + sin(_effect_elapsed * 7.0) * 0.18


func show_stage_clear(clear_snapshot: Dictionary, clear_id: int) -> bool:
	if not _is_eligible_snapshot(clear_snapshot, clear_id):
		return false
	if _active_clear_id != NO_CLEAR_ID or clear_id <= _last_seen_clear_id:
		return false

	_clear_snapshot = clear_snapshot.duplicate(true)
	_active_clear_id = clear_id
	_last_seen_clear_id = clear_id
	_request_emitted = false
	_effect_elapsed = 0.0
	stage_identity_label.text = "%s COMPLETE" % str(_clear_snapshot["stage_display_name"]).to_upper()
	stage_score_value.text = ScoreFormatter.format_score(float(_clear_snapshot["stage_score"]))
	run_score_value.text = ScoreFormatter.format_score(float(_clear_snapshot["run_score"]))
	next_stage_button.disabled = false
	visible = true
	set_process(not _reduced_effects)
	_play_open_motion()
	next_stage_button.grab_focus()
	return true


func request_next_stage(clear_id: int) -> bool:
	if not visible or clear_id != _active_clear_id or _request_emitted:
		return false
	_request_emitted = true
	next_stage_button.disabled = true
	next_stage_requested.emit(clear_id)
	return true


func hide_stage_clear(clear_id: int) -> bool:
	if clear_id != _active_clear_id:
		return false
	_close_panel()
	return true


func reset_for_new_run() -> void:
	# Keep the process-lifetime high-water mark so delayed callbacks from an old
	# Run cannot reopen the panel after Retry/Main/new Run reset.
	_close_panel()


func set_reduced_effects(enabled: bool) -> void:
	_reduced_effects = enabled
	if not visible:
		return
	if _reduced_effects:
		_kill_open_tween()
		panel_surface.position = Vector2.ZERO
		panel_surface.modulate.a = 1.0
		celebration_lights.modulate.a = 1.0
	set_process(not _reduced_effects)


func get_clear_snapshot() -> Dictionary:
	return _clear_snapshot.duplicate(true)


func get_active_clear_id() -> int:
	return _active_clear_id


func get_last_seen_clear_id() -> int:
	return _last_seen_clear_id


func has_emitted_request() -> bool:
	return _request_emitted


func is_reduced_effects() -> bool:
	return _reduced_effects


func is_open_motion_active() -> bool:
	return _open_tween != null and _open_tween.is_valid()


func _on_next_stage_pressed() -> void:
	request_next_stage(_active_clear_id)


func _play_open_motion() -> void:
	_kill_open_tween()
	celebration_lights.modulate.a = 1.0
	if _reduced_effects:
		panel_surface.position = Vector2.ZERO
		panel_surface.modulate.a = 1.0
		return
	panel_surface.position = Vector2(0.0, 16.0)
	panel_surface.modulate.a = 0.0
	_open_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_open_tween.set_parallel(true)
	_open_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_open_tween.tween_property(panel_surface, "position:y", 0.0, 0.18)
	_open_tween.tween_property(panel_surface, "modulate:a", 1.0, 0.12)


func _close_panel() -> void:
	_kill_open_tween()
	if is_instance_valid(next_stage_button):
		next_stage_button.release_focus()
		next_stage_button.disabled = true
	visible = false
	set_process(false)
	panel_surface.position = Vector2.ZERO
	panel_surface.modulate.a = 1.0
	celebration_lights.modulate.a = 1.0
	_clear_snapshot.clear()
	_active_clear_id = NO_CLEAR_ID
	_request_emitted = false


func _kill_open_tween() -> void:
	if _open_tween != null and _open_tween.is_valid():
		_open_tween.kill()
	_open_tween = null


func _is_eligible_snapshot(clear_snapshot: Dictionary, clear_id: int) -> bool:
	if clear_id < 1:
		return false
	for required_key in [
		"stage_index",
		"stage_display_name",
		"stage_score",
		"run_score",
		"outcome",
		"is_final_stage",
	]:
		if not clear_snapshot.has(required_key):
			return false

	var stage_index := int(clear_snapshot["stage_index"])
	var stage_name := str(clear_snapshot["stage_display_name"]).strip_edges()
	var outcome := StringName(clear_snapshot["outcome"])
	if stage_index < 0 or stage_index >= 2 or stage_name.is_empty():
		return false
	if stage_name.to_upper() == "GALACTIC" or bool(clear_snapshot["is_final_stage"]):
		return false
	if outcome != &"CLEARED":
		return false
	return true
