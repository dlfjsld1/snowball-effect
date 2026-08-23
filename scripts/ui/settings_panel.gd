class_name SettingsPanel
extends Control

## Content-owned Settings v1 view. System changes stay behind the Integration
## adapter: this panel only renders snapshots and emits session-bound requests.

signal settings_apply_requested(session_id: int, draft: Dictionary)
signal settings_close_requested(session_id: int)
signal settings_preview_requested(session_id: int, draft: Dictionary)

@onready var volume_minus_button: Button = %VolumeMinusButton
@onready var volume_gauge = %VolumeGauge
@onready var volume_plus_button: Button = %VolumePlusButton
@onready var bgm_minus_button: Button = %BgmMinusButton
@onready var bgm_gauge = %BgmGauge
@onready var bgm_plus_button: Button = %BgmPlusButton
@onready var sfx_minus_button: Button = %SfxMinusButton
@onready var sfx_gauge = %SfxGauge
@onready var sfx_plus_button: Button = %SfxPlusButton
@onready var value_popups_toggle: BrassPopupToggle = %ValuePopupsToggle
@onready var apply_button: Button = %ApplyButton
@onready var close_button: Button = %CloseButton

var _session_id := -1
var _return_view: StringName = &""
var _draft: Dictionary = {}
var _apply_requested := false
var _close_requested := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	volume_minus_button.pressed.connect(_adjust_master.bind(-1))
	volume_plus_button.pressed.connect(_adjust_master.bind(1))
	bgm_minus_button.pressed.connect(_adjust_bgm.bind(-1))
	bgm_plus_button.pressed.connect(_adjust_bgm.bind(1))
	sfx_minus_button.pressed.connect(_adjust_sfx.bind(-1))
	sfx_plus_button.pressed.connect(_adjust_sfx.bind(1))
	value_popups_toggle.toggled.connect(_on_value_popups_toggled)
	apply_button.pressed.connect(_request_apply)
	close_button.pressed.connect(_request_close)


func _input(event: InputEvent) -> void:
	if not visible or not event.is_action_pressed("ui_cancel") or _is_echo(event):
		return
	_request_close()
	get_viewport().set_input_as_handled()


func show_for_session(session_id: int, snapshot: Dictionary, return_view: StringName) -> bool:
	if session_id < 0 or not _is_valid_return_view(return_view) or not _is_valid_snapshot(snapshot):
		return false
	_session_id = session_id
	_return_view = return_view
	_apply_requested = false
	_close_requested = false
	_set_draft(snapshot)
	visible = true
	volume_minus_button.grab_focus()
	return true


func apply_snapshot(snapshot: Dictionary) -> bool:
	if _session_id < 0 or not _is_valid_snapshot(snapshot):
		return false
	_apply_requested = false
	_set_draft(snapshot)
	return true


func accept_closed(session_id: int, return_view: StringName) -> bool:
	if session_id != _session_id or return_view != _return_view:
		return false
	visible = false
	_session_id = -1
	_return_view = &""
	_draft.clear()
	_apply_requested = false
	_close_requested = false
	return true


func get_active_session_id() -> int:
	return _session_id


func get_return_view() -> StringName:
	return _return_view


func get_draft() -> Dictionary:
	return _draft.duplicate(true)


func _adjust_master(delta: int) -> void:
	_adjust_volume("master_volume", volume_gauge, delta)


func _adjust_bgm(delta: int) -> void:
	_adjust_volume("bgm_volume", bgm_gauge, delta)


func _adjust_sfx(delta: int) -> void:
	_adjust_volume("sfx_volume", sfx_gauge, delta)


func _adjust_volume(key: StringName, gauge, delta: int) -> void:
	if _draft.is_empty():
		return
	var step := clampi(_volume_to_step(int(_draft[key])) + delta, 0, 10)
	_draft[key] = step
	gauge.level = step
	_apply_requested = false
	_request_preview()


func _on_value_popups_toggled(enabled: bool) -> void:
	if _draft.is_empty():
		return
	_draft["value_popups_enabled"] = enabled
	_apply_requested = false
	_request_preview()


func _request_apply() -> void:
	if _session_id < 0 or _apply_requested or _close_requested or not _is_valid_snapshot(_draft):
		return
	_apply_requested = true
	settings_apply_requested.emit(_session_id, get_draft())


func _request_preview() -> void:
	if _session_id < 0 or _close_requested or not _is_valid_snapshot(_draft):
		return
	settings_preview_requested.emit(_session_id, get_draft())


func _request_close() -> void:
	if _session_id < 0 or _close_requested:
		return
	_close_requested = true
	settings_close_requested.emit(_session_id)


func _set_draft(snapshot: Dictionary) -> void:
	_draft = snapshot.duplicate(true)
	volume_gauge.level = _volume_to_step(int(_draft["master_volume"]))
	bgm_gauge.level = _volume_to_step(int(_draft["bgm_volume"]))
	sfx_gauge.level = _volume_to_step(int(_draft["sfx_volume"]))
	value_popups_toggle.set_pressed_no_signal(bool(_draft["value_popups_enabled"]))
	value_popups_toggle.queue_redraw()


func _is_valid_snapshot(snapshot: Dictionary) -> bool:
	return snapshot.size() == 4 \
		and snapshot.get("master_volume", null) is int \
		and int(snapshot["master_volume"]) >= 0 \
		and int(snapshot["master_volume"]) <= 10 \
		and snapshot.get("bgm_volume", null) is int and int(snapshot["bgm_volume"]) >= 0 and int(snapshot["bgm_volume"]) <= 10 \
		and snapshot.get("sfx_volume", null) is int and int(snapshot["sfx_volume"]) >= 0 and int(snapshot["sfx_volume"]) <= 10 \
		and snapshot.get("value_popups_enabled", null) is bool


func _volume_to_step(volume: int) -> int:
	return clampi(volume, 0, 10)


func _is_valid_return_view(return_view: StringName) -> bool:
	return return_view == &"title" or return_view == &"pause"


func _is_echo(event: InputEvent) -> bool:
	return event is InputEventKey and event.echo
