extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const STAGE_CATALOG := preload("res://scripts/data/stage_catalog.gd")
const STAGE_SIGN_ASSET_PATH := "res://assets/sprites/ui/frame/paper8_lab_v2/runtime/stage_sign_v1_84x24.png"
const CRT_FONT_PATH := "res://assets/fonts/crt/crt_terminal_5x7.fnt"
const EXPECTED_STAGE_SOURCE_NAMES := ["Ground", "Planetary", "Galactic"]
const EXPECTED_STAGE_CRT_NAMES := ["GROUND", "PLANETARY", "GALACTIC"]
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
	add_child(frame)
	add_child(hud)
	await get_tree().process_frame

	var sign := hud.get_node_or_null("StageSign") as Control
	var sign_plate := hud.get_node_or_null("StageSign/Plate") as TextureRect
	var sign_label := hud.get_node_or_null("StageSign/Label") as Label
	_expect(sign != null, "The HUD must mount one dedicated StageSign node.")
	_expect(sign_plate != null, "The StageSign must use a separate reusable plate texture.")
	_expect(sign_label != null, "The StageSign must keep its functional text in a Godot Label.")
	if sign == null or sign_plate == null or sign_label == null:
		get_tree().quit(_failures)
		return

	_expect(sign_label.text == "STAGE", "The dedicated placard text must be exactly STAGE.")
	_expect(sign_label.get_theme_font("font").resource_path == CRT_FONT_PATH, "The placard must use the approved bold uppercase CRT font.")
	_expect(sign_label.get_theme_font_size("font_size") == 10, "The placard must use the bitmap font at its native integer size.")
	_expect(sign.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The placard root must use nearest sampling.")
	_expect(sign_plate.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "The placard plate must use nearest sampling.")
	_expect(sign.position == sign.position.round() and sign.size == sign.size.round(), "The placard must use integer geometry.")
	_expect(sign_label.position == sign_label.position.round() and sign_label.size == sign_label.size.round(), "The placard label must use integer geometry.")
	_expect(sign_plate.position == sign_plate.position.round() and sign_plate.size == sign_plate.size.round(), "The placard texture must use integer geometry.")
	_expect(sign.size == Vector2(84.0, 24.0), "The placard must retain its purpose-built 84x24 native size.")
	_expect(sign_plate.size == sign.size, "The placard texture must render at native size without scaling.")
	_expect(sign_plate.texture != null and sign_plate.texture.resource_path == STAGE_SIGN_ASSET_PATH, "The placard node must use the dedicated project-local asset.")
	_verify_stage_sign_asset()

	for profile in range(4):
		frame.set_profile(profile)
		var left_wing := frame.get_left_wing_rect()
		hud.apply_frame_layout(left_wing, frame.get_right_wing_rect())
		var sign_bounds := Rect2(sign.position, sign.size)
		var stage_crt_bounds := _get_crt_mask_bounds(frame, &"stage")
		_expect(left_wing.encloses(sign_bounds), "Profile L%d placard must remain inside the left frame." % profile)
		_expect(not sign_bounds.intersects(stage_crt_bounds), "Profile L%d placard must not overlap the Stage CRT display." % profile)
		_expect(is_equal_approx(sign_bounds.end.y + 4.0, stage_crt_bounds.position.y), "Profile L%d placard must retain the exact 4px attachment gap above the Stage CRT display." % profile)
		_expect(sign_bounds.position == sign_bounds.position.round(), "Profile L%d placard position must remain pixel-aligned." % profile)

	var stage_catalog = STAGE_CATALOG.new()
	for stage_index in range(EXPECTED_STAGE_SOURCE_NAMES.size()):
		var definition: StageDefinition = stage_catalog.get_stage(stage_index)
		var source_name: String = definition.display_name
		_expect(source_name == EXPECTED_STAGE_SOURCE_NAMES[stage_index], "Authoritative StageDefinition display_name must remain title case and unchanged.")
		hud._on_stage_changed(definition)
		_expect(hud.stage_name_label.text == EXPECTED_STAGE_CRT_NAMES[stage_index], "The Stage CRT must display only the exact uppercase current Stage name.")
		_expect(not hud.stage_name_label.text.contains("STAGE"), "The Stage CRT body must not repeat the STAGE prefix.")
		_expect(definition.display_name == source_name, "Presentation uppercase conversion must not mutate StageDefinition data.")
		_expect(sign_label.text == "STAGE", "Stage changes must not mutate the dedicated placard text.")

	if _failures == 0:
		print("S3_G6_STAGE_HEADER_PLACARD_VERIFIED asset=84x24 grid=2x2 alpha=binary palette=paper8 text=STAGE stages=GROUND/PLANETARY/GALACTIC profiles=L0/L1/L2/L3 gap=4px nearest=true source_unchanged=true")
	get_tree().quit(_failures)


func _verify_stage_sign_asset() -> void:
	_expect(FileAccess.file_exists(STAGE_SIGN_ASSET_PATH), "The dedicated Stage sign PNG must exist.")
	if not FileAccess.file_exists(STAGE_SIGN_ASSET_PATH):
		return
	var image := Image.new()
	var error := image.load_png_from_buffer(FileAccess.get_file_as_bytes(STAGE_SIGN_ASSET_PATH))
	_expect(error == OK, "The dedicated Stage sign PNG must decode.")
	if error != OK:
		return
	_expect(image.get_size() == Vector2i(84, 24), "The dedicated Stage sign asset must be exact 84x24.")
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
	_expect(binary_alpha, "The placard asset must use binary alpha without antialiasing fringe.")
	_expect(palette_valid, "Every opaque placard pixel must use the approved Paper 8 palette.")
	_expect(_uses_exact_two_by_two_grid(image), "Every placard detail must align to the enforced 2x2 authoring grid.")


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
	_expect(false, "The GameplayFrame must expose the Stage CRT mask geometry.")
	return Rect2()


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G6 Stage header placard verification failed: %s" % message)
