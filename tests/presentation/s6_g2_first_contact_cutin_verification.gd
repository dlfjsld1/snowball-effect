extends Node

const CutInScene := preload("res://scenes/effects/first_contact_cutin.tscn")
const MainScene := preload("res://scenes/main/main.tscn")
const BACKGROUND_PATH := "res://assets/sprites/cutins/first_contact/first-contact-background-v1.png"
const ACTIVE_ROSTER := [
	{
		"first_contact_id": &"ground_giant_snowball",
		"stage_index": 0, "stage_id": &"ground", "global_level": 3, "local_level": 3,
		"handoff_kind": &"RESUME_PLAYING", "black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-giant-snowball-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/giant-snowball-portrait-v1.png",
	},
	{
		"first_contact_id": &"ground_moon",
		"stage_index": 0, "stage_id": &"ground", "global_level": 4, "local_level": 4,
		"handoff_kind": &"RESUME_PLAYING", "black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-moon-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/moon-portrait-v1.png",
	},
	{
		"first_contact_id": &"planetary_supernova",
		"stage_index": 1, "stage_id": &"planetary", "global_level": 8, "local_level": 3,
		"handoff_kind": &"RESUME_PLAYING", "black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-supernova-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/supernova-portrait-v1.png",
	},
	{
		"first_contact_id": &"planetary_galaxy",
		"stage_index": 1, "stage_id": &"planetary", "global_level": 10, "local_level": 4,
		"handoff_kind": &"RESUME_PLAYING", "black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-galaxy-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/galaxy-portrait-v1.png",
	},
	{
		"first_contact_id": &"galactic_event_horizon",
		"stage_index": 2, "stage_id": &"galactic", "global_level": 13, "local_level": 3,
		"handoff_kind": &"RESUME_PLAYING", "black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-event-horizon-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/event-horizon-portrait-v1.png",
	},
	{
		"first_contact_id": &"galactic_black_hole",
		"stage_index": 2, "stage_id": &"galactic", "global_level": 14, "local_level": 4,
		"handoff_kind": &"BLACK_HOLE_PHASE", "black_hole_entity_ordinal": 1,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-black-hole-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/black-hole-portrait-v1.png",
	},
]

var _failures := 0
var _controller_completions: Array[Vector2i] = []
var _main_completions: Array[Vector2i] = []


func _ready() -> void:
	var controller := CutInScene.instantiate() as CutInController
	add_child(controller)
	await get_tree().process_frame
	controller.cutin_finished.connect(_on_controller_finished)

	await _verify_six_mappings_and_composition(controller)
	await _verify_timing_validation_and_lifecycle(controller)
	_verify_presenter_source_boundary()
	controller.queue_free()
	await get_tree().process_frame
	await _verify_actual_main_handoff()

	if _failures == 0:
		print("S6_G2_VERIFIED mappings=6 field_clipped=true duration=1.10 reduced_duration=0.85 same_epoch_stage_reset=true duplicate_stale=true reset_no_emit=true exact_once=true main_handoff=true core_readonly=true")
	get_tree().quit(_failures)


