extends Node

const HudScene = preload("res://scenes/ui/hud.tscn")
const MainScene = preload("res://scenes/main/main.tscn")
const GALAXY_CLUSTER_GAMEPLAY_PATH := "res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png"
const GALAXY_CLUSTER_CRT_PATH := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv01_galaxy_cluster_tri_spiral_core_crt_24.png"
const MISSING_OVERRIDE_PATH := "res://assets/sprites/balls/galactic/runtime/__missing_galaxy_cluster_crt.png"

var _failures := 0
var _progression_metrics := {
	"stage_time_delta": 0.0,
	"ball_displacement": 0.0,
}


func _ready() -> void:
	var hud: Node = HudScene.instantiate()
	var fallback := ResourceLoader.load(GALAXY_CLUSTER_GAMEPLAY_PATH, "Texture2D") as Texture2D
	_expect(fallback != null, "The already-approved 16px gameplay texture must remain a valid fallback resource.")
	var resolved := hud.call("_resolve_optional_genealogy_texture", MISSING_OVERRIDE_PATH, fallback) as Texture2D
	_expect(resolved == fallback, "A missing or not-yet-imported HUD-only override must fall back without blocking Hud compilation.")
	var hud_source := FileAccess.get_file_as_string("res://scripts/ui/hud.gd")
	_expect(
		not hud_source.contains('preload("%s")' % GALAXY_CLUSTER_CRT_PATH),
		"The HUD-only Galaxy Cluster icon must not be a compile-time preload dependency."
	)
	hud.free()
	await _verify_main_progression()
	if _failures == 0:
		print(
			"S3_G6_GALAXY_CLUSTER_IMPORT_FALLBACK_VERIFIED compile_dependency=false fallback=gameplay_texture main=true stage_time=true ball_motion=true stage_time_delta=%.3f ball_displacement=%.3f"
			% [_progression_metrics["stage_time_delta"], _progression_metrics["ball_displacement"]]
		)
	get_tree().quit(_failures)


func _verify_main_progression() -> void:
	var main := MainScene.instantiate()
	add_child(main)
	for _frame in range(3):
		await get_tree().process_frame
	var game_manager: Node = main.get_node("GameManager")
	var simulation: Node = main.get_node("PlayField/SimulationMount/BallSimulationManager")
	var title_screen: Node = main.get_node("UI/TitleScreen")
	title_screen.emit_signal(&"start_requested")
	await get_tree().physics_frame
	var before: Dictionary = game_manager.call("get_runtime_snapshot")
	var before_render: Dictionary = simulation.call("get_render_snapshot")
	var before_positions: PackedVector2Array = before_render["positions"].duplicate()
	for _frame in range(12):
		await get_tree().physics_frame
	var after: Dictionary = game_manager.call("get_runtime_snapshot")
	var after_render: Dictionary = simulation.call("get_render_snapshot")
	var after_positions: PackedVector2Array = after_render["positions"]
	var stage_time_delta := float(before["stage_time_left"]) - float(after["stage_time_left"])
	var ball_displacement := 0.0
	if not before_positions.is_empty() and not after_positions.is_empty():
		ball_displacement = before_positions[0].distance_to(after_positions[0])
	_progression_metrics["stage_time_delta"] = stage_time_delta
	_progression_metrics["ball_displacement"] = ball_displacement
	_expect(before["stage_state"] == &"PLAYING" and after["stage_state"] == &"PLAYING", "Main must enter and remain in PLAYING during the progression probe.")
	_expect(stage_time_delta > 0.0, "Stage time must advance after Main starts.")
	_expect(int(before_render["count"]) > 0 and int(after_render["count"]) > 0, "Main must keep an active logical ball while the probe runs.")
	_expect(ball_displacement > 0.0, "The first logical ball must move across physics frames.")
	main.queue_free()
	await get_tree().process_frame


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error(message)
