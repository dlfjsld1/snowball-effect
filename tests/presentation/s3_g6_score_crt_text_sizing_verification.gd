extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const SCORE_LEDGER := preload("res://scripts/core/score_ledger.gd")
const SCORE_FORMATTER := preload("res://scripts/utils/score_formatter.gd")

const CRT_FONT_PATH := "res://assets/fonts/crt/crt_terminal_5x7.fnt"
const CRT_ATLAS_PATH := "res://assets/fonts/crt/crt_terminal_5x7.png"
const SCORE_CRT_ASSET_PATH := "res://assets/sprites/ui/frame/paper8_lab_v2/runtime/crt_score_v2_176x112.png"
const SCORE_SIGN_ASSET_PATH := "res://assets/sprites/ui/frame/paper8_lab_v2/runtime/score_sign_v1_84x24.png"
const SCORE_FORMATTER_PATH := "res://scripts/utils/score_formatter.gd"
const SCORE_CRT_ASSET_SHA256 := "9ad895b471bc83873b64bb1327140116b9fe778e6f24043e2ed9050965bcc27d"
const SCORE_SIGN_ASSET_SHA256 := "eb7880225e6e7594c602a73fc7ff8ca7b8de1032df01397c1062b2285d87aa40"
const SCORE_FORMATTER_SHA256 := "02590526487c764e33c9d71d16e785276e24f16f54408f0daf9ffa45806b9b16"

const SCORE_MASK_LOCAL_RECT := Rect2(42.0, 54.0, 110.0, 52.0)
const SCORE_LABEL_LOCAL_RECT := Rect2(44.0, 71.0, 106.0, 20.0)
const SCORE_SIGN_LOCAL_RECT := Rect2(55.0, 26.0, 84.0, 24.0)
const DISPLAY_SAFE_INSET := 2.0
const NATIVE_FONT_SIZE := 10
const CHOSEN_FONT_SIZE := 20
const REQUIRED_OUTPUTS := ["0", "400M", "4.00E+25", "1.00E+50"]
const ALLOWED_SCORE_CHARACTERS := "0123456789.KMBTE+-"

var _failures := 0


