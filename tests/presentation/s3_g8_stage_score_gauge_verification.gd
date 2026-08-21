extends Node

const GaugeScript = preload("res://scripts/ui/stage_score_gauge.gd")
const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageManager = preload("res://scripts/core/stage_manager.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const HudScene = preload("res://scenes/ui/hud.tscn")

var _failures := 0


func _ready() -> void:
	_verify_gauge_component()
	_verify_hud_read_only_integration()
	if _failures == 0:
		print("S3_G8_VERIFIED cells=20 progress=70pct_14cells overflow=true decrease=true reset=true galactic_hidden=true core_readonly=true")
	get_tree().quit(_failures)


func _verify_gauge_component() -> void:
	var gauge: StageScoreGauge = GaugeScript.new()
	add_child(gauge)

	gauge.set_score_progress(0.0, 100.0)
	_expect(gauge.visible and gauge.get_filled_cell_count() == 0, "A fresh Stage must show no filled gauge cells.")

	gauge.set_score_progress(70.0, 100.0)
	_expect(gauge.visible and gauge.get_filled_cell_count() == 14, "70 percent must display exactly 14 of 20 cells.")
	_expect(is_equal_approx(gauge.get_progress(), 0.7), "Gauge progress must retain the score ratio.")

	gauge.set_score_progress(500.0, 100.0)
	_expect(gauge.get_filled_cell_count() == 20 and is_equal_approx(gauge.get_progress(), 1.0), "Score overflow must cap at all 20 cells.")

	gauge.set_score_progress(-10.0, 100.0)
	_expect(gauge.get_filled_cell_count() == 0 and is_equal_approx(gauge.get_progress(), 0.0), "Score decreases must clamp to an empty gauge.")

	gauge.set_score_progress(10.0, 0.0)
	_expect(not gauge.visible and gauge.get_filled_cell_count() == 0, "Galactic without a clear target must hide the gauge.")

	gauge.reset_gauge()
	_expect(gauge.visible and gauge.get_filled_cell_count() == 0, "A component reset must restore an empty visible gauge.")
	gauge.queue_free()


func _verify_hud_read_only_integration() -> void:
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
	var clear_score: float = stage_manager.get_current_stage().clear_score
	_expect(clear_score > 0.0, "The Ground fixture must provide an authoritative clear target.")
	_expect(hud.stage_score_gauge.visible and hud.stage_score_gauge.get_filled_cell_count() == 0, "Ground must mount one empty 20-cell gauge.")

	ledger.apply_score_event(clear_score * 0.7)
	_expect(hud.stage_score_gauge.get_filled_cell_count() == 14, "HUD score signals must fill the canonical 20-cell component.")

	ledger.apply_score_event(clear_score)
	_expect(hud.stage_score_gauge.get_filled_cell_count() == 20, "HUD overflow must remain clamped to 20 cells.")

	ledger.stage_score = clear_score * 0.25
	ledger.score_changed.emit(ledger.stage_score, ledger.run_score)
	_expect(hud.stage_score_gauge.get_filled_cell_count() == 5, "A score decrease must reduce the mounted gauge.")

	var run_score_before_reset: float = ledger.run_score
	ledger.begin_stage()
	_expect(hud.stage_score_gauge.get_filled_cell_count() == 0, "Stage reset must empty the mounted gauge.")
	_expect(ledger.run_score == run_score_before_reset, "The fixture Stage reset must preserve Run Score.")

	var catalog = StageCatalog.new()
	var core_before := stage_manager.get_runtime_snapshot().duplicate(true)
	hud._on_stage_changed(catalog.get_stage(2))
	hud._on_score_changed(1.0e50, 1.0e50)
	_expect(not hud.stage_score_gauge.visible, "Galactic clear_score <= 0 must hide the mounted gauge.")
	_expect(is_zero_approx(hud.get_stage_score_gauge_progress()), "A hidden Galactic gauge must not retain progress.")
	var core_after := stage_manager.get_runtime_snapshot()
	_expect(_same_core_snapshot(core_before, core_after), "HUD gauge updates must not mutate Core score, time, state, or Stage.")

	hud._on_stage_changed(catalog.get_stage(0))
	hud._on_score_changed(0.0, ledger.run_score)
	_expect(hud.stage_score_gauge.visible and hud.stage_score_gauge.get_filled_cell_count() == 0, "Returning to a non-final Stage must restore an empty gauge.")


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
