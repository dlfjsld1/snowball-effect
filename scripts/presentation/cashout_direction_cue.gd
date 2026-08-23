@tool
extends Control
class_name CashoutDirectionCue

const StageScoreGaugeScript := preload("res://scripts/ui/stage_score_gauge.gd")

const ACTIVE_GAMEPLAY_LIFETIME_SECONDS := 10.0
const FLOW_DURATION_SECONDS := 0.84
const CHEVRON_SPACING := 48.0
const PIXEL_SIZE := 2.0
const CHEVRON_PIXEL_OFFSETS: Array[Vector2] = [
	Vector2(-6.0, -2.0),
	Vector2(-4.0, 0.0),
	Vector2(-2.0, 2.0),
	Vector2(0.0, 4.0),
	Vector2(2.0, 2.0),
	Vector2(4.0, 0.0),
	Vector2(6.0, -2.0),
]
const CUE_COLOR: Color = StageScoreGaugeScript.CELL_COLOR

var _gameplay_active := false
var _reduced_effects := false
var _flow_phase := 0.0
var _active_gameplay_elapsed := 0.0
var _hud_source: CanvasItem
var _pause_source: CanvasItem


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_sync_visibility()
	queue_redraw()


func _process(delta: float) -> void:
	var active_delta := 0.0
	if _is_active_gameplay_context() and _active_gameplay_elapsed < ACTIVE_GAMEPLAY_LIFETIME_SECONDS:
		active_delta = minf(maxf(delta, 0.0), ACTIVE_GAMEPLAY_LIFETIME_SECONDS - _active_gameplay_elapsed)
		_active_gameplay_elapsed += active_delta
		if not _reduced_effects:
			_flow_phase = fmod(_flow_phase + active_delta / FLOW_DURATION_SECONDS, 1.0)
	_sync_visibility()
	if active_delta > 0.0:
		queue_redraw()


func configure_lifecycle(hud_source: CanvasItem, pause_source: CanvasItem) -> void:
	_hud_source = hud_source
	_pause_source = pause_source
	_sync_visibility()


func set_gameplay_active(active: bool) -> void:
	_gameplay_active = active
	_sync_visibility()


func set_reduced_effects(enabled: bool) -> void:
	_reduced_effects = enabled
	_sync_visibility()
	queue_redraw()


func reset_for_new_run() -> void:
	_active_gameplay_elapsed = 0.0
	_flow_phase = 0.0
	_sync_visibility()
	queue_redraw()


func set_cue_rect(cue_rect: Rect2) -> void:
	position = cue_rect.position.round()
	size = cue_rect.size.round()
	queue_redraw()


func get_visual_metrics() -> Dictionary:
	var chevron_count := _get_chevron_count()
	var drawn_area := float(chevron_count * CHEVRON_PIXEL_OFFSETS.size()) * PIXEL_SIZE * PIXEL_SIZE
	return {
		"cue_rect": Rect2(position, size),
		"color": CUE_COLOR,
		"active_gameplay_lifetime_seconds": ACTIVE_GAMEPLAY_LIFETIME_SECONDS,
		"active_gameplay_elapsed_seconds": _active_gameplay_elapsed,
		"expired": _active_gameplay_elapsed >= ACTIVE_GAMEPLAY_LIFETIME_SECONDS,
		"flow_direction": Vector2.DOWN,
		"flow_duration_seconds": FLOW_DURATION_SECONDS,
		"flow_phase": _flow_phase,
		"chevron_count": chevron_count,
		"filled_area_ratio": drawn_area / maxf(size.x * size.y, 1.0),
		"solid_background": false,
		"animated": not _reduced_effects,
		"visible": visible,
	}


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var count := _get_chevron_count()
	var span := float(count - 1) * CHEVRON_SPACING
	var first_x := roundf((size.x - span) * 0.5)
	var chevron_y := _get_chevron_y()
	for chevron_index in range(count):
		var center := Vector2(first_x + float(chevron_index) * CHEVRON_SPACING, chevron_y)
		for pixel_offset in CHEVRON_PIXEL_OFFSETS:
			draw_rect(Rect2(center + pixel_offset, Vector2(PIXEL_SIZE, PIXEL_SIZE)), CUE_COLOR, true)


func _get_chevron_count() -> int:
	return maxi(1, int(floor(maxf(size.x - 16.0, 0.0) / CHEVRON_SPACING)) + 1)


func _get_chevron_y() -> float:
	if _reduced_effects:
		return floor((size.y - 7.0) / PIXEL_SIZE) * PIXEL_SIZE
	var start_y := 4.0
	var end_y := maxf(start_y, size.y - 6.0)
	return floor(lerpf(start_y, end_y, _flow_phase) / PIXEL_SIZE) * PIXEL_SIZE


func _sync_visibility() -> void:
	visible = _is_active_gameplay_context() and _active_gameplay_elapsed < ACTIVE_GAMEPLAY_LIFETIME_SECONDS


func _is_active_gameplay_context() -> bool:
	var should_show := _gameplay_active and not get_tree().paused
	if is_instance_valid(_hud_source):
		should_show = should_show and _hud_source.visible
	if is_instance_valid(_pause_source):
		should_show = should_show and _pause_source.visible
	return should_show
