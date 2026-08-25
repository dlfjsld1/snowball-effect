extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageManager = preload("res://scripts/core/stage_manager.gd")
const HudScript = preload("res://scripts/ui/hud.gd")
const HudScene = preload("res://scenes/ui/hud.tscn")
const FrameScene = preload("res://scenes/backgrounds/gameplay_frame.tscn")
const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")
const BallCatalog = preload("res://scripts/data/ball_catalog.gd")
const BallTextureLodCatalog = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")
const GALAXY_CLUSTER_GAMEPLAY_PATH := "res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png"
const GALAXY_CLUSTER_CRT_PATH := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv01_galaxy_cluster_tri_spiral_core_crt_24.png"
const GALAXY_CLUSTER_GAMEPLAY_SHA256 := "b56ed4b3a55c94be2f7e1b54821261691cc0948f02d3bdfbb5f766e902c13947"
const GALAXY_CLUSTER_CRT_SHA256 := "0018b474579832cf0d8a29c3b154acf148f33744ace3cdb83cbcc9dac198af6c"
const CRT_FONT_NATIVE_SIZE := 10.0
const CRT_FONT_LINE_HEIGHT := 10.0
const CRT_FONT_GLYPH_HEIGHT := 7.0
const CRT_FONT_GLYPH_Y_OFFSET := 1.0
const CRT_FONT_X_ADVANCE := 6.0

var _failures := 0


func _ready() -> void:
	var simulation: SimulationManager = SimulationManager.new()
	var stage_manager: StageManager = StageManager.new()
	var frame: GameplayFrame = FrameScene.instantiate()
	simulation.name = "BallSimulationManager"
	stage_manager.name = "StageManager"
	stage_manager.simulation_path = NodePath("../BallSimulationManager")
	var hud: HudScript = HudScene.instantiate()
	add_child(frame)
	add_child(simulation)
	add_child(stage_manager)
	add_child(hud)
	hud.apply_frame_layout(frame.get_left_wing_rect(), frame.get_right_wing_rect())
	stage_manager.start_run()
	hud.bind_sources(stage_manager.get_score_ledger(), simulation, stage_manager)

	_expect(hud.stage_name_label.text == "GROUND", "The Stage CRT must display only the entered uppercase Stage name.")
	var expected_target := "TARGET %s" % ScoreFormatter.format_score(stage_manager.get_current_stage().clear_score)
	_expect(hud.clear_target_label.text == expected_target, "HUD must display the authoritative current Stage clear target.")
	_expect(hud.genealogy_slots[0].text == "SNOWFLAKE", "Stage entry must reveal only the uppercase local base ball.")
	_expect(hud.genealogy_slots[1].text == "", "Undiscovered genealogy slots must hide their names.")
	_verify_genealogy_structure(hud, frame)
	_verify_reveal_state(hud, 1)

	stage_manager._stage_runtime.stage_time_left = 12.5
	hud._process(0.0)
	_expect(hud.time_label.text == "TIME 12.5", "HUD must display the current Stage time.")
	_verify_time_crt_layout(hud, frame)

	var stage_score_before := stage_manager.get_score_ledger().stage_score
	var run_score_before := stage_manager.get_score_ledger().run_score
	simulation.spawn_ball(Vector2(100.0, 100.0), Vector2.ZERO, 4.0, 0)
	simulation.spawn_ball(Vector2(106.0, 100.0), Vector2.ZERO, 4.0, 0)
	simulation.commit_merge_candidates()
	_expect(hud.genealogy_slots[1].text == "SNOWBALL", "A newly created local Lv1 must reveal its uppercase genealogy slot once.")
	_expect(hud.genealogy_slots[2].text == "", "Later genealogy slots must remain hidden until created.")
	_verify_reveal_state(hud, 2)
	_expect(stage_manager.get_score_ledger().stage_score == stage_score_before and stage_manager.get_score_ledger().run_score == run_score_before, "HUD genealogy display must not mutate score.")
	_expect(simulation.get_active_count() == 1, "HUD genealogy display must not alter the committed Merge result.")

	_verify_all_stage_texture_mappings(hud)
	hud._on_stage_changed(stage_manager.get_current_stage())
	for level in [1, 2, 3, 4]:
		hud._on_ball_merged(level, Vector2.ZERO)
	_verify_reveal_state(hud, 5)
	stage_manager.start_run()
	_verify_reveal_state(hud, 1)
	_expect(hud.genealogy_slots[0].text == "SNOWFLAKE", "Retry/fresh Run stage entry must restore only the uppercase Ground base ball.")

	if _failures == 0:
		print("S3_G6_VERIFIED stage_time=true time_font=10 time_position=24x154 time_clip=false score_readonly=true title=BALLS genealogy_nodes=5 connectors=4 flow=bottom_to_top textures=15 carryover=planetary_moon:ground_moon,galactic_galaxy:planetary_galaxy galaxy_cluster=tri_spiral_core gameplay=16x16 crt=24x24 display=24x24 node_diameter=38 crt_bounds=106x317 margin=2px bounds=true sampling=runtime snowflake_linear=true locked_hidden=true stage_retry_reset=true")
	get_tree().quit(_failures)


