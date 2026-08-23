class_name CutInController
extends Control

signal cutin_finished(event_id: int, run_epoch: int)

const SCHEMA_VERSION := 1
const ENTER_DURATION := 0.20
const HOLD_DURATION := 0.65
const EXIT_DURATION := 0.25
const REDUCED_ENTER_DURATION := 0.12
const REDUCED_HOLD_DURATION := 0.55
const REDUCED_EXIT_DURATION := 0.18
const DIM_ALPHA := 0.34
const BANNER_HEIGHT_RATIO := 0.44
const BACKGROUND_PATH := "res://assets/sprites/cutins/first_contact/first-contact-background-v1.png"
const REQUIRED_FIELDS := [
	"schema_version",
	"event_id",
	"run_epoch",
	"stage_index",
	"stage_id",
	"global_level",
	"local_level",
	"world_position",
	"first_contact_id",
	"handoff_kind",
	"black_hole_entity_ordinal",
]
const ROSTER := {
	&"ground_giant_snowball": {
		"stage_index": 0,
		"stage_id": &"ground",
		"global_level": 3,
		"local_level": 3,
		"handoff_kind": &"RESUME_PLAYING",
		"black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-giant-snowball-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/giant-snowball-portrait-v1.png",
	},
	&"ground_moon": {
		"stage_index": 0,
		"stage_id": &"ground",
		"global_level": 4,
		"local_level": 4,
		"handoff_kind": &"RESUME_PLAYING",
		"black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-moon-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/moon-portrait-v1.png",
	},
	&"planetary_supernova": {
		"stage_index": 1,
		"stage_id": &"planetary",
		"global_level": 8,
		"local_level": 3,
		"handoff_kind": &"RESUME_PLAYING",
		"black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-supernova-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/supernova-portrait-v1.png",
	},
	&"planetary_galaxy": {
		"stage_index": 1,
		"stage_id": &"planetary",
		"global_level": 10,
		"local_level": 4,
		"handoff_kind": &"RESUME_PLAYING",
		"black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-galaxy-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/galaxy-portrait-v1.png",
	},
	&"galactic_event_horizon": {
		"stage_index": 2,
		"stage_id": &"galactic",
		"global_level": 13,
		"local_level": 3,
		"handoff_kind": &"RESUME_PLAYING",
		"black_hole_entity_ordinal": 0,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-event-horizon-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/event-horizon-portrait-v1.png",
	},
	&"galactic_black_hole": {
		"stage_index": 2,
		"stage_id": &"galactic",
		"global_level": 14,
		"local_level": 4,
		"handoff_kind": &"BLACK_HOLE_PHASE",
		"black_hole_entity_ordinal": 1,
		"title_path": "res://assets/sprites/cutins/first_contact/first-contact-black-hole-title-v1.png",
		"portrait_path": "res://assets/sprites/cutins/first_contact/black-hole-portrait-v1.png",
	},
}

@onready var dim_overlay: ColorRect = %DimOverlay
@onready var field_clip: Control = %FieldClip
@onready var card_root: Control = %CardRoot
@onready var background_texture: TextureRect = %BackgroundTexture
@onready var title_texture: TextureRect = %TitleTexture
@onready var portrait_texture: TextureRect = %PortraitTexture

var _animation_tween: Tween
var _active_payload: Dictionary = {}
var _completed_pairs: Dictionary = {}
var _highest_run_epoch := -1
var _last_started_event_id := -1
var _reset_epoch_high_water := -1
var _animation_generation := 0
var _reduced_effects := false
var _field_visual_rect := Rect2()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _field_visual_rect.size == Vector2.ZERO:
		_field_visual_rect = Rect2(Vector2.ZERO, size)
	_apply_field_layout()
	_hide_visuals()


