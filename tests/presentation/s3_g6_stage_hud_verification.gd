extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageManager = preload("res://scripts/core/stage_manager.gd")
const HudScript = preload("res://scripts/ui/hud.gd")
const HudScene = preload("res://scenes/ui/hud.tscn")

var _failures := 0


func _ready() -> void:
	var simulation: SimulationManager = SimulationManager.new()
	var stage_manager: StageManager = StageManager.new()
	simulation.name = "BallSimulationManager"
	stage_manager.name = "StageManager"
	stage_manager.simulation_path = NodePath("../BallSimulationManager")
	var hud: HudScript = HudScene.instantiate()
	add_child(simulation)
	add_child(stage_manager)
	add_child(hud)
	stage_manager.start_run()
	hud.bind_sources(stage_manager.get_score_ledger(), simulation, stage_manager)

	_expect(hud.stage_name_label.text == "STAGE GROUND", "HUD must display the entered Stage name.")
	_expect(hud.clear_target_label.text == "TARGET 4M", "HUD must display the current Stage clear target.")
	_expect(hud.genealogy_slots[0].text == "Snowflake", "Stage entry must reveal only the local base ball.")
	_expect(hud.genealogy_slots[1].text == "", "Undiscovered genealogy slots must hide their names.")

	stage_manager._stage_runtime.stage_time_left = 12.5
	hud._process(0.0)
	_expect(hud.time_label.text == "TIME 12.5", "HUD must display the current Stage time.")

	var stage_score_before := stage_manager.get_score_ledger().stage_score
	var run_score_before := stage_manager.get_score_ledger().run_score
	simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0)
	simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 0)
	simulation.commit_merge_candidates()
	_expect(hud.genealogy_slots[1].text == "Snowball", "A newly created local Lv1 must reveal its genealogy slot once.")
	_expect(hud.genealogy_slots[2].text == "", "Later genealogy slots must remain hidden until created.")
	_expect(stage_manager.get_score_ledger().stage_score == stage_score_before and stage_manager.get_score_ledger().run_score == run_score_before, "HUD genealogy display must not mutate score.")
	_expect(simulation.get_active_count() == 1, "HUD genealogy display must not alter the committed Merge result.")

	if _failures == 0:
		print("S3_G6_VERIFIED stage_time=true score_readonly=true genealogy_reveal=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G6 verification failed: %s" % message)