func _verify_six_mappings_and_composition(controller: CutInController) -> void:
	var field_rect := Rect2(520.0, 50.0, 560.0, 800.0)
	controller.configure_field_visual_rect(field_rect)
	controller.set_reduced_effects(true)
	var roster_paths := controller.get_roster_asset_paths()
	_expect(roster_paths.size() == 6, "The active roster must contain exactly six identities.")
	_expect(not str(roster_paths).to_lower().contains("galaxy-cluster") and not str(roster_paths).to_lower().contains("quasar"), "Galaxy Cluster and Quasar drafts must not be registered.")
	_expect(controller.background_texture.texture.resource_path == BACKGROUND_PATH, "Every identity must use the one common background resource.")
	_expect(controller.background_texture.texture.get_size() == Vector2(1600.0, 900.0), "The common background must be exactly 1600x900.")
	_expect(controller.field_clip.clip_contents, "CUT-IN must clip its visuals to the active Play Field.")
	_expect(Rect2(controller.field_clip.position, controller.field_clip.size).is_equal_approx(field_rect), "CUT-IN field clip must match the supplied active Play Field rect.")
	_expect(controller.dim_overlay.size == field_rect.size, "Dim layer must cover only the active Play Field.")
	_expect(is_equal_approx(controller.background_texture.size.x, field_rect.size.x), "Banner background width must fill the active Play Field.")
	_expect(is_equal_approx(controller.background_texture.size.y, field_rect.size.y * CutInController.BANNER_HEIGHT_RATIO), "Banner height must follow the field-local ratio.")

	var seen_titles := {}
	var seen_portraits := {}
	for roster_index in range(ACTIVE_ROSTER.size()):
		var roster_entry: Dictionary = ACTIVE_ROSTER[roster_index]
		var payload := _payload_from_entry(roster_entry, 1, 11 + roster_index)
		var supplied_before := payload.duplicate(true)
		var completion_count_before := _controller_completions.size()
		_expect(controller.play_first_contact_cutin(payload), "Approved roster identity %s must play." % roster_entry["first_contact_id"])
		_expect(payload == supplied_before, "Presentation must not mutate the supplied payload.")
		await get_tree().process_frame
		var metrics := controller.get_visual_metrics()
		_expect(metrics["visible"] and metrics["active"], "Accepted CUT-IN must become visible and active.")
		_expect(metrics["first_contact_id"] == roster_entry["first_contact_id"], "Visible identity must match the accepted payload.")
		_expect(metrics["background_path"] == BACKGROUND_PATH, "All six identities must reuse the common background.")
		_expect(metrics["title_path"] == roster_entry["title_path"], "Identity must bind its approved title layer.")
		_expect(metrics["portrait_path"] == roster_entry["portrait_path"], "Identity must bind its approved portrait layer.")
		_expect(controller.title_texture.texture.get_image().detect_alpha() != Image.ALPHA_NONE, "Approved title layers must retain transparency.")
		_expect(controller.portrait_texture.texture.get_image().detect_alpha() != Image.ALPHA_NONE, "Approved portrait layers must retain transparency.")
		_expect(float(metrics["dim_alpha"]) > 0.0, "The active Play Field must dim while the overlay is visible.")
		_expect((metrics["field_clip_rect"] as Rect2).is_equal_approx(field_rect), "Visible CUT-IN must retain its active Play Field clip.")
		_expect(is_zero_approx((metrics["card_position"] as Vector2).x), "Reduced effects must remove slide motion without removing the card.")
		seen_titles[metrics["title_path"]] = true
		seen_portraits[metrics["portrait_path"]] = true
		await get_tree().create_timer(controller.get_total_duration() + 0.08).timeout
		_expect(_controller_completions.size() == completion_count_before + 1, "Each approved identity must complete exactly once.")
		_expect(not controller.visible and not controller.is_cutin_active(), "Normal exit must restore dim and hide the overlay before completion returns.")

	_expect(seen_titles.size() == 6 and seen_portraits.size() == 6, "The six identities must select six distinct title and portrait layers.")
	_expect(_controller_completions.size() == 6, "The six mapping run must produce exactly six completions.")