func play_first_contact_cutin(payload: Dictionary) -> bool:
	if not _is_valid_payload(payload) or not _active_payload.is_empty():
		return false

	var event_id := int(payload["event_id"])
	var run_epoch := int(payload["run_epoch"])
	var pair_key := _pair_key(run_epoch, event_id)
	if run_epoch < _reset_epoch_high_water or run_epoch < _highest_run_epoch:
		return false
	if event_id <= _last_started_event_id or _completed_pairs.has(pair_key):
		return false

	var identity: StringName = payload["first_contact_id"]
	var roster_entry: Dictionary = ROSTER[identity]
	var next_title := ResourceLoader.load(String(roster_entry["title_path"]), "Texture2D") as Texture2D
	var next_portrait := ResourceLoader.load(String(roster_entry["portrait_path"]), "Texture2D") as Texture2D
	if next_title == null or next_portrait == null or background_texture.texture == null:
		return false

	_highest_run_epoch = maxi(_highest_run_epoch, run_epoch)
	_last_started_event_id = event_id
	_active_payload = payload.duplicate(true)
	_animation_generation += 1
	title_texture.texture = next_title
	portrait_texture.texture = next_portrait
	_start_animation(_animation_generation, event_id, run_epoch)
	return true


func reset_first_contact_cutin(run_epoch: int) -> void:
	if run_epoch >= 0:
		_reset_epoch_high_water = maxi(_reset_epoch_high_water, run_epoch)
		_highest_run_epoch = maxi(_highest_run_epoch, run_epoch)
	if _active_payload.is_empty():
		return
	if run_epoch >= 0 and int(_active_payload["run_epoch"]) > run_epoch:
		return

	_animation_generation += 1
	_cancel_animation()
	_active_payload.clear()
	_hide_visuals()


func set_reduced_effects(enabled: bool) -> void:
	_reduced_effects = enabled


func is_reduced_effects() -> bool:
	return _reduced_effects


func configure_field_visual_rect(field_visual_rect: Rect2) -> void:
	if field_visual_rect.size.x <= 0.0 or field_visual_rect.size.y <= 0.0:
		return
	_field_visual_rect = field_visual_rect
	if is_node_ready():
		_apply_field_layout()


func is_cutin_active() -> bool:
	return not _active_payload.is_empty()


func get_total_duration() -> float:
	if _reduced_effects:
		return REDUCED_ENTER_DURATION + REDUCED_HOLD_DURATION + REDUCED_EXIT_DURATION
	return ENTER_DURATION + HOLD_DURATION + EXIT_DURATION


func get_active_payload() -> Dictionary:
	return _active_payload.duplicate(true)


func get_roster_asset_paths() -> Dictionary:
	var paths := {}
	for identity in ROSTER:
		var entry: Dictionary = ROSTER[identity]
		paths[identity] = {
			"title_path": entry["title_path"],
			"portrait_path": entry["portrait_path"],
		}
	return paths


func get_visual_metrics() -> Dictionary:
	return {
		"visible": visible,
		"active": is_cutin_active(),
		"event_id": int(_active_payload.get("event_id", -1)),
		"run_epoch": int(_active_payload.get("run_epoch", -1)),
		"first_contact_id": _active_payload.get("first_contact_id", &""),
		"background_path": background_texture.texture.resource_path if background_texture.texture != null else "",
		"title_path": title_texture.texture.resource_path if title_texture.texture != null else "",
		"portrait_path": portrait_texture.texture.resource_path if portrait_texture.texture != null else "",
		"dim_alpha": dim_overlay.color.a,
		"field_visual_rect": _field_visual_rect,
		"field_clip_rect": Rect2(field_clip.position, field_clip.size),
		"banner_size": card_root.size,
		"card_position": card_root.position,
		"total_duration": get_total_duration(),
		"completed_pair_count": _completed_pairs.size(),
		"reduced_effects": _reduced_effects,
	}


