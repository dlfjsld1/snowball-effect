extends Node

const TitleScreenScene = preload("res://scenes/ui/title_screen.tscn")
const PauseMenuScene = preload("res://scenes/ui/pause_menu.tscn")
const ResultPanelScene = preload("res://scenes/ui/result_panel.tscn")
const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")

var _failures := 0
var _start_requests := 0
var _title_settings_requests := 0
var _pause_requests := 0
var _resume_requests := 0
var _retry_requests := 0
var _settings_requests := 0
var _main_menu_requests := 0


func _ready() -> void:
	var title = TitleScreenScene.instantiate()
	var pause_menu: PauseMenu = PauseMenuScene.instantiate()
	var result = ResultPanelScene.instantiate()
	add_child(title)
	add_child(pause_menu)
	add_child(result)
	await get_tree().process_frame

	title.start_requested.connect(func() -> void: _start_requests += 1)
	title.settings_requested.connect(func() -> void: _title_settings_requests += 1)
	pause_menu.pause_requested.connect(func() -> void: _pause_requests += 1)
	pause_menu.resume_requested.connect(func() -> void: _resume_requests += 1)
	pause_menu.retry_requested.connect(func() -> void: _retry_requests += 1)
	pause_menu.settings_requested.connect(func() -> void: _settings_requests += 1)
	pause_menu.main_menu_requested.connect(func() -> void: _main_menu_requests += 1)
	result.main_menu_requested.connect(func() -> void: _main_menu_requests += 1)
	result.retry_requested.connect(func() -> void: _retry_requests += 1)

	_verify_title(title)
	_verify_pause_modal(pause_menu)
	_verify_result(result)
	_verify_ball_catalog_textures()
	_expect(not get_tree().paused, "Content UI must not change the SceneTree pause state.")

	if _failures == 0:
		print("S8_G3_VERIFIED title=true pause_modal=true result_snapshot=read_only actual_buttons=true hover=face_only requests=once")
	get_tree().quit(_failures)


