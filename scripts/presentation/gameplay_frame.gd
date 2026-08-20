@tool
extends Control
class_name GameplayFrame

const PROFILE_IDS := ["L0", "L1", "L2", "L3"]
const FIELD_WIDTHS: Array[float] = [560.0, 720.0, 880.0, 1040.0]
const VIEWPORT_SIZE := Vector2(1600.0, 900.0)
const FRAME_INSET := 50.0
const FIELD_HEIGHT := VIEWPORT_SIZE.y - FRAME_INSET * 2.0
const LOGICAL_FIELD_BOTTOM_INSET := 32.0
const WING_WIDTH := 200.0
const FIELD_GAP := 12.0

@export_range(0, 3, 1) var profile_index := 0:
	set(value):
		profile_index = clampi(value, 0, PROFILE_IDS.size() - 1)
		if is_node_ready():
			_apply_profile()

@onready var left_housing: TextureRect = %LeftHousing
@onready var right_top_housing: TextureRect = %RightTopHousing
@onready var right_bottom_housing: Control = %RightBottomHousing
@onready var right_empty_waist: Control = %RightEmptyWaist
@onready var field_bezel: NinePatchRect = %FieldBezel
@onready var left_crt_group: Control = %LeftCrtGroup
@onready var right_crt_group: Control = %RightCrtGroup


func _ready() -> void:
	_apply_profile()


func set_profile(value: int) -> void:
	profile_index = value


func get_profile_id() -> StringName:
	return StringName(PROFILE_IDS[profile_index])


func get_field_rect() -> Rect2:
	return _get_field_rect(profile_index)


func get_field_rect_for_profile(value: int) -> Rect2:
	return _get_field_rect(value)


func _get_field_rect(value: int) -> Rect2:
	var field_width := FIELD_WIDTHS[clampi(value, 0, PROFILE_IDS.size() - 1)]
	var field_x := (VIEWPORT_SIZE.x - field_width) * 0.5
	return Rect2(field_x, FRAME_INSET, field_width, FIELD_HEIGHT - LOGICAL_FIELD_BOTTOM_INSET)


func get_field_visual_rect() -> Rect2:
	return get_field_visual_rect_for_profile(profile_index)


func get_field_visual_rect_for_profile(value: int) -> Rect2:
	var field_width := FIELD_WIDTHS[clampi(value, 0, PROFILE_IDS.size() - 1)]
	var field_x := (VIEWPORT_SIZE.x - field_width) * 0.5
	return Rect2(field_x, FRAME_INSET, field_width, FIELD_HEIGHT)


func get_field_visual_rect_lerp(from_profile: int, to_profile: int, weight: float) -> Rect2:
	var clamped_weight := clampf(weight, 0.0, 1.0)
	var from_rect := get_field_visual_rect_for_profile(from_profile)
	var to_rect := get_field_visual_rect_for_profile(to_profile)
	return Rect2(
		from_rect.position.lerp(to_rect.position, clamped_weight),
		from_rect.size.lerp(to_rect.size, clamped_weight)
	)


func get_field_bezel_rect() -> Rect2:
	return _get_field_bezel_rect(profile_index)


func _get_field_bezel_rect(value: int) -> Rect2:
	return _get_field_rect(value).grow(FRAME_INSET)


func get_rig_rect() -> Rect2:
	var bezel := get_field_bezel_rect()
	var rig_width := bezel.size.x + WING_WIDTH * 2.0 + FIELD_GAP * 2.0
	return Rect2((VIEWPORT_SIZE.x - rig_width) * 0.5, 0.0, rig_width, VIEWPORT_SIZE.y)


func get_left_wing_rect() -> Rect2:
	return _get_left_wing_rect(profile_index)


func _get_left_wing_rect(value: int) -> Rect2:
	var bezel := _get_field_bezel_rect(value)
	return Rect2(
		Vector2(bezel.position.x - FIELD_GAP - WING_WIDTH, 0.0),
		Vector2(WING_WIDTH, VIEWPORT_SIZE.y)
	)


func get_right_wing_rect() -> Rect2:
	return _get_right_wing_rect(profile_index)


func _get_right_wing_rect(value: int) -> Rect2:
	var bezel := _get_field_bezel_rect(value)
	return Rect2(
		Vector2(bezel.end.x + FIELD_GAP, 0.0),
		Vector2(WING_WIDTH, VIEWPORT_SIZE.y)
	)


func get_right_bottom_panel_rect() -> Rect2:
	return _get_right_bottom_panel_rect(get_right_wing_rect())


func _get_right_bottom_panel_rect(right_wing: Rect2) -> Rect2:
	return Rect2(
		Vector2(right_wing.position.x + 24.0, VIEWPORT_SIZE.y - 104.0),
		Vector2(152.0, 104.0)
	)


func get_visual_left_wing_rect() -> Rect2:
	return Rect2(left_housing.position, left_housing.size)


func get_visual_right_wing_rect() -> Rect2:
	return Rect2(right_top_housing.position, right_top_housing.size)


func get_visual_right_bottom_panel_rect() -> Rect2:
	return _get_right_bottom_panel_rect(get_visual_right_wing_rect())


func apply_visual_profile_lerp(from_profile: int, to_profile: int, weight: float) -> void:
	var clamped_weight := clampf(weight, 0.0, 1.0)
	var from_bezel := _get_field_bezel_rect(from_profile)
	var to_bezel := _get_field_bezel_rect(to_profile)
	var bezel := Rect2(
		from_bezel.position.lerp(to_bezel.position, clamped_weight),
		from_bezel.size.lerp(to_bezel.size, clamped_weight)
	)
	var from_left := _get_left_wing_rect(from_profile)
	var to_left := _get_left_wing_rect(to_profile)
	var left_wing := Rect2(from_left.position.lerp(to_left.position, clamped_weight), from_left.size)
	var from_right := _get_right_wing_rect(from_profile)
	var to_right := _get_right_wing_rect(to_profile)
	var right_wing := Rect2(from_right.position.lerp(to_right.position, clamped_weight), from_right.size)
	_apply_visual_rects(bezel, left_wing, right_wing)


func get_spawn_safe_y(radius: float, clearance := 12.0) -> float:
	return get_field_rect().position.y + radius + clearance


func get_cashout_line_y() -> float:
	return get_field_rect().end.y


func _apply_profile() -> void:
	var left_wing := get_left_wing_rect()
	var right_wing := get_right_wing_rect()
	_apply_visual_rects(get_field_bezel_rect(), left_wing, right_wing)


func _apply_visual_rects(bezel: Rect2, left_wing: Rect2, right_wing: Rect2) -> void:
	var right_bottom := _get_right_bottom_panel_rect(right_wing)

	_set_rect(left_housing, left_wing)
	_set_rect(right_top_housing, right_wing)
	_set_rect(right_bottom_housing, right_bottom)
	_set_rect(right_empty_waist, Rect2(right_wing.position, Vector2.ZERO))
	_set_rect(field_bezel, bezel)

	left_crt_group.position = left_wing.position
	right_crt_group.position = right_wing.position


func _set_rect(node: Control, rect: Rect2) -> void:
	node.position = rect.position
	node.size = rect.size
