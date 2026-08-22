class_name BallRenderer
extends Node2D

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallTextureLodCatalogScript = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")

const FIRST_STANDARD_GLOBAL_LEVEL := 0
const LAST_STANDARD_GLOBAL_LEVEL := 13
const BLACK_HOLE_GLOBAL_LEVEL := 14
const STANDARD_BATCH_COUNT := LAST_STANDARD_GLOBAL_LEVEL + 1

const CIRCLE_SHADER := preload("res://scripts/simulation/ball_renderer_circle.gdshader")

@export var simulation_path: NodePath
@export var ball_color := Color(0.86, 0.92, 1.0, 1.0)

var _simulation: SimulationManager
var _ball_catalog = BallCatalogScript.new()
var _ball_texture_lod_catalog = BallTextureLodCatalogScript.new()
var _batches: Array[MultiMeshInstance2D] = []
var _multimeshes: Array[MultiMesh] = []
var _circle_materials: Array[ShaderMaterial] = []
var _batch_transform_cache: Array = []
var _batch_capacities := PackedInt32Array()
var _level_counts := PackedInt32Array()
var _level_offsets := PackedInt32Array()
var _level_cursors := PackedInt32Array()
var _ordered_snapshot_indices := PackedInt32Array()
var _special_positions := PackedVector2Array()
var _special_radii := PackedFloat32Array()
var _special_levels := PackedInt32Array()
var _black_hole_positions := PackedVector2Array()
var _black_hole_radii := PackedFloat32Array()
var _clip_rect := Rect2()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_create_standard_batches()
	if not simulation_path.is_empty():
		set_simulation_manager(get_node_or_null(simulation_path) as SimulationManager)


func _process(_delta: float) -> void:
	refresh_render_snapshot()


func _draw() -> void:
	for index in range(_special_positions.size()):
		var definition = _ball_catalog.get_definition(_special_levels[index])
		var color: Color = definition.base_color if definition != null else ball_color
		draw_circle(_special_positions[index], _special_radii[index], color)
	for index in range(_black_hole_positions.size()):
		var position := _black_hole_positions[index]
		var radius := _black_hole_radii[index]
		draw_circle(position, radius + 3.0, Color(0.35, 0.17, 0.62, 0.9), false, 3.0)
		draw_circle(position, radius, Color(0.06, 0.03, 0.12, 1.0))


func set_simulation_manager(simulation: SimulationManager) -> void:
	_simulation = simulation
	refresh_render_snapshot()


func refresh_render_snapshot() -> void:
	if not is_instance_valid(_simulation):
		return

	var snapshot: Dictionary = _simulation.get_render_snapshot()
	var snapshot_positions: PackedVector2Array = snapshot["positions"]
	var snapshot_radii: PackedFloat32Array = snapshot["radii"]
	var snapshot_global_levels: PackedInt32Array = snapshot["global_levels"]
	var snapshot_count: int = snapshot["count"]
	_prepare_level_buckets(snapshot_count, snapshot_global_levels)
	_update_standard_batches(snapshot_positions, snapshot_radii)
	_update_special_fallback(snapshot_positions, snapshot_radii, snapshot_global_levels)
	_clip_rect = _simulation.get_active_play_field_rect()
	_update_clip_rect()
	_update_black_holes()
	queue_redraw()


func get_render_metrics() -> Dictionary:
	return {
		"standard_ball_count": _ordered_snapshot_indices.size(),
		"special_fallback_count": _special_positions.size(),
		"black_hole_count": _black_hole_positions.size(),
		"batch_visible_counts": _level_counts.duplicate(),
		"batch_capacities": _batch_capacities.duplicate(),
		"clip_rect": _clip_rect,
	}


func get_black_hole_render_position(index: int) -> Vector2:
	return _black_hole_positions[index] if index >= 0 and index < _black_hole_positions.size() else Vector2.ZERO


func get_batch_instance_transform(global_level: int, instance_index: int) -> Transform2D:
	if not _is_standard_global_level(global_level):
		return Transform2D.IDENTITY
	if instance_index < 0 or instance_index >= _level_counts[global_level]:
		return Transform2D.IDENTITY
	return _batch_transform_cache[global_level][instance_index]


func _create_standard_batches() -> void:
	_batch_capacities.resize(STANDARD_BATCH_COUNT)
	_level_counts.resize(STANDARD_BATCH_COUNT)
	_level_offsets.resize(STANDARD_BATCH_COUNT)
	_level_cursors.resize(STANDARD_BATCH_COUNT)
	for global_level in range(FIRST_STANDARD_GLOBAL_LEVEL, LAST_STANDARD_GLOBAL_LEVEL + 1):
		var multimesh := MultiMesh.new()
		multimesh.transform_format = MultiMesh.TRANSFORM_2D
		multimesh.use_colors = true
		multimesh.mesh = _create_circle_mesh()

		var batch := MultiMeshInstance2D.new()
		batch.name = "LevelBatch%d" % global_level
		batch.multimesh = multimesh
		batch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var circle_material := _create_circle_material()
		var definition = _ball_catalog.get_definition(global_level)
		if definition != null and definition.texture != null:
			batch.texture = definition.texture
		else:
			batch.material = circle_material
		add_child(batch)
		_batches.append(batch)
		_multimeshes.append(multimesh)
		_circle_materials.append(circle_material)
		_batch_transform_cache.append([])


