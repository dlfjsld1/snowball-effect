extends Node

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const STAGE_CATALOG := preload("res://scripts/data/stage_catalog.gd")
const CRT_FONT_PATH := "res://assets/fonts/crt/crt_terminal_5x7.fnt"
const CRT_ATLAS_PATH := "res://assets/fonts/crt/crt_terminal_5x7.png"
const PAUSE_RETRY_REFERENCE_PATH := "res://assets/sprites/ui/frame/paper8_lab_v2/runtime/crt_pause_b_v2_176x104.png"
const CRT_FONT_SHA256 := "091e4ebe230d34ac91a8a7ef893f0ec8154de9acea165a78dff20c5fa43c5c38"
const CRT_ATLAS_SHA256 := "f4dbda3f70d4bbea5955390005531b4b8464ebcbec490fbd288f1da3b76c8f85"
const PAUSE_RETRY_REFERENCE_SHA256 := "5ac15800958b3c94f420eaba9c3e29fe8a1ebd0790361758ad6757732f1613b8"
const CRT_FONT_SIZE := 10
const PRIMARY_CRT_FONT_SIZE := 20
const TIME_FONT_SIZE := 10
const CRT_ATLAS_SIZE := Vector2i(96, 48)
const GLYPH_CELL_SIZE := Vector2i(6, 8)
const GLYPH_DRAW_SIZE := Vector2i(5, 7)
const ASCII_FIRST := 32
const ASCII_LAST := 126
const THICK_STROKE_GLYPHS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"

var _failures := 0


