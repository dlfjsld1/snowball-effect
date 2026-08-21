extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageManager = preload("res://scripts/core/stage_manager.gd")
const HudScene = preload("res://scenes/ui/hud.tscn")

var _failures := 0
var _finished_count := 0


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
	hud.effect_manager.final_settlement_presentation_finished.connect(_on_finished)

	for index in range(100):
		var column := index % 10
		var row := index / 10
		simulation.spawn_ball(Vector2(560.0 + column * 36.0, 120.0 + row * 48.0), Vector2.ZERO, 4.0, 0)

	var active_before := simulation.get_active_count()
	stage_manager._settle_and_resolve(&"TIME_UP")
	var effect: Node2D = hud.effect_manager._active_settlement_effect
	_expect(active_before == 100, "Fixture must contain 100 active balls before Settlement.")
	_expect(is_instance_valid(effect), "Settlement start must create one visual effect.")
	_expect(effect.get_visual_sample_count() == 64, "Settlement visual must cap samples at 64.")
	_expect(simulation.get_active_count() == 0, "Presentation must not block or mutate the existing Core deactivation result.")
	_expect(stage_manager.get_score_ledger().stage_score == 100.0, "Presentation must not change the authoritative Settlement score.")

	hud._process(0.25)
	_expect(hud.stage_score_label.text != "STAGE SCORE 0", "HUD must begin count-up during the visual.")
	_expect(hud.stage_score_label.text != "STAGE SCORE 100", "HUD must not jump directly to the final score during count-up.")

	effect._process(0.25)
	effect._process(0.25)
	_expect(_finished_count == 1, "Settlement presentation must finish exactly once.")
	_expect(hud.stage_score_label.text == "STAGE SCORE 100", "HUD must show the authoritative final score after the visual.")
	_expect(stage_manager.get_score_ledger().stage_score == 100.0, "Visual completion must not duplicate score.")

	hud.effect_manager._on_final_settlement_started(0.0)
	var canceled_effect: Node2D = hud.effect_manager._active_settlement_effect
	_expect(is_instance_valid(canceled_effect), "A repeated Settlement fixture must create a visual before reset.")
	canceled_effect.duration = 0.05
	hud.effect_manager.reset_runtime_fx(true)
	_expect(hud.effect_manager._active_settlement_effect == null, "Retry/Main reset must release the active Settlement visual immediately.")
	await get_tree().create_timer(0.1).timeout
	_expect(not is_instance_valid(canceled_effect), "Retry/Main reset must retire the stale Settlement draw node.")
	_expect(_finished_count == 1, "A canceled Settlement visual must not emit completion into the next Run.")

	if _failures == 0:
		print("S6_G6_VERIFIED samples=64 duration=0.5 score_countup=true completion=1 reset_stale_safe=true core_readonly=true")
	get_tree().quit(_failures)


func _on_finished() -> void:
	_finished_count += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G6 verification failed: %s" % message)
