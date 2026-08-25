class_name ItemBlizzardVisual
extends Node2D

## Content-owned, read-only optional-item visual. Integration mounts this node
## under Main and connects ItemManager/ItemBlizzard signals; it never changes
## gameplay. The pre-break Item Ball uses the shared Rescue Beacon Capsule
## damage sequence, the falling Orb visual is selected by item_type, and the
## active snow FX remains Blizzard-specific.

const ITEM_TYPE := &"blizzard"
const FIRE_ITEM_TYPE := &"fire_core"
const MAGNET_ITEM_TYPE := &"magnet"
const SUPPORTED_ORB_TYPES := {
	ITEM_TYPE: true,
	FIRE_ITEM_TYPE: true,
	MAGNET_ITEM_TYPE: true,
}
const ITEM_BALL_FRAME_SIZE := Vector2(64.0, 64.0)
const ITEM_BALL_FRAME_COUNT := 5
const BREAK_FRAGMENT_FRAME_COUNT := 4
const BREAK_FRAGMENT_FRAME_SECONDS := 0.08
const SNOW_PARTICLE_COUNT := 48
const PLAY_FIELD := Rect2(500.0, 0.0, 600.0, 900.0)
const ICE_DARK := Color("244466")
const ICE_MID := Color("5caed0")
const ICE_LIGHT := Color("d8fbff")
const AURORA := Color("78f4ee")
const ITEM_BALL_TEXTURE: Texture2D = preload("res://assets/sprites/items/item_ball_rescue_beacon_h0_h4.png")
const BREAK_FRAGMENTS_TEXTURE: Texture2D = preload("res://assets/sprites/items/item_ball_rescue_beacon_rupture_4f.png")
const FIRE_ORB_TEXTURE: Texture2D = preload("res://assets/particles/items/fire/fire_orb.png")
const MagnetOrbPortraitScript = preload("res://scripts/presentation/magnet_orb_portrait.gd")

var _planet := {}
var _break_fragments := {}
var _orb := {}
var _blizzard_active := false
var _blizzard_remaining := 0.0
var _elapsed := 0.0
var _orb_motion_frozen := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func show_item_planet_spawned(item_type: StringName, world_position: Vector2, radius: float) -> void:
	_planet = {
		"item_type": item_type,
		"position": world_position,
		"radius": radius,
		"remaining_hits": ITEM_BALL_FRAME_COUNT,
		"required_hits": ITEM_BALL_FRAME_COUNT,
	}
	_break_fragments.clear()
	queue_redraw()


func show_item_planet_damaged(item_type: StringName, current_hits: int, required_hits: int, world_position: Vector2) -> void:
	if not _planet.is_empty() and StringName(_planet.get("item_type", &"")) != item_type:
		return
	var authoritative_required_hits := maxi(required_hits, 1)
	_planet = {
		"item_type": item_type,
		"position": world_position,
		"radius": float(_planet.get("radius", 24.0)),
		"remaining_hits": maxi(authoritative_required_hits - current_hits, 0),
		"required_hits": authoritative_required_hits,
	}
	queue_redraw()


func show_item_planet_broken(item_type: StringName, world_position: Vector2) -> void:
	if not _planet.is_empty() and StringName(_planet.get("item_type", &"")) != item_type:
		return
	_planet.clear()
	_break_fragments = {"position": world_position, "elapsed": 0.0, "frame_index": 0}
	queue_redraw()


func show_item_orb_spawned(item_type: StringName, world_position: Vector2) -> void:
	if not SUPPORTED_ORB_TYPES.has(item_type):
		return
	_orb = {"item_type": item_type, "position": world_position, "radius": 16.0}
	queue_redraw()


func hide_item_orb(item_type: StringName, _world_position: Vector2) -> void:
	if not _orb.is_empty() and StringName(_orb.get("item_type", &"")) == item_type:
		_orb.clear()
		queue_redraw()


func set_blizzard_state(snapshot: Dictionary) -> void:
	if StringName(snapshot.get("item_type", &"")) != ITEM_TYPE:
		return
	_blizzard_active = bool(snapshot.get("active", false))
	_blizzard_remaining = maxf(float(snapshot.get("remaining_seconds", 0.0)), 0.0)
	queue_redraw()


func set_orb_motion_frozen(frozen: bool) -> void:
	_orb_motion_frozen = frozen
	queue_redraw()


func reset_runtime() -> void:
	_planet.clear()
	_break_fragments.clear()
	_orb.clear()
	_blizzard_active = false
	_blizzard_remaining = 0.0
	_elapsed = 0.0
	_orb_motion_frozen = false
	queue_redraw()


func _physics_process(delta: float) -> void:
	_elapsed += maxf(delta, 0.0)
	if not _break_fragments.is_empty():
		var break_elapsed: float = float(_break_fragments.get("elapsed", 0.0)) + maxf(delta, 0.0)
		if break_elapsed >= BREAK_FRAGMENT_FRAME_SECONDS * float(BREAK_FRAGMENT_FRAME_COUNT):
			_break_fragments.clear()
		else:
			_break_fragments["elapsed"] = break_elapsed
			_break_fragments["frame_index"] = mini(int(break_elapsed / BREAK_FRAGMENT_FRAME_SECONDS), BREAK_FRAGMENT_FRAME_COUNT - 1)
	if not _orb.is_empty() and not _orb_motion_frozen:
		_orb["position"] = (_orb["position"] as Vector2) + Vector2.DOWN * 160.0 * delta
	queue_redraw()


func _draw() -> void:
	if _blizzard_active:
		_draw_blizzard()
	if not _planet.is_empty():
		_draw_item_ball()
	if not _break_fragments.is_empty():
		_draw_break_fragments()
	if not _orb.is_empty():
		_draw_orb()


