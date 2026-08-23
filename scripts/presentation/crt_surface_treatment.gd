@tool
extends Control
class_name CrtSurfaceTreatment

const StageScoreGaugeScript := preload("res://scripts/ui/stage_score_gauge.gd")

const CRT_BACKING := Color("1f244b")
const CRT_EDGE := Color("3c6b64")
const PHOSPHOR := StageScoreGaugeScript.CELL_COLOR
const PHOSPHOR_BRIGHT := StageScoreGaugeScript.CELL_HIGHLIGHT
const WARM_READOUT := Color("f6e79c")
const SCANLINE_PITCH := 4
const SCANLINE_HEIGHT := 1
const DITHER_STEP := 16
const PIXEL_GLYPH_SCALE := 2

const LEFT_MASKS := [
	{"id": &"stage", "rect": Rect2(32.0, 54.0, 136.0, 56.0), "corner": 8},
	{"id": &"time", "rect": Rect2(28.0, 158.0, 104.0, 40.0), "corner": 8},
	{"id": &"genealogy", "rect": Rect2(48.0, 262.0, 106.0, 317.0), "corner": 10},
]
const RIGHT_MASKS := [
	{"id": &"stage_score", "rect": Rect2(42.0, 54.0, 110.0, 52.0), "corner": 8},
	{"id": &"item_status", "rect": Rect2(42.0, 196.0, 116.0, 198.0), "corner": 10},
	{"id": &"pause", "rect": Rect2(42.0, 826.0, 48.0, 48.0), "corner": 12},
	{"id": &"retry", "rect": Rect2(110.0, 826.0, 48.0, 48.0), "corner": 12},
]
const PIXEL_GLYPHS := {
	"A": ["010", "101", "111", "101", "101"],
	"E": ["111", "100", "110", "100", "111"],
	"P": ["110", "101", "110", "100", "100"],
	"R": ["110", "101", "110", "101", "101"],
	"S": ["111", "100", "111", "001", "111"],
	"T": ["111", "010", "010", "010", "010"],
	"U": ["101", "101", "101", "101", "111"],
	"Y": ["101", "101", "010", "010", "010"],
}

var _left_origin := Vector2.ZERO
var _right_origin := Vector2.ZERO
var _masks: Array[Dictionary] = []


func _ready() -> void:
	set_process(false)
	set_physics_process(false)
	_rebuild_masks()


func set_frame_layout(left_wing: Rect2, right_wing: Rect2) -> void:
	_left_origin = left_wing.position.round()
	_right_origin = right_wing.position.round()
	_rebuild_masks()
	queue_redraw()


func get_visual_metrics() -> Dictionary:
	var mask_metrics: Array[Dictionary] = []
	for mask in _masks:
		mask_metrics.append({
			"id": mask["id"],
			"mask_bounds": mask["rect"],
			"halo_bounds": mask["rect"],
			"corner_cut": mask["corner"],
		})
	return {
		"static": true,
		"animated": false,
		"module_count": 6,
		"mask_count": _masks.size(),
		"scanline_pitch": SCANLINE_PITCH,
		"scanline_height": SCANLINE_HEIGHT,
		"dither_step": DITHER_STEP,
		"backing": CRT_BACKING,
		"edge": CRT_EDGE,
		"phosphor": PHOSPHOR,
		"phosphor_bright": PHOSPHOR_BRIGHT,
		"warm_readout": WARM_READOUT,
		"pause_labels": ["PAUSE", "RETRY"],
		"masks": mask_metrics,
		"pattern_signature": _get_pattern_signature(mask_metrics),
	}


func _draw() -> void:
	for mask_index in _masks.size():
		_draw_surface(_masks[mask_index], mask_index)
	_draw_pixel_label(_mask_rect(&"pause"), "PAUSE")
	_draw_pixel_label(_mask_rect(&"retry"), "RETRY")


func _rebuild_masks() -> void:
	_masks.clear()
	_append_masks(LEFT_MASKS, _left_origin)
	_append_masks(RIGHT_MASKS, _right_origin)


func _append_masks(source_masks: Array, origin: Vector2) -> void:
	for source_mask in source_masks:
		var local_rect: Rect2 = source_mask["rect"]
		_masks.append({
			"id": source_mask["id"],
			"rect": Rect2((origin + local_rect.position).round(), local_rect.size.round()),
			"corner": source_mask["corner"],
		})


func _draw_surface(mask: Dictionary, mask_index: int) -> void:
	var rect: Rect2 = mask["rect"]
	var corner := int(mask["corner"])
	draw_colored_polygon(_stepped_rect(rect, corner), Color(PHOSPHOR, 0.52))
	var inner_rect := rect.grow(-2.0)
	draw_colored_polygon(_stepped_rect(inner_rect, maxi(corner - 2, 2)), CRT_BACKING)
	_draw_edge_dither(inner_rect, corner, mask_index)
	_draw_scanlines(inner_rect, maxi(corner - 2, 2))


