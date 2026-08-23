extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const BallCatalog = preload("res://scripts/data/ball_catalog.gd")
const HudScene = preload("res://scenes/ui/hud.tscn")
const MergeEffectScene = preload("res://scenes/effects/merge_effect.tscn")
const NormalBallTexture = preload("res://assets/sprites/balls/ground/runtime/ball_lv02_big_snowball_32.png")
const HighBallTexture = preload("res://assets/sprites/balls/galactic/runtime/ball_lv13_event_horizon_64.png")

const CAPTURE_DIRECTORY := "res://tmp/presentation-captures"

var _failures := 0


func _ready() -> void:
	if "--merge-fx-capture" in OS.get_cmdline_user_args():
		await _run_native_capture()
	else:
		await _run_verification()
	get_tree().quit(_failures)


func _run_verification() -> void:
	var simulation: SimulationManager = SimulationManager.new()
	var hud: Hud = HudScene.instantiate()
	add_child(simulation)
	add_child(hud)
	var ground_stage: StageDefinition = StageCatalog.new().get_stage(0)
	simulation.apply_stage_definition(ground_stage)
	hud.bind_sources(null, simulation)
	_expect(simulation.get_stage_snapshot()["local_ball_levels"] == ground_stage.local_ball_levels, "Merge FX fixture must use the active StageDefinition chain.")
	_expect(_get_signal_argument_count(simulation, &"ball_merged") == 2, "Presentation must remain compatible with the two-argument ball_merged contract.")

	simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0)
	simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 0)
	simulation.commit_merge_candidates()
	_expect(simulation.get_active_count() == 1, "Presentation must not alter the committed Merge result.")
	_expect(hud.effect_manager.merge_effect_count == 1, "One committed Merge must spawn exactly one presentation effect.")
	_expect(hud.effect_manager.get_active_merge_effect_count() == 1, "A Merge effect must be visible after the event.")

	var normal_effect := _get_last_merge_effect(hud.effect_manager)
	_expect(normal_effect != null, "The committed Merge must create a MergeEffect instance.")
	if normal_effect != null:
		var normal_profile: Dictionary = normal_effect.get_visual_profile()
		_expect(int(normal_profile["local_level"]) == 1, "Ground Lv0 merge result must use resulting local Lv1 intensity.")
		_expect(_count_text_nodes(normal_effect) == 0, "Ordinary Merge FX must not emit a ball name, value, score, or debug Label.")
		_expect(
			[normal_effect.get_phase_at(0.04), normal_effect.get_phase_at(0.12), normal_effect.get_phase_at(0.22), normal_effect.get_phase_at(normal_effect.lifetime)]
			== [MergeEffect.PHASE_INWARD, MergeEffect.PHASE_CORE, MergeEffect.PHASE_RESOLVE, MergeEffect.PHASE_FINISHED],
			"Merge FX phases must remain ordered inward, core, resolve, finished."
		)
		_expect(normal_effect.get_inward_distance_at(0.0) > normal_effect.get_inward_distance_at(0.09), "Phase 1 trail endpoints must converge toward the contact point.")

	var galactic_stage: StageDefinition = StageCatalog.new().get_stage(2)
	simulation.apply_stage_definition(galactic_stage)
	hud.effect_manager.set_simulation_source(simulation)
	var active_count_before_presentation_only_events := simulation.get_active_count()
	hud.effect_manager._on_ball_merged(13, Vector2(200.0, 200.0))
	var high_effect := _get_last_merge_effect(hud.effect_manager)
	_expect(high_effect != null, "A high-level two-argument event must create one MergeEffect.")
	if high_effect != null and normal_effect != null:
		var normal_profile: Dictionary = normal_effect.get_visual_profile()
		var high_profile: Dictionary = high_effect.get_visual_profile()
		_expect(int(high_profile["local_level"]) == 3, "Galactic Event Horizon must use current Stage local Lv3 intensity.")
		_expect(float(high_profile["ring_max_radius"]) > float(normal_profile["ring_max_radius"]), "Higher local levels may use a modestly larger ring.")
		_expect(int(high_profile["resolve_pixels"]) > int(normal_profile["resolve_pixels"]), "Higher local levels may use a few additional resolve pixels.")
		_expect(_count_text_nodes(high_effect) == 0, "High-level ordinary Merge FX must remain text-free.")
	_expect(hud.effect_manager.merge_effect_count == 2, "Presentation effect count must follow accepted events only.")
	_expect(simulation.get_active_count() == active_count_before_presentation_only_events, "Presentation-only Merge events must not mutate simulation state.")

	_test_level_intensity_bounds()

	hud.effect_manager.reset_runtime_fx()
	hud.effect_manager.set_reduced_effects(true)
	hud.effect_manager._on_ball_merged(13, Vector2(240.0, 200.0))
	var reduced_effect := _get_last_merge_effect(hud.effect_manager)
	_expect(reduced_effect != null, "Reduced Effects must retain a visible Merge cue.")
	if reduced_effect != null:
		var reduced_profile: Dictionary = reduced_effect.get_visual_profile()
		_expect(reduced_effect.get_phase_at(0.0) == MergeEffect.PHASE_CORE, "Reduced Effects must start with the compact core flash.")
		_expect(reduced_effect.get_phase_at(0.08) == MergeEffect.PHASE_RESOLVE, "Reduced Effects must finish with the restrained ring.")
		_expect(int(reduced_profile["trail_count"]) == 0 and int(reduced_profile["resolve_pixels"]) == 0, "Reduced Effects must omit trails and secondary pixels.")
		_expect(int(reduced_profile["ring_count"]) == 1 and float(reduced_profile["lifetime"]) <= MergeEffect.REDUCED_LIFETIME, "Reduced Effects must keep one short ring within its reduced lifetime.")
		_expect(not bool(reduced_profile["camera_shake"]), "Merge FX must never request camera shake.")
		reduced_effect.set_process(false)
		reduced_effect._process(reduced_effect.lifetime)
		_expect(hud.effect_manager.get_active_merge_effect_count() == 0, "An expired Merge FX must release the active budget immediately.")
		await get_tree().process_frame
		_expect(_count_registered_merge_children(hud.effect_manager) == 0, "Expired Merge FX must be freed without stale pooled children.")

	if _failures == 0:
		print("S2_G5_VERIFIED merge_fx_once=true no_text=true phases=inward/core/resolve local_intensity=0..4_bounded reduced=core_ring cleanup=true contract_args=2 presentation_readonly=true")


