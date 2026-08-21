class_name TitleMechanicalMotion
extends Control

## Content-owned decorative motion for the title screen.
## It never changes gameplay state and ignores pointer input.

const DESIGN_SIZE := Vector2(1672.0, 941.0)
const LEFT_GAUGE_CENTER := Vector2(234.0, 608.0)
const RIGHT_GAUGE_CENTER := Vector2(1435.0, 608.0)
const GAUGE_TARGETS := [-148.0, -120.0, -92.0, -64.0, -36.0]
const LEFT_LAMP_CENTERS := [176.0, 236.0, 296.0]
const RIGHT_LAMP_CENTERS := [1375.0, 1435.0, 1495.0]
const SNOW_RECT := Rect2(526.0, 356.0, 620.0, 338.0)
var _start_button_face := PackedVector2Array([
	Vector2(480.0, 744.0), Vector2(828.0, 744.0),
	Vector2(842.0, 758.0), Vector2(842.0, 826.0),
	Vector2(828.0, 840.0), Vector2(480.0, 840.0),
	Vector2(466.0, 826.0), Vector2(466.0, 758.0),
])
var _settings_button_face := PackedVector2Array([
	Vector2(1010.0, 746.0), Vector2(1174.0, 746.0),
	Vector2(1188.0, 760.0), Vector2(1188.0, 826.0),
	Vector2(1174.0, 840.0), Vector2(1010.0, 840.0),
	Vector2(996.0, 826.0), Vector2(996.0, 760.0),
])

var _left_angle := -132.0
var _right_angle := -48.0
var _left_target := -132.0
var _right_target := -48.0
var _left_delay := 0.0
var _right_delay := 0.0
var _left_last_index := -1
var _right_last_index := -1
var _flakes: Array[Dictionary] = []
var _start_hovered := false
var _settings_hovered := false
var _start_held := false
var _settings_held := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visibility_changed.connect(_sync_processing)
	for index in 44:
		_flakes.append({
			"position": Vector2(
				SNOW_RECT.position.x + randf() * SNOW_RECT.size.x,
				SNOW_RECT.position.y + randf() * SNOW_RECT.size.y
			),
			"size": 6.0 if index % 8 == 0 else 4.0,
			"speed": 38.0 + float(index % 3) * 13.0,
			"drift": randf() * TAU,
		})
	_bind_button_feedback(get_node("../StartButton") as Button, true)
	_bind_button_feedback(get_node("../SettingsButton") as Button, false)
	_sync_processing()
	queue_redraw()


func _process(delta: float) -> void:
	_left_delay -= delta
	_right_delay -= delta
	if _left_delay <= 0.0:
		_left_last_index = _pick_new_target(_left_last_index)
		_left_target = GAUGE_TARGETS[_left_last_index]
		_left_delay = randf_range(0.28, 1.60)
	if _right_delay <= 0.0:
		_right_last_index = _pick_new_target(_right_last_index)
		_right_target = GAUGE_TARGETS[_right_last_index]
		_right_delay = randf_range(0.28, 1.60)

	_left_angle = lerpf(_left_angle, _left_target, 1.0 - exp(-12.0 * delta))
	_right_angle = lerpf(_right_angle, _right_target, 1.0 - exp(-10.0 * delta))
	for flake in _flakes:
		var position: Vector2 = flake["position"]
		position.y += float(flake["speed"]) * delta
		position.x += sin(Time.get_ticks_msec() * 0.0012 + float(flake["drift"])) * 8.0 * delta
		if position.y > SNOW_RECT.end.y - 4.0:
			position.y = SNOW_RECT.position.y + 4.0
			position.x = SNOW_RECT.position.x + randf() * SNOW_RECT.size.x
		flake["position"] = position
	queue_redraw()


func _sync_processing() -> void:
	set_process(is_visible_in_tree())