func _draw_edge_dither(rect: Rect2, corner: int, mask_index: int) -> void:
	var dither_color := Color(PHOSPHOR_BRIGHT, 0.18)
	var left := int(rect.position.x) + corner
	var right := int(rect.end.x) - corner - 2
	var top := int(rect.position.y) + 2
	var bottom := int(rect.end.y) - 4
	var phase := (mask_index % 2) * 8
	for x in range(left + phase, right, DITHER_STEP):
		draw_rect(Rect2(Vector2(x, top), Vector2(2.0, 2.0)), dither_color)
	for x in range(left + (8 - phase), right, DITHER_STEP):
		draw_rect(Rect2(Vector2(x, bottom), Vector2(2.0, 2.0)), dither_color)


func _draw_scanlines(rect: Rect2, corner: int) -> void:
	var scanline_color := Color(CRT_EDGE, 0.24)
	var top := int(rect.position.y)
	var bottom := int(rect.end.y)
	for y in range(top + 2, bottom - 1, SCANLINE_PITCH):
		var inset := _corner_inset(y - top, bottom - top, corner)
		var line_start := int(rect.position.x) + inset + 2
		var line_end := int(rect.end.x) - inset - 2
		if line_end > line_start:
			draw_rect(Rect2(Vector2(line_start, y), Vector2(line_end - line_start, SCANLINE_HEIGHT)), scanline_color)


func _corner_inset(row: int, height: int, corner: int) -> int:
	var edge_distance := mini(row, height - 1 - row)
	if edge_distance < 2:
		return corner
	if edge_distance < 4:
		return maxi(corner - 4, 0)
	if edge_distance < 6:
		return maxi(corner - 8, 0)
	return 0


func _stepped_rect(rect: Rect2, corner: int) -> PackedVector2Array:
	var left := rect.position.x
	var top := rect.position.y
	var right := rect.end.x
	var bottom := rect.end.y
	var first_step := maxf(float(corner - 4), 2.0)
	var second_step := maxf(float(corner - 2), 4.0)
	return PackedVector2Array([
		Vector2(left + corner, top),
		Vector2(right - corner, top),
		Vector2(right - first_step, top + 2.0),
		Vector2(right - 2.0, top + second_step),
		Vector2(right, top + corner),
		Vector2(right, bottom - corner),
		Vector2(right - 2.0, bottom - second_step),
		Vector2(right - first_step, bottom - 2.0),
		Vector2(right - corner, bottom),
		Vector2(left + corner, bottom),
		Vector2(left + first_step, bottom - 2.0),
		Vector2(left + 2.0, bottom - second_step),
		Vector2(left, bottom - corner),
		Vector2(left, top + corner),
		Vector2(left + 2.0, top + second_step),
		Vector2(left + first_step, top + 2.0),
	])


func _draw_pixel_label(mask_rect: Rect2, label_text: String) -> void:
	var glyph_width := 3 * PIXEL_GLYPH_SCALE
	var glyph_gap := PIXEL_GLYPH_SCALE
	var total_width := label_text.length() * glyph_width + (label_text.length() - 1) * glyph_gap
	var origin := Vector2(
		floor(mask_rect.get_center().x - float(total_width) * 0.5),
		floor(mask_rect.get_center().y - float(5 * PIXEL_GLYPH_SCALE) * 0.5)
	)
	for character_index in label_text.length():
		var character := label_text.substr(character_index, 1)
		var rows: Array = PIXEL_GLYPHS.get(character, [])
		for row_index in rows.size():
			var row: String = rows[row_index]
			for column_index in row.length():
				if row.substr(column_index, 1) != "1":
					continue
				var pixel_position := origin + Vector2(
					character_index * (glyph_width + glyph_gap) + column_index * PIXEL_GLYPH_SCALE,
					row_index * PIXEL_GLYPH_SCALE
				)
				draw_rect(Rect2(pixel_position, Vector2.ONE * PIXEL_GLYPH_SCALE), PHOSPHOR_BRIGHT)


func _mask_rect(mask_id: StringName) -> Rect2:
	for mask in _masks:
		if mask["id"] == mask_id:
			return mask["rect"]
	return Rect2()


func _get_pattern_signature(mask_metrics: Array[Dictionary]) -> String:
	var parts := PackedStringArray([
		"scan=%d/%d" % [SCANLINE_PITCH, SCANLINE_HEIGHT],
		"dither=%d" % DITHER_STEP,
		"palette=1f244b,3c6b64,60ae7b,b6cf8e,f6e79c",
		"labels=PAUSE,RETRY",
	])
	for mask in mask_metrics:
		var rect: Rect2 = mask["mask_bounds"]
		parts.append("%s:%d,%d,%d,%d" % [
			str(mask["id"]),
			int(rect.position.x),
			int(rect.position.y),
			int(rect.size.x),
			int(rect.size.y),
		])
	return "|".join(parts)