func _test_level_intensity_bounds() -> void:
	var previous_ring_radius := 0.0
	var previous_pixel_count := -1
	for local_level in range(5):
		var effect: MergeEffect = MergeEffectScene.instantiate()
		effect.set_process(false)
		add_child(effect)
		effect.setup(Vector2.ZERO, Color("98d8b1"), local_level)
		var profile: Dictionary = effect.get_visual_profile()
		var ring_radius := float(profile["ring_max_radius"])
		var pixel_count := int(profile["resolve_pixels"])
		_expect(ring_radius >= previous_ring_radius and ring_radius <= 82.0, "Local-level ring intensity must be monotonic and capped just outside the 64px-radius top ball.")
		_expect(pixel_count >= previous_pixel_count and pixel_count <= 6, "Resolve pixel count must be monotonic and capped at six.")
		_expect(int(profile["ring_count"]) == 1, "Every intensity level must keep exactly one ring.")
		_expect(int(profile["trail_count"]) == 2 and int(profile["trail_segments"]) <= 4, "Normal intensity must keep two short trails with at most four pixels each.")
		_expect(float(profile["lifetime"]) == MergeEffect.NORMAL_LIFETIME, "All normal intensity levels must share the 0.32s cleanup lifetime.")
		previous_ring_radius = ring_radius
		previous_pixel_count = pixel_count
		remove_child(effect)
		effect.free()