func _draw_blizzard() -> void:
	for index in range(SNOW_PARTICLE_COUNT):
		var lane := float((index * 83) % 593) / 593.0
		var phase := fmod(_elapsed * (94.0 + float(index % 7) * 9.0) + float(index * 41), PLAY_FIELD.size.y + 32.0)
		var x := PLAY_FIELD.position.x + 4.0 + lane * (PLAY_FIELD.size.x - 8.0)
		var size := 2.0 + float(index % 3)
		draw_rect(Rect2(Vector2(x, PLAY_FIELD.position.y + phase - 16.0), Vector2(size, size)), ICE_LIGHT * Color(1.0, 1.0, 1.0, 0.72))


func _draw_item_ball() -> void:
	var center: Vector2 = (_planet["position"] as Vector2).round()
	var destination := Rect2(center - ITEM_BALL_FRAME_SIZE * 0.5, ITEM_BALL_FRAME_SIZE)
	draw_texture_rect_region(ITEM_BALL_TEXTURE, destination, _item_ball_source_region())


func _draw_break_fragments() -> void:
	var center: Vector2 = (_break_fragments["position"] as Vector2).round()
	var destination := Rect2(center - ITEM_BALL_FRAME_SIZE * 0.5, ITEM_BALL_FRAME_SIZE)
	draw_texture_rect_region(BREAK_FRAGMENTS_TEXTURE, destination, _break_fragment_source_region())


func _item_ball_frame_index() -> int:
	if _planet.is_empty():
		return -1
	var required_hits := maxi(int(_planet.get("required_hits", ITEM_BALL_FRAME_COUNT)), 1)
	var remaining_hits := clampi(int(_planet.get("remaining_hits", required_hits)), 0, required_hits)
	return clampi(required_hits - remaining_hits, 0, ITEM_BALL_FRAME_COUNT - 1)


func _item_ball_source_region() -> Rect2:
	var frame_index := maxi(_item_ball_frame_index(), 0)
	return Rect2(Vector2(float(frame_index) * ITEM_BALL_FRAME_SIZE.x, 0.0), ITEM_BALL_FRAME_SIZE)


func _break_fragment_source_region() -> Rect2:
	var frame_index := clampi(int(_break_fragments.get("frame_index", 0)), 0, BREAK_FRAGMENT_FRAME_COUNT - 1)
	return Rect2(Vector2(float(frame_index) * ITEM_BALL_FRAME_SIZE.x, 0.0), ITEM_BALL_FRAME_SIZE)


func _draw_orb() -> void:
	var item_type: StringName = _orb.get("item_type", &"")
	if item_type == FIRE_ITEM_TYPE:
		_draw_fire_orb()
	elif item_type == MAGNET_ITEM_TYPE:
		_draw_magnet_orb()
	else:
		_draw_blizzard_orb()


func _draw_blizzard_orb() -> void:
	var center: Vector2 = _orb["position"]
	var radius: float = _orb["radius"]
	draw_circle(center, radius + 3.0, ICE_DARK)
	draw_circle(center, radius, AURORA)
	draw_rect(Rect2(center - Vector2(4.0, 8.0), Vector2(8.0, 16.0)), ICE_LIGHT)
	draw_rect(Rect2(center - Vector2(8.0, 4.0), Vector2(16.0, 8.0)), ICE_LIGHT)


func _draw_fire_orb() -> void:
	var center: Vector2 = _orb["position"]
	var radius: float = _orb["radius"]
	var texture_size := FIRE_ORB_TEXTURE.get_size()
	var max_size := Vector2(radius * 2.0, radius * 2.0)
	var scale_factor := minf(max_size.x / texture_size.x, max_size.y / texture_size.y)
	var draw_size := texture_size * scale_factor
	draw_texture_rect(FIRE_ORB_TEXTURE, Rect2(center - draw_size * 0.5, draw_size), false)


func _draw_magnet_orb() -> void:
	var center: Vector2 = _orb["position"]
	var radius: float = _orb["radius"]
	var scale_factor := radius * 2.0 / 64.0
	var origin := center - Vector2(32.0, 32.0) * scale_factor
	for pixel: Array in MagnetOrbPortraitScript.PIXELS:
		var rect := Rect2(
			origin + Vector2(float(pixel[0]), float(pixel[1])) * scale_factor,
			Vector2(float(pixel[2]), float(pixel[3])) * scale_factor
		)
		draw_rect(rect, Color(String(pixel[4])))


func get_visual_snapshot() -> Dictionary:
	return {
		"planet_visible": not _planet.is_empty(),
		"item_ball_radius": float(_planet.get("radius", 0.0)),
		"item_ball_remaining_hits": int(_planet.get("remaining_hits", -1)),
		"item_ball_frame_index": _item_ball_frame_index(),
		"item_ball_source_region": _item_ball_source_region() if not _planet.is_empty() else Rect2(),
		"break_fragments_visible": not _break_fragments.is_empty(),
		"break_fragment_frame_index": int(_break_fragments.get("frame_index", -1)),
		"break_fragment_source_region": _break_fragment_source_region() if not _break_fragments.is_empty() else Rect2(),
		"orb_visible": not _orb.is_empty(),
		"orb_type": StringName(_orb.get("item_type", &"")),
		"orb_position": _orb.get("position", Vector2.ZERO),
		"orb_motion_frozen": _orb_motion_frozen,
		"blizzard_active": _blizzard_active,
		"snow_particle_count": SNOW_PARTICLE_COUNT if _blizzard_active else 0,
		"remaining_seconds": _blizzard_remaining,
	}