func _verify_title(title) -> void:
	title.show_title()
	_expect(title.visible, "Title API must reveal the title screen.")
	_expect(title.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Title pixel assets must use nearest filtering.")
	_expect(title.get_node("TitleArtwork").texture != null, "Title must present the approved Ground mechanical artwork.")
	_expect(title.get_node("MechanicalMotion") != null, "Title must keep decorative motion separate from input controls.")
	_expect(title.start_button is Button and title.settings_button is Button, "Title actions must be real Godot Button components.")
	_expect(title.start_button.mouse_filter == Control.MOUSE_FILTER_STOP and title.settings_button.mouse_filter == Control.MOUSE_FILTER_STOP, "Title buttons must own their pointer hit areas.")
	_expect(title.help_button is Button and title.help_visual is Control, "Title must separate its real help Button hit area from the fixed circular visual.")
	_expect(title.help_button.mouse_filter == Control.MOUSE_FILTER_STOP, "Title help control must own its pointer hit area.")
	_verify_title_help_button(title.help_button)
	_expect(title.get_node("MechanicalMotion").mouse_filter == Control.MOUSE_FILTER_IGNORE, "Title decorative motion must not intercept pointer input.")
	_verify_clear_button_chrome(title.start_button, "Title Start")
	_verify_clear_button_chrome(title.settings_button, "Title Settings")
	_verify_title_hover_feedback(title)
	_verify_title_help_modal(title)
	_expect(title.start_button.has_focus(), "Title must focus the primary Start action when shown.")
	title.start_button.pressed.emit()
	_expect(_start_requests == 1, "Title start action must emit exactly one request.")
	title.settings_button.pressed.emit()
	_expect(_title_settings_requests == 1, "Title settings action must emit exactly one request.")
	title.hide_title()
	_expect(not title.visible, "Title API must hide the title screen.")


func _verify_pause_modal(pause_menu: PauseMenu) -> void:
	pause_menu.set_paused(false)
	pause_menu.pause_button.pressed.emit()
	_expect(_pause_requests == 1, "Quick pause control must emit exactly one request.")
	pause_menu.set_paused(true)
	_expect(pause_menu.pause_modal.visible, "Paused UI must reveal the modal.")
	pause_menu.resume_button.pressed.emit()
	pause_menu.modal_retry_button.pressed.emit()
	pause_menu.settings_button.pressed.emit()
	pause_menu.main_menu_button.pressed.emit()
	_expect(_resume_requests == 1 and _retry_requests == 1, "Resume and retry actions must each emit once.")
	_expect(_settings_requests == 1 and _main_menu_requests == 1, "Settings and main-menu actions must each emit once.")


func _verify_result(result) -> void:
	var supplied_snapshot := {
		"run_score": 1234567.0,
		"black_holes": [{"position": Vector2(10.0, 20.0)}],
		"optional_stats": {"merge_count": 148, "run_time_seconds": 766.9},
	}
	result.show_result(supplied_snapshot)
	_expect(result.visible, "Result API must reveal the result panel.")
	_expect(result.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Result pixel assets must use nearest filtering.")
	_expect(result.get_node("SlidePanel/Artwork").texture != null, "Result must present the approved Galactic terminal artwork.")
	_expect(result.get_node("SlidePanel/Artwork").texture.resource_path.ends_with("result_galactic_terminal_plate_v3.png"), "Result must use the revised Title-style tube-gauge artwork.")
	_expect(result.mechanical_motion != null, "Result must keep decorative tube and gauge motion separate from input controls.")
	_expect(result.retry_button is Button and result.main_menu_button is Button, "Result actions must be real Godot Button components.")
	_expect(result.mechanical_motion.mouse_filter == Control.MOUSE_FILTER_IGNORE, "Result decorative motion must not intercept pointer input.")
	_expect(is_equal_approx(result.mechanical_motion.RIGHT_GAUGE_CENTER.x, result.mechanical_motion.DESIGN_SIZE.x - result.mechanical_motion.LEFT_GAUGE_CENTER.x), "Result gauge centers must be horizontally symmetric in artwork coordinates.")
	_expect(is_equal_approx(result.mechanical_motion.RIGHT_TUBE.get_center().x, result.mechanical_motion.DESIGN_SIZE.x - result.mechanical_motion.LEFT_TUBE.get_center().x), "Result tube animation bounds must be horizontally symmetric in artwork coordinates.")
	_expect(is_equal_approx(result.mechanical_motion.LEFT_GAUGE_CENTER.y, result.mechanical_motion.LEFT_TUBE.end.y + 70.0) and is_equal_approx(result.mechanical_motion.RIGHT_GAUGE_CENTER.y, result.mechanical_motion.RIGHT_TUBE.end.y + 70.0), "Result tube gauges must sit below their lower caps with the recalculated 70px gap.")
	_verify_pixel_tube_particles(result.mechanical_motion)
	_verify_clear_button_chrome(result.retry_button, "Result Retry")
	_verify_clear_button_chrome(result.main_menu_button, "Result Main")
	_verify_result_hover_feedback(result)
	_expect(result.retry_button.position.is_equal_approx(Vector2(433.0, 740.0)) and result.retry_button.size.is_equal_approx(Vector2(315.0, 81.0)), "Result Retry hit area must remain aligned to the approved button face.")
	_expect(result.main_menu_button.position.is_equal_approx(Vector2(850.0, 740.0)) and result.main_menu_button.size.is_equal_approx(Vector2(316.0, 81.0)), "Result Main hit area must remain aligned to the approved button face.")
	_expect(result.retry_button.has_focus(), "Result must focus the primary Retry action when shown.")
	_expect(result.slide_panel.position.y > 0.0, "Result must begin its entrance below the viewport.")
	_expect(result.score_label.text == "1,234,567", "Result must show the complete comma-grouped final run score.")
	_expect(result.stats_row.visible, "Result must reveal supplied Run statistics.")
	_expect(result.merge_count_label.text == "148", "Result must display the authoritative cumulative Merge count without duplicating baked artwork labels.")
	_expect(result.run_time_label.text == "12:46", "Result must format authoritative Run Time as MM:SS without duplicating baked artwork labels.")
	_expect(result.merge_count_label.position.is_equal_approx(Vector2(699.0, 649.0)) and result.merge_count_label.size.is_equal_approx(Vector2(96.0, 38.0)), "Result Merge count must remain optically centered in its baked value plate.")
	_expect(result.run_time_label.position.is_equal_approx(Vector2(1065.0, 649.0)) and result.run_time_label.size.is_equal_approx(Vector2(115.0, 38.0)), "Result Run Time must remain optically centered in its baked value plate.")
	_verify_result_summary(result)
	supplied_snapshot["black_holes"][0]["position"] = Vector2.ZERO
	var copied_snapshot: Dictionary = result.get_result_snapshot()
	_expect(copied_snapshot["black_holes"][0]["position"] == Vector2(10.0, 20.0), "Result must keep a read-only copy of the terminal snapshot.")
	result.retry_button.pressed.emit()
	_expect(_retry_requests == 2, "Result retry action must emit exactly once.")
	result.main_menu_button.pressed.emit()
	_expect(_main_menu_requests == 2, "Result main-menu action must emit exactly once.")
	result.show_result({"run_score": 10.0})
	_expect(not result.stats_row.visible, "Result must hide the statistics row when the snapshot has no statistics.")
	result.show_result({"run_score": 4.13e36})
	_expect(result.score_label.text.replace("\n", ",") == "4,130,000,000,000,000,000,000,000,000,000,000,000", "Result must expand huge scores without scientific notation.")
	_expect(result.score_label.text.count("\n") == 2, "The approved huge-score example must use a balanced three-line layout.")
	_expect(result.score_label.get_theme_font_size(&"font_size") < 86, "Huge Result scores must reduce font size to remain inside the Clear Score plate.")
	result.hide_result()
	_expect(not result.visible and result.get_result_snapshot().is_empty(), "Hiding the result must clear only its UI copy.")


func _verify_result_summary(result) -> void:
	result.show_result({"run_score": 1.0, "stage_index": 0, "highest_ball_global_level": 4})
	_expect(result.highest_stage_label.text == "GROUND", "Ground Result must show the terminal Stage catalog name.")
	_expect(result.highest_ball_label.text == "MOON", "Ground Result must show the highest committed Ball catalog name.")
	_expect(result.ground_stage_art.visible and not result.planetary_stage_art.visible, "Ground Result must use only the approved Ground strip art.")
	_expect(result.ball_preview.texture != null, "Result must show the highest Ball catalog texture.")
	result.show_result({"run_score": 1.0, "stage_index": 1, "highest_ball_global_level": 10})
	_expect(result.highest_stage_label.text == "PLANETARY", "Planetary Result must show the terminal Stage catalog name.")
	_expect(result.highest_ball_label.text == "GALAXY", "Planetary Result must show the highest committed Ball catalog name.")
	_expect(not result.ground_stage_art.visible and result.planetary_stage_art.visible, "Planetary Result must use only the approved Earth-orbit strip art.")
	result.show_result({"run_score": 1.0, "stage_index": 1, "highest_ball_global_level": 8})
	_expect(result.highest_ball_label.text == "SUPERNOVA", "Planetary Result must resolve the Supernova catalog name.")
	_expect(result.ball_preview.texture != null and result.ball_preview.texture.resource_path.ends_with("ball_planetary_local_lv03_supernova_user_authored_64.png"), "Supernova Result must use the approved Supernova artwork, not the Earth placeholder.")
	result.show_result({"run_score": 1.0, "stage_index": 2, "highest_ball_global_level": 14})
	_expect(result.highest_stage_label.text == "GALACTIC" and result.highest_ball_label.text == "BLACK HOLE", "Galactic finale Result must show Galactic and Black Hole.")
	_expect(not result.ground_stage_art.visible and not result.planetary_stage_art.visible and not result.stage_preview_mask.visible, "Galactic Result must preserve its approved base-plate galaxy strip.")
	_expect(not result.ball_preview_backdrop.visible and not result.ball_preview.visible, "Black Hole Result must preserve its approved base-plate Black Hole preview.")


func _verify_ball_catalog_textures() -> void:
	var catalog = BallCatalogScript.new()
	for global_level in range(15):
		var definition = catalog.get_definition(global_level)
		_expect(definition != null, "Ball catalog must define global level %d." % global_level)
		if definition == null:
			continue
		_expect(definition.texture != null, "Ball catalog level %d (%s) must have a direct texture for Result UI." % [global_level, definition.display_name])
	_expect(catalog.get_definition(5).texture.resource_path.ends_with("ball_planetary_local_lv01_earth_user_authored_16.png"), "Earth must not use the former Mercury placeholder.")
	_expect(catalog.get_definition(6).texture.resource_path.ends_with("ball_planetary_local_lv02_sun_corona_crown_32.png"), "Sun must not use the former Mars placeholder.")
	_expect(catalog.get_definition(7).texture.resource_path.ends_with("ball_lv07_red_giant_1024.png"), "Red Giant must have its dedicated catalog artwork.")
	_expect(catalog.get_definition(9).texture.resource_path.ends_with("ball_lv09_nebula_1024.png"), "Nebula must have its dedicated catalog artwork.")


func _verify_clear_button_chrome(button: Button, label: String) -> void:
	_expect(button.tooltip_text.is_empty(), "%s must not reveal a duplicate browser-style tooltip." % label)
	for state in [&"normal", &"hover", &"pressed", &"focus"]:
		var stylebox := button.get_theme_stylebox(state)
		var flat := stylebox as StyleBoxFlat
		_expect(flat != null, "%s %s style must be an explicit StyleBoxFlat." % [label, state])
		if flat == null:
			continue
		var has_no_border := (
			flat.border_width_left == 0
			and flat.border_width_top == 0
			and flat.border_width_right == 0
			and flat.border_width_bottom == 0
		)
		_expect(is_zero_approx(flat.bg_color.a) and has_no_border, "%s %s style must not draw a rectangular overlay." % [label, state])


func _verify_title_help_button(button: Button) -> void:
	_expect(button.size.is_equal_approx(Vector2(36.0, 36.0)), "Title help control must keep a compact 36x36 circular hit area.")
	_expect(button.position.x >= 1550.0 and button.position.y <= 24.0, "Title help control must remain in the dark upper-right edge outside the brass pipe detail.")
	var visual := button.get_node("HelpVisual") as Control
	var circle := button.get_node("HelpVisual/Circle") as Panel
	var mark := button.get_node("HelpVisual/QuestionMark") as Label
	_expect(visual.size.is_equal_approx(Vector2(36.0, 36.0)), "Title help visual must remain an exact square independently of Button content sizing.")
	var circle_style := circle.get_theme_stylebox(&"panel") as StyleBoxFlat
	_expect(circle_style != null and circle_style.corner_radius_top_left == 18 and circle_style.border_width_left == 4, "Title help visual must draw a thick true circle.")
	_expect(mark.text == "?" and mark.get_theme_constant(&"outline_size") == 1, "Title help question mark must use the reinforced glyph treatment.")
	button.mouse_entered.emit()
	_expect(is_equal_approx(visual.modulate.a, 0.45), "Title help circle and question mark must become translucent together while hovered.")
	button.mouse_exited.emit()
	_expect(is_equal_approx(visual.modulate.a, 1.0), "Title help visual must return to full opacity after hover.")


func _verify_title_help_modal(title) -> void:
	_expect(not title.help_modal.visible, "Title help modal must start hidden.")
	title.help_button.pressed.emit()
	_expect(title.help_modal.visible, "Title help button must open the guide modal.")
	_expect(title.help_modal.mouse_filter == Control.MOUSE_FILTER_STOP, "Title help modal must block input to the title actions behind it.")
	_expect(title.help_image.texture != null and title.help_image.texture.resource_path.ends_with("title_controls_guide.png"), "Title help modal must show the approved six-panel guide image.")
	_expect(title.help_image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Title help image must preserve its aspect ratio.")
	title.help_dismiss_button.pressed.emit()
	_expect(not title.help_modal.visible, "Title help modal must close through its dismiss surface.")


func _verify_title_hover_feedback(title) -> void:
	var motion = title.get_node("MechanicalMotion")
	title.start_button.mouse_entered.emit()
	_expect(bool(motion.get("_start_hovered")), "Title Start hover must activate only its custom face feedback.")
	title.start_button.button_down.emit()
	_expect(bool(motion.get("_start_held")), "Title Start press must strengthen its custom face feedback.")
	title.start_button.button_up.emit()
	title.start_button.mouse_exited.emit()
	_expect(not bool(motion.get("_start_hovered")) and not bool(motion.get("_start_held")), "Title Start feedback must clear after pointer exit.")
	title.settings_button.mouse_entered.emit()
	_expect(bool(motion.get("_settings_hovered")), "Title Settings hover must activate its custom face feedback.")
	title.settings_button.mouse_exited.emit()
	_expect(not bool(motion.get("_settings_hovered")), "Title Settings feedback must clear after pointer exit.")


func _verify_result_hover_feedback(result) -> void:
	var motion = result.mechanical_motion
	result.retry_button.mouse_entered.emit()
	_expect(bool(motion.get("_retry_hovered")), "Result Retry hover must activate only its custom face feedback.")
	result.retry_button.button_down.emit()
	_expect(bool(motion.get("_retry_held")), "Result Retry press must strengthen its custom face feedback.")
	result.retry_button.button_up.emit()
	result.retry_button.mouse_exited.emit()
	_expect(not bool(motion.get("_retry_hovered")) and not bool(motion.get("_retry_held")), "Result Retry feedback must clear after pointer exit.")
	result.main_menu_button.mouse_entered.emit()
	_expect(bool(motion.get("_main_hovered")), "Result Main hover must activate its custom face feedback.")
	result.main_menu_button.mouse_exited.emit()
	_expect(not bool(motion.get("_main_hovered")), "Result Main feedback must clear after pointer exit.")


func _verify_pixel_tube_particles(motion) -> void:
	var left_particles: Array = motion.get("_left_bubbles")
	var right_particles: Array = motion.get("_right_bubbles")
	_expect(left_particles.size() == 7 and right_particles.size() == 8, "Result must animate independent pixel droplets in both left and right tubes.")
	for particle in left_particles + right_particles:
		_expect(particle.has("pixel_size") and not particle.has("radius"), "Result tube droplets must use square pixel sizes instead of circular radii.")
		_expect(int(particle.get("pixel_size", 0)) >= 2, "Result tube droplets must retain a visible pixel footprint.")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G3 verification failed: %s" % message)
