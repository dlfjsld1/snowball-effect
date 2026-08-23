extends Node

const CashoutEffectScene = preload("res://scenes/effects/cashout_effect.tscn")
const EffectManagerScript = preload("res://scripts/presentation/effect_manager.gd")
const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")

const ACTIVE_FIELD := Rect2(520.0, 50.0, 560.0, 768.0)
const CAPTURE_DIRECTORY := "res://tmp/presentation-captures"
const COMPARISON_CAPTURE := "s4_g4_cashout_popup_local_levels.png"
const EDGE_CAPTURE := "s4_g4_cashout_popup_local_lv4_edge.png"
const EXPECTED_FONT_SIZES := [18, 19, 20, 21, 22]
const EXPECTED_FONT_COLORS := [
	Color("f4f5e8"),
	Color("c9f3f5"),
	Color("f6e79c"),
	Color("48ddec"),
	Color("ffc857"),
]
const EXPECTED_OUTLINE_SIZES := [3, 3, 3, 4, 4]
const EXPECTED_SHADOW_OFFSETS := [2, 2, 2, 2, 3]

var _failures := 0


class FakeSimulationSource extends Node:
	signal ball_merged(result_level: int, world_position: Vector2)
	signal cashout_completed(score_amount: float, global_level: int, world_position: Vector2)

	var active_play_field_rect := ACTIVE_FIELD
	var local_ball_levels := PackedInt32Array()


	func get_active_play_field_rect() -> Rect2:
		return active_play_field_rect


	func get_stage_snapshot() -> Dictionary:
		return {"local_ball_levels": local_ball_levels}


func _ready() -> void:
	if "--cashout-popup-capture" in OS.get_cmdline_user_args():
		await _run_native_capture()
	else:
		await _run_verification()
	get_tree().quit(_failures)


func _run_verification() -> void:
	var authoritative_amount := 4.13e36
	var expected_digits := ScoreFormatter.format_score_full(authoritative_amount).replace(",", "")
	await _test_five_local_level_styles(authoritative_amount, expected_digits)
	await _test_largest_tier_edge_clamp()
	await _test_reduced_effects_and_cleanup(authoritative_amount, expected_digits)
	await _test_stage_local_level_mappings()
	await _test_event_contract_and_budget(authoritative_amount, expected_digits)

	if _failures == 0:
		print("S4_G4_CASHOUT_PRESENTATION_VERIFIED digits_only=true local_styles=5 fonts=18/19/20/21/22 colors=f4f5e8/c9f3f5/f6e79c/48ddec/ffc857 mappings=ground/planetary/galactic identical_reuse=true fallback=local0 outline=3/3/3/4/4 shadow=2/2/2/2/3 integer=true edge_lv4=true lifetime=0.38 rise=18 cleanup=true reduced=true event_args=3 value_unchanged=true active_cashout=1 cleanup_active=0")