func _verify_timing_validation_and_lifecycle(controller: CutInController) -> void:
	controller.set_reduced_effects(false)
	_expect(is_equal_approx(CutInController.ENTER_DURATION, 0.20), "Enter duration must use the field-local banner contract.")
	_expect(is_equal_approx(CutInController.HOLD_DURATION, 0.65), "Hold duration must use the field-local banner contract.")
	_expect(is_equal_approx(CutInController.EXIT_DURATION, 0.25), "Exit duration must use the field-local banner contract.")
	_expect(is_equal_approx(controller.get_total_duration(), 1.10), "Normal total duration must remain 1.10s.")
	controller.set_reduced_effects(true)
	_expect(is_equal_approx(controller.get_total_duration(), 0.85), "Reduced-effects duration must remain 0.85s.")

	var base_entry: Dictionary = ACTIVE_ROSTER[0]
	var valid := _payload_from_entry(base_entry, 2, 100)
	var invalid_schema := valid.duplicate(true)
	invalid_schema["schema_version"] = 2
	_expect(not controller.play_first_contact_cutin(invalid_schema), "Unknown schema versions must be rejected.")
	var missing_field := valid.duplicate(true)
	missing_field.erase("world_position")
	_expect(not controller.play_first_contact_cutin(missing_field), "Missing v1 fields must be rejected.")
	var wrong_type := valid.duplicate(true)
	wrong_type["run_epoch"] = "2"
	_expect(not controller.play_first_contact_cutin(wrong_type), "Wrong v1 field types must be rejected.")
	var wrong_roster := valid.duplicate(true)
	wrong_roster["stage_index"] = 2
	_expect(not controller.play_first_contact_cutin(wrong_roster), "Identity/Stage roster mismatches must be rejected.")
	var cluster := valid.duplicate(true)
	cluster["first_contact_id"] = &"galactic_galaxy_cluster"
	_expect(not controller.play_first_contact_cutin(cluster), "Galaxy Cluster draft identity must be rejected.")
	var quasar := valid.duplicate(true)
	quasar["first_contact_id"] = &"galactic_quasar"
	_expect(not controller.play_first_contact_cutin(quasar), "Quasar draft identity must be rejected.")

	var completions_before_lifecycle := _controller_completions.size()
	_expect(controller.play_first_contact_cutin(valid), "A fresh Ground payload must start.")
	_expect(not controller.play_first_contact_cutin(valid), "An active duplicate pair must be rejected.")
	var queued_while_active := _payload_from_entry(ACTIVE_ROSTER[2], 2, 101)
	_expect(not controller.play_first_contact_cutin(queued_while_active), "Presentation must not build its own queue while a CUT-IN is active.")
	await get_tree().create_timer(controller.get_total_duration() + 0.08).timeout
	_expect(_controller_completions.size() == completions_before_lifecycle + 1, "The Ground event must complete exactly once before Stage transition cleanup.")
	_expect(_controller_completions.count(Vector2i(100, 2)) == 1, "The completed Ground pair must be recorded exactly once.")
	_expect(not controller.play_first_contact_cutin(valid), "A completed pair must be rejected.")
	_expect(not controller.play_first_contact_cutin(_payload_from_entry(ACTIVE_ROSTER[1], 2, 99)), "A non-monotonic old event ID must be rejected.")

	controller.reset_first_contact_cutin(2)
	_expect(not controller.visible and not controller.is_cutin_active(), "Stage-transition visual reset must leave the completed Ground CUT-IN hidden.")
	_expect(_controller_completions.size() == completions_before_lifecycle + 1, "Stage-transition visual reset must not emit completion.")
	_expect(controller.play_first_contact_cutin(queued_while_active), "A later Planetary event in the same Run epoch must survive Stage-transition visual reset.")
	await get_tree().process_frame
	var planetary_metrics := controller.get_visual_metrics()
	_expect(planetary_metrics["visible"] and planetary_metrics["active"], "The accepted same-epoch Planetary CUT-IN must be visible and active.")
	_expect(planetary_metrics["first_contact_id"] == &"planetary_supernova", "The same-epoch Stage-transition payload must retain its Planetary identity.")
	_expect(not controller.play_first_contact_cutin(queued_while_active), "An active same-epoch duplicate must still be rejected.")
	await get_tree().create_timer(controller.get_total_duration() + 0.08).timeout
	_expect(_controller_completions.size() == completions_before_lifecycle + 2, "The same-epoch Planetary event must complete exactly once.")
	_expect(_controller_completions.count(Vector2i(101, 2)) == 1, "The same-epoch Planetary pair must emit one matching completion.")
	_expect(not controller.play_first_contact_cutin(queued_while_active), "The completed Planetary pair must be rejected.")
	_expect(not controller.play_first_contact_cutin(_payload_from_entry(ACTIVE_ROSTER[3], 1, 102)), "An older Run epoch must remain stale even with a greater event ID.")

	var canceled_payload := _payload_from_entry(ACTIVE_ROSTER[4], 3, 102)
	_expect(controller.play_first_contact_cutin(canceled_payload), "A fresh epoch must play before active reset cancellation.")
	await get_tree().create_timer(0.05).timeout
	controller.reset_first_contact_cutin(3)
	_expect(not controller.visible and not controller.is_cutin_active(), "Matching reset must hide and cancel an active visual immediately.")
	await get_tree().create_timer(controller.get_total_duration() + 0.08).timeout
	_expect(_controller_completions.size() == completions_before_lifecycle + 2, "Active reset cancellation must not emit completion.")

	var reduced_payload := _payload_from_entry(ACTIVE_ROSTER[1], 4, 103)
	reduced_payload["debug_probe"] = {"writes": 0}
	var reduced_before := reduced_payload.duplicate(true)
	controller.set_reduced_effects(true)
	_expect(controller.play_first_contact_cutin(reduced_payload), "A newer epoch must play after active reset cancellation.")
	(reduced_payload["debug_probe"] as Dictionary)["writes"] = 9
	_expect((controller.get_active_payload()["debug_probe"] as Dictionary)["writes"] == 0, "Controller must retain its own deep payload copy.")
	_expect(reduced_before["first_contact_id"] == controller.get_active_payload()["first_contact_id"], "Reduced effects must preserve identity.")
	await get_tree().create_timer(controller.get_total_duration() + 0.08).timeout
	_expect(_controller_completions.size() == completions_before_lifecycle + 3, "Reduced effects must preserve normal exact-once completion.")
	_expect(not controller.play_first_contact_cutin(reduced_before), "A completed pair must be rejected.")
	controller.reset_first_contact_cutin(4)
	_expect(_controller_completions.size() == completions_before_lifecycle + 3, "Reset after completion must not emit again.")

	var future_payload := _payload_from_entry(ACTIVE_ROSTER[5], 6, 104)
	_expect(controller.play_first_contact_cutin(future_payload), "A newer epoch/event must play.")
	controller.reset_first_contact_cutin(5)
	_expect(controller.visible and controller.is_cutin_active(), "A stale reset must not cancel a newer active visual.")
	await get_tree().create_timer(controller.get_total_duration() + 0.08).timeout
	_expect(_controller_completions.size() == completions_before_lifecycle + 4, "The newer visual must still complete exactly once.")
	_expect(not controller.play_first_contact_cutin(_payload_from_entry(ACTIVE_ROSTER[3], 5, 105)), "A lower epoch must be rejected as stale.")


