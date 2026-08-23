extends Node

const ItemManagerScript = preload("res://scripts/gameplay/item_manager.gd")
const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")

var _failures := 0
var _damage_count := 0
var _planet_spawned_count := 0
var _broken_count := 0
var _spawned_count := 0
var _collected_count := 0
var _missed_count := 0


func _ready() -> void:
	var manager = ItemManagerScript.new()
	add_child(manager)
	manager.item_planet_spawned.connect(func(_type, _position, _radius): _planet_spawned_count += 1)
	manager.item_planet_damaged.connect(func(_type, _hits, _required, _position): _damage_count += 1)
	manager.item_planet_broken.connect(func(_type, _position): _broken_count += 1)
	manager.item_orb_spawned.connect(func(_type, _position): _spawned_count += 1)
	manager.item_collected.connect(func(_type, _position): _collected_count += 1)
	manager.item_orb_missed.connect(func(_type, _position): _missed_count += 1)

	var stage = StageCatalogScript.new().get_stage(0)
	var play_field := Rect2(0.0, 0.0, 400.0, 400.0)
	manager.enter_stage(stage, play_field, 16.0, 0.0, &"blizzard", 7)
	manager.advance(0.01)
	var planet := manager.get_item_ball_snapshot()
	_expect(not planet.is_empty() and _planet_spawned_count == 1, "Stage must spawn exactly one Item Ball and one matching display signal after its scheduled delay.")
	_expect(is_equal_approx(float(planet.get("radius", 0.0)), 24.0), "Item Ball gameplay collision radius must remain 24px.")

	manager.process_ball_snapshots([_snapshot(1, 1, planet.position, 16.0)])
	_expect(_damage_count == 0, "Local level below 2 must not damage an Item Ball.")
	for ball_id in range(10, 15):
		manager.process_ball_snapshots([_snapshot(ball_id, 2, planet.position, 16.0)])
		manager.process_ball_snapshots([])
	_expect(_damage_count == 5, "Five separated local-level-2 contacts must deal exactly five damage events.")
	_expect(_broken_count == 1 and _spawned_count == 1, "The fifth valid contact must break once and spawn exactly one Orb.")
	_expect(manager.get_item_ball_snapshot().is_empty(), "Broken Item Ball must be removed before the Orb exists.")
	var orb := manager.get_item_orb_snapshot()
	_expect(not orb.is_empty() and is_equal_approx(orb.radius, 16.0) and orb.velocity == Vector2.DOWN * 160.0, "Orb must use local-level-2 radius and a vertical-down initial velocity.")
	_expect(manager.try_collect_orb(orb.position, 1.0), "Paddle pickup must collect an overlapping Orb.")
	_expect(not manager.try_collect_orb(orb.position, 1.0) and _collected_count == 1, "Collected Orb must resolve once and never activate twice.")

	manager.enter_stage(stage, play_field, 16.0, 0.0, &"fire_core", 9)
	manager.advance(0.01)
	planet = manager.get_item_ball_snapshot()
	for ball_id in range(20, 25):
		manager.process_ball_snapshots([_snapshot(ball_id, 2, planet.position, 16.0)])
		manager.process_ball_snapshots([])
	manager.advance(4.0)
	_expect(_missed_count == 1, "An Orb crossing the open bottom must emit one miss and no collection.")
	_expect(manager.get_item_orb_snapshot().is_empty(), "Missed Orb must be removed.")

	if _failures == 0:
		print("S7_G1C_VERIFIED item_ball=once hits=5 orb=collect_or_miss")
	get_tree().quit(_failures)


func _snapshot(id: int, global_level: int, position: Vector2, radius: float) -> Dictionary:
	return {"id": id, "global_level": global_level, "position": position, "radius": radius}


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G1C verification failed: %s" % message)
