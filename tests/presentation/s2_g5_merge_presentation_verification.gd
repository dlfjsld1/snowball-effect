extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const HudScene = preload("res://scenes/ui/hud.tscn")

var _failures := 0


func _ready() -> void:
	var simulation: SimulationManager = SimulationManager.new()
	var hud: Hud = HudScene.instantiate()
	add_child(simulation)
	add_child(hud)
	simulation.configure_stage_ball_levels(PackedInt32Array([0, 1, 2, 3, 4]))
	hud.bind_sources(null, simulation)

	simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0)
	simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 0)
	simulation.commit_merge_candidates()
	_expect(simulation.get_active_count() == 1, "Presentation must not alter the committed Merge result.")
	_expect(hud.effect_manager.merge_effect_count == 1, "One committed Merge must spawn exactly one presentation effect.")
	_expect(hud.effect_manager.get_active_merge_effect_count() == 1, "A Merge effect must be visible after the event.")

	hud.effect_manager._on_ball_merged(13, Vector2(200.0, 200.0))
	var high_value_effect: MergeEffect = hud.effect_manager.get_child(-1)
	_expect(high_value_effect.value_label.text == "EVENT HORIZON", "Merge display must use the catalog name without inferring a score amount.")
	_expect(hud.effect_manager.merge_effect_count == 2, "Presentation effect count must follow emitted events only.")

	if _failures == 0:
		print("S2_G5_VERIFIED merge_fx_once=true catalog_name=true presentation_readonly=true")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S2-G5 verification failed: %s" % message)