func _ready() -> void:
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	var hud: Hud = HUD_SCENE.instantiate()
	var ledger = SCORE_LEDGER.new()
	add_child(frame)
	add_child(ledger)
	add_child(hud)
	await get_tree().process_frame

	var score_label := hud.stage_score_label
	var stage_label := hud.stage_name_label
	var score_font := score_label.get_theme_font("font")
	var stage_font := stage_label.get_theme_font("font")
	var descriptor := FileAccess.get_file_as_string(CRT_FONT_PATH)
	var atlas := _load_png(CRT_ATLAS_PATH)
	var font_metrics := _read_bmfont_metrics(descriptor)

	_expect(score_font != null and score_font.resource_path == CRT_FONT_PATH, "StageScoreLabel must use the approved project-local CRT BMFont.")
	_expect(score_font == stage_font, "StageScoreLabel and StageNameLabel must use the exact same approved font resource.")
	_expect(score_label.get_theme_font_size("font_size") == CHOSEN_FONT_SIZE, "StageScoreLabel must use the approved Stage CRT 20px size.")
	_expect(score_label.get_theme_font_size("font_size") == stage_label.get_theme_font_size("font_size"), "SCORE and STAGE CRT text sizes must be exactly equal.")
	_expect(int(font_metrics["native_size"]) == NATIVE_FONT_SIZE, "The BMFont must retain its declared native 10px size.")
	_expect(int(font_metrics["line_height"]) == NATIVE_FONT_SIZE, "The native BMFont line cell must remain 10px high.")
	_expect(CHOSEN_FONT_SIZE / NATIVE_FONT_SIZE == 2 and CHOSEN_FONT_SIZE % NATIVE_FONT_SIZE == 0, "The 20px choice must be a crisp integer 2x scale.")
	_expect(atlas != null, "The verifier must read the actual CRT atlas pixels.")
	_expect(hud.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The HUD must retain nearest-neighbor sampling for CRT text.")
	_expect(score_label.texture_filter == CanvasItem.TEXTURE_FILTER_PARENT_NODE, "StageScoreLabel must inherit the HUD's nearest sampling without a fractional override.")
	_expect(score_label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "Required score outputs must remain horizontally centered.")

	var safe_local_rect := SCORE_MASK_LOCAL_RECT.grow(-DISPLAY_SAFE_INSET)
	_expect(safe_local_rect == Rect2(44.0, 56.0, 106.0, 48.0), "The actual 110x52 SCORE mask and 2px treatment inset must yield the exact 106x48 safe region.")
	_verify_required_output_formats()
	_verify_runtime_score_paths(hud, ledger)

	var final_margins := {}
	for profile in range(4):
		frame.set_profile(profile)
		var right_wing := frame.get_right_wing_rect()
		hud.apply_frame_layout(frame.get_left_wing_rect(), right_wing)
		var score_mask := _get_score_mask(frame)
		var safe_rect := score_mask.grow(-DISPLAY_SAFE_INSET)
		var label_rect := Rect2(score_label.position, score_label.size)
		_expect(score_mask == Rect2(right_wing.position + SCORE_MASK_LOCAL_RECT.position, SCORE_MASK_LOCAL_RECT.size), "Profile L%d must retain the fixed SCORE CRT mask geometry." % profile)
		_expect(safe_rect == Rect2(right_wing.position + safe_local_rect.position, safe_local_rect.size), "Profile L%d must expose the actual SCORE safe geometry." % profile)
		_expect(label_rect == Rect2(right_wing.position + SCORE_LABEL_LOCAL_RECT.position, SCORE_LABEL_LOCAL_RECT.size), "Profile L%d must use the ink-derived StageScoreLabel rect." % profile)
		_expect(right_wing.encloses(score_mask) and right_wing.encloses(label_rect), "Profile L%d SCORE mask and label must remain inside the right wing." % profile)
		_expect(safe_rect.encloses(label_rect), "Profile L%d StageScoreLabel rect must remain inside the SCORE safe region." % profile)
		_expect(label_rect.position == label_rect.position.round() and label_rect.size == label_rect.size.round(), "Profile L%d StageScoreLabel must use integer geometry." % profile)

		for output in REQUIRED_OUTPUTS:
			score_label.text = output
			var measured := _measure_text(score_font, atlas, output, CHOSEN_FONT_SIZE, font_metrics)
			var line_bounds := _measure_label_line_bounds(score_label, measured)
			var ink_bounds := _measure_label_ink_bounds(score_label, measured)
			var margins := {
				"left": ink_bounds.position.x - safe_rect.position.x,
				"right": safe_rect.end.x - ink_bounds.end.x,
				"top": ink_bounds.position.y - safe_rect.position.y,
				"bottom": safe_rect.end.y - ink_bounds.end.y,
			}
			final_margins = margins
			_expect(float(measured["line_width"]) <= safe_rect.size.x, "Profile L%d required output %s must fit the fixed SCORE safe width." % [profile, output])
			_expect(safe_rect.encloses(ink_bounds), "Profile L%d required output %s ink must remain inside the SCORE safe region." % [profile, output])
			_expect(is_equal_approx(line_bounds.get_center().x, safe_rect.get_center().x), "Profile L%d required output %s advance box must be horizontally centered." % [profile, output])
			_expect(absf(ink_bounds.get_center().x - safe_rect.get_center().x) <= 1.0, "Profile L%d required output %s actual ink must be horizontally centered within the BMFont trailing-gutter allowance." % [profile, output])
			_expect(absf(float(margins["top"]) - float(margins["bottom"])) <= 1.0, "Profile L%d required output %s actual top/bottom ink spacing must differ by at most 1px." % [profile, output])
			_expect(is_equal_approx(float(margins["top"]), 17.0) and is_equal_approx(float(margins["bottom"]), 17.0), "Profile L%d required output %s must realize the derived equal 17px vertical margins." % [profile, output])
		_verify_unchanged_score_placard(hud, right_wing, score_mask, profile)

	_expect(FileAccess.get_sha256(SCORE_CRT_ASSET_PATH) == SCORE_CRT_ASSET_SHA256, "The approved SCORE CRT shell must remain byte-for-byte unchanged.")
	_expect(FileAccess.get_sha256(SCORE_SIGN_ASSET_PATH) == SCORE_SIGN_ASSET_SHA256, "The approved SCORE placard must remain byte-for-byte unchanged.")
	_expect(FileAccess.get_sha256(SCORE_FORMATTER_PATH) == SCORE_FORMATTER_SHA256, "ScoreFormatter must remain byte-for-byte unchanged.")
	if _failures == 0:
		print("S3_G6_SCORE_CRT_TEXT_SIZING_VERIFIED font=20px stage_equal=true native=10px crisp_scale=2 mask=110x52 safe=106x48 label=106x20 required=0/400M/4.00E+25/1.00E+50 max_line=96 horizontal_centered=true vertical_margins=%d/%d profiles=L0/L1/L2/L3 nearest=true numeric_only=true settlement=countup/completion formatter_unchanged=true score_placard=unchanged" % [
			int(final_margins["top"]),
			int(final_margins["bottom"]),
		])
	get_tree().quit(_failures)


func _verify_required_output_formats() -> void:
	var source_outputs := [
		SCORE_FORMATTER.format_score(0.0),
		SCORE_FORMATTER.format_score(4.0e8),
		SCORE_FORMATTER.format_score(4.0e25),
		SCORE_FORMATTER.format_score(1.0e50),
	]
	_expect(source_outputs == ["0", "400M", "4.00e+25", "1.00e+50"], "ScoreFormatter's authoritative required outputs must remain unchanged.")
	for output in REQUIRED_OUTPUTS:
		_expect(_is_numeric_score_body(output), "Required SCORE body %s must remain numeric-only with approved suffix/scientific characters." % output)
		_expect(output == output.to_upper(), "Required SCORE body %s must retain uppercase scientific notation." % output)


func _verify_runtime_score_paths(hud: Hud, ledger: Node) -> void:
	hud.bind_sources(ledger, null)
	_expect(hud.stage_score_label.text == "0", "The normal zero-score path must render numeric-only 0.")
	ledger.apply_score_event(4.0e8)
	_expect(hud.stage_score_label.text == "400M", "A normal 400M score update must render the required centered body.")
	_expect(ledger.stage_score == 4.0e8 and ledger.run_score == 4.0e8, "HUD formatting must not change the authoritative normal Stage/Run values.")
	hud._on_score_changed(4.0e25, 4.0e25)
	_expect(hud.stage_score_label.text == "4.00E+25", "A normal scientific score update must render numeric-only uppercase E notation.")
	_expect(hud._authoritative_stage_score == 4.0e25 and hud._authoritative_run_score == 4.0e25, "Normal scientific formatting must retain its authoritative Presentation values.")
	_expect(ledger.stage_score == 4.0e8 and ledger.run_score == 4.0e8, "A direct scientific Presentation update must not mutate the authoritative ledger.")

	hud._on_score_changed(0.0, 0.0)
	hud._on_final_settlement_visual_started(0.5)
	hud._on_score_changed(1.0e50, 1.0e50)
	hud._process(0.25)
	var expected_midpoint := SCORE_FORMATTER.format_score(lerpf(0.0, 1.0e50, 0.5)).to_upper()
	_expect(hud.stage_score_label.text == expected_midpoint, "Final Settlement interpolation must use the numeric-only uppercase formatter path.")
	_expect(_is_numeric_score_body(hud.stage_score_label.text), "Final Settlement interpolation must remain a numeric-only SCORE body.")
	hud._on_final_settlement_presentation_finished()
	_expect(hud.stage_score_label.text == "1.00E+50", "Final Settlement completion must render the required authoritative 1.00E+50 value.")
	_expect(hud._authoritative_stage_score == 1.0e50 and hud._authoritative_run_score == 1.0e50, "Presentation interpolation/completion must preserve its authoritative values.")
	_expect(ledger.stage_score == 4.0e8 and ledger.run_score == 4.0e8, "Direct Presentation settlement paths must not mutate the authoritative ledger.")


func _measure_text(font: Font, atlas: Image, text: String, font_size: int, font_metrics: Dictionary) -> Dictionary:
	var native_size := int(font_metrics["native_size"])
	var scale := font_size / native_size
	var line_width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size).x
	var cursor_x := 0
	var ink_left := 1000000
	var ink_top := 1000000
	var ink_right := -1000000
	var ink_bottom := -1000000
	for character in text:
		var codepoint := character.unicode_at(0)
		var glyph: Dictionary = font_metrics["glyphs"].get(codepoint, {})
		_expect(not glyph.is_empty(), "The BMFont descriptor must own required character %s." % character)
		if glyph.is_empty():
			continue
		var opaque_bounds := _get_glyph_opaque_bounds(atlas, glyph)
		_expect(opaque_bounds.size.x > 0 and opaque_bounds.size.y > 0, "Required glyph %s must contain opaque rendered pixels." % character)
		ink_left = mini(ink_left, cursor_x + (int(glyph["xoffset"]) + opaque_bounds.position.x) * scale)
		ink_top = mini(ink_top, (int(glyph["yoffset"]) + opaque_bounds.position.y) * scale)
		ink_right = maxi(ink_right, cursor_x + (int(glyph["xoffset"]) + opaque_bounds.end.x) * scale)
		ink_bottom = maxi(ink_bottom, (int(glyph["yoffset"]) + opaque_bounds.end.y) * scale)
		cursor_x += int(glyph["xadvance"]) * scale
	_expect(is_equal_approx(line_width, float(cursor_x)), "%s Font.get_string_size must match actual descriptor advances at 20px." % text)
	return {
		"line_height": font.get_height(font_size),
		"line_width": line_width,
		"ink_bounds": Rect2(float(ink_left), float(ink_top), float(ink_right - ink_left), float(ink_bottom - ink_top)),
	}