func _verify_genealogy_structure(hud: HudScript, frame: GameplayFrame) -> void:
	var metrics: Dictionary = hud.get_genealogy_visual_metrics()
	_expect(metrics["node_count"] == 5, "Genealogy must keep exactly five circular nodes.")
	_expect(metrics["connector_count"] == 4, "Genealogy must connect the five nodes with exactly four lines.")
	_expect(metrics["flow"] == &"bottom_to_top", "Genealogy local levels must progress from bottom to top.")
	_expect(metrics["title"] == "BALLS", "The player-facing CRT title must be exactly BALLS.")
	_expect(metrics["icon_size"] == Vector2(24.0, 24.0), "Genealogy icon metrics must expose the exact 24x24 display contract.")
	_expect(is_equal_approx(float(metrics["node_radius"]), 19.0), "Genealogy circles must retain the exact 19px radius contract.")
	_expect(hud.genealogy_icons.size() == 5, "Genealogy must own one icon surface per catalog entry.")
	var genealogy_mask := _get_crt_mask_bounds(frame, &"genealogy")
	_expect(genealogy_mask.size == Vector2(106.0, 317.0), "The genealogy CRT display must retain its exact 106x317 mask.")
	_expect(metrics["display_bounds"] == genealogy_mask, "HUD genealogy bounds must match the actual CRT genealogy display mask.")
	var expected_safe_bounds: Rect2 = genealogy_mask.grow(-HudScript.GENEALOGY_DISPLAY_INSET)
	_expect(metrics["safe_bounds"] == expected_safe_bounds, "Genealogy content must use the actual scanline-safe display inset.")
	_expect(expected_safe_bounds.size == Vector2(102.0, 313.0), "The 2px inset must produce the exact 102x313 safe bounds.")
	_expect(not hud.get_node("Genealogy").clip_contents and not hud.get_node("Genealogy/Content").clip_contents and not hud.get_node("Genealogy/Content/Slots").clip_contents, "Genealogy containment must come from layout bounds, not clipping.")
	_verify_bounds_inside(expected_safe_bounds, [metrics["title_bounds"]], "title")
	_verify_bounds_inside(expected_safe_bounds, metrics["node_bounds"], "node")
	_verify_bounds_inside(expected_safe_bounds, metrics["connector_bounds"], "connector")
	_verify_bounds_inside(expected_safe_bounds, metrics["icon_bounds"], "icon")
	_verify_bounds_inside(expected_safe_bounds, metrics["label_bounds"], "label")
	var all_bounds: Array = [metrics["title_bounds"]]
	all_bounds.append_array(metrics["node_bounds"])
	all_bounds.append_array(metrics["connector_bounds"])
	all_bounds.append_array(metrics["icon_bounds"])
	all_bounds.append_array(metrics["label_bounds"])
	_expect(is_equal_approx(_minimum_margin(genealogy_mask, all_bounds), 2.0), "The nearest genealogy visual must retain the explicit 2px CRT display margin.")
	var previous_y := INF
	for slot_index in range(hud.genealogy_icons.size()):
		var icon: TextureRect = hud.genealogy_icons[slot_index]
		_expect(icon.size == HudScript.GENEALOGY_ICON_SIZE, "Genealogy icon %d must render at the testable 24x24 display size." % slot_index)
		_expect(icon.size.length() * 0.5 < float(metrics["node_radius"]), "Genealogy icon %d must fit completely inside its circular node." % slot_index)
		_expect(hud.genealogy_slots[slot_index].autowrap_mode != TextServer.AUTOWRAP_OFF, "Genealogy names must wrap inside their fixed CRT label bounds.")
		_expect(hud.genealogy_slots[slot_index].get_theme_font_size("font_size") == 10, "Genealogy labels must use the bitmap font's native 10px size for crisp bold strokes.")
		var center_y: float = metrics["node_centers"][slot_index].y
		if slot_index > 0:
			_expect(center_y < previous_y, "Higher local levels must be placed above lower local levels.")
		previous_y = center_y


