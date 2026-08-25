extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")


func _ready() -> void:
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	add_child(frame)
	var hud: Hud = HUD_SCENE.instantiate()
	add_child(hud)
	await get_tree().process_frame

	var treatment: CrtSurfaceTreatment = frame.get_crt_surface_treatment()
	var metrics := treatment.get_visual_metrics()
	assert(metrics["static"] and not metrics["animated"])
	assert(not treatment.is_processing() and not treatment.is_physics_processing())
	assert(metrics["module_count"] == 6 and metrics["mask_count"] == 7)
	assert(metrics["scanline_pitch"] == 4 and metrics["scanline_height"] == 1)
	assert(metrics["backing"] == Color("1f244b"))
	assert(metrics["edge"] == Color("3c6b64"))
	assert(metrics["phosphor"] == StageScoreGauge.CELL_COLOR)
	assert(metrics["phosphor_bright"] == StageScoreGauge.CELL_HIGHLIGHT)
	assert(StageScoreGauge.CELL_SHADOW == Color("3c6b64"))
	assert(metrics["pause_labels"] == ["PAUSE", "RETRY"])
	assert(frame.get_node("CrtShells").get_index() < treatment.get_index())

	var first_signature: String = metrics["pattern_signature"]
	for _frame_index in range(3):
		await get_tree().process_frame
	assert(treatment.get_visual_metrics()["pattern_signature"] == first_signature)
	var treatment_source := FileAccess.get_file_as_string("res://scripts/presentation/crt_surface_treatment.gd")
	assert(not treatment_source.contains("func _process"))
	assert(not treatment_source.contains("rand"))
	assert(not treatment_source.contains("Tween"))
	assert(not treatment_source.contains("shader"))

	for profile in range(4):
		frame.set_profile(profile)
		var profile_metrics := frame.get_crt_surface_metrics()
		var left_wing := frame.get_left_wing_rect()
		var right_wing := frame.get_right_wing_rect()
		for mask in profile_metrics["masks"]:
			var mask_bounds: Rect2 = mask["mask_bounds"]
			var halo_bounds: Rect2 = mask["halo_bounds"]
			assert(mask_bounds == halo_bounds, "Glow must remain inside the exact CRT mask bounds.")
			assert(mask_bounds.position == mask_bounds.position.round())
			assert(mask_bounds.size == mask_bounds.size.round())
			var mask_id: StringName = mask["id"]
			var owner_rect := left_wing if mask_id in [&"stage", &"time", &"genealogy"] else right_wing
			assert(owner_rect.encloses(mask_bounds), "CRT treatment must not spill over its chassis wing.")

	assert(hud.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST)
	assert(hud.stage_name_label.text == "GROUND")
	assert(hud.time_label.text == "TIME 45.0")
	assert(hud.stage_score_label.text == "0")
	assert((hud.get_node("Genealogy/Content/Title") as Label).text == "BALLS")
	assert(hud.stage_name_label.get_theme_font_size("font_size") == 20)
	assert(hud.time_label.get_theme_font_size("font_size") == 10)
	assert(hud.stage_score_label.get_theme_font_size("font_size") == 20)
	assert(hud.genealogy_slots[0].get_theme_font_size("font_size") == 10)
	for label in [hud.stage_name_label, hud.time_label, hud.stage_score_label] + hud.genealogy_slots:
		assert(label.position == label.position.round())
		assert(label.size == label.size.round())

	var frame_scene_source := FileAccess.get_file_as_string("res://scenes/backgrounds/gameplay_frame.tscn")
	var main_scene_source := FileAccess.get_file_as_string("res://scenes/main/main.tscn")
	assert(frame_scene_source.find("[node name=\"CrtShells\"") < frame_scene_source.find("[node name=\"CrtSurfaceTreatment\""))
	assert(main_scene_source.find("[node name=\"GameplayFrame\" parent=\"UI\"") < main_scene_source.find("[node name=\"HUDMount\""))
	assert(main_scene_source.find("[node name=\"GameplayFrame\" parent=\"UI\"") < main_scene_source.find("[node name=\"PauseMenu\" parent=\"UI\""))

	print("S5_G4_CRT_SURFACE_VERIFIED static=true masks=7 scanlines=1px palette=paper8 text_above=true integer=true genealogy_title=BALLS")
	get_tree().quit()
