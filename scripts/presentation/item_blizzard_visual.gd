class_name ItemBlizzardVisual
extends Node2D

## Content-owned, read-only Blizzard visual. Integration mounts this node under
## Main and connects ItemManager/ItemBlizzard signals; it never changes gameplay.

const ITEM_TYPE := &"blizzard"
const SNOW_PARTICLE_COUNT := 48
const PLAY_FIELD := Rect2(500.0, 0.0, 600.0, 900.0)
const ICE_DARK := Color("244466")
const ICE_MID := Color("5caed0")
const ICE_LIGHT := Color("d8fbff")
const AURORA := Color("78f4ee")
const BLIZZARD_CRYSTAL_TEXTURE: Texture2D = preload("res://assets/particles/items/blizzard/blizzard_crystal.png")

signal activation_cue_requested(event_id: int)

var _planet := {}
var _orb := {}
var _blizzard_active := false
var _blizzard_remaining := 0.0
var _elapsed := 0.0
var _cutin_event_id := -1
var _cutin_seconds := 0.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func show_item_planet_spawned(item_type: StringName, world_position: Vector2, radius: float) -> void:
	if item_type != ITEM_TYPE:
		return
	_planet = {"position": world_position, "radius": radius, "hits": 0, "required_hits": 5}
	queue_redraw()


func show_item_planet_damaged(item_type: StringName, current_hits: int, required_hits: int, world_position: Vector2) -> void:
	if item_type != ITEM_TYPE:
		return
	_planet = {
		"position": world_position,
		"radius": float(_planet.get("radius", 24.0)),
		"hits": current_hits,
		"required_hits": required_hits,
	}
	queue_redraw()


func show_item_planet_broken(item_type: StringName, _world_position: Vector2) -> void:
	if item_type == ITEM_TYPE:
		_planet.clear()
		queue_redraw()


func show_item_orb_spawned(item_type: StringName, world_position: Vector2) -> void:
	if item_type != ITEM_TYPE:
		return
	_orb = {"position": world_position, "radius": 16.0}
	queue_redraw()


func hide_item_orb(item_type: StringName, _world_position: Vector2) -> void:
	if item_type == ITEM_TYPE:
		_orb.clear()
		queue_redraw()


func set_blizzard_state(snapshot: Dictionary) -> void:
	if StringName(snapshot.get("item_type", &"")) != ITEM_TYPE:
		return
	_blizzard_active = bool(snapshot.get("active", false))
	_blizzard_remaining = maxf(float(snapshot.get("remaining_seconds", 0.0)), 0.0)
	queue_redraw()


func play_item_cutin(event_id: int, item_type: StringName, _world_position: Vector2) -> bool:
	if item_type != ITEM_TYPE or event_id < 0 or _cutin_event_id >= 0:
		return false
	_cutin_event_id = event_id
	_cutin_seconds = 0.65
	queue_redraw()
	return true


func reset_runtime() -> void:
	_planet.clear()
	_orb.clear()
	_blizzard_active = false
	_blizzard_remaining = 0.0
	_elapsed = 0.0
	_cutin_event_id = -1
	_cutin_seconds = 0.0
	queue_redraw()


func _physics_process(delta: float) -> void:
	_elapsed += maxf(delta, 0.0)
	if _cutin_event_id >= 0:
		_cutin_seconds = maxf(0.0, _cutin_seconds - delta)
		if is_zero_approx(_cutin_seconds):
			var event_id := _cutin_event_id
			_cutin_event_id = -1
			activation_cue_requested.emit(event_id)
	if not _orb.is_empty():
		_orb["position"] = (_orb["position"] as Vector2) + Vector2.DOWN * 160.0 * delta
	queue_redraw()


func _draw() -> void:
	if _blizzard_active:
		_draw_blizzard()
	if not _planet.is_empty():
		_draw_ice_planet()
	if not _orb.is_empty():
		_draw_orb()
	if _cutin_event_id >= 0:
		_draw_item_cutin()


