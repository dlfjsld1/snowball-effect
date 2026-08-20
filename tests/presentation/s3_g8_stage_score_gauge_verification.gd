extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageManager = preload("res://scripts/core/stage_manager.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const HudScene = preload("res://scenes/ui/hud.tscn")

var _failures := 0


func _ready() -> void:
	var simulation: SimulationManager = SimulationManager.new()
	var stage_manager: StageManager = StageManager.new()
	simulation.name = "BallSimulationManager"
	stage_manager.name = "StageManager"
	stage_manager.simulation_path = NodePath("../BallSimulationManager")
	var hud: Hud = HudScene.instantiate()
	add_child(simulation)
	add_child(stage_manager)
	add_child(hud)
	stage_manager.start_run()
	hud.bind_sources(stage_manager.get_score_ledger(), simulation, stage_manager)

	var ledger = stage_manager.get_score_ledger()
	var full_width := hud.stage_score_gauge.size.x - Hud.STAGE_SCORE_GAUGE_INSET * 2.0
	_expect(hud.stage_score_gauge.visible, "Ground must show the Stage Score gauge.")
	_expect(is_zero_approx(hud.get_stage_score_gauge_progress()), "A fresh Stage must start at 0%.")
	_expect(is_zero_approx(hud.stage_score_gauge_fill.size.x), "A fresh Stage must have an empty fill.")
	_expect(hud.stage_score_gauge_label.text == "CLEAR 0%", "The gauge must label a fresh Stage as 0%.")

	ledger.apply_score_event(1000000.0)
	_expect(is_equal_approx(hud.get_stage_score_gauge_progress(), 0.25), "A quarter of clear_score must show 25%.")
	_expect(hud.stage_score_gauge_label.text == "CLEAR 25%", "Partial progress must be labeled.")
	_expect(is_equal_approx(hud.stage_score_gauge_fill.size.x, snappedf(full_width * 0.25, 1.0)), "Partial fill width must match authoritative progress.")

	ledger.apply_score_event(3000000.0)
	_expect(is_equal_approx(hud.get_stage_score_gauge_progress(), 1.0), "clear_score must show 100%.")
	_expect(hud.stage_score_gauge_label.text == "CLEAR 100%", "The clear target must be labeled 100%.")
	var complete_width := hud.stage_score_gauge_fill.size.x

	ledger.apply_score_event(1000000.0)
	_expect(is_equal_approx(hud.get_stage_score_gauge_progress(), 1.0), "Overflow must clamp to 100%.")
	_expect(is_equal_approx(hud.stage_score_gauge_fill.size.x, complete_width), "Overflow must not draw outside the gauge.")

	ledger.stage_score = 2000000.0
	ledger.score_changed.emit(ledger.stage_score, ledger.run_score)
	_expect(is_equal_approx(hud.get_stage_score_gauge_progress(), 0.5), "A score decrease must reduce gauge progress.")
	_expect(hud.stage_score_gauge_fill.size.x < complete_width, "A score decrease must visibly shrink the fill.")
	_expect(hud.stage_score_gauge_label.text == "CLEAR 50%", "A score decrease must update the percent label.")

	var run_score_before_reset: float = ledger.run_score
	ledger.begin_stage()
	_expect(is_zero_approx(hud.get_stage_score_gauge_progress()), "Stage reset must return the gauge to 0%.")
	_expect(is_zero_approx(hud.stage_score_gauge_fill.size.x), "Stage reset must empty the gauge.")
	_expect(ledger.run_score == run_score_before_reset, "The fixture Stage reset must preserve Run Score.")

	var catalog = StageCatalog.new()
	var core_before := stage_manager.get_runtime_snapshot().duplicate(true)
	hud._on_stage_changed(catalog.get_stage(2))
	hud._on_score_changed(1.0e50, 1.0e50)
	_expect(not hud.stage_score_gauge.visible, "Galactic clear_score <= 0 must hide the gauge.")
	_expect(is_zero_approx(hud.get_stage_score_gauge_progress()), "A hidden Galactic gauge must not retain progress.")
	var core_after := stage_manager.get_runtime_snapshot()
	_expect(_same_core_snapshot(core_before, core_after), "HUD gauge updates must not mutate Core score, time, state, or Stage.")

	hud._on_stage_changed(catalog.get_stage(0))
	hud._on_score_changed(0.0, ledger.run_score)
	_expect(hud.stage_score_gauge.visible and is_zero_approx(hud.get_stage_score_gauge_progress()), "Returning to a non-final Stage must restore a reset gauge.")

	if _failures == 0:
		print("S3_G8_VERIFIED zero=true partial=true complete=true overflow_clamped=true decrease=true reset=true galactic_hidden=true core_readonly=true")
	get_tree().quit(_failures)


func _same_core_snapshot(before: Dictionary, after: Dictionary) -> bool:
	for key in ["state", "stage_index", "stage_time_left", "stage_score", "run_score", "pending_shift_id", "pending_black_hole_phase_id"]:
		if before.get(key) != after.get(key):
			return false
	return true


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G8 verification failed: %s" % message)
