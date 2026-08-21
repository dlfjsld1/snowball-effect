extends Node

const StageClearPanelScene = preload("res://scenes/ui/stage_clear_panel.tscn")
const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")

var _failures := 0
var _requested_ids: Array[int] = []


func _ready() -> void:
	var panel: StageClearPanel = StageClearPanelScene.instantiate()
	add_child(panel)
	await get_tree().process_frame
	panel.next_stage_requested.connect(func(clear_id: int) -> void: _requested_ids.append(clear_id))

	_verify_open_display_and_read_only(panel)
	await _verify_first_press_and_duplicate_suppression(panel)
	_verify_stale_hide_and_reset(panel)
	_verify_exclusions(panel)
	_verify_reduced_effects(panel)

	if _failures == 0:
		print("S5_G6_VERIFIED open=true scores=true focus=true request_once=true duplicate_hidden_stale=true reset=true exclusions=true reduced=true core_readonly=true")
	get_tree().quit(_failures)


func _verify_open_display_and_read_only(panel: StageClearPanel) -> void:
	var supplied_snapshot := _ground_snapshot()
	var supplied_before := supplied_snapshot.duplicate(true)
	_expect(panel.show_stage_clear(supplied_snapshot, 41), "A valid non-final Score Clear snapshot must open the Panel.")
	_expect(panel.visible and panel.get_active_clear_id() == 41, "Open must expose only the current clear_id.")
	_expect(panel.stage_identity_label.text == "GROUND COMPLETE", "The completed Stage identity must be readable.")
	_expect(panel.stage_score_value.text == ScoreFormatter.format_score(400000000.0), "Stage Score must use the shared score formatter.")
	_expect(panel.run_score_value.text == ScoreFormatter.format_score(525000000.0), "Run Score must use the shared score formatter.")
	_expect(panel.next_stage_button.text == "NEXT STAGE", "The action must not use Result or failure language.")
	_expect(panel.next_stage_button is Button and panel.next_stage_button.has_focus(), "The real Button must own keyboard focus.")
	_expect(panel.next_stage_button.mouse_filter == Control.MOUSE_FILTER_STOP, "The real Button must own mouse/Web pointer input.")
	_expect(not _tree_text_contains(panel, "TIME BONUS"), "The Clear Panel must not show Time Bonus.")
	_expect(supplied_snapshot == supplied_before, "Opening Presentation must not mutate the supplied Core-style snapshot.")

	supplied_snapshot["stage_display_name"] = "MUTATED SOURCE"
	(supplied_snapshot["debug_probe"] as Dictionary)["writes"] = 99
	_expect(panel.stage_identity_label.text == "GROUND COMPLETE", "The Panel must retain its own copied display values.")
	var copied_snapshot := panel.get_clear_snapshot()
	(copied_snapshot["debug_probe"] as Dictionary)["writes"] = 7
	_expect(int((panel.get_clear_snapshot()["debug_probe"] as Dictionary)["writes"]) == 0, "Snapshot reads must return a deep copy.")


func _verify_first_press_and_duplicate_suppression(panel: StageClearPanel) -> void:
	var accept_event := InputEventKey.new()
	accept_event.keycode = KEY_ENTER
	accept_event.pressed = true
	get_viewport().push_input(accept_event)
	await get_tree().process_frame
	accept_event.pressed = false
	get_viewport().push_input(accept_event)
	_expect(_requested_ids == [41], "The first focused/clickable Button press must request the active clear_id once.")
	_expect(panel.has_emitted_request() and panel.next_stage_button.disabled, "The first request must lock further Panel input.")
	panel.next_stage_button.pressed.emit()
	_expect(not panel.request_next_stage(41), "A duplicate callback for the active clear_id must be rejected.")
	_expect(not panel.request_next_stage(40), "A stale callback must be rejected.")
	_expect(_requested_ids == [41], "Duplicate and stale callbacks must not emit again.")


