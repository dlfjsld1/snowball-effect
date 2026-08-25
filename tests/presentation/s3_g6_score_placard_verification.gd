extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const SCORE_LEDGER := preload("res://scripts/core/score_ledger.gd")
const SCORE_FORMATTER := preload("res://scripts/utils/score_formatter.gd")
const SCORE_SIGN_ASSET_PATH := "res://assets/sprites/ui/frame/paper8_lab_v2/runtime/score_sign_v1_84x24.png"
const SCORE_FORMATTER_PATH := "res://scripts/utils/score_formatter.gd"
const SCORE_FORMATTER_SHA256 := "02590526487c764e33c9d71d16e785276e24f16f54408f0daf9ffa45806b9b16"
const CRT_FONT_PATH := "res://assets/fonts/crt/crt_terminal_5x7.fnt"
const PAPER8_PALETTE_HEX := [
	"1f244b",
	"654053",
	"a8605d",
	"d1a67e",
	"f6e79c",
	"b6cf8e",
	"60ae7b",
	"3c6b64",
]

var _failures := 0


func _ready() -> void:
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	var hud: Hud = HUD_SCENE.instantiate()
	var ledger = SCORE_LEDGER.new()
	add_child(frame)
	add_child(ledger)
	add_child(hud)
	await get_tree().process_frame

	var sign := hud.get_node_or_null("ScoreSign") as Control
	var sign_plate := hud.get_node_or_null("ScoreSign/Plate") as TextureRect
	var sign_label := hud.get_node_or_null("ScoreSign/Label") as Label
	_expect(sign != null, "The HUD must mount one dedicated ScoreSign node.")
	_expect(sign_plate != null, "The ScoreSign must use a separate reusable plate texture.")
	_expect(sign_label != null, "The ScoreSign must keep its functional text in a Godot Label.")
	if sign != null and sign_plate != null and sign_label != null:
		_expect(sign_label.text == "SCORE", "The dedicated placard text must be exactly SCORE.")
		_expect(sign_label.get_theme_font("font").resource_path == CRT_FONT_PATH, "The placard must use the approved bold uppercase CRT font.")
		_expect(sign_label.get_theme_font_size("font_size") == 10, "The placard must use the bitmap font at its native integer size.")
		_expect(sign.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The placard root must use nearest sampling.")
		_expect(sign_plate.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The placard plate must use nearest sampling.")
		_expect(sign.position == sign.position.round() and sign.size == sign.size.round(), "The placard must use integer geometry.")
		_expect(sign_label.position == sign_label.position.round() and sign_label.size == sign_label.size.round(), "The placard label must use integer geometry.")
		_expect(sign_plate.position == sign_plate.position.round() and sign_plate.size == sign_plate.size.round(), "The placard texture must use integer geometry.")
		_expect(sign.size == Vector2(84.0, 24.0), "The SCORE placard must share STAGE's 84x24 native construction system.")
		_expect(sign_plate.size == sign.size, "The placard texture must render at native size without scaling.")
		_expect(sign_plate.texture != null and sign_plate.texture.resource_path == SCORE_SIGN_ASSET_PATH, "The placard node must use the dedicated project-local SCORE asset.")
		for profile in range(4):
			frame.set_profile(profile)
			var right_wing := frame.get_right_wing_rect()
			hud.apply_frame_layout(frame.get_left_wing_rect(), right_wing)
			var sign_bounds := Rect2(sign.position, sign.size)
			var score_crt_bounds := _get_crt_mask_bounds(frame, &"stage_score")
			_expect(right_wing.encloses(sign_bounds), "Profile L%d SCORE placard must remain inside the right frame." % profile)
			_expect(not sign_bounds.intersects(score_crt_bounds), "Profile L%d SCORE placard must not overlap the Stage Score CRT display." % profile)
			_expect(is_equal_approx(sign_bounds.end.y + 4.0, score_crt_bounds.position.y), "Profile L%d SCORE placard must retain the exact 4px gap above the CRT display." % profile)
			_expect(is_equal_approx(sign_bounds.get_center().x, score_crt_bounds.get_center().x), "Profile L%d SCORE placard must stay centered over the CRT display." % profile)
			_expect(sign_bounds.position == sign_bounds.position.round(), "Profile L%d SCORE placard position must remain pixel-aligned." % profile)
	_verify_score_sign_asset()

	_expect(hud.stage_score_label.text == "0", "The authored Stage Score CRT body must start with only the numeric score.")
	_expect(not _has_score_prefix(hud.stage_score_label.text), "The authored Stage Score CRT body must not contain a STAGE or SCORE prefix.")
	hud.bind_sources(ledger, null)
	ledger.apply_score_event(1234.0)
	_expect(hud.stage_score_label.text == SCORE_FORMATTER.format_score(1234.0).to_upper(), "Normal score updates must show only the shared formatted number.")
	_expect(not _has_score_prefix(hud.stage_score_label.text), "Normal score updates must not contain a STAGE or SCORE prefix.")
	_expect(ledger.stage_score == 1234.0 and ledger.run_score == 1234.0, "HUD formatting must not change authoritative score values.")

	var large_score := 4.0e25
	hud._on_score_changed(large_score, large_score)
	_expect(SCORE_FORMATTER.format_score(large_score) == "4.00e+25", "ScoreFormatter lowercase scientific source behavior must remain unchanged.")
	_expect(hud.stage_score_label.text == "4.00E+25", "The visible CRT must preserve its approved uppercase scientific notation.")
	_expect(not _has_score_prefix(hud.stage_score_label.text), "Large scientific score updates must not contain a STAGE or SCORE prefix.")

	hud._on_score_changed(0.0, 0.0)
	hud._on_final_settlement_visual_started(0.5)
	hud._on_score_changed(large_score, large_score)
	hud._process(0.25)
	var expected_midpoint := SCORE_FORMATTER.format_score(lerpf(0.0, large_score, 0.5)).to_upper()
	_expect(hud.stage_score_label.text == expected_midpoint, "Settlement count-up must show only the interpolated formatted number.")
	_expect(not _has_score_prefix(hud.stage_score_label.text), "Settlement count-up must not contain a STAGE or SCORE prefix.")
	hud._on_final_settlement_presentation_finished()
	_expect(hud.stage_score_label.text == "4.00E+25", "Settlement completion must show only the authoritative formatted number.")
	_expect(not _has_score_prefix(hud.stage_score_label.text), "Settlement completion must not contain a STAGE or SCORE prefix.")
	_expect(hud._authoritative_stage_score == large_score, "Presentation interpolation must retain the authoritative Stage Score value.")
	_expect(ledger.stage_score == 1234.0 and ledger.run_score == 1234.0, "Direct presentation paths must not mutate the authoritative ledger.")
	_expect(FileAccess.get_sha256(SCORE_FORMATTER_PATH) == SCORE_FORMATTER_SHA256, "The shared ScoreFormatter source must remain byte-for-byte unchanged.")

	if _failures == 0:
		print("S3_G6_SCORE_PLACARD_VERIFIED asset=84x24 grid=2x2 alpha=binary palette=paper8 text=SCORE profiles=L0/L1/L2/L3 gap=4px centered=true nearest=true score_body=numeric_only scientific=uppercase settlement=countup/completion formatter_unchanged=true authoritative_readonly=true")
	get_tree().quit(_failures)


func _verify_score_sign_asset() -> void:
	_expect(FileAccess.file_exists(SCORE_SIGN_ASSET_PATH), "The dedicated SCORE sign PNG must exist.")
	if not FileAccess.file_exists(SCORE_SIGN_ASSET_PATH):
		return
	var image := Image.new()
	var error := image.load_png_from_buffer(FileAccess.get_file_as_bytes(SCORE_SIGN_ASSET_PATH))
	_expect(error == OK, "The dedicated SCORE sign PNG must decode.")
	if error != OK:
		return
	_expect(image.get_size() == Vector2i(84, 24), "The dedicated SCORE sign asset must be exact 84x24.")
	var palette_valid := true
	var binary_alpha := true
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			var alpha_byte := roundi(pixel.a * 255.0)
			if alpha_byte != 0 and alpha_byte != 255:
				binary_alpha = false
			if alpha_byte == 255 and not PAPER8_PALETTE_HEX.has(pixel.to_html(false)):
				palette_valid = false
	_expect(binary_alpha, "The SCORE placard asset must use binary alpha without antialiasing fringe.")
	_expect(palette_valid, "Every opaque SCORE placard pixel must use the approved Paper 8 palette.")
	_expect(_uses_exact_two_by_two_grid(image), "Every SCORE placard detail must align to the enforced 2x2 authoring grid.")


func _uses_exact_two_by_two_grid(image: Image) -> bool:
	for y in range(0, image.get_height(), 2):
		for x in range(0, image.get_width(), 2):
			var block_color := image.get_pixel(x, y).to_rgba32()
			for offset_y in range(2):
				for offset_x in range(2):
					if image.get_pixel(x + offset_x, y + offset_y).to_rgba32() != block_color:
						return false
	return true


func _get_crt_mask_bounds(frame: GameplayFrame, mask_id: StringName) -> Rect2:
	for mask in frame.get_crt_surface_metrics()["masks"]:
		if mask["id"] == mask_id:
			return mask["mask_bounds"]
	_expect(false, "The GameplayFrame must expose the Stage Score CRT mask geometry.")
	return Rect2()


func _has_score_prefix(value: String) -> bool:
	return value.contains("STAGE") or value.contains("SCORE")


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G6 SCORE placard verification failed: %s" % message)
