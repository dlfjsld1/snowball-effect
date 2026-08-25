extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const Ledger = preload("res://scripts/core/score_ledger.gd")
const HudScript = preload("res://scripts/ui/hud.gd")
const HudScene = preload("res://scenes/ui/hud.tscn")

var _failures := 0


func _ready() -> void:
	var simulation: SimulationManager = SimulationManager.new()
	var ledger: Ledger = Ledger.new()
	var hud: HudScript = HudScene.instantiate()
	add_child(simulation)
	add_child(ledger)
	add_child(hud)
	hud.bind_sources(ledger, simulation)

	var stage_before := ledger.stage_score
	var run_before := ledger.run_score
	simulation.spawn_ball(Vector2(100.0, 100.0))
	_expect(hud.ball_count_label.text == "BALLS 1", "HUD must display the active ball count signal.")
	_expect(ledger.stage_score == stage_before and ledger.run_score == run_before, "Ball count display must not mutate score.")

	ledger.apply_score_event(1.0)
	_expect(hud.stage_score_label.text == "1", "HUD must display the numeric stage score once.")
	_expect(hud.run_score_label.text == "RUN SCORE 1", "HUD must display run score once.")
	_expect(ledger.stage_score == 1.0 and ledger.run_score == 1.0, "HUD subscription must not duplicate gameplay score.")

	hud.reset_view()
	_expect(hud.stage_score_label.text == "0" and hud.ball_count_label.text == "BALLS 0", "HUD reset must clear display state.")
	_expect(ledger.stage_score == 1.0 and simulation.get_active_count() == 1, "HUD reset must not mutate gameplay state.")

	if _failures == 0:
		print("S1_G4_VERIFIED score_readonly=true ball_count=1 reset_view=display_only")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S1-G4 verification failed: %s" % message)
