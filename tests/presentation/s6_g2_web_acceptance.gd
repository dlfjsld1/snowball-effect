extends Control

const CutInScene := preload("res://scenes/effects/first_contact_cutin.tscn")
const MainScene := preload("res://scenes/main/main.tscn")
const StageCatalogScript := preload("res://scripts/data/stage_catalog.gd")

const MIN_DURATION_SECONDS := 1.95
const MAX_DURATION_SECONDS := 2.05
const FIXTURE_TIMEOUT_SECONDS := 40.0

@onready var status_label: Label = $StatusLabel

var _failures := 0
var _finished := false
var _fixture_started_usec := 0
var _timing_pair := Vector2i(-1, -1)
var _timing_completion_usec := -1
var _completion_counts := {}
var _main_controller: CutInController
var _main_stage_manager: StageManager
var _f_event_id := -1
var _f_run_epoch := -1
var _f_completion_frame := -1
var _f_phase_frame := -1
var _f_phase_id := -1
var _f_gameplay_frames_between := 0
var _f_gap_open := false
var _f_event_log: Array[Dictionary] = []


func _ready() -> void:
	_fixture_started_usec = Time.get_ticks_usec()
	status_label.text = "S6-G2 WEB ACCEPTANCE RUNNING"
	await _run_acceptance()


func _process(_delta: float) -> void:
	if _finished:
		return
	if _f_gap_open and _main_stage_manager != null:
		if _main_stage_manager.current_state == StageManager.PLAYING and not _main_stage_manager.is_first_contact_pause_locked():
			_f_gameplay_frames_between += 1
	if _elapsed_fixture_seconds() > FIXTURE_TIMEOUT_SECONDS:
		_failures += 1
		_finish({"watchdog_timeout": true})


func _run_acceptance() -> void:
	var timing_result := await _verify_browser_timing()
	var main_result := await _verify_main_handoff_and_resets()
	var report := {
		"result": "PASS" if _failures == 0 else "FAIL",
		"c": timing_result,
		"f": main_result["f"],
		"g": main_result["g"],
		"failures": _failures,
		"elapsed_seconds": _elapsed_fixture_seconds(),
	}
	_finish(report)


func _verify_browser_timing() -> Dictionary:
	var controller := CutInScene.instantiate() as CutInController
	add_child(controller)
	await get_tree().process_frame
	controller.configure_field_visual_rect(Rect2(520.0, 50.0, 560.0, 800.0))
	controller.cutin_finished.connect(_on_timing_cutin_finished)

	var normal_samples: Array[float] = []
	var reduced_samples: Array[float] = []
	var warmup_seconds := await _measure_timing_sample(controller, false, 9, 901)
	print("S6_G2_WEB_C_WARMUP sample_seconds=%.6f" % warmup_seconds)
	for sample_index in range(3):
		var sample := await _measure_timing_sample(controller, false, 10, 1001 + sample_index)
		normal_samples.append(sample)
	for sample_index in range(3):
		var sample := await _measure_timing_sample(controller, true, 11, 1101 + sample_index)
		reduced_samples.append(sample)

	var normal_pass := _samples_in_range(normal_samples)
	var reduced_pass := _samples_in_range(reduced_samples)
	var web_authoritative := OS.has_feature("web")
	if web_authoritative:
		_expect(normal_pass, "All normal Web timing samples must be within 1.95-2.05 seconds.")
		_expect(reduced_pass, "All reduced Web timing samples must be within 1.95-2.05 seconds.")
	var result := {
		"pass": normal_pass and reduced_pass if web_authoritative else true,
		"web_authoritative": web_authoritative,
		"native_observed_in_window": normal_pass and reduced_pass,
		"clock": "Time.get_ticks_usec",
		"window_seconds": [MIN_DURATION_SECONDS, MAX_DURATION_SECONDS],
		"normal_samples_seconds": normal_samples,
		"reduced_samples_seconds": reduced_samples,
	}
	print("S6_G2_WEB_C_RAW %s" % JSON.stringify(result))
	controller.queue_free()
	await get_tree().process_frame
	return result