func _verify_stale_hide_and_reset(panel: StageClearPanel) -> void:
	_expect(not panel.hide_stage_clear(40) and panel.visible, "A stale hide callback must not close the active Panel.")
	_expect(panel.hide_stage_clear(41) and not panel.visible, "The matching hide callback must close the Panel.")
	panel.next_stage_button.pressed.emit()
	_expect(_requested_ids == [41], "Hidden Button callbacks must not emit.")

	var planetary := _planetary_snapshot()
	_expect(panel.show_stage_clear(planetary, 42), "A newer clear_id may open after the previous Panel is hidden.")
	_expect(not panel.request_next_stage(41), "The previous clear_id must stay stale while a new Panel is open.")
	panel.next_stage_button.pressed.emit()
	_expect(_requested_ids == [41, 42], "The new active clear_id must emit exactly once.")
	panel.reset_for_new_run()
	_expect(not panel.visible and panel.get_active_clear_id() == -1 and panel.get_clear_snapshot().is_empty(), "New Run reset must hide and clear only Presentation state.")
	_expect(panel.get_last_seen_clear_id() == 42, "New Run reset must retain the stale-ID high-water mark.")
	_expect(not panel.show_stage_clear(_ground_snapshot(), 42), "A pre-reset clear_id must never reopen the Panel.")


func _verify_exclusions(panel: StageClearPanel) -> void:
	var galactic := {
		"stage_index": 2,
		"stage_display_name": "Galactic",
		"stage_score": 1.0e40,
		"run_score": 1.0e42,
		"outcome": &"CLEARED",
		"is_final_stage": true,
	}
	var failure := _ground_snapshot()
	failure["outcome"] = &"FAILED"
	var result := _ground_snapshot()
	result["outcome"] = &"RESULT"
	result["is_final_stage"] = true
	_expect(not panel.show_stage_clear(galactic, 43), "Galactic must not open the non-final Clear Panel.")
	_expect(not panel.show_stage_clear(failure, 43), "Failure/Time Up must not open the Clear Panel.")
	_expect(not panel.show_stage_clear(result, 43), "Result must not open the Clear Panel.")
	_expect(not panel.visible and _requested_ids == [41, 42], "Excluded contexts must remain hidden and request-free.")


func _verify_reduced_effects(panel: StageClearPanel) -> void:
	panel.set_reduced_effects(true)
	_expect(panel.show_stage_clear(_ground_snapshot(), 43), "A fresh eligible ID must still open in reduced-effects mode.")
	_expect(panel.is_reduced_effects(), "Reduced-effects state must be queryable for integration verification.")
	_expect(not panel.is_open_motion_active(), "Reduced-effects must skip entrance motion.")
	_expect(panel.panel_surface.position == Vector2.ZERO and is_equal_approx(panel.panel_surface.modulate.a, 1.0), "Reduced-effects must present a stable fully readable panel.")
	panel.next_stage_button.pressed.emit()
	_expect(_requested_ids == [41, 42, 43], "Reduced-effects must preserve the same first-press request semantics.")
	panel.reset_for_new_run()


func _ground_snapshot() -> Dictionary:
	return {
		"stage_index": 0,
		"stage_display_name": "Ground",
		"stage_score": 400000000.0,
		"run_score": 525000000.0,
		"outcome": &"CLEARED",
		"is_final_stage": false,
		"debug_probe": {"state": &"CLEARED", "writes": 0},
	}


func _planetary_snapshot() -> Dictionary:
	return {
		"stage_index": 1,
		"stage_display_name": "Planetary",
		"stage_score": 4.0e25,
		"run_score": 4.13e25,
		"outcome": &"CLEARED",
		"is_final_stage": false,
	}


func _tree_text_contains(root: Node, needle: String) -> bool:
	if root is Label and (root as Label).text.contains(needle):
		return true
	if root is Button and (root as Button).text.contains(needle):
		return true
	for child in root.get_children():
		if _tree_text_contains(child, needle):
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S5-G6 verification failed: %s" % message)
