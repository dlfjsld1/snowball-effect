extends Node

const SettingsAdapterScript = preload("res://scripts/core/settings_adapter.gd")

var _failures := 0
var _snapshots: Array[Dictionary] = []
var _closed: Array[Dictionary] = []


func _ready() -> void:
	var test_settings_path := "user://s10_g1_settings_adapter_test.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_settings_path))
	var adapter = SettingsAdapterScript.new()
	adapter.settings_path = test_settings_path
	adapter.settings_snapshot_changed.connect(func(snapshot: Dictionary) -> void: _snapshots.append(snapshot.duplicate(true)))
	adapter.settings_closed.connect(func(session_id: int, return_view: StringName) -> void:
		_closed.append({"session_id": session_id, "return_view": return_view})
	)
	add_child(adapter)
	await get_tree().process_frame

	_expect(adapter.get_snapshot() == SettingsAdapterScript.DEFAULT_SNAPSHOT, "Missing persistence must load the default snapshot.")
	var title_session: int = adapter.open_settings(SettingsAdapterScript.RETURN_VIEW_TITLE)
	_expect(title_session == 1, "First valid title session must receive ID 1.")
	_expect(adapter.open_settings(SettingsAdapterScript.RETURN_VIEW_PAUSE) == -1, "A second open during an active session must be stale.")
	var applied_snapshot := {"master_volume": 7, "bgm_volume": 8, "sfx_volume": 9, "value_popups_enabled": false}
	_expect(not adapter.apply_settings(title_session + 1, applied_snapshot), "Stale apply must not mutate settings.")
	_expect(not adapter.apply_settings(title_session, {"master_volume": 11, "bgm_volume": 8, "sfx_volume": 9, "value_popups_enabled": false}), "Out-of-range volume must be rejected.")
	_expect(adapter.preview_settings(title_session, {"master_volume": 4, "bgm_volume": 5, "sfx_volume": 6, "value_popups_enabled": true}), "Current session must preview a valid draft.")
	_expect(adapter.get_snapshot()["master_volume"] == 4, "Preview must immediately apply to the effective snapshot.")
	_expect(adapter.close_settings(title_session), "Close must revert preview values and close once.")
	_expect(adapter.get_snapshot() == SettingsAdapterScript.DEFAULT_SNAPSHOT, "Close must restore the last applied snapshot.")
	var apply_session: int = adapter.open_settings(SettingsAdapterScript.RETURN_VIEW_TITLE)
	_expect(adapter.apply_settings(apply_session, applied_snapshot), "Current session must apply a valid draft.")
	_expect(adapter.get_snapshot() == applied_snapshot, "Applied snapshot must retain all v1 fields.")
	var master_bus := AudioServer.get_bus_index(&"Master")
	_expect(master_bus >= 0 and not AudioServer.is_bus_mute(master_bus), "Three-volume settings must not retain a mute state.")
	_expect(master_bus >= 0 and is_equal_approx(AudioServer.get_bus_volume_db(master_bus), linear_to_db(7.0 / 5.0)), "Level 5 baseline mapping must apply to the Master bus.")
	_expect(adapter.close_settings(apply_session), "Matching session must close once.")
	_expect(not adapter.close_settings(apply_session), "Duplicate close must be rejected.")
	_expect(_closed.size() == 2 and _closed[1]["return_view"] == SettingsAdapterScript.RETURN_VIEW_TITLE, "Close must preserve the title return view.")

	var pause_session: int = adapter.open_settings(SettingsAdapterScript.RETURN_VIEW_PAUSE)
	_expect(pause_session == 3, "Session IDs must be monotonic across returns.")
	_expect(adapter.close_settings(pause_session), "Pause-origin session must close normally.")
	_expect(_closed.size() == 3 and _closed[2]["return_view"] == SettingsAdapterScript.RETURN_VIEW_PAUSE, "Close must preserve the pause return view.")
	_expect(_snapshots.size() >= 6, "Open, preview, revert, apply and later open operations must publish read-only snapshots.")

	var restored = SettingsAdapterScript.new()
	restored.settings_path = adapter.settings_path
	add_child(restored)
	await get_tree().process_frame
	_expect(restored.get_snapshot() == adapter.get_snapshot(), "Persisted v1 snapshot must restore in a fresh adapter.")
	var corrupt_file := FileAccess.open(test_settings_path, FileAccess.WRITE)
	corrupt_file.store_string("this is not a ConfigFile")
	corrupt_file.close()
	var fallback = SettingsAdapterScript.new()
	fallback.settings_path = test_settings_path
	add_child(fallback)
	await get_tree().process_frame
	_expect(fallback.get_snapshot() == SettingsAdapterScript.DEFAULT_SNAPSHOT, "Unreadable persistence must fall back to defaults.")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(test_settings_path))

	if _failures == 0:
		print("S10_G1_SETTINGS_ADAPTER_VERIFIED title_pause_sessions=true stale_rejected=true persistence=true")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S10-G1 settings adapter verification failed: %s" % message)