func _measure_timing_sample(controller: CutInController, reduced: bool, run_epoch: int, event_id: int) -> float:
	controller.set_reduced_effects(reduced)
	_timing_pair = Vector2i(event_id, run_epoch)
	_timing_completion_usec = -1
	var accepted := controller.play_first_contact_cutin(_ground_payload(run_epoch, event_id, &"ground_giant_snowball"))
	_expect(accepted and controller.visible and controller.is_cutin_active(), "Timing sample must synchronously reach its visible start.")
	var visible_started_usec := Time.get_ticks_usec()
	var deadline_usec := visible_started_usec + 3_000_000
	while _timing_completion_usec < 0 and Time.get_ticks_usec() < deadline_usec and not _finished:
		await get_tree().process_frame
	if _timing_completion_usec < 0:
		_expect(false, "Timing sample must complete within three seconds.")
		return -1.0
	var seconds := float(_timing_completion_usec - visible_started_usec) / 1_000_000.0
	print("S6_G2_WEB_C_SAMPLE profile=%s sample_seconds=%.6f event_id=%d run_epoch=%d" % ["reduced" if reduced else "normal", seconds, event_id, run_epoch])
	return seconds


func _verify_main_handoff_and_resets() -> Dictionary:
	var main := MainScene.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var game_manager: GameManager = main.get_node("GameManager")
	_main_stage_manager = main.get_node("StageManager") as StageManager
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager") as PresentationManager
	_main_controller = presenter.get_node("FirstContactCutIn") as CutInController

	# Observe the authoritative completion before the already-connected Integration
	# handler, then reconnect that same production handler. This lets the fixture
	# count process frames in the semantic completion-to-phase interval.
	var integration_finish := Callable(game_manager, "_on_first_contact_cutin_finished")
	if presenter.first_contact_cutin_finished.is_connected(integration_finish):
		presenter.first_contact_cutin_finished.disconnect(integration_finish)
	presenter.first_contact_cutin_finished.connect(_on_main_cutin_finished)
	presenter.first_contact_cutin_finished.connect(integration_finish)
	_main_stage_manager.black_hole_phase_started.connect(_on_black_hole_phase_started)

	var f_result := await _verify_black_hole_handoff(game_manager)
	var g_result := await _verify_retry_and_main_reset(game_manager)
	main.queue_free()
	await get_tree().process_frame
	_main_controller = null
	_main_stage_manager = null
	return {"f": f_result, "g": g_result}


func _verify_black_hole_handoff(game_manager: GameManager) -> Dictionary:
	game_manager._on_start_requested()
	_main_stage_manager.current_stage_index = 2
	_main_stage_manager._enter_stage(StageCatalogScript.new().get_stage(2))
	_f_run_epoch = int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	_f_event_id = 3001
	_f_completion_frame = -1
	_f_phase_frame = -1
	_f_phase_id = -1
	_f_gameplay_frames_between = 0
	_f_gap_open = false
	_f_event_log.clear()
	var payload := _black_hole_payload(_f_run_epoch, _f_event_id)
	_expect(game_manager.accept_first_contact_discovery(payload), "Actual Main must accept the authoritative Black Hole FIRST CONTACT payload.")
	game_manager._on_black_hole_phase_requested()
	await get_tree().process_frame
	_expect(_main_controller.visible and _main_controller.is_cutin_active(), "Black Hole CUT-IN must be visible before S8 phase starts.")
	_expect(int(_main_stage_manager.get_runtime_snapshot()["pending_black_hole_phase_id"]) == -1, "S8 phase ID must not exist before CUT-IN completion.")

	var deadline_usec := Time.get_ticks_usec() + 3_500_000
	while _f_phase_frame < 0 and Time.get_ticks_usec() < deadline_usec and not _finished:
		await get_tree().process_frame
	_f_gap_open = false
	var same_frame := _f_completion_frame >= 0 and _f_completion_frame == _f_phase_frame
	var phase_locked := _main_stage_manager.current_state == StageManager.BLACK_HOLE_PHASE_LOCKED
	var hidden_at_handoff := not _main_controller.visible and not _main_controller.is_cutin_active()
	var passed := same_frame and _f_gameplay_frames_between == 0 and phase_locked and hidden_at_handoff and _f_phase_id > 0
	_expect(passed, "Black Hole completion must hand off to S8 in the same frame with zero resumed gameplay frames.")
	var result := {
		"pass": passed,
		"event_id": _f_event_id,
		"run_epoch": _f_run_epoch,
		"completion_frame": _f_completion_frame,
		"phase_start_frame": _f_phase_frame,
		"phase_id": _f_phase_id,
		"gameplay_resumed_frames_between": _f_gameplay_frames_between,
		"stage_state": String(_main_stage_manager.current_state),
		"cutin_hidden_at_phase_start": hidden_at_handoff,
		"events": _f_event_log,
	}
	print("S6_G2_WEB_F_RAW %s" % JSON.stringify(result))
	return result


