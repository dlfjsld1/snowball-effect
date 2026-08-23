class_name StageScoreGauge
extends Control

const CELL_COUNT := 20
const GAUGE_WIDTH := 104.0
const GAUGE_HEIGHT := 197.0
const CELL_GAP := 2.0
const EMPTY_COLOR := Color(0.0, 0.0, 0.0, 0.0)
const CELL_COLOR := Color("60ae7b")
const CELL_HIGHLIGHT := Color("b6cf8e")
const CELL_SHADOW := Color("3c6b64")

var _progress := 0.0
var _filled_cell_count := 0


func _ready() -> void:
	custom_minimum_size = Vector2(GAUGE_WIDTH, GAUGE_HEIGHT)
	size = Vector2(GAUGE_WIDTH, GAUGE_HEIGHT)
	queue_redraw()


func set_score_progress(stage_score: float, clear_score: float) -> void:
	if clear_score <= 0.0:
		visible = false
		_progress = 0.0
		_filled_cell_count = 0
		queue_redraw()
		return
	visible = true
	_progress = clampf(stage_score / clear_score, 0.0, 1.0)
	_filled_cell_count = ceili(_progress * float(CELL_COUNT))
	queue_redraw()


func reset_gauge() -> void:
	_progress = 0.0
	_filled_cell_count = 0
	visible = true
	queue_redraw()


func get_filled_cell_count() -> int:
	return _filled_cell_count


func get_progress() -> float:
	return _progress


func _draw() -> void:
	if _filled_cell_count <= 0:
		return
	for cell_index in range(CELL_COUNT - _filled_cell_count, CELL_COUNT):
		_draw_cell(cell_index)


func _draw_cell(cell_index: int) -> void:
	var cell_rect := _get_cell_rect(cell_index)
	var is_top := cell_index == 0
	var is_bottom := cell_index == CELL_COUNT - 1
	var pixels := PackedVector2Array([
		Vector2(2.0, 0.0),
		Vector2(cell_rect.size.x - 2.0, 0.0),
		Vector2(cell_rect.size.x, 2.0),
		Vector2(cell_rect.size.x, cell_rect.size.y - 2.0),
		Vector2(cell_rect.size.x - 2.0, cell_rect.size.y),
		Vector2(2.0, cell_rect.size.y),
		Vector2(0.0, cell_rect.size.y - 2.0),
		Vector2(0.0, 2.0),
	])
	for point_index in pixels.size():
		pixels[point_index] += cell_rect.position
	if is_top:
		pixels[0] = cell_rect.position + Vector2(3.0, 1.0)
		pixels[1] = cell_rect.position + Vector2(cell_rect.size.x - 3.0, 1.0)
	if is_bottom:
		pixels[4] = cell_rect.position + Vector2(cell_rect.size.x - 3.0, cell_rect.size.y - 1.0)
		pixels[5] = cell_rect.position + Vector2(3.0, cell_rect.size.y - 1.0)
	draw_colored_polygon(pixels, CELL_COLOR)
	draw_line(cell_rect.position + Vector2(3.0, 1.0), cell_rect.position + Vector2(cell_rect.size.x - 3.0, 1.0), CELL_HIGHLIGHT, 1.0, false)
	draw_line(cell_rect.position + Vector2(2.0, cell_rect.size.y - 1.0), cell_rect.position + Vector2(cell_rect.size.x - 2.0, cell_rect.size.y - 1.0), CELL_SHADOW, 1.0, false)


func _get_cell_rect(cell_index: int) -> Rect2:
	var cell_height := _get_cell_height(cell_index)
	var y := 0.0
	for previous_index in cell_index:
		y += _get_cell_height(previous_index) + CELL_GAP
	return Rect2(Vector2(0.0, y), Vector2(GAUGE_WIDTH, cell_height))


func _get_cell_height(cell_index: int) -> float:
	if cell_index < 6:
		return 9.0
	if cell_index < 13:
		return 8.0
	return 7.0
