extends Node

const PANEL_SCENE := preload("res://scenes/ui/settings_panel.tscn")

var _failures := 0
var _apply_requests: Array[Dictionary] = []
var _close_requests: Array[int] = []
var _preview_requests: Array[Dictionary] = []


func _ready() -> void:
	var panel = PANEL_SCENE.instantiate()
	add_child(panel)
	await get_tree().process_frame
	panel.settings_apply_requested.connect(func(session_id: int, draft: Dictionary) -> void:
		_apply_requests.append({"session_id": session_id, "draft": draft.duplicate(true)})
	)
	panel.settings_close_requested.connect(func(session_id: int) -> void: _close_requests.append(session_id))
	panel.settings_preview_requested.connect(func(session_id: int, draft: Dictionary) -> void:
		_preview_requests.append({"session_id": session_id, "draft": draft.duplicate(true)})
	)

	var initial_snapshot := {"master_volume": 5, "bgm_volume": 5, "sfx_volume": 5, "value_popups_enabled": true}
	_expect(panel.show_for_session(7, initial_snapshot, &"title"), "A valid title session must show the panel.")
	_expect(panel.visible and panel.get_active_session_id() == 7 and panel.get_return_view() == &"title", "Panel must retain title session metadata.")
	_expect(panel.apply_button.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS, "Apply must commit on mouse press rather than requiring an in-bounds release.")
	_expect(panel.close_button.action_mode == BaseButton.ACTION_MODE_BUTTON_PRESS, "Close must commit on mouse press rather than requiring an in-bounds release.")
	_expect(panel.get_draft() == initial_snapshot, "Panel must render its initial read-only snapshot as the draft.")
	panel._adjust_master(2)
	panel._adjust_bgm(1)
	panel._adjust_sfx(-1)
	panel.value_popups_toggle.button_pressed = false
	_expect(_preview_requests.size() == 4, "Each editable setting must request an immediate preview.")
	_expect(_preview_requests.back()["draft"] == {"master_volume": 7, "bgm_volume": 6, "sfx_volume": 4, "value_popups_enabled": false}, "Preview must contain the current complete draft.")
	panel.apply_button.emit_signal("pressed")
	panel.apply_button.emit_signal("pressed")
	_expect(_apply_requests.size() == 1, "Repeated Apply presses must create one request until a new snapshot arrives.")
	_expect(_apply_requests[0]["session_id"] == 7, "Apply request must preserve its session ID.")
	_expect(_apply_requests[0]["draft"] == {"master_volume": 7, "bgm_volume": 6, "sfx_volume": 4, "value_popups_enabled": false}, "Apply request must contain only the edited v1 draft.")
	_expect(panel.apply_snapshot(_apply_requests[0]["draft"]), "Matching adapter snapshot must be accepted.")
	panel.close_button.emit_signal("pressed")
	panel.close_button.emit_signal("pressed")
	_expect(_close_requests == [7], "Repeated Close presses must create one request.")
	_expect(panel.accept_closed(7, &"title") and not panel.visible, "Matching close must hide the title session.")

	_expect(panel.show_for_session(8, initial_snapshot, &"pause"), "A valid pause session must reuse the same panel instance.")
	_expect(panel.get_return_view() == &"pause", "Panel must retain the frozen pause return view.")
	_expect(not panel.accept_closed(7, &"title"), "Stale close must not hide the active pause session.")
	panel.close_button.emit_signal("pressed")
	_expect(_close_requests == [7, 8], "Pause close must preserve its own session ID.")
	_expect(panel.accept_closed(8, &"pause") and not panel.visible, "Matching pause close must hide the panel.")

	if _failures == 0:
		print("S10_G2_SETTINGS_PANEL_VERIFIED shared_instance=true draft=true request_once=true return_views=true")
	await get_tree().create_timer(0.5).timeout
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S10-G2 settings panel verification failed: %s" % message)