func _get_crt_mask_bounds(frame: GameplayFrame, mask_id: StringName) -> Rect2:
	for mask in frame.get_crt_surface_metrics()["masks"]:
		if mask["id"] == mask_id:
			return mask["mask_bounds"]
	_expect(false, "The GameplayFrame must expose the genealogy CRT mask geometry.")
	return Rect2()


func _verify_time_crt_layout(hud: HudScript, frame: GameplayFrame) -> void:
	var time_mask := _get_crt_mask_bounds(frame, &"time")
	var time_inner := time_mask.grow(-2.0)
	var font_size := hud.time_label.get_theme_font_size("font_size")
	_expect(font_size == 10, "TIME CRT must retain the approved native 10px bitmap font size.")
	_expect(hud.time_label.position == frame.get_left_wing_rect().position + Vector2(24.0, 154.0), "TIME CRT must retain the approved wing-local position at X24/Y154.")
	var glyph_bounds := _predict_bitmap_glyph_bounds(hud.time_label, font_size)
	_expect(time_inner.encloses(glyph_bounds), "TIME glyphs must stay fully inside the visible CRT interior without clipping.")
	var left_spacing := int(round(glyph_bounds.position.x - time_inner.position.x))
	var right_spacing := int(round(time_inner.end.x - glyph_bounds.end.x))
	_expect(abs(left_spacing - right_spacing) <= 1, "TIME CRT horizontal centering must remain unchanged.")


func _predict_bitmap_glyph_bounds(label: Label, font_size: int) -> Rect2:
	var scale := float(font_size) / CRT_FONT_NATIVE_SIZE
	var line_height := roundf(CRT_FONT_LINE_HEIGHT * scale)
	var glyph_height := roundf(CRT_FONT_GLYPH_HEIGHT * scale)
	var y_offset := roundf(CRT_FONT_GLYPH_Y_OFFSET * scale)
	var glyph_width := roundf(float(label.text.length()) * CRT_FONT_X_ADVANCE * scale - scale)
	var line_top := label.global_position.y + floorf((label.size.y - line_height) * 0.5)
	var glyph_top := line_top + y_offset
	var glyph_left := label.global_position.x + floorf((label.size.x - glyph_width) * 0.5)
	return Rect2(Vector2(glyph_left, glyph_top), Vector2(glyph_width, glyph_height))


func _verify_bounds_inside(container: Rect2, bounds_list: Array, kind: String) -> void:
	for bounds_index in range(bounds_list.size()):
		var bounds: Rect2 = bounds_list[bounds_index]
		_expect(container.encloses(bounds), "Genealogy %s %d must remain completely inside the actual CRT scanline display." % [kind, bounds_index])


func _minimum_margin(container: Rect2, bounds_list: Array) -> float:
	var minimum := INF
	for bounds_value in bounds_list:
		var bounds: Rect2 = bounds_value
		minimum = minf(minimum, bounds.position.x - container.position.x)
		minimum = minf(minimum, bounds.position.y - container.position.y)
		minimum = minf(minimum, container.end.x - bounds.end.x)
		minimum = minf(minimum, container.end.y - bounds.end.y)
	return minimum


