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
const BLIZZARD_CRYSTAL_SOURCE_PATH := "res://assets/particles/items/blizzard/blizzard_crystal.png"

var _planet := {}
var _orb := {}
var _blizzard_active := false
var _blizzard_remaining := 0.0
var _elapsed := 0.0
var _blizzard_crystal_texture: ImageTexture


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var crystal_image := Image.load_from_file(BLIZZARD_CRYSTAL_SOURCE_PATH)
	if crystal_image != null:
		_blizzard_crystal_texture = ImageTexture.create_from_image(crystal_image)
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


func reset_runtime() -> void:
	_planet.clear()
	_orb.clear()
	_blizzard_active = false
	_blizzard_remaining = 0.0
	_elapsed = 0.0
	queue_redraw()


func _physics_process(delta: float) -> void:
	_elapsed += maxf(delta, 0.0)
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


func _draw_ice_planet() -> void:
	var center: Vector2 = _planet["position"]
	var radius: float = _planet["radius"]
	# User-selected ImageGen crystal. It keeps its transparent pixel-art source
	# and is rendered on an integer 64px display box with nearest filtering.
	var display_size := Vector2.ONE * maxf(radius * 2.67, 64.0)
	if _blizzard_crystal_texture != null:
		draw_texture_rect(_blizzard_crystal_texture, Rect2(center - display_size * 0.5, display_size), false)
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
	}