func _verify_retry_and_main_reset(game_manager: GameManager) -> Dictionary:
	game_manager._on_retry_requested()
	var retry_old_epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	var retry_old_event := 4001
	_expect(game_manager.accept_first_contact_discovery(_ground_payload(retry_old_epoch, retry_old_event, &"ground_giant_snowball")), "Retry reset probe CUT-IN must be accepted.")
	await get_tree().process_frame
	_expect(_main_controller.visible, "Retry reset probe must become visible.")
	await get_tree().create_timer(0.25).timeout
	game_manager._on_retry_requested()
	var retry_new_epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	var retry_hidden_immediately := not _main_controller.visible and not _main_controller.is_cutin_active()
	await get_tree().create_timer(2.10).timeout
	var retry_stale_completions := _completion_count(retry_old_event, retry_old_epoch)
	var retry_new_event := 4002
	_expect(game_manager.accept_first_contact_discovery(_ground_payload(retry_new_epoch, retry_new_event, &"ground_giant_snowball")), "Fresh Retry epoch CUT-IN must be accepted.")
	var retry_new_completed := await _wait_for_completion(retry_new_event, retry_new_epoch, 3.0)

	var main_old_epoch := retry_new_epoch
	var main_old_event := 4003
	_expect(game_manager.accept_first_contact_discovery(_ground_payload(main_old_epoch, main_old_event, &"ground_moon")), "Main reset probe CUT-IN must be accepted.")
	await get_tree().process_frame
	_expect(_main_controller.visible, "Main reset probe must become visible.")
	await get_tree().create_timer(0.25).timeout
	game_manager._on_main_menu_requested()
	var main_hidden_immediately := not _main_controller.visible and not _main_controller.is_cutin_active()
	var main_epoch_invalidated := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"]) == -1
	await get_tree().create_timer(2.10).timeout
	var main_stale_completions := _completion_count(main_old_event, main_old_epoch)
	game_manager._on_start_requested()
	var main_new_epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	var main_new_event := 4004
	_expect(game_manager.accept_first_contact_discovery(_ground_payload(main_new_epoch, main_new_event, &"ground_giant_snowball")), "Fresh post-Main epoch CUT-IN must be accepted.")
	var main_new_completed := await _wait_for_completion(main_new_event, main_new_epoch, 3.0)

	var retry_pass := retry_new_epoch > retry_old_epoch and retry_hidden_immediately and retry_stale_completions == 0 and retry_new_completed
	var main_pass := main_new_epoch > main_old_epoch and main_hidden_immediately and main_epoch_invalidated and main_stale_completions == 0 and main_new_completed
	_expect(retry_pass, "Retry must cancel the active Tween without stale completion and complete a fresh-epoch CUT-IN.")
	_expect(main_pass, "Main reset must cancel the active Tween without stale completion and complete a fresh-epoch CUT-IN.")
	var result := {
		"pass": retry_pass and main_pass,
		"retry": {
			"pass": retry_pass,
			"old_pair": [retry_old_event, retry_old_epoch],
			"new_pair": [retry_new_event, retry_new_epoch],
			"hidden_immediately": retry_hidden_immediately,
			"stale_completions": retry_stale_completions,
			"new_completion_count": _completion_count(retry_new_event, retry_new_epoch),
		},
		"main": {
			"pass": main_pass,
			"old_pair": [main_old_event, main_old_epoch],
			"new_pair": [main_new_event, main_new_epoch],
			"epoch_invalidated": main_epoch_invalidated,
			"hidden_immediately": main_hidden_immediately,
			"stale_completions": main_stale_completions,
			"new_completion_count": _completion_count(main_new_event, main_new_epoch),
		},
	}
	print("S6_G2_WEB_G_RAW %s" % JSON.stringify(result))
	return result