func _ready() -> void:
	var hud: Hud = HUD_SCENE.instantiate()
	add_child(hud)

	var expected_font := load(CRT_FONT_PATH) as Font
	_expect(expected_font != null, "The visible CRT HUD must use a project-local pixel font resource.")
	_expect(expected_font != null and not expected_font is SystemFont, "The CRT font must not resolve through SystemFont.")
	_expect(FileAccess.get_sha256(CRT_FONT_PATH) == CRT_FONT_SHA256, "The BMFont descriptor identity must stay deterministic.")
	_expect(FileAccess.get_sha256(CRT_ATLAS_PATH) == CRT_ATLAS_SHA256, "The bold 5x7 atlas identity must stay deterministic.")
	_expect(FileAccess.get_sha256(PAUSE_RETRY_REFERENCE_PATH) == PAUSE_RETRY_REFERENCE_SHA256, "The baked PAUSE/RETRY lettering must remain the CRT stroke-weight authority.")
	var descriptor := FileAccess.get_file_as_string(CRT_FONT_PATH)
	_expect(descriptor.contains("smooth=0 aa=0"), "The bitmap font descriptor must disable smoothing and antialiasing.")
	_expect(descriptor.contains("size=10 bold=1"), "The BMFont descriptor must identify the project-local bold face.")
	_expect(descriptor.contains("page id=0 file=\"crt_terminal_5x7.png\""), "The BMFont must use the project-local bitmap atlas page.")
	_expect(descriptor.count("width=5 height=7 xoffset=0 yoffset=1 xadvance=6") == 94, "Every non-space ASCII glyph must stay inside a 5x7 draw box with a 1px advance gutter.")
	var import_contract := FileAccess.get_file_as_string("%s.import" % CRT_FONT_PATH)
	_expect(import_contract.contains("fallbacks=[]"), "The imported BMFont must declare an empty fallback chain.")
	for codepoint in range(ASCII_FIRST, ASCII_LAST + 1):
		_expect(expected_font != null and expected_font.has_char(codepoint), "The CRT font must own visible ASCII U+%04X without fallback." % codepoint)
	var atlas := _load_png(CRT_ATLAS_PATH)
	_expect(atlas != null and atlas.get_size() == CRT_ATLAS_SIZE, "The bold CRT atlas must retain its deterministic 96x48 cell grid.")
	var atlas_metrics := _verify_bold_atlas(atlas)
	var reference := _load_png(PAUSE_RETRY_REFERENCE_PATH)
	var reference_blocks := _count_reference_two_by_two_blocks(reference)
	_expect(reference != null and reference_blocks >= 10, "The baked PAUSE/RETRY authority must retain fully filled 2x2 pixel stroke blocks.")
	_expect(int(atlas_metrics["thick_glyphs"]) == THICK_STROKE_GLYPHS.length(), "Every uppercase and numeric runtime glyph must contain fully opaque 2x2 stroke blocks.")
	var visible_crt_labels: Array[Label] = [
		hud.stage_sign_label,
		hud.score_sign_label,
		hud.stage_name_label,
		hud.time_label,
		hud.stage_score_label,
		hud.genealogy_title,
	]
	visible_crt_labels.append_array(hud.genealogy_slots)
	for label in visible_crt_labels:
		var label_font := label.get_theme_font("font")
		_expect(label_font == expected_font, "%s must share the deterministic CRT pixel font identity." % label.name)
		_expect(label_font != null and label_font.resource_path == CRT_FONT_PATH, "%s must not fall back to an OS/default font." % label.name)
		var expected_size := CRT_FONT_SIZE
		if label in [hud.stage_name_label, hud.stage_score_label]:
			expected_size = PRIMARY_CRT_FONT_SIZE
		elif label == hud.time_label:
			expected_size = TIME_FONT_SIZE
		_expect(label.get_theme_font_size("font_size") == expected_size, "%s must render at its approved integer bitmap scale." % label.name)

	var stage_catalog = STAGE_CATALOG.new()
	var uppercase_strings := 0
	for stage_index in range(3):
		var stage_definition: StageDefinition = stage_catalog.get_stage(stage_index)
		var source_stage_name := stage_definition.display_name
		hud._on_stage_changed(stage_definition)
		_expect(hud.stage_sign_label.text == "STAGE", "The dedicated machine placard must own the STAGE heading.")
		_expect(hud.score_sign_label.text == "SCORE", "The paired machine placard must own the SCORE heading.")
		_expect(hud.stage_name_label.text == source_stage_name.to_upper(), "The Stage CRT must contain only the uppercase Stage name.")
		_expect(not hud.stage_name_label.text.contains("STAGE"), "The Stage CRT must not repeat the dedicated placard heading.")
		_expect(stage_definition.display_name == source_stage_name, "Uppercase CRT rendering must not mutate authoritative Stage data.")
		uppercase_strings += 1
		for local_level in range(stage_definition.local_ball_levels.size()):
			if local_level > 0:
				hud._on_ball_merged(stage_definition.local_ball_levels[local_level], Vector2.ZERO)
			var ball_definition = hud._ball_catalog.get_definition(stage_definition.local_ball_levels[local_level])
			var source_ball_name: String = ball_definition.display_name
			_expect(hud.genealogy_slots[local_level].text == source_ball_name.to_upper(), "Every runtime BallCatalog name must enter the genealogy CRT in uppercase.")
			_expect(hud.genealogy_slots[local_level].text == hud.genealogy_slots[local_level].text.to_upper(), "No mixed lowercase may remain in a visible genealogy label.")
			_expect(ball_definition.display_name == source_ball_name, "Uppercase CRT rendering must not mutate authoritative BallCatalog data.")
			_expect_visible_crt_uppercase(visible_crt_labels)
			uppercase_strings += 1
	hud._on_score_changed(4.0e25, 7.0e25)
	_expect_visible_crt_uppercase(visible_crt_labels)
	hud._on_final_settlement_visual_started(0.5)
	hud._process(0.25)
	_expect_visible_crt_uppercase(visible_crt_labels)
	hud._on_final_settlement_presentation_finished()
	for label in visible_crt_labels:
		_expect(label.text == label.text.to_upper(), "%s must expose uppercase player-visible CRT output." % label.name)

	for hidden_label in [hud.run_score_label, hud.clear_target_label, hud.ball_count_label]:
		_expect(hidden_label.get_theme_font("font") != expected_font, "%s is hidden/non-CRT and must stay outside this visual-only font change." % hidden_label.name)

	if _failures == 0:
		print("S3_G6_CRT_PIXEL_FONT_VERIFIED resource=%s labels=%d glyphs=95 atlas=96x48 native_size=10 stage_name_size=20 stage_score_size=20 time_size=10 crisp_scale=2 stroke=opaque_2px thick_glyphs=%d opaque_pixels=%d partial_alpha=0 reference_2x2=%d gutters=clear uppercase_strings=%d system_fallback=false hidden_excluded=3" % [CRT_FONT_PATH, visible_crt_labels.size(), atlas_metrics["thick_glyphs"], atlas_metrics["opaque_pixels"], reference_blocks, uppercase_strings])
	get_tree().quit(_failures)