func _draw_blizzard() -> void:
	for index in range(SNOW_PARTICLE_COUNT):
		var lane := float((index * 83) % 593) / 593.0
		var phase := fmod(_elapsed * (94.0 + float(index % 7) * 9.0) + float(index * 41), PLAY_FIELD.size.y + 32.0)
		var x := PLAY_FIELD.position.x + 4.0 + lane * (PLAY_FIELD.size.x - 8.0)
		var size := 2.0 + float(index % 3)
		draw_rect(Rect2(Vector2(x, PLAY_FIELD.position.y + phase - 16.0), Vector2(size, size)), ICE_LIGHT * Color(1.0, 1.0, 1.0, 0.72))
	var banner := Rect2(PLAY_FIELD.get_center() - Vector2(94.0, 33.0), Vector2(188.0, 24.0))
	draw_rect(banner.grow(3.0), ICE_DARK * Color(1.0, 1.0, 1.0, 0.9))
	draw_rect(banner, AURORA * Color(1.0, 1.0, 1.0, 0.92), false, 2.0)
	draw_string(ThemeDB.fallback_font, banner.position + Vector2(27.0, 17.0), "BLIZZARD!  %.1fs" % _blizzard_remaining, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, ICE_LIGHT)


func _draw_item_cutin() -> void:
	var panel := Rect2(PLAY_FIELD.get_center() - Vector2(132.0, 67.0), Vector2(264.0, 134.0))
	draw_rect(PLAY_FIELD, Color(0.02, 0.10, 0.19, 0.58))
	draw_rect(panel.grow(4.0), ICE_DARK)
	draw_rect(panel, AURORA, false, 2.0)
	draw_texture_rect(BLIZZARD_CRYSTAL_TEXTURE, Rect2(panel.position + Vector2(16.0, 19.0), Vector2(96.0, 96.0)), false)
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(126.0, 51.0), "BLIZZARD", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 22, ICE_LIGHT)
	draw_string(ThemeDB.fallback_font, panel.position + Vector2(126.0, 79.0), "SPAWN RATE x3", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, Color.WHITE)


func _draw_ice_planet() -> void:
	var center: Vector2 = _planet["position"]
	var radius: float = _planet["radius"]
	# User-selected ImageGen crystal. It keeps its transparent pixel-art source
	# and is rendered on an integer 64px display box with nearest filtering.
	var display_size := Vector2.ONE * maxf(radius * 2.67, 64.0)
	draw_texture_rect(BLIZZARD_CRYSTAL_TEXTURE, Rect2(center - display_size * 0.5, display_size), false)
	var hits: int = _planet["hits"]
	for crack in range(hits):
		var direction := Vector2.RIGHT.rotated(TAU * float(crack) / 5.0)
		var crack_start := center + direction * 12.0
		var crack_end := center + direction * 34.0 + direction.rotated(0.55) * 8.0
		draw_line(crack_start, crack_end, ICE_DARK, 2.0, false)
	draw_string(ThemeDB.fallback_font, center + Vector2(-58.0, -radius * 2.45), "ICE CRYSTAL %d/5" % hits, HORIZONTAL_ALIGNMENT_LEFT, -1.0, 11, ICE_LIGHT)


func _draw_orb() -> void:
	var center: Vector2 = _orb["position"]
	var radius: float = _orb["radius"]
	draw_circle(center, radius + 3.0, ICE_DARK)
	draw_circle(center, radius, AURORA)
	draw_rect(Rect2(center - Vector2(4.0, 8.0), Vector2(8.0, 16.0)), ICE_LIGHT)
	draw_rect(Rect2(center - Vector2(8.0, 4.0), Vector2(16.0, 8.0)), ICE_LIGHT)


func get_visual_snapshot() -> Dictionary:
	return {
		"planet_visible": not _planet.is_empty(),
		"orb_visible": not _orb.is_empty(),
		"blizzard_active": _blizzard_active,
		"snow_particle_count": SNOW_PARTICLE_COUNT if _blizzard_active else 0,
		"remaining_seconds": _blizzard_remaining,
		"cutin_active": _cutin_event_id >= 0,
	}