func _measure_label_line_bounds(label: Label, measured: Dictionary) -> Rect2:
	var line_width := float(measured["line_width"])
	var line_height := float(measured["line_height"])
	return Rect2(
		Vector2(
			label.position.x + floorf((label.size.x - line_width) * 0.5),
			label.position.y + floorf((label.size.y - line_height) * 0.5)
		),
		Vector2(line_width, line_height)
	)


func _measure_label_ink_bounds(label: Label, measured: Dictionary) -> Rect2:
	var line_bounds := _measure_label_line_bounds(label, measured)
	var relative_ink := measured["ink_bounds"] as Rect2
	return Rect2(line_bounds.position + relative_ink.position, relative_ink.size)


func _read_bmfont_metrics(descriptor: String) -> Dictionary:
	var result := {
		"native_size": 0,
		"line_height": 0,
		"glyphs": {},
	}
	for line in descriptor.split("\n", false):
		if line.begins_with("info "):
			result["native_size"] = _read_int_field(line, "size")
		elif line.begins_with("common "):
			result["line_height"] = _read_int_field(line, "lineHeight")
		elif line.begins_with("char id="):
			var codepoint := _read_int_field(line, "id")
			result["glyphs"][codepoint] = {
				"x": _read_int_field(line, "x"),
				"y": _read_int_field(line, "y"),
				"width": _read_int_field(line, "width"),
				"height": _read_int_field(line, "height"),
				"xoffset": _read_int_field(line, "xoffset"),
				"yoffset": _read_int_field(line, "yoffset"),
				"xadvance": _read_int_field(line, "xadvance"),
			}
	return result