func _verify_bold_atlas(atlas: Image) -> Dictionary:
	var opaque_pixels := 0
	var partial_alpha_pixels := 0
	for y in range(atlas.get_height()):
		for x in range(atlas.get_width()):
			var alpha_byte := roundi(atlas.get_pixel(x, y).a * 255.0)
			if alpha_byte == 255:
				opaque_pixels += 1
			elif alpha_byte != 0:
				partial_alpha_pixels += 1
	_expect(opaque_pixels > 0, "The bold atlas must contain fully opaque glyph pixels.")
	_expect(partial_alpha_pixels == 0, "Nearest-neighbor CRT glyphs must not rely on translucent shoulder pixels for stroke weight.")
	for cell_y in range(floori(float(CRT_ATLAS_SIZE.y) / float(GLYPH_CELL_SIZE.y))):
		for cell_x in range(floori(float(CRT_ATLAS_SIZE.x) / float(GLYPH_CELL_SIZE.x))):
			var origin := Vector2i(cell_x * GLYPH_CELL_SIZE.x, cell_y * GLYPH_CELL_SIZE.y)
			for draw_y in range(GLYPH_DRAW_SIZE.y):
				_expect(atlas.get_pixel(origin.x + GLYPH_DRAW_SIZE.x, origin.y + draw_y).a == 0.0, "Glyph cell (%d,%d) must retain its transparent inter-character gutter." % [cell_x, cell_y])
			for draw_x in range(GLYPH_CELL_SIZE.x):
				_expect(atlas.get_pixel(origin.x + draw_x, origin.y + GLYPH_DRAW_SIZE.y).a == 0.0, "Glyph cell (%d,%d) must retain its transparent line gutter." % [cell_x, cell_y])
	var thick_glyphs := 0
	for character in THICK_STROKE_GLYPHS:
		var block_count := _count_glyph_opaque_two_by_two_blocks(atlas, character.unicode_at(0))
		_expect(block_count >= 3, "Glyph %s must contain at least three fully opaque 2x2 stroke blocks, not metadata-only bolding." % character)
		if block_count >= 3:
			thick_glyphs += 1
	_expect(_count_glyph_opaque_two_by_two_blocks(atlas, ".".unicode_at(0)) >= 1, "The decimal point used by TIME must be a fully opaque 2x2 pixel mark.")
	return {
		"opaque_pixels": opaque_pixels,
		"partial_alpha_pixels": partial_alpha_pixels,
		"thick_glyphs": thick_glyphs,
	}


func _load_png(path: String) -> Image:
	var image := Image.new()
	var error := image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
	_expect(error == OK, "PNG evidence must decode from project-local bytes: %s" % path)
	return image


func _count_glyph_opaque_two_by_two_blocks(atlas: Image, codepoint: int) -> int:
	var count := 0
	var glyph_index := codepoint - ASCII_FIRST
	var origin := Vector2i((glyph_index % 16) * GLYPH_CELL_SIZE.x, floori(float(glyph_index) / 16.0) * GLYPH_CELL_SIZE.y)
	for y in range(GLYPH_DRAW_SIZE.y - 1):
		for x in range(GLYPH_DRAW_SIZE.x - 1):
			if (
				_is_opaque(atlas.get_pixel(origin.x + x, origin.y + y))
				and _is_opaque(atlas.get_pixel(origin.x + x + 1, origin.y + y))
				and _is_opaque(atlas.get_pixel(origin.x + x, origin.y + y + 1))
				and _is_opaque(atlas.get_pixel(origin.x + x + 1, origin.y + y + 1))
			):
				count += 1
	return count


func _count_reference_two_by_two_blocks(reference: Image) -> int:
	var count := 0
	for rect in [Rect2i(37, 53, 26, 7), Rect2i(111, 53, 27, 7)]:
		for y in range(rect.position.y, rect.end.y - 1):
			for x in range(rect.position.x, rect.end.x - 1):
				if (
					_is_reference_letter_pixel(reference.get_pixel(x, y))
					and _is_reference_letter_pixel(reference.get_pixel(x + 1, y))
					and _is_reference_letter_pixel(reference.get_pixel(x, y + 1))
					and _is_reference_letter_pixel(reference.get_pixel(x + 1, y + 1))
				):
					count += 1
	return count


func _is_opaque(color: Color) -> bool:
	return roundi(color.a * 255.0) == 255


func _is_reference_letter_pixel(color: Color) -> bool:
	return color.g >= 90.0 / 255.0 and color.g > color.r + 10.0 / 255.0 and color.g > color.b + 10.0 / 255.0


func _expect_visible_crt_uppercase(labels: Array[Label]) -> void:
	for label in labels:
		_expect(label.text == label.text.to_upper(), "%s must stay uppercase after every runtime text update path." % label.name)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G6 CRT pixel font verification failed: %s" % message)