func _test_five_local_level_styles(authoritative_amount: float, expected_digits: String) -> void:
	var previous_font_size := 0
	var previous_outline_size := 0
	var previous_shadow_offset := 0
	for local_level in range(5):
		var effect := _create_effect(Vector2(800.0, 1200.0), authoritative_amount, false, local_level)
		var profile: Dictionary = effect.get_visual_profile()
		_expect(String(profile["text"]) == expected_digits, "Every local style must preserve the authoritative full integer formatting with separators removed.")
		_expect(_is_decimal_digits_only(String(profile["text"])), "Every local style must output decimal digits only.")
		_expect(not _contains_forbidden_copy(String(profile["text"])), "Every local style must omit labels, names, units, signs, scientific notation, and debug text.")
		_expect(int(profile["local_level"]) == local_level, "CashoutEffect must retain the resolved current Stage local level.")
		_expect(int(profile["font_size"]) == EXPECTED_FONT_SIZES[local_level], "Local Cashout font size must match the restrained five-step pixel scale.")
		_expect(Color(profile["font_color"]).is_equal_approx(EXPECTED_FONT_COLORS[local_level]), "Local Cashout color must match its approved project-palette step.")
		_expect(Color(profile["outline_color"]).is_equal_approx(CashoutEffect.OUTLINE_COLOR), "Every local style must retain the approved hard dark outline color.")
		_expect(int(profile["outline_size"]) == EXPECTED_OUTLINE_SIZES[local_level], "Local Cashout hard outline must match its bounded emphasis step.")
		var shadow_offset := Vector2i(profile["shadow_offset"])
		_expect(shadow_offset == Vector2i.ONE * EXPECTED_SHADOW_OFFSETS[local_level], "Local Cashout hard shadow must match its integer emphasis step.")
		_expect(int(profile["font_size"]) > previous_font_size, "Higher local levels must strictly increase numeric size.")
		_expect(int(profile["outline_size"]) >= previous_outline_size and shadow_offset.x >= previous_shadow_offset, "Higher local levels must not reduce hard-pixel emphasis.")
		_expect(effect.value_label.get_theme_color("font_shadow_color").is_equal_approx(CashoutEffect.OUTLINE_COLOR), "Every local style must use the approved hard dark shadow color.")
		_expect(effect.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Cashout popup must use nearest texture filtering.")
		var pixel_font := effect.value_label.get_theme_font("font")
		_expect(int(pixel_font.get("antialiasing")) == 0, "Cashout font antialiasing must be disabled.")
		_expect(int(pixel_font.get("subpixel_positioning")) == 0, "Cashout font subpixel positioning must be disabled.")
		_expect(_is_integer_vector(effect.position) and _is_integer_vector(effect.value_label.position), "Cashout number must start on integer coordinates.")
		effect.set_process(false)
		effect._process(0.19)
		_expect(_is_integer_vector(effect.position), "Cashout number drift must remain integer-positioned.")
		_expect(_rect_inside(effect.get_value_rect(), ACTIVE_FIELD), "Each local Cashout style must remain inside the active Play Field.")
		previous_font_size = int(profile["font_size"])
		previous_outline_size = int(profile["outline_size"])
		previous_shadow_offset = shadow_offset.x
		effect.queue_free()
	await get_tree().process_frame


func _test_largest_tier_edge_clamp() -> void:
	var local_lv4_amount := 1.0e25
	var left_effect := _create_effect(Vector2(420.0, 1200.0), local_lv4_amount, false, 4)
	var right_effect := _create_effect(Vector2(1180.0, 1200.0), local_lv4_amount, false, 4)
	var galactic_lv3_effect := _create_effect(Vector2(1180.0, 1200.0), 1.0e43, false, 3)
	left_effect.set_process(false)
	right_effect.set_process(false)
	galactic_lv3_effect.set_process(false)
	left_effect._process(0.37)
	right_effect._process(0.37)
	galactic_lv3_effect._process(0.37)
	_expect(int(left_effect.get_visual_profile()["local_level"]) == 4 and int(right_effect.get_visual_profile()["font_size"]) == 22, "Largest tier edge fixture must exercise the exact local Lv4 style.")
	_expect(_rect_inside(left_effect.get_value_rect(), ACTIVE_FIELD), "Left-edge local Lv4 number must clamp inside the active Play Field.")
	_expect(_rect_inside(right_effect.get_value_rect(), ACTIVE_FIELD), "Right/bottom-edge local Lv4 number must clamp inside the active Play Field.")
	_expect(_rect_inside(galactic_lv3_effect.get_value_rect(), ACTIVE_FIELD), "Realistic Galactic local Lv3 width must clamp inside the active Play Field.")
	_expect(_is_decimal_digits_only(left_effect.value_label.text) and _is_decimal_digits_only(right_effect.value_label.text), "Largest edge-clamped output must remain digits-only.")
	left_effect.queue_free()
	right_effect.queue_free()
	galactic_lv3_effect.queue_free()
	await get_tree().process_frame


func _test_reduced_effects_and_cleanup(authoritative_amount: float, expected_digits: String) -> void:
	var reduced_effect := _create_effect(Vector2(800.0, 1200.0), authoritative_amount, true, 4)
	var reduced_profile: Dictionary = reduced_effect.get_visual_profile()
	_expect(reduced_effect.is_reduced_effects(), "Reduced Effects must reach the Cashout popup.")
	_expect(reduced_effect.value_label.text == expected_digits, "Reduced Effects must preserve the authoritative awarded amount.")
	_expect(int(reduced_profile["local_level"]) == 4 and int(reduced_profile["font_size"]) == EXPECTED_FONT_SIZES[4], "Reduced Effects must preserve local-tier numeric styling.")
	_expect(is_equal_approx(reduced_effect.lifetime, 0.38), "Reduced Effects must preserve the existing popup lifetime.")
	reduced_effect.set_process(false)
	reduced_effect._process(reduced_effect.lifetime)
	_expect(reduced_effect.is_queued_for_deletion(), "Cashout popup must deterministically queue cleanup at its lifetime.")
	await get_tree().process_frame
	_expect(not is_instance_valid(reduced_effect), "Cashout popup cleanup must leave no stale effect node.")


func _test_stage_local_level_mappings() -> void:
	var manager: EffectManager = EffectManagerScript.new()
	var simulation_source := FakeSimulationSource.new()
	var stage_catalog = StageCatalog.new()
	var reference_styles: Array[String] = ["", "", "", "", ""]
	add_child(manager)
	add_child(simulation_source)
	manager.set_simulation_source(simulation_source)
	for stage_index in range(3):
		var stage: StageDefinition = stage_catalog.get_stage(stage_index)
		simulation_source.local_ball_levels = stage.local_ball_levels.duplicate()
		manager._apply_stage_definition(stage)
		for local_level in range(5):
			manager.reset_runtime_fx()
			var global_level: int = stage.local_ball_levels[local_level]
			simulation_source.cashout_completed.emit(float(100 + local_level), global_level, Vector2(800.0, 700.0))
			var effect := _get_cashout_effect(manager)
			_expect(effect != null, "Every mapped Stage local level must create one accepted Cashout popup.")
			if effect == null:
				continue
			var profile: Dictionary = effect.get_visual_profile()
			_expect(int(profile["local_level"]) == local_level, "Ground, Planetary, and Galactic global levels must resolve through the current StageDefinition ordering.")
			var signature := _get_style_signature(profile)
			if stage_index == 0:
				reference_styles[local_level] = signature
			else:
				_expect(signature == reference_styles[local_level], "The same local level must reuse an identical Cashout font/color/outline/shadow style in every Stage.")

	manager.reset_runtime_fx()
	var ground_stage: StageDefinition = stage_catalog.get_stage(0)
	simulation_source.local_ball_levels = ground_stage.local_ball_levels.duplicate()
	manager._apply_stage_definition(ground_stage)
	simulation_source.cashout_completed.emit(100.0, 14, Vector2(800.0, 700.0))
	var fallback_effect := _get_cashout_effect(manager)
	_expect(fallback_effect != null, "A catalog-valid level outside the current Stage mapping must retain a safe numeric popup.")
	if fallback_effect != null:
		var fallback_profile: Dictionary = fallback_effect.get_visual_profile()
		_expect(int(fallback_profile["local_level"]) == 0, "A missing current-Stage mapping must fall back to readable local Lv0, not raw global/fx tier.")
		_expect(_get_style_signature(fallback_profile) == reference_styles[0], "Fallback must reuse the exact local Lv0 visual style.")

	manager.reset_runtime_fx()
	var count_before_invalid := manager.cashout_effect_count
	simulation_source.cashout_completed.emit(100.0, 999, Vector2(800.0, 700.0))
	_expect(manager.cashout_effect_count == count_before_invalid and manager.get_active_cashout_effect_count() == 0, "An invalid BallCatalog global level must keep the existing no-popup fallback behavior.")
	manager.queue_free()
	simulation_source.queue_free()
	await get_tree().process_frame


func _test_event_contract_and_budget(authoritative_amount: float, expected_digits: String) -> void:
	var manager: EffectManager = EffectManagerScript.new()
	var simulation_source := FakeSimulationSource.new()
	simulation_source.local_ball_levels = StageCatalog.new().get_stage(0).local_ball_levels.duplicate()
	add_child(manager)
	add_child(simulation_source)
	manager.set_simulation_source(simulation_source)
	_expect(_get_signal_argument_count(simulation_source, &"cashout_completed") == 3, "cashout_completed must keep its three-argument signature.")
	var forwarded := {"level": -1, "position": Vector2.ZERO}
	manager.cashout_effect_spawned.connect(func(global_level: int, world_position: Vector2) -> void:
		forwarded["level"] = global_level
		forwarded["position"] = world_position
	)
	var source_position := Vector2(1180.0, 1200.0)
	simulation_source.cashout_completed.emit(authoritative_amount, 3, source_position)
	_expect(manager.cashout_effect_count == 1 and manager.get_active_cashout_effect_count() == 1, "One accepted active Cashout event must create exactly one budgeted popup.")
	var effect := _get_cashout_effect(manager)
	_expect(effect != null, "Budgeted Cashout event must instantiate CashoutEffect.")
	if effect != null:
		_expect(effect.value_label.text == expected_digits, "EffectManager must forward the authoritative score value without inventing a replacement.")
		_expect(int(effect.get_visual_profile()["local_level"]) == 3, "Event global level must resolve to the current Stage local level before styling.")
		_expect(_rect_inside(effect.get_value_rect(), ACTIVE_FIELD), "EffectManager must use the simulation's read-only active Play Field for edge clamping.")
	_expect(int(forwarded["level"]) == 3 and Vector2(forwarded["position"]) == source_position, "Presentation spawn telemetry must preserve event level and original world position.")
	manager.set_reduced_effects(true)
	_expect(effect != null and effect.is_reduced_effects(), "Reduced Effects must update an already-active Cashout popup.")
	manager.reset_runtime_fx()
	_expect(manager.get_active_cashout_effect_count() == 0, "FX reset must release the active Cashout budget slot.")
	manager.queue_free()
	simulation_source.queue_free()
	await get_tree().process_frame


func _create_effect(world_position: Vector2, amount: float, reduced_effects: bool, local_level := 0) -> CashoutEffect:
	var effect: CashoutEffect = CashoutEffectScene.instantiate()
	add_child(effect)
	effect.setup(world_position, "FORBIDDEN BALL NAME", amount, Color("3a1a61"), local_level, ACTIVE_FIELD, reduced_effects)
	return effect


func _run_native_capture() -> void:
	if DisplayServer.get_name() == "headless":
		print("S4_G4_CASHOUT_CAPTURE_SKIPPED headless_renderer=true")
		return
	get_window().size = Vector2i(1600, 900)
	_build_capture_background()
	var comparison_amounts := [1.0e8, 5.0e10, 1.0e13, 5.0e17, 1.0e25]
	var comparison_anchors := [190.0, 320.0, 450.0, 580.0, 710.0]
	var comparison_effects: Array[CashoutEffect] = []
	for local_level in range(5):
		var effect := _create_effect(Vector2(800.0, comparison_anchors[local_level]), comparison_amounts[local_level], false, local_level)
		effect.set_process(false)
		effect._process(0.06)
		comparison_effects.append(effect)
	await _save_capture(COMPARISON_CAPTURE)
	for effect in comparison_effects:
		effect.queue_free()
	await get_tree().process_frame

	var edge_effect := _create_effect(Vector2(1180.0, 880.0), 1.0e25, false, 4)
	edge_effect.set_process(false)
	edge_effect._process(0.06)
	await _save_capture(EDGE_CAPTURE)
	print("S4_G4_CASHOUT_CAPTURE size=1600x900 comparison_active=5 edge_active=1 local_styles=0/1/2/3/4 fonts=18/19/20/21/22 lifetime=0.38 rise=18")
	edge_effect.queue_free()
	await get_tree().process_frame


func _build_capture_background() -> void:
	_add_color_rect(Rect2(0.0, 0.0, 1600.0, 900.0), Color("080a18"))
	_add_color_rect(Rect2(520.0, 50.0, 560.0, 800.0), Color("10192b"))
	for index in range(28):
		var x := 536.0 + float((index * 83) % 520)
		var y := 70.0 + float((index * 137) % 720)
		_add_color_rect(Rect2(x, y, 2.0, 2.0), Color("72d8ff") if index % 3 == 0 else Color("3a8dff"))
	var border := Color("3c6b64")
	_add_color_rect(Rect2(516.0, 46.0, 568.0, 4.0), border)
	_add_color_rect(Rect2(516.0, 850.0, 568.0, 4.0), border)
	_add_color_rect(Rect2(516.0, 50.0, 4.0, 800.0), border)
	_add_color_rect(Rect2(1080.0, 50.0, 4.0, 800.0), border)


func _add_color_rect(rect: Rect2, color: Color) -> void:
	var panel := ColorRect.new()
	panel.position = rect.position
	panel.size = rect.size
	panel.color = color
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(panel)
	move_child(panel, 0)


func _save_capture(file_name: String) -> void:
	await RenderingServer.frame_post_draw
	var directory_path := ProjectSettings.globalize_path(CAPTURE_DIRECTORY)
	DirAccess.make_dir_recursive_absolute(directory_path)
	var capture_path := "%s/%s" % [directory_path, file_name]
	var image := get_viewport().get_texture().get_image()
	var save_error := image.save_png(capture_path)
	_expect(image.get_size() == Vector2i(1600, 900), "Native Cashout capture must use the 1600x900 review canvas.")
	_expect(save_error == OK, "Native Cashout capture must save successfully.")
	print("S4_G4_CASHOUT_CAPTURE_FRAME path=%s save_error=%d" % [capture_path, save_error])


func _get_cashout_effect(manager: EffectManager) -> CashoutEffect:
	for child in manager.get_children():
		if child is CashoutEffect and StringName(child.get_meta("s6_event_key", &"")) == &"CASHOUT":
			return child
	return null


func _get_signal_argument_count(source: Object, signal_name: StringName) -> int:
	for signal_info in source.get_signal_list():
		if StringName(signal_info.get("name", &"")) == signal_name:
			return Array(signal_info.get("args", [])).size()
	return -1


func _get_style_signature(profile: Dictionary) -> String:
	var shadow_offset := Vector2i(profile["shadow_offset"])
	return "%d|%s|%d|%d,%d" % [
		int(profile["font_size"]),
		Color(profile["font_color"]).to_html(false),
		int(profile["outline_size"]),
		shadow_offset.x,
		shadow_offset.y,
	]


func _is_decimal_digits_only(value: String) -> bool:
	if value.is_empty():
		return false
	for index in range(value.length()):
		var code := value.unicode_at(index)
		if code < 48 or code > 57:
			return false
	return true


func _contains_forbidden_copy(value: String) -> bool:
	var upper := value.to_upper()
	return (
		upper.contains("CASH")
		or upper.contains("OUT")
		or upper.contains("BALL")
		or upper.contains("SCORE")
		or upper.contains("TIME")
		or upper.contains("DEBUG")
		or value.contains("+")
		or value.contains("-")
		or value.contains(".")
		or value.contains(",")
		or upper.contains("E")
	)


func _rect_inside(inner: Rect2, outer: Rect2) -> bool:
	return (
		inner.position.x >= outer.position.x
		and inner.position.y >= outer.position.y
		and inner.end.x <= outer.end.x
		and inner.end.y <= outer.end.y
	)


func _is_integer_vector(value: Vector2) -> bool:
	return is_equal_approx(value.x, roundf(value.x)) and is_equal_approx(value.y, roundf(value.y))


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S4-G4 Cashout presentation verification failed: %s" % message)