func _verify_presenter_source_boundary() -> void:
	var controller_source := FileAccess.get_file_as_string("res://scripts/presentation/cutin_controller.gd")
	var manager_source := FileAccess.get_file_as_string("res://scripts/presentation/presentation_manager.gd")
	for forbidden_subscription in ["ball_merged", "top_ball_created", "black_hole_phase_requested"]:
		_expect(not controller_source.contains(forbidden_subscription), "CutInController must not subscribe to or infer %s." % forbidden_subscription)
		_expect(not manager_source.contains(forbidden_subscription), "PresentationManager FIRST_CONTACT path must not subscribe to %s." % forbidden_subscription)
	_expect(not controller_source.contains("GameManager") and not controller_source.contains("StageManager") and not controller_source.contains("BallSimulationManager"), "The CUT-IN controller must not read or mutate Core/Stage/Simulation nodes.")


func _verify_actual_main_handoff() -> void:
	var main := MainScene.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	var cutin := presenter.get_node("FirstContactCutIn") as CutInController
	presenter.first_contact_cutin_finished.connect(_on_main_finished)
	game_manager._on_start_requested()
	game_manager.set_physics_process(false)
	stage_manager.set_physics_process(false)
	await get_tree().process_frame

	var before := stage_manager.get_runtime_snapshot()
	var epoch := int(game_manager.get_runtime_snapshot()["first_contact_run_epoch"])
	var payload := _payload_from_entry(ACTIVE_ROSTER[0], epoch, 5001)
	_expect(game_manager.accept_first_contact_discovery(payload), "The existing S6-G2I Main producer fixture must accept a valid discovery.")
	await get_tree().process_frame
	await get_tree().process_frame
	var active_metrics := presenter.get_first_contact_cutin_metrics()
	_expect(cutin.visible and active_metrics["first_contact_id"] == &"ground_giant_snowball", "Main's existing call must visibly open the real Presentation layer.")
	_expect(stage_manager.is_first_contact_pause_locked(), "The verified Main pause lock must remain active while the real Tween runs.")
	_expect(int(game_manager.get_runtime_snapshot()["first_contact_active_event_id"]) == 5001, "Main must wait for the real matching completion.")
	await get_tree().create_timer(cutin.get_total_duration() + 0.10).timeout
	var after := stage_manager.get_runtime_snapshot()
	_expect(_main_completions == [Vector2i(5001, epoch)], "The actual PresentationManager must emit one matching completion.")
	_expect(not cutin.visible and not stage_manager.is_first_contact_pause_locked(), "Normal exit must hide the layer and let Integration release the pause lock.")
	_expect(after["state"] == before["state"] and after["stage_index"] == before["stage_index"], "Presentation must not change Core Stage state.")
	_expect(after["stage_score"] == before["stage_score"] and after["run_score"] == before["run_score"], "Presentation must not change score state.")
	_expect(after["stage_time_left"] == before["stage_time_left"] and after["run_time_seconds"] == before["run_time_seconds"], "Presentation must not mutate timer/runtime statistics.")
	main.queue_free()
	await get_tree().process_frame


func _payload_from_entry(entry: Dictionary, run_epoch: int, event_id: int) -> Dictionary:
	return {
		"schema_version": 1,
		"event_id": event_id,
		"run_epoch": run_epoch,
		"stage_index": entry["stage_index"],
		"stage_id": entry["stage_id"],
		"global_level": entry["global_level"],
		"local_level": entry["local_level"],
		"world_position": Vector2(800.0, 360.0),
		"first_contact_id": entry["first_contact_id"],
		"handoff_kind": entry["handoff_kind"],
		"black_hole_entity_ordinal": entry["black_hole_entity_ordinal"],
	}


func _on_controller_finished(event_id: int, run_epoch: int) -> void:
	_controller_completions.append(Vector2i(event_id, run_epoch))


func _on_main_finished(event_id: int, run_epoch: int) -> void:
	_main_completions.append(Vector2i(event_id, run_epoch))


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G2 verification failed: %s" % message)