func _run_native_capture() -> void:
	get_window().size = Vector2i(1600, 900)
	_build_capture_background()
	var normal_anchor := Vector2(680.0, 450.0)
	var high_anchor := Vector2(920.0, 450.0)
	_add_capture_ball(NormalBallTexture, normal_anchor)
	_add_capture_ball(HighBallTexture, high_anchor)

	var catalog = BallCatalog.new()
	var normal_definition = catalog.get_definition(2)
	var high_definition = catalog.get_definition(13)
	var normal_effect: MergeEffect = MergeEffectScene.instantiate()
	var high_effect: MergeEffect = MergeEffectScene.instantiate()
	add_child(normal_effect)
	add_child(high_effect)
	normal_effect.setup(normal_anchor, normal_definition.base_color, 2)
	high_effect.setup(high_anchor, high_definition.base_color, 3)
	normal_effect.set_process(false)
	high_effect.set_process(false)

	await get_tree().process_frame
	await _advance_and_capture([normal_effect, high_effect], 0.04, "s2_g5_merge_fx_01_inward.png", &"INWARD")
	await _advance_and_capture([normal_effect, high_effect], 0.09, "s2_g5_merge_fx_02_core.png", &"CORE")
	await _advance_and_capture([normal_effect, high_effect], 0.10, "s2_g5_merge_fx_03_resolve.png", &"RESOLVE")
	if _failures == 0:
		print("S2_G5_CAPTURE size=1600x900 normal_local=2 high_local=3 active_fx=2 frames=3 text=false")


func _build_capture_background() -> void:
	_add_color_rect(Rect2(0.0, 0.0, 1600.0, 900.0), Color("050709"))
	_add_color_rect(Rect2(520.0, 50.0, 560.0, 800.0), Color("0b121c"))
	var border_color := Color("344345")
	_add_color_rect(Rect2(518.0, 48.0, 564.0, 2.0), border_color)
	_add_color_rect(Rect2(518.0, 850.0, 564.0, 2.0), border_color)
	_add_color_rect(Rect2(518.0, 50.0, 2.0, 800.0), border_color)
	_add_color_rect(Rect2(1080.0, 50.0, 2.0, 800.0), border_color)


func _add_color_rect(rect: Rect2, color: Color) -> void:
	var panel := ColorRect.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.color = color
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)


func _add_capture_ball(texture: Texture2D, world_position: Vector2) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = world_position
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)


func _advance_and_capture(effects: Array, delta: float, file_name: String, expected_phase: StringName) -> void:
	for effect in effects:
		effect._process(delta)
		effect.set_process(false)
		_expect(effect.get_phase() == expected_phase, "Capture frame must sample the requested Merge FX phase.")
	await RenderingServer.frame_post_draw
	var directory_path := ProjectSettings.globalize_path(CAPTURE_DIRECTORY)
	DirAccess.make_dir_recursive_absolute(directory_path)
	var capture_path := "%s/%s" % [directory_path, file_name]
	var image := get_viewport().get_texture().get_image()
	var save_error := image.save_png(capture_path)
	_expect(save_error == OK, "Native Merge FX capture must save successfully.")
	print("S2_G5_CAPTURE_FRAME phase=%s path=%s save_error=%d" % [expected_phase, capture_path, save_error])


func _get_last_merge_effect(manager: EffectManager) -> MergeEffect:
	for child_index in range(manager.get_child_count() - 1, -1, -1):
		var child := manager.get_child(child_index)
		if child is MergeEffect and StringName(child.get_meta("s6_event_key", &"")) == &"MERGE":
			return child
	return null


func _count_text_nodes(node: Node) -> int:
	var count := 1 if node is Label or node is RichTextLabel else 0
	for child in node.get_children():
		count += _count_text_nodes(child)
	return count


func _count_registered_merge_children(manager: EffectManager) -> int:
	var count := 0
	for child in manager.get_children():
		if StringName(child.get_meta("s6_event_key", &"")) == &"MERGE":
			count += 1
	return count


func _get_signal_argument_count(source: Object, signal_name: StringName) -> int:
	for signal_info in source.get_signal_list():
		if StringName(signal_info.get("name", &"")) == signal_name:
			return Array(signal_info.get("args", [])).size()
	return -1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S2-G5 verification failed: %s" % message)