func _start_animation(generation: int, event_id: int, run_epoch: int) -> void:
	_cancel_animation()
	_apply_field_layout()
	visible = true
	card_root.modulate = Color.WHITE
	dim_overlay.color = Color(0.008, 0.012, 0.035, 0.0)
	var banner_y := card_root.position.y
	card_root.position = Vector2.ZERO if _reduced_effects else Vector2(field_clip.size.x, banner_y)
	if _reduced_effects:
		card_root.position.y = banner_y

	var enter_duration := REDUCED_ENTER_DURATION if _reduced_effects else ENTER_DURATION
	var hold_duration := REDUCED_HOLD_DURATION if _reduced_effects else HOLD_DURATION
	var exit_duration := REDUCED_EXIT_DURATION if _reduced_effects else EXIT_DURATION
	_animation_tween = create_tween()
	_animation_tween.tween_property(dim_overlay, "color:a", DIM_ALPHA, enter_duration)
	if not _reduced_effects:
		_animation_tween.parallel().tween_property(card_root, "position:x", 0.0, enter_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	_animation_tween.tween_interval(hold_duration)
	_animation_tween.tween_property(dim_overlay, "color:a", 0.0, exit_duration)
	if _reduced_effects:
		_animation_tween.parallel().tween_property(card_root, "modulate:a", 0.0, exit_duration)
	else:
		_animation_tween.parallel().tween_property(card_root, "position:x", -card_root.size.x, exit_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	_animation_tween.tween_callback(_finish_normal_exit.bind(generation, event_id, run_epoch))


func _finish_normal_exit(generation: int, event_id: int, run_epoch: int) -> void:
	if generation != _animation_generation or _active_payload.is_empty():
		return
	if event_id != int(_active_payload["event_id"]) or run_epoch != int(_active_payload["run_epoch"]):
		return

	_completed_pairs[_pair_key(run_epoch, event_id)] = true
	_animation_tween = null
	_active_payload.clear()
	_hide_visuals()
	cutin_finished.emit(event_id, run_epoch)


func _cancel_animation() -> void:
	if _animation_tween != null and _animation_tween.is_valid():
		_animation_tween.kill()
	_animation_tween = null


func _hide_visuals() -> void:
	visible = false
	dim_overlay.color = Color(0.008, 0.012, 0.035, 0.0)
	card_root.position = Vector2(field_clip.size.x, card_root.position.y)
	card_root.modulate = Color.WHITE
	title_texture.texture = null
	portrait_texture.texture = null


func _apply_field_layout() -> void:
	var viewport_size := size
	if viewport_size == Vector2.ZERO:
		viewport_size = get_viewport_rect().size
	if _field_visual_rect.size == Vector2.ZERO:
		_field_visual_rect = Rect2(Vector2.ZERO, viewport_size)
	field_clip.position = _field_visual_rect.position
	field_clip.size = _field_visual_rect.size
	var banner_height := _field_visual_rect.size.y * BANNER_HEIGHT_RATIO
	card_root.size = Vector2(_field_visual_rect.size.x, banner_height)
	card_root.position = Vector2(field_clip.size.x, (field_clip.size.y - banner_height) * 0.5)


func _is_valid_payload(payload: Dictionary) -> bool:
	for field in REQUIRED_FIELDS:
		if not payload.has(field):
			return false
	if typeof(payload["schema_version"]) != TYPE_INT or int(payload["schema_version"]) != SCHEMA_VERSION:
		return false
	if typeof(payload["event_id"]) != TYPE_INT or int(payload["event_id"]) <= 0:
		return false
	if typeof(payload["run_epoch"]) != TYPE_INT or int(payload["run_epoch"]) <= 0:
		return false
	if typeof(payload["stage_index"]) != TYPE_INT or typeof(payload["global_level"]) != TYPE_INT or typeof(payload["local_level"]) != TYPE_INT:
		return false
	if typeof(payload["stage_id"]) != TYPE_STRING_NAME or typeof(payload["first_contact_id"]) != TYPE_STRING_NAME:
		return false
	if typeof(payload["handoff_kind"]) != TYPE_STRING_NAME or typeof(payload["black_hole_entity_ordinal"]) != TYPE_INT:
		return false
	if typeof(payload["world_position"]) != TYPE_VECTOR2:
		return false

	var identity: StringName = payload["first_contact_id"]
	if not ROSTER.has(identity):
		return false
	var entry: Dictionary = ROSTER[identity]
	return (
		int(payload["stage_index"]) == int(entry["stage_index"])
		and payload["stage_id"] == entry["stage_id"]
		and int(payload["global_level"]) == int(entry["global_level"])
		and int(payload["local_level"]) == int(entry["local_level"])
		and payload["handoff_kind"] == entry["handoff_kind"]
		and int(payload["black_hole_entity_ordinal"]) == int(entry["black_hole_entity_ordinal"])
	)


func _pair_key(run_epoch: int, event_id: int) -> String:
	return "%d:%d" % [run_epoch, event_id]
