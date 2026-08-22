class_name SettingsAdapter
extends Node

## Integration-owned boundary for persisted volume settings. UI submits only a
## session-bound draft; this node owns validation, persistence and Master bus.

signal settings_snapshot_changed(snapshot: Dictionary)
signal settings_closed(session_id: int, return_view: StringName)

const RETURN_VIEW_TITLE: StringName = &"title"
const RETURN_VIEW_PAUSE: StringName = &"pause"
const SETTINGS_SECTION := "settings_v1"
const DEFAULT_SNAPSHOT := {
	"master_volume": 5,
	"bgm_volume": 5,
	"sfx_volume": 5,
	"value_popups_enabled": true,
}

@export var audio_bus: StringName = &"Master"
@export var settings_path := "user://settings_v1.cfg"

var _snapshot: Dictionary = DEFAULT_SNAPSHOT.duplicate(true)
var _applied_snapshot: Dictionary = DEFAULT_SNAPSHOT.duplicate(true)
var _next_session_id := 1
var _active_session_id := -1
var _active_return_view: StringName = &""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_or_reset()


func open_settings(return_view: StringName, _user_gesture := false) -> int:
	if _active_session_id != -1 or not _is_valid_return_view(return_view):
		return -1
	_active_session_id = _next_session_id
	_next_session_id += 1
	_active_return_view = return_view
	settings_snapshot_changed.emit(get_snapshot())
	return _active_session_id


func apply_settings(session_id: int, draft: Dictionary, _user_gesture := false) -> bool:
	if not preview_settings(session_id, draft):
		return false
	_persist_or_reset()
	_applied_snapshot = _snapshot.duplicate(true)
	return true


func preview_settings(session_id: int, draft: Dictionary) -> bool:
	if session_id != _active_session_id:
		return false
	var validated := _validate_snapshot(draft)
	if validated.is_empty():
		return false
	_snapshot = validated
	_apply_audio()
	settings_snapshot_changed.emit(get_snapshot())
	return true


func close_settings(session_id: int) -> bool:
	if session_id != _active_session_id:
		return false
	if _snapshot != _applied_snapshot:
		_snapshot = _applied_snapshot.duplicate(true)
		_apply_audio()
		settings_snapshot_changed.emit(get_snapshot())
	var return_view := _active_return_view
	_active_session_id = -1
	_active_return_view = &""
	settings_closed.emit(session_id, return_view)
	return true


func get_snapshot() -> Dictionary:
	return _snapshot.duplicate(true)


func get_active_session_id() -> int:
	return _active_session_id


func get_active_return_view() -> StringName:
	return _active_return_view


func _load_or_reset() -> void:
	var config := ConfigFile.new()
	if config.load(settings_path) != OK:
		_snapshot = DEFAULT_SNAPSHOT.duplicate(true)
		_applied_snapshot = _snapshot.duplicate(true)
		_apply_audio()
		return
	var loaded := {
		"master_volume": config.get_value(SETTINGS_SECTION, "master_volume", DEFAULT_SNAPSHOT["master_volume"]),
		"bgm_volume": config.get_value(SETTINGS_SECTION, "bgm_volume", DEFAULT_SNAPSHOT["bgm_volume"]),
		"sfx_volume": config.get_value(SETTINGS_SECTION, "sfx_volume", DEFAULT_SNAPSHOT["sfx_volume"]),
		"value_popups_enabled": config.get_value(SETTINGS_SECTION, "value_popups_enabled", DEFAULT_SNAPSHOT["value_popups_enabled"]),
	}
	var validated := _validate_snapshot(loaded)
	_snapshot = validated if not validated.is_empty() else DEFAULT_SNAPSHOT.duplicate(true)
	_applied_snapshot = _snapshot.duplicate(true)
	_apply_audio()


func _persist_or_reset() -> void:
	var config := ConfigFile.new()
	config.set_value(SETTINGS_SECTION, "master_volume", _snapshot["master_volume"])
	config.set_value(SETTINGS_SECTION, "bgm_volume", _snapshot["bgm_volume"])
	config.set_value(SETTINGS_SECTION, "sfx_volume", _snapshot["sfx_volume"])
	config.set_value(SETTINGS_SECTION, "value_popups_enabled", _snapshot["value_popups_enabled"])
	if config.save(settings_path) != OK:
		_snapshot = DEFAULT_SNAPSHOT.duplicate(true)
		_apply_audio()
		settings_snapshot_changed.emit(get_snapshot())


func _validate_snapshot(draft: Dictionary) -> Dictionary:
	if draft.size() != DEFAULT_SNAPSHOT.size():
		return {}
	for key in DEFAULT_SNAPSHOT:
		if not draft.has(key):
			return {}
	for key in [&"master_volume", &"bgm_volume", &"sfx_volume"]:
		if not (draft[key] is int) or int(draft[key]) < 0 or int(draft[key]) > 10:
			return {}
	if not (draft["value_popups_enabled"] is bool):
		return {}
	return {
		"master_volume": int(draft["master_volume"]),
		"bgm_volume": int(draft["bgm_volume"]),
		"sfx_volume": int(draft["sfx_volume"]),
		"value_popups_enabled": draft["value_popups_enabled"],
	}


func _apply_audio() -> void:
	var bus_index := AudioServer.get_bus_index(audio_bus)
	if bus_index < 0:
		return
	# Level 5 preserves the authored pre-settings mix.
	var linear_volume := float(_snapshot["master_volume"]) / 5.0
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(linear_volume, 0.0001)))
	AudioServer.set_bus_mute(bus_index, false)


func _is_valid_return_view(return_view: StringName) -> bool:
	return return_view == RETURN_VIEW_TITLE or return_view == RETURN_VIEW_PAUSE