func _create_circle_mesh() -> QuadMesh:
	var mesh := QuadMesh.new()
	mesh.size = Vector2(2.0, 2.0)
	return mesh


func _create_circle_material() -> ShaderMaterial:
	var material := ShaderMaterial.new()
	material.shader = CIRCLE_SHADER
	material.set_shader_parameter("play_field_rect", Vector4(_clip_rect.position.x, _clip_rect.position.y, _clip_rect.end.x, _clip_rect.end.y))
	return material


func _update_clip_rect() -> void:
	var shader_rect := Vector4(_clip_rect.position.x, _clip_rect.position.y, _clip_rect.end.x, _clip_rect.end.y)
	for batch in _batches:
		var material := batch.material as ShaderMaterial
		if material != null:
			material.set_shader_parameter("play_field_rect", shader_rect)


func _prepare_level_buckets(snapshot_count: int, snapshot_global_levels: PackedInt32Array) -> void:
	_level_counts.fill(0)
	_special_positions.clear()
	_special_radii.clear()
	_special_levels.clear()
	for snapshot_index in range(snapshot_count):
		var global_level := snapshot_global_levels[snapshot_index]
		if _is_standard_global_level(global_level):
			_level_counts[global_level] += 1

	var standard_count := 0
	for global_level in range(STANDARD_BATCH_COUNT):
		_level_offsets[global_level] = standard_count
		_level_cursors[global_level] = standard_count
		standard_count += _level_counts[global_level]
		_ensure_batch_capacity(global_level, _level_counts[global_level])
		_batches[global_level].visible = _level_counts[global_level] > 0
		_multimeshes[global_level].visible_instance_count = _level_counts[global_level]

	_ordered_snapshot_indices.resize(standard_count)
	for snapshot_index in range(snapshot_count):
		var global_level := snapshot_global_levels[snapshot_index]
		if _is_standard_global_level(global_level):
			var write_index := _level_cursors[global_level]
			_ordered_snapshot_indices[write_index] = snapshot_index
			_level_cursors[global_level] += 1


func _update_standard_batches(snapshot_positions: PackedVector2Array, snapshot_radii: PackedFloat32Array) -> void:
	for global_level in range(STANDARD_BATCH_COUNT):
		var count := _level_counts[global_level]
		var offset := _level_offsets[global_level]
		if count > 0:
			var first_snapshot_index := _ordered_snapshot_indices[offset]
			_update_batch_visual(global_level, snapshot_radii[first_snapshot_index] * 2.0)
		for instance_index in range(count):
			var snapshot_index := _ordered_snapshot_indices[offset + instance_index]
			var radius := snapshot_radii[snapshot_index]
			var instance_transform := Transform2D(Vector2(radius, 0.0), Vector2(0.0, radius), snapshot_positions[snapshot_index])
			_multimeshes[global_level].set_instance_transform_2d(instance_index, instance_transform)
			_batch_transform_cache[global_level][instance_index] = instance_transform


func _update_special_fallback(snapshot_positions: PackedVector2Array, snapshot_radii: PackedFloat32Array, snapshot_global_levels: PackedInt32Array) -> void:
	for snapshot_index in range(snapshot_global_levels.size()):
		var global_level := snapshot_global_levels[snapshot_index]
		if _is_standard_global_level(global_level):
			continue
		_special_positions.append(snapshot_positions[snapshot_index])
		_special_radii.append(snapshot_radii[snapshot_index])
		_special_levels.append(global_level)


func _update_black_holes() -> void:
	var snapshot := _simulation.get_black_hole_snapshot()
	_black_hole_positions = snapshot["positions"]
	_black_hole_radii = snapshot["radii"]


func _ensure_batch_capacity(global_level: int, required_count: int) -> void:
	if required_count <= _batch_capacities[global_level]:
		return
	var new_capacity := maxi(8, _batch_capacities[global_level] * 2)
	new_capacity = maxi(new_capacity, required_count)
	_batch_capacities[global_level] = new_capacity
	_multimeshes[global_level].instance_count = new_capacity
	_batch_transform_cache[global_level].resize(new_capacity)
	var color := _get_batch_instance_color(global_level)
	for instance_index in range(new_capacity):
		_multimeshes[global_level].set_instance_color(instance_index, color)


func _update_batch_visual(global_level: int, runtime_diameter: float) -> void:
	var definition = _ball_catalog.get_definition(global_level)
	var primary_texture: Texture2D = definition.texture if definition != null else null
	var texture := _ball_texture_lod_catalog.resolve_texture(global_level, runtime_diameter, primary_texture)
	var use_texture := texture != null
	var batch := _batches[global_level]
	var next_texture: Texture2D = texture if use_texture else null
	var next_material: Material = null if use_texture else _circle_materials[global_level]
	if batch.texture == next_texture and batch.material == next_material:
		return
	batch.texture = next_texture
	batch.material = next_material
	var color := _get_batch_instance_color(global_level)
	for instance_index in range(_batch_capacities[global_level]):
		_multimeshes[global_level].set_instance_color(instance_index, color)


func _get_batch_instance_color(global_level: int) -> Color:
	if _batches[global_level].texture != null:
		return Color.WHITE
	var definition = _ball_catalog.get_definition(global_level)
	return definition.base_color if definition != null else ball_color


func _is_standard_global_level(global_level: int) -> bool:
	return global_level >= FIRST_STANDARD_GLOBAL_LEVEL and global_level <= LAST_STANDARD_GLOBAL_LEVEL
