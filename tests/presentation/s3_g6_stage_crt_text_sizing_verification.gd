extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const HUD_SCRIPT := preload("res://scripts/ui/hud.gd")
const STAGE_CATALOG := preload("res://scripts/data/stage_catalog.gd")
const CRT_FONT_PATH := "res://assets/fonts/crt/crt_terminal_5x7.fnt"
const CRT_ATLAS_PATH := "res://assets/fonts/crt/crt_terminal_5x7.png"
const STAGE_CRT_ASSET_PATH := "res://assets/sprites/ui/frame/paper8_lab_v2/runtime/crt_stage_v2_176x108.png"
const STAGE_SIGN_ASSET_PATH := "res://assets/sprites/ui/frame/paper8_lab_v2/runtime/stage_sign_v1_84x24.png"
const STAGE_CRT_ASSET_SHA256 := "2c500fefac6c7255f860368285cc37db95e8b7d1273a7030954280addaff23f2"
const STAGE_SIGN_ASSET_SHA256 := "eb7880225e6e7594c602a73fc7ff8ca7b8de1032df01397c1062b2285d87aa40"
const EXPECTED_STAGE_NAMES := ["GROUND", "PLANETARY", "GALACTIC"]
const SIZING_AUTHORITY := "PLANETARY"
const STAGE_MASK_LOCAL_RECT := Rect2(32.0, 54.0, 136.0, 56.0)
const DISPLAY_SAFE_INSET := 2.0
const NATIVE_FONT_SIZE := 10
const CHOSEN_FONT_SIZE := 20
const NEXT_CRISP_FONT_SIZE := 30
const REPRESENTATIVE_CHARACTER := "M"

var _failures := 0