func _read_int_field(line: String, field_name: String) -> int:
	var marker := "%s=" % field_name
	var start := line.find(marker)
	if start < 0:
		return 0
	start += marker.length()
	var end := line.find(" ", start)
	if end < 0:
		end = line.length()
	return int(line.substr(start, end - start))


func _get_glyph_opaque_bounds(atlas: Image, glyph: Dictionary) -> Rect2i:
	var left := int(glyph["width"])
	var top := int(glyph["height"])
	var right := -1
	var bottom := -1
	for local_y in range(int(glyph["height"])):
		for local_x in range(int(glyph["width"])):
			var color := atlas.get_pixel(int(glyph["x"]) + local_x, int(glyph["y"]) + local_y)
			if roundi(color.a * 255.0) != 255:
				continue
			left = mini(left, local_x)
			top = mini(top, local_y)
			right = maxi(right, local_x)
			bottom = maxi(bottom, local_y)
	if right < left or bottom < top:
		return Rect2i()
	return Rect2i(left, top, right - left + 1, bottom - top + 1)


func _get_score_mask(frame: GameplayFrame) -> Rect2:
	for mask in frame.get_crt_surface_metrics()["masks"]:
		if mask["id"] == &"stage_score":
			return mask["mask_bounds"]
	_expect(false, "GameplayFrame must expose the Stage Score CRT mask.")
	return Rect2()


func _verify_unchanged_score_placard(hud: Hud, right_wing: Rect2, score_mask: Rect2, profile: int) -> void:
	var sign_rect := Rect2(hud.score_sign.position, hud.score_sign.size)
	var sign_plate := hud.get_node("ScoreSign/Plate") as TextureRect
	_expect(sign_rect == Rect2(right_wing.position + SCORE_SIGN_LOCAL_RECT.position, SCORE_SIGN_LOCAL_RECT.size), "Profile L%d must preserve the approved SCORE placard rect." % profile)
	_expect(hud.score_sign_label.text == "SCORE", "The dedicated SCORE placard text must stay unchanged.")
	_expect(hud.score_sign_label.get_theme_font_size("font_size") == NATIVE_FONT_SIZE, "The SCORE placard must stay at its approved native 10px size.")
	_expect(hud.score_sign.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST and sign_plate.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The SCORE placard must retain nearest sampling.")
	_expect(sign_plate.texture != null and sign_plate.texture.resource_path == SCORE_SIGN_ASSET_PATH, "The SCORE placard must retain its approved asset.")
	_expect(right_wing.encloses(sign_rect), "Profile L%d SCORE placard must remain inside the right wing." % profile)
	_expect(is_equal_approx(sign_rect.end.y + 4.0, score_mask.position.y), "Profile L%d SCORE placard must retain the approved 4px CRT gap." % profile)
	_expect(is_equal_approx(sign_rect.get_center().x, score_mask.get_center().x), "Profile L%d SCORE placard must remain centered over the CRT." % profile)


func _is_numeric_score_body(value: String) -> bool:
	if value.is_empty() or value.contains("STAGE") or value.contains("SCORE"):
		return false
	for character in value:
		if ALLOWED_SCORE_CHARACTERS.find(character) < 0:
			return false
	return true


func _load_png(path: String) -> Image:
	var image := Image.new()
	var error := image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	_expect(error == OK, "PNG evidence must decode: %s" % path)
	return image if error == OK else null


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G6 SCORE CRT text sizing verification failed: %s" % message)