func _verify_reveal_state(hud: HudScript, expected_revealed: int) -> void:
	var metrics: Dictionary = hud.get_genealogy_visual_metrics()
	_expect(metrics["revealed_count"] == expected_revealed, "Genealogy revealed count must match the authoritative public state.")
	for slot_index in range(hud.genealogy_slots.size()):
		var should_reveal := slot_index < expected_revealed
		_expect(hud.genealogy_icons[slot_index].visible == should_reveal, "Only revealed genealogy entries may show a ball image.")
		_expect((hud.genealogy_icons[slot_index].texture != null) == should_reveal, "Locked genealogy entries must not retain a drawable ball image.")
		_expect((hud.genealogy_slots[slot_index].text != "") == should_reveal, "Locked genealogy entries must hide their ball name.")
		_expect(metrics["revealed"][slot_index] == should_reveal, "Circle state must match its name and icon reveal state.")


func _verify_all_stage_texture_mappings(hud: HudScript) -> void:
	var stage_catalog = StageCatalog.new()
	var ball_catalog = BallCatalog.new()
	var texture_catalog = BallTextureLodCatalog.new()
	var verified_entries := 0
	var unchanged_current_stage_entries := 0
	var ground_moon_texture: Texture2D
	var planetary_moon_texture: Texture2D
	var planetary_galaxy_texture: Texture2D
	var galactic_galaxy_texture: Texture2D
	var galaxy_cluster_gameplay_texture: Texture2D
	var galaxy_cluster_genealogy_texture: Texture2D
	var planetary_moon_small_texture: Texture2D
	var galactic_galaxy_small_texture: Texture2D
	for stage_index in range(3):
		var stage_definition: StageDefinition = stage_catalog.get_stage(stage_index)
		_expect(stage_definition.local_ball_levels.size() == 5, "Every Stage genealogy must consume its five StageDefinition entries.")
		hud._on_stage_changed(stage_definition)
		_verify_reveal_state(hud, 1)
		for local_level in range(stage_definition.local_ball_levels.size()):
			var global_level: int = stage_definition.local_ball_levels[local_level]
			if local_level > 0:
				hud._on_ball_merged(global_level, Vector2.ZERO)
			var definition = ball_catalog.get_definition(global_level)
			var runtime_diameter := float(8 * (1 << local_level))
			var current_stage_texture: Texture2D = texture_catalog.resolve_texture(global_level, runtime_diameter, definition.texture)
			var expected_runtime_texture: Texture2D = current_stage_texture
			if stage_index == 1 and local_level == 0:
				expected_runtime_texture = texture_catalog.resolve_texture(global_level, 128.0, definition.texture)
				planetary_moon_small_texture = current_stage_texture
			elif stage_index == 2 and local_level == 0:
				expected_runtime_texture = texture_catalog.resolve_texture(global_level, 128.0, definition.texture)
				galactic_galaxy_small_texture = current_stage_texture
			elif stage_index == 2 and local_level == 1:
				expected_runtime_texture = load(GALAXY_CLUSTER_CRT_PATH) as Texture2D
				galaxy_cluster_gameplay_texture = current_stage_texture
			else:
				unchanged_current_stage_entries += 1
			var icon: TextureRect = hud.genealogy_icons[local_level]
			_expect(expected_runtime_texture != null, "Every active Stage entry must have an approved in-game presentation texture.")
			_expect(icon.texture == expected_runtime_texture, "Stage %d local Lv%d must use the exact approved genealogy presentation texture." % [stage_index, local_level])
			var expected_filter := (expected_runtime_texture as CanvasTexture).texture_filter if expected_runtime_texture is CanvasTexture else CanvasItem.TEXTURE_FILTER_NEAREST
			_expect(icon.texture_filter == expected_filter, "Stage %d local Lv%d must preserve the in-game texture sampling mode." % [stage_index, local_level])
			_expect(icon.size == HudScript.GENEALOGY_ICON_SIZE, "Every approved in-game texture must use the same 24x24 genealogy display size.")
			_expect(hud.genealogy_slots[local_level].text == definition.display_name.to_upper(), "Genealogy names must uppercase BallCatalog-authored text without changing its texture mapping.")
			_expect(hud.genealogy_slots[local_level].text == hud.genealogy_slots[local_level].text.to_upper(), "Every visible genealogy name must be uppercase.")
			_expect(hud.genealogy_slots[local_level].get_line_count() <= 2, "Stage %d local Lv%d name must fit its fixed label in at most two wrapped lines." % [stage_index, local_level])
			if stage_index == 0 and local_level == 4:
				ground_moon_texture = icon.texture
			elif stage_index == 1 and local_level == 0:
				planetary_moon_texture = icon.texture
			elif stage_index == 1 and local_level == 4:
				planetary_galaxy_texture = icon.texture
			elif stage_index == 2 and local_level == 0:
				galactic_galaxy_texture = icon.texture
			elif stage_index == 2 and local_level == 1:
				galaxy_cluster_genealogy_texture = icon.texture
			verified_entries += 1
		_verify_reveal_state(hud, 5)
	_expect(verified_entries == 15, "The three StageDefinition chains must verify all fifteen active genealogy entries.")
	_expect(unchanged_current_stage_entries == 12, "Only the two carryovers and Galaxy Cluster's dedicated CRT icon may replace their current-Stage texture source.")
	_expect(ground_moon_texture != null and planetary_moon_texture == ground_moon_texture, "Planetary Moon must use the exact Ground final Moon texture resource.")
	_expect(ground_moon_texture != null and ground_moon_texture.resource_path == "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.tres", "Ground and Planetary Moon genealogy identity must be the approved Ground final resource.")
	_expect(planetary_moon_texture != planetary_moon_small_texture, "Planetary Moon genealogy must not use the small current-Stage gameplay texture.")
	_expect(planetary_galaxy_texture != null and galactic_galaxy_texture == planetary_galaxy_texture, "Galactic Galaxy must use the exact Planetary final Galaxy texture resource.")
	_expect(planetary_galaxy_texture != null and planetary_galaxy_texture.resource_path == "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.tres", "Planetary and Galactic Galaxy genealogy identity must be the approved Planetary final resource.")
	_expect(galactic_galaxy_texture != galactic_galaxy_small_texture, "Galactic Galaxy genealogy must not use the small current-Stage gameplay texture.")
	_expect(galaxy_cluster_gameplay_texture != null and galaxy_cluster_gameplay_texture.resource_path == GALAXY_CLUSTER_GAMEPLAY_PATH, "Galactic local Lv1 gameplay must keep the exact 16px Galaxy Cluster LOD path.")
	_expect(galaxy_cluster_gameplay_texture.get_size() == Vector2(16.0, 16.0), "Galaxy Cluster gameplay source must remain 16x16 for radius 8.")
	_expect(galaxy_cluster_genealogy_texture != null and galaxy_cluster_genealogy_texture.resource_path == GALAXY_CLUSTER_CRT_PATH, "Galaxy Cluster genealogy must use the selected dedicated CRT icon.")
	_expect(galaxy_cluster_genealogy_texture.get_size() == Vector2(24.0, 24.0), "Galaxy Cluster genealogy source must remain exact 24x24.")
	_expect(galaxy_cluster_genealogy_texture != galaxy_cluster_gameplay_texture, "The readability-specific CRT icon must not replace the gameplay LOD identity.")
	_expect(FileAccess.get_sha256(GALAXY_CLUSTER_GAMEPLAY_PATH) == GALAXY_CLUSTER_GAMEPLAY_SHA256, "Galaxy Cluster gameplay bytes must match selected A TRI-SPIRAL CORE.")
	_expect(FileAccess.get_sha256(GALAXY_CLUSTER_CRT_PATH) == GALAXY_CLUSTER_CRT_SHA256, "Galaxy Cluster CRT bytes must match selected A TRI-SPIRAL CORE.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G6 verification failed: %s" % message)
