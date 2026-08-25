extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const BallRendererScript = preload("res://scripts/simulation/ball_renderer.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")

@onready var simulation: SimulationManager = $BallSimulationManager
@onready var renderer: BallRenderer = $BallRenderer

var _failures := 0


func _ready() -> void:
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	renderer.process_mode = Node.PROCESS_MODE_DISABLED
	_run_verification()


func _run_verification():
	var probes := [
		{"position": Vector2(100.0, 100.0), "radius": 4.0, "level": 0},
		{"position": Vector2(180.0, 160.0), "radius": 8.0, "level": 1},
		{"position": Vector2(260.0, 220.0), "radius": 16.0, "level": 4},
		{"position": Vector2(340.0, 280.0), "radius": 32.0, "level": 10},
		{"position": Vector2(420.0, 340.0), "radius": 64.0, "level": 13},
		{"position": Vector2(500.0, 400.0), "radius": 32.0, "level": 14},
	]
	for probe in probes:
		simulation.spawn_ball(probe["position"], Vector2.ZERO, probe["radius"], probe["level"])
	simulation.spawn_ball(Vector2(560.0, 240.0), Vector2.ZERO, 16.0, 2, SimulationManager.BallSpecialType.FIRE)

	renderer.refresh_render_snapshot()
	await get_tree().process_frame
	var metrics := renderer.get_render_metrics()
	_expect(metrics["clip_rect"] == simulation.play_field_rect, "Every standard batch must use the active logical Play Field as its clip rect.")
	_expect(metrics["standard_ball_count"] == 6, "Levels 0 through 13 must use MultiMesh batches.")
	_expect(metrics["fire_overlay_count"] == 1, "Only Fire balls must enter the shared Fire overlay batch.")
	_expect(metrics["fire_overlay_capacity"] >= metrics["fire_overlay_count"], "The Fire overlay batch must grow by reusable capacity.")
	_expect(metrics["special_fallback_count"] == 1, "Lv14 Black Hole must stay on the special fallback path.")
	var visible_counts: PackedInt32Array = metrics["batch_visible_counts"]
	_expect(visible_counts[0] == 1 and visible_counts[1] == 1 and visible_counts[4] == 1, "Each populated early level must expose one instance.")
	_expect(visible_counts[10] == 1 and visible_counts[13] == 1, "Each populated late standard level must expose one instance.")
	_expect(_standard_batch_keeps_clip_material(0), "A standard batch must retain the Play Field clip material.")
	_expect(_standard_batch_keeps_clip_material(13), "A textured top-ball batch must retain the Play Field clip material.")
	_expect(_transform_matches(0, 0, Vector2(100.0, 100.0), 4.0), "Lv0 transform must preserve position and runtime radius.")
	_expect(_transform_matches(13, 0, Vector2(420.0, 340.0), 64.0), "Lv13 transform must preserve position and runtime radius.")
	_expect(_fire_overlay_matches(0, Vector2(560.0, 238.08), 16.0), "The Fire shell must cover the Snowball lower edge while the flowing upper flame mass avoids a horn silhouette.")
	_expect(renderer._fire_overlay_batch.z_index == 1, "The Fire shell must render above the standard Snowball batch.")

	simulation.reset_runtime()
	renderer.refresh_render_snapshot()
	await get_tree().process_frame
	metrics = renderer.get_render_metrics()
	_expect(metrics["standard_ball_count"] == 0 and metrics["special_fallback_count"] == 0, "Reset must remove all visible instances without stale fallback balls.")
	_expect(metrics["fire_overlay_count"] == 0 and not renderer._fire_overlay_batch.visible, "Reset must hide the shared Fire overlay without stale instances.")
	visible_counts = metrics["batch_visible_counts"]
	for visible_count in visible_counts:
		_expect(visible_count == 0, "Reset must hide every level batch.")

	simulation.spawn_ball(Vector2(640.0, 120.0), Vector2.ZERO, 4.0, 10)
	renderer.refresh_render_snapshot()
	await get_tree().process_frame
	metrics = renderer.get_render_metrics()
	visible_counts = metrics["batch_visible_counts"]
	_expect(metrics["standard_ball_count"] == 1 and visible_counts[10] == 1, "A later Stage level must reuse its matching batch after reset.")
	_expect(_transform_matches(10, 0, Vector2(640.0, 120.0), 4.0), "Stage re-baselined radius must render from the current runtime value.")

	simulation.apply_stage_definition(StageCatalog.new().get_stage(2))
	simulation.spawn_ball(Vector2(640.0, 300.0), Vector2.ZERO, 32.0, 13)
	simulation.spawn_ball(Vector2(640.0, 300.0), Vector2.ZERO, 32.0, 13)
	simulation.commit_merge_candidates()
	renderer.refresh_render_snapshot()
	await get_tree().process_frame
	metrics = renderer.get_render_metrics()
	_expect(metrics["black_hole_count"] == 1, "A converted Black Hole runtime entity must remain visible after leaving normal ball slots.")
	_expect(renderer.get_black_hole_render_position(0).is_equal_approx(Vector2(640.0, 300.0)), "Black Hole rendering must use the runtime entity position.")

	if _failures == 0:
		print("S4_G4_MULTIMESH_VERIFIED standard=%d fallback=%d black_holes=%d" % [metrics["standard_ball_count"], metrics["special_fallback_count"], metrics["black_hole_count"]])
	get_tree().quit(_failures)


func _transform_matches(global_level: int, instance_index: int, expected_origin: Vector2, expected_radius: float) -> bool:
	var transform := renderer.get_batch_instance_transform(global_level, instance_index)
	return (
		transform.origin.is_equal_approx(expected_origin)
		and is_equal_approx(transform.x.length(), expected_radius)
		and is_equal_approx(transform.y.length(), expected_radius)
	)


func _standard_batch_keeps_clip_material(global_level: int) -> bool:
	var batch: MultiMeshInstance2D = renderer._batches[global_level]
	var material := batch.material as ShaderMaterial
	return material != null and material.get_shader_parameter("use_texture") == (batch.texture != null)


func _fire_overlay_matches(instance_index: int, expected_origin: Vector2, expected_radius: float) -> bool:
	var transform := renderer.get_fire_overlay_transform(instance_index)
	return (
		transform.origin.is_equal_approx(expected_origin)
		and is_equal_approx(transform.x.length(), expected_radius * 1.49)
		and is_equal_approx(transform.y.length(), expected_radius * 1.49)
		and transform.y.y < 0.0
	)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S4-G4 MultiMesh verification failed: %s" % message)