func _ready() -> void:
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	var hud: Hud = HUD_SCENE.instantiate()
	add_child(frame)
	add_child(hud)
	await get_tree().process_frame

	var font := hud.stage_name_label.get_theme_font("font")
	var descriptor := FileAccess.get_file_as_string(CRT_FONT_PATH)
	var atlas := _load_png(CRT_ATLAS_PATH)
	var font_metrics := _read_bmfont_metrics(descriptor)
	_expect(font != null and font.resource_path == CRT_FONT_PATH, "The Stage name must keep the approved project-local CRT BMFont.")
	_expect(atlas != null, "The Stage sizing oracle must read the actual CRT atlas pixels.")
	_expect(int(font_metrics["native_size"]) == NATIVE_FONT_SIZE, "The crisp scale must derive from the BMFont's declared native 10px size.")
	_expect(int(font_metrics["line_height"]) == NATIVE_FONT_SIZE, "The BMFont line height must remain one native 10px cell.")
	_expect(hud.stage_name_label.get_theme_font_size("font_size") == CHOSEN_FONT_SIZE, "The Stage name must use the derived 20px crisp size.")
	_expect(CHOSEN_FONT_SIZE > NATIVE_FONT_SIZE, "The refined Stage name must be larger than the former 10px size.")
	_expect(_is_crisp_size(CHOSEN_FONT_SIZE, font_metrics), "The chosen size must scale every atlas pixel by an integer factor.")
	_expect(_is_crisp_size(NEXT_CRISP_FONT_SIZE, font_metrics), "The maximality comparison must use the next permissible crisp scale.")
	for intervening_size in range(CHOSEN_FONT_SIZE + 1, NEXT_CRISP_FONT_SIZE):
		_expect(not _is_crisp_size(intervening_size, font_metrics), "%dpx must be rejected because it fractionally scales the 10px bitmap source." % intervening_size)
	_expect(hud.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The Stage CRT text must inherit nearest-neighbor sampling.")
	_expect(hud.stage_name_label.horizontal_alignment == HORIZONTAL_ALIGNMENT_CENTER, "All Stage names must stay horizontally centered.")
	_expect(hud.stage_name_label.vertical_alignment == VERTICAL_ALIGNMENT_CENTER, "The measured line box must retain centered Label alignment.")

	var safe_local_rect := STAGE_MASK_LOCAL_RECT.grow(-DISPLAY_SAFE_INSET)
	_expect(safe_local_rect == Rect2(34.0, 56.0, 132.0, 52.0), "The fixed 136x56 Stage mask and its treatment-defined 2px inset must yield the exact 132x52 safe region.")
	var authority_metrics := _measure_text(font, atlas, SIZING_AUTHORITY, CHOSEN_FONT_SIZE, font_metrics)
	var next_metrics := _measure_text(font, atlas, SIZING_AUTHORITY, NEXT_CRISP_FONT_SIZE, font_metrics)
	var representative_advance := font.get_char_size(REPRESENTATIVE_CHARACTER.unicode_at(0), CHOSEN_FONT_SIZE).x
	var next_representative_advance := font.get_char_size(REPRESENTATIVE_CHARACTER.unicode_at(0), NEXT_CRISP_FONT_SIZE).x
	_expect(is_equal_approx(float(authority_metrics["line_width"]), 108.0), "PLANETARY must measure 108px from the actual 20px BMFont advances.")
	_expect(is_equal_approx(representative_advance, 12.0), "One representative 20px CRT character must advance exactly 12px.")
	_expect(is_equal_approx(float(authority_metrics["line_width"]) + representative_advance * 2.0, safe_local_rect.size.x), "PLANETARY plus one representative advance on each side must exactly consume the 132px safe width.")
	_expect(float((authority_metrics["ink_bounds"] as Rect2).size.x) + representative_advance * 2.0 <= safe_local_rect.size.x, "The actual PLANETARY ink plus two representative advances must fit the safe width.")
	_expect(float(next_metrics["line_width"]) + next_representative_advance * 2.0 > safe_local_rect.size.x, "The next crisp 30px step must fail the same one-character-per-side invariant.")

	var stage_catalog = STAGE_CATALOG.new()
	var measured_widths: Array[float] = []
	for stage_index in range(EXPECTED_STAGE_NAMES.size()):
		var definition: StageDefinition = stage_catalog.get_stage(stage_index)
		hud._on_stage_changed(definition)
		var expected_name: String = EXPECTED_STAGE_NAMES[stage_index]
		_expect(hud.stage_name_label.text == expected_name, "The Stage CRT must retain the exact uppercase %s name." % expected_name)
		var measured := _measure_text(font, atlas, expected_name, CHOSEN_FONT_SIZE, font_metrics)
		measured_widths.append(float(measured["line_width"]))
		_expect(float(measured["line_width"]) + representative_advance * 2.0 <= safe_local_rect.size.x, "%s plus one character of capacity on each side must fit." % expected_name)
	_expect(measured_widths[1] > measured_widths[0] and measured_widths[1] > measured_widths[2], "PLANETARY must be the unique longest Stage label and sizing authority.")

	hud._on_stage_changed(stage_catalog.get_stage(1))
	var final_margins := {}
	for profile in range(4):
		frame.set_profile(profile)
		var left_wing := frame.get_left_wing_rect()
		hud.apply_frame_layout(left_wing, frame.get_right_wing_rect())
		var stage_mask := _get_stage_mask(frame)
		var safe_rect := stage_mask.grow(-DISPLAY_SAFE_INSET)
		var label_rect := Rect2(hud.stage_name_label.position, hud.stage_name_label.size)
		var rendered_bounds := _measure_label_ink_bounds(hud.stage_name_label, authority_metrics)
		var line_bounds := _measure_label_line_bounds(hud.stage_name_label, authority_metrics)
		var margins := {
			"left": rendered_bounds.position.x - safe_rect.position.x,
			"right": safe_rect.end.x - rendered_bounds.end.x,
			"top": rendered_bounds.position.y - safe_rect.position.y,
			"bottom": safe_rect.end.y - rendered_bounds.end.y,
		}
		final_margins = margins
		_expect(stage_mask == Rect2(left_wing.position + STAGE_MASK_LOCAL_RECT.position, STAGE_MASK_LOCAL_RECT.size), "Profile L%d must retain the fixed Stage CRT mask geometry." % profile)
		_expect(left_wing.encloses(stage_mask) and left_wing.encloses(label_rect), "Profile L%d Stage mask and text rect must remain inside the left frame." % profile)
		_expect(safe_rect.encloses(label_rect), "Profile L%d StageNameLabel rect must remain inside the 2px-safe CRT region." % profile)
		_expect(safe_rect.encloses(rendered_bounds), "Profile L%d measured PLANETARY pixels must remain inside the safe region." % profile)
		_expect(label_rect.position == label_rect.position.round() and label_rect.size == label_rect.size.round(), "Profile L%d StageNameLabel must use integer geometry." % profile)
		_expect(is_equal_approx(line_bounds.get_center().x, safe_rect.get_center().x), "Profile L%d PLANETARY advance box must be horizontally centered." % profile)
		_expect(absf(rendered_bounds.get_center().x - safe_rect.get_center().x) <= 1.0, "Profile L%d actual PLANETARY ink must be centered within the trailing-gutter rounding allowance." % profile)
		_expect(float(margins["left"]) >= representative_advance and float(margins["right"]) >= representative_advance, "Profile L%d actual ink must retain at least one representative advance on each side." % profile)
		_expect(absf(float(margins["top"]) - float(margins["bottom"])) <= 1.0, "Profile L%d measured glyph top/bottom spacing must differ by at most 1px." % profile)
		_expect(is_equal_approx(float(margins["top"]), 19.0) and is_equal_approx(float(margins["bottom"]), 19.0), "Profile L%d must realize the derived equal 19px glyph margins." % profile)
		_verify_unchanged_stage_placard(hud, left_wing, stage_mask, profile)

	_expect(FileAccess.get_sha256(STAGE_CRT_ASSET_PATH) == STAGE_CRT_ASSET_SHA256, "The Stage CRT shell must remain byte-for-byte unchanged.")
	_expect(FileAccess.get_sha256(STAGE_SIGN_ASSET_PATH) == STAGE_SIGN_ASSET_SHA256, "The approved STAGE placard asset must remain byte-for-byte unchanged.")
	if _failures == 0:
		print("S3_G6_STAGE_CRT_TEXT_SIZING_VERIFIED authority=PLANETARY font=20px native=10px crisp_scale=2 safe=132x52 line_width=108 ink=106x14 representative_advance=12 horizontal_margins=%d/%d vertical_margins=%d/%d next_crisp=30px next_required=198 profiles=L0/L1/L2/L3 centered=true nearest=true stage_placard=unchanged" % [
			int(final_margins["left"]),
			int(final_margins["right"]),
			int(final_margins["top"]),
			int(final_margins["bottom"]),
		])
	get_tree().quit(_failures)


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
		_expect(not glyph.is_empty(), "The BMFont descriptor must own %s." % character)
		if glyph.is_empty():
			continue
		var opaque_bounds := _get_glyph_opaque_bounds(atlas, glyph)
		_expect(opaque_bounds.size.x > 0 and opaque_bounds.size.y > 0, "The atlas glyph %s must contain opaque rendered pixels." % character)
		ink_left = mini(ink_left, cursor_x + (int(glyph["xoffset"]) + opaque_bounds.position.x) * scale)
		ink_top = mini(ink_top, (int(glyph["yoffset"]) + opaque_bounds.position.y) * scale)
		ink_right = maxi(ink_right, cursor_x + (int(glyph["xoffset"]) + opaque_bounds.end.x) * scale)
		ink_bottom = maxi(ink_bottom, (int(glyph["yoffset"]) + opaque_bounds.end.y) * scale)
		cursor_x += int(glyph["xadvance"]) * scale
	_expect(is_equal_approx(line_width, float(cursor_x)), "%s Font.get_string_size must match the descriptor's actual glyph advances at %dpx." % [text, font_size])
	return {
		"font_size": font_size,
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


func _is_crisp_size(font_size: int, font_metrics: Dictionary) -> bool:
	var native_size := int(font_metrics["native_size"])
	return native_size > 0 and font_size % native_size == 0


func _get_stage_mask(frame: GameplayFrame) -> Rect2:
	for mask in frame.get_crt_surface_metrics()["masks"]:
		if mask["id"] == &"stage":
			return mask["mask_bounds"]
	_expect(false, "GameplayFrame must expose the Stage CRT mask.")
	return Rect2()


func _verify_unchanged_stage_placard(hud: Hud, left_wing: Rect2, stage_mask: Rect2, profile: int) -> void:
	var sign_rect := Rect2(hud.stage_sign.position, hud.stage_sign.size)
	_expect(sign_rect == Rect2(left_wing.position + HUD_SCRIPT.STAGE_SIGN_LOCAL_RECT.position, HUD_SCRIPT.STAGE_SIGN_LOCAL_RECT.size), "Profile L%d must preserve the approved STAGE placard rect." % profile)
	_expect(hud.stage_sign_label.text == "STAGE", "The dedicated STAGE placard text must stay unchanged.")
	_expect(hud.stage_sign_label.get_theme_font_size("font_size") == NATIVE_FONT_SIZE, "The STAGE placard must stay at its approved native 10px size.")
	_expect(hud.stage_sign.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The STAGE placard must retain nearest sampling.")
	_expect(is_equal_approx(sign_rect.end.y + 4.0, stage_mask.position.y), "Profile L%d must retain the approved 4px placard-to-CRT gap." % profile)


func _load_png(path: String) -> Image:
	var image := Image.new()
	var error := image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	_expect(error == OK, "PNG evidence must decode: %s" % path)
	return image if error == OK else null


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G6 Stage CRT text sizing verification failed: %s" % message)