func _wait_for_completion(event_id: int, run_epoch: int, timeout_seconds: float) -> bool:
	var deadline_usec := Time.get_ticks_usec() + int(timeout_seconds * 1_000_000.0)
	while _completion_count(event_id, run_epoch) == 0 and Time.get_ticks_usec() < deadline_usec and not _finished:
		await get_tree().process_frame
	return _completion_count(event_id, run_epoch) == 1


func _on_timing_cutin_finished(event_id: int, run_epoch: int) -> void:
	if _timing_pair == Vector2i(event_id, run_epoch):
		_timing_completion_usec = Time.get_ticks_usec()


func _on_main_cutin_finished(event_id: int, run_epoch: int) -> void:
	var key := _pair_key(event_id, run_epoch)
	_completion_counts[key] = int(_completion_counts.get(key, 0)) + 1
	if event_id == _f_event_id and run_epoch == _f_run_epoch:
		_f_completion_frame = Engine.get_process_frames()
		_f_gap_open = true
		_f_event_log.append({"kind": "matching_completion", "frame": _f_completion_frame, "event_id": event_id, "run_epoch": run_epoch})


func _on_black_hole_phase_started(phase_id: int, _from_rect: Rect2, _to_rect: Rect2) -> void:
	if _f_event_id < 0:
		return
	_f_phase_frame = Engine.get_process_frames()
	_f_phase_id = phase_id
	_f_event_log.append({"kind": "s8_phase_started", "frame": _f_phase_frame, "event_id": _f_event_id, "run_epoch": _f_run_epoch, "phase_id": phase_id})
	_f_gap_open = false


func _ground_payload(run_epoch: int, event_id: int, identity: StringName) -> Dictionary:
	var is_moon := identity == &"ground_moon"
	return {
		"schema_version": 1,
		"event_id": event_id,
		"run_epoch": run_epoch,
		"stage_index": 0,
		"stage_id": &"ground",
		"global_level": 4 if is_moon else 3,
		"local_level": 4 if is_moon else 3,
		"world_position": Vector2(800.0, 320.0),
		"first_contact_id": identity,
		"handoff_kind": &"RESUME_PLAYING",
		"black_hole_entity_ordinal": 0,
	}


func _black_hole_payload(run_epoch: int, event_id: int) -> Dictionary:
	return {
		"schema_version": 1,
		"event_id": event_id,
		"run_epoch": run_epoch,
		"stage_index": 2,
		"stage_id": &"galactic",
		"global_level": 14,
		"local_level": 4,
		"world_position": Vector2(800.0, 320.0),
		"first_contact_id": &"galactic_black_hole",
		"handoff_kind": &"BLACK_HOLE_PHASE",
		"black_hole_entity_ordinal": 1,
	}


func _samples_in_range(samples: Array[float]) -> bool:
	if samples.size() != 3:
		return false
	for sample in samples:
		if sample < MIN_DURATION_SECONDS or sample > MAX_DURATION_SECONDS:
			return false
	return true


func _completion_count(event_id: int, run_epoch: int) -> int:
	return int(_completion_counts.get(_pair_key(event_id, run_epoch), 0))


func _pair_key(event_id: int, run_epoch: int) -> String:
	return "%d:%d" % [event_id, run_epoch]


func _elapsed_fixture_seconds() -> float:
	return float(Time.get_ticks_usec() - _fixture_started_usec) / 1_000_000.0


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G2 Web acceptance failed: %s" % message)


func _finish(report: Dictionary) -> void:
	if _finished:
		return
	_finished = true
	var passed := _failures == 0 and String(report.get("result", "PASS")) != "FAIL"
	var marker := "S6_G2_WEB_ACCEPTANCE_%s %s" % ["PASS" if passed else "FAIL", JSON.stringify(report)]
	status_label.text = marker
	print(marker)
	if OS.has_feature("web"):
		JavaScriptBridge.eval("document.title = %s" % JSON.stringify("S6_G2_WEB_ACCEPTANCE_PASS" if passed else "S6_G2_WEB_ACCEPTANCE_FAIL"))
	else:
		get_tree().quit(0 if passed else 1)
