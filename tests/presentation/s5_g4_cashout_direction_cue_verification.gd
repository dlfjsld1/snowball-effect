extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const PAUSE_SCENE := preload("res://scenes/ui/pause_menu.tscn")
const STAGE_SCORE_GAUGE_SCRIPT := preload("res://scripts/ui/stage_score_gauge.gd")
const EXPECTED_FIELD_WIDTHS: Array[float] = [560.0, 720.0, 880.0, 1040.0]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	add_child(frame)
	await get_tree().process_frame

	var cue := frame.get_node_or_null("CashoutDirectionCue")
	assert(cue != null, "The approved frame must contain the Cashout direction cue.")
	assert(cue is Control, "The cue must remain a Presentation-only Control.")

	var hud: Hud = HUD_SCENE.instantiate()
	var pause_menu: PauseMenu = PAUSE_SCENE.instantiate()
	add_child(hud)
	add_child(pause_menu)
	hud.visible = true
	pause_menu.visible = true
	var presenter: PresentationManager = frame.get_node("PresentationManager")
	presenter.configure(null, hud, pause_menu)
	frame.set_cashout_cue_active(true)
	await get_tree().process_frame

	for profile in range(4):
		frame.set_profile(profile)
		await get_tree().process_frame
		var field_rect := frame.get_field_rect()
		var visual_rect := frame.get_field_visual_rect()
		var metrics: Dictionary = frame.get_cashout_cue_metrics()
		var cue_rect: Rect2 = metrics["cue_rect"]
		assert(is_equal_approx(field_rect.size.x, EXPECTED_FIELD_WIDTHS[profile]))
		assert(is_equal_approx(cue_rect.position.x, visual_rect.position.x + 24.0))
		assert(is_equal_approx(cue_rect.end.x, visual_rect.end.x - 24.0))
		assert(cue_rect.position.y >= field_rect.end.y - 32.0, "The cue must remain in the restrained bottom lane.")
		assert(cue_rect.end.y < field_rect.end.y, "The cue must stay immediately inside the open Cashout line.")
		assert(cue_rect.end.y <= visual_rect.end.y)
		assert(metrics["color"] == STAGE_SCORE_GAUGE_SCRIPT.CELL_COLOR)
		assert((metrics["color"] as Color).to_html(false) == "60ae7b")
		assert(metrics["flow_direction"] == Vector2.DOWN)
		assert(float(metrics["flow_duration_seconds"]) <= 1.0)
		assert(int(metrics["chevron_count"]) >= 8)
		assert(float(metrics["filled_area_ratio"]) < 0.08, "Sparse chevrons must not read as a solid wall.")
		assert(not bool(metrics["solid_background"]))
		assert(cue.mouse_filter == Control.MOUSE_FILTER_IGNORE, "The open bottom must remain input-unobstructed.")
	frame.apply_visual_profile_lerp(0, 3, 0.5)
	var midpoint_metrics: Dictionary = frame.get_cashout_cue_metrics()
	var midpoint_rect: Rect2 = midpoint_metrics["cue_rect"]
	assert(midpoint_rect == Rect2(424.0, 792.0, 752.0, 20.0), "Shift interpolation must keep the cue on the moving opening.")
	frame.set_profile(0)

	assert(cue.visible, "The cue must be visible during active gameplay.")
	var phase_before := float(frame.get_cashout_cue_metrics()["flow_phase"])
	await get_tree().create_timer(0.12).timeout
	var phase_after := float(frame.get_cashout_cue_metrics()["flow_phase"])
	assert(phase_after > phase_before, "The normal cue must flow downward within one second.")

	# Stop automatic frame consumption so timing boundaries remain deterministic below.
	cue.set_process(false)
	presenter.reset_black_hole_presentation()
	cue._process(0.0)
	assert(is_zero_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"])))
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_lifetime_seconds"]), 10.0))
	cue._process(9.999)
	assert(cue.visible, "The cue must remain visible before the 10.0-second boundary.")
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"]), 9.999))

	var elapsed_before_pause := float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"])
	get_tree().paused = true
	cue._process(3.0)
	assert(not cue.visible, "Pause must hide the active Cashout cue.")
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"]), elapsed_before_pause), "Pause must freeze Run cue time.")
	get_tree().paused = false
	cue._process(0.0)
	assert(cue.visible)
	cue._process(0.001)
	assert(not cue.visible, "The cue must expire exactly at 10.0 active gameplay seconds.")
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"]), 10.0))
	assert(bool(frame.get_cashout_cue_metrics()["expired"]))

	presenter.reset_black_hole_presentation()
	cue._process(3.25)
	var elapsed_before_non_gameplay := float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"])
	pause_menu.visible = false
	cue._process(2.0)
	assert(not cue.visible, "Clear/result/non-gameplay UI lifecycle must hide the cue.")
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"]), elapsed_before_non_gameplay))
	pause_menu.visible = true
	hud.visible = false
	cue._process(2.0)
	assert(not cue.visible)
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"]), elapsed_before_non_gameplay))
	hud.visible = true
	cue._process(0.0)
	assert(cue.visible)
	frame.set_cashout_cue_active(false)
	cue._process(2.0)
	assert(not cue.visible, "CUT-IN/transition/finale suppression must hide the cue.")
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"]), elapsed_before_non_gameplay))
	frame.set_cashout_cue_active(true)
	cue._process(0.0)

	presenter.reset_black_hole_presentation()
	presenter.reduced_effects = true
	cue._process(9.999)
	var reduced_metrics: Dictionary = frame.get_cashout_cue_metrics()
	assert(cue.visible and not bool(reduced_metrics["animated"]), "Reduced effects must retain a static direction cue.")
	assert(reduced_metrics["color"] == STAGE_SCORE_GAUGE_SCRIPT.CELL_COLOR)
	cue._process(0.001)
	assert(not cue.visible and bool(frame.get_cashout_cue_metrics()["expired"]), "Reduced effects must obey the same 10-second lifetime.")

	# Retry and Start/New Run share PresentationManager.reset_black_hole_presentation in Main.
	presenter.reset_black_hole_presentation()
	cue._process(0.0)
	assert(cue.visible and is_zero_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"])), "Retry must reset the per-Run cue lifetime.")
	cue._process(4.0)
	var elapsed_before_stage_change := float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"])
	var planetary := StageDefinition.new()
	planetary.stage_index = 1
	planetary.background_id = &"planetary"
	presenter.apply_stage(planetary)
	cue._process(0.0)
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"]), elapsed_before_stage_change), "Stage transition must not reset Run cue time.")

	presenter.reduced_effects = false
	presenter.shift_duration = 0.05
	presenter.play_stage_shift(planetary, 901)
	cue._process(2.0)
	assert(not cue.visible, "Scale Shift must suppress the active gameplay cue.")
	assert(is_equal_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"]), elapsed_before_stage_change), "Scale Shift must freeze Run cue time.")
	while presenter.is_shift_active():
		await get_tree().process_frame
	assert(cue.visible, "The cue must return on the resized Planetary opening.")
	cue._process(6.0)
	assert(not cue.visible and bool(frame.get_cashout_cue_metrics()["expired"]))
	presenter.reset_black_hole_presentation()
	cue._process(0.0)
	assert(cue.visible and is_zero_approx(float(frame.get_cashout_cue_metrics()["active_gameplay_elapsed_seconds"])), "A new Run must reset an expired cue.")

	print("S5_G4_CASHOUT_CUE_VERIFIED profiles=4 aligned=true open=true color=60ae7b lifetime=10.0 pause_freeze=true stage_no_reset=true retry_new_run_reset=true reduced_static=true")
	get_tree().quit()