func _draw() -> void:
	var transform_scale := size / DESIGN_SIZE
	draw_set_transform(Vector2.ZERO, 0.0, transform_scale)
	_draw_snow()
	_draw_needle(LEFT_GAUGE_CENTER, _left_angle)
	_draw_needle(RIGHT_GAUGE_CENTER, _right_angle)
	_draw_lamps(_left_angle, LEFT_LAMP_CENTERS)
	_draw_lamps(_right_angle, RIGHT_LAMP_CENTERS)
	if _start_hovered:
		_draw_pressed_face(_start_button_face, _start_held)
	if _settings_hovered:
		_draw_pressed_face(_settings_button_face, _settings_held)


func _bind_button_feedback(button: Button, is_start: bool) -> void:
	button.mouse_entered.connect(func() -> void:
		if is_start:
			_start_hovered = true
		else:
			_settings_hovered = true
		queue_redraw()
	)
	button.mouse_exited.connect(func() -> void:
		if is_start:
			_start_hovered = false
			_start_held = false
		else:
			_settings_hovered = false
			_settings_held = false
		queue_redraw()
	)
	button.button_down.connect(func() -> void:
		if is_start:
			_start_held = true
		else:
			_settings_held = true
		queue_redraw()
	)
	button.button_up.connect(func() -> void:
		if is_start:
			_start_held = false
		else:
			_settings_held = false
		queue_redraw()
	)


func _draw_pressed_face(points: PackedVector2Array, held: bool) -> void:
	var fill_alpha := 0.18 if held else 0.1
	draw_colored_polygon(points, Color(0.015, 0.055, 0.035, fill_alpha))


func _pick_new_target(previous: int) -> int:
	var picked := randi_range(0, GAUGE_TARGETS.size() - 1)
	if picked == previous:
		picked = (picked + randi_range(1, GAUGE_TARGETS.size() - 1)) % GAUGE_TARGETS.size()
	return picked


func _draw_snow() -> void:
	for index in _flakes.size():
		var flake := _flakes[index]
		var flake_size: float = flake["size"]
		var position: Vector2 = flake["position"]
		position.x = clampf(position.x, SNOW_RECT.position.x + flake_size, SNOW_RECT.end.x - flake_size)
		position.y = clampf(position.y, SNOW_RECT.position.y + flake_size, SNOW_RECT.end.y - flake_size)
		var color := Color("f6e79c") if index % 3 == 0 else Color("b6cf8e") if index % 3 == 1 else Color("d1a67e")
		color.a = 0.86 if index % 6 == 0 else 0.52
		draw_rect(Rect2(position.floor(), Vector2.ONE * flake_size), color)


func _draw_needle(center: Vector2, angle_degrees: float) -> void:
	var endpoint := center + Vector2.RIGHT.rotated(deg_to_rad(angle_degrees)) * 58.0
	draw_line(center, endpoint, Color("f6e79c"), 5.0, false)
	draw_rect(Rect2(center - Vector2(5.0, 5.0), Vector2(10.0, 10.0)), Color("d1a67e"))
	draw_rect(Rect2(center - Vector2(2.0, 2.0), Vector2(4.0, 4.0)), Color("654053"))


func _draw_lamps(angle_degrees: float, centers: Array) -> void:
	var normalized := clampf((angle_degrees + 148.0) / 112.0, 0.0, 1.0)
	var lit_index := 0 if normalized < 0.34 else 1 if normalized < 0.67 else 2
	var colors := [Color("60ae7b"), Color("f6e79c"), Color("a8605d")]
	for index in centers.size():
		var color: Color = colors[index]
		color.a = 1.0 if index == lit_index else 0.22
		var top_left := Vector2(float(centers[index]) - 9.0, 658.0)
		draw_rect(Rect2(top_left, Vector2(18.0, 18.0)), color)
		if index == lit_index:
			draw_rect(Rect2(top_left + Vector2(4.0, 3.0), Vector2(6.0, 4.0)), Color("f6e79c"))
