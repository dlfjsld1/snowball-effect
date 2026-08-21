class_name SpatialGrid
extends RefCounted

var cell_size := 32.0
var _cells_by_level: Dictionary = {}
var _maximum_radius_by_level: Dictionary = {}
var _sorted_indices: Array[int] = []
var _candidate_check_count := 0
var _cell_count := 0
var _allocated_bucket_count := 0
var _new_bucket_count := 0


func rebuild(
		positions: PackedVector2Array,
		radii: PackedFloat32Array,
		global_levels: PackedInt32Array,
		active_indices: Array[int]
) -> void:
	for level_value in _cells_by_level:
		var pooled_level_cells: Dictionary = _cells_by_level[level_value]
		for cell_value in pooled_level_cells:
			var pooled_indices: Array = pooled_level_cells[cell_value]
			pooled_indices.clear()
	for level_value in _maximum_radius_by_level:
		_maximum_radius_by_level[level_value] = 0.0
	_sorted_indices.assign(active_indices)
	_sorted_indices.sort()
	_candidate_check_count = 0
	_cell_count = 0
	_new_bucket_count = 0

	for index in _sorted_indices:
		var level := global_levels[index]
		var level_cells: Dictionary = _cells_by_level.get(level, {})
		var cell := _position_to_cell(positions[index])
		var indices: Array = level_cells.get(cell, [])
		if not level_cells.has(cell):
			level_cells[cell] = indices
			_allocated_bucket_count += 1
			_new_bucket_count += 1
		if indices.is_empty():
			_cell_count += 1
		indices.append(index)
		_cells_by_level[level] = level_cells
		_maximum_radius_by_level[level] = maxf(_maximum_radius_by_level.get(level, 0.0), radii[index])


func fill_overlapping_pairs(
		positions: PackedVector2Array,
		radii: PackedFloat32Array,
		global_levels: PackedInt32Array,
		pairs: Array[Vector2i]
) -> void:
	pairs.clear()
	_candidate_check_count = 0

	for first_index in _sorted_indices:
		var level := global_levels[first_index]
		var level_cells: Dictionary = _cells_by_level[level]
		var center_cell := _position_to_cell(positions[first_index])
		var search_distance: float = radii[first_index] + _maximum_radius_by_level[level]
		var cell_range := ceili(search_distance / cell_size)

		for cell_y in range(center_cell.y - cell_range, center_cell.y + cell_range + 1):
			for cell_x in range(center_cell.x - cell_range, center_cell.x + cell_range + 1):
				var indices: Array = level_cells.get(Vector2i(cell_x, cell_y), [])
				for second_index_value in indices:
					var second_index: int = second_index_value
					if second_index <= first_index:
						continue
					_candidate_check_count += 1
					var combined_radius := radii[first_index] + radii[second_index]
					if positions[first_index].distance_squared_to(positions[second_index]) <= combined_radius * combined_radius:
						pairs.append(Vector2i(first_index, second_index))

	pairs.sort()


func fill_non_merge_contact_pairs(
		previous_positions: PackedVector2Array,
		positions: PackedVector2Array,
		radii: PackedFloat32Array,
		global_levels: PackedInt32Array,
		stage_top_global_level: int,
		travel_padding: float,
		pairs: Array[Vector2i]
) -> void:
	pairs.clear()
	_candidate_check_count = 0

	for first_index in _sorted_indices:
		for level_value in _cells_by_level:
			var level: int = level_value
			if level == global_levels[first_index] and level != stage_top_global_level:
				continue
			var level_cells: Dictionary = _cells_by_level[level]
			var search_radius: float = radii[first_index] + float(_maximum_radius_by_level[level]) + travel_padding
			var minimum_position := Vector2(
				minf(previous_positions[first_index].x, positions[first_index].x),
				minf(previous_positions[first_index].y, positions[first_index].y)
			) - Vector2(search_radius, search_radius)
			var maximum_position := Vector2(
				maxf(previous_positions[first_index].x, positions[first_index].x),
				maxf(previous_positions[first_index].y, positions[first_index].y)
			) + Vector2(search_radius, search_radius)
			var minimum_cell := _position_to_cell(minimum_position)
			var maximum_cell := _position_to_cell(maximum_position)

			for cell_y in range(minimum_cell.y, maximum_cell.y + 1):
				for cell_x in range(minimum_cell.x, maximum_cell.x + 1):
					var indices: Array = level_cells.get(Vector2i(cell_x, cell_y), [])
					for second_index_value in indices:
						var second_index: int = second_index_value
						# One lower index owns each cross-level contact pair.
						if second_index <= first_index:
							continue
						_candidate_check_count += 1
						pairs.append(Vector2i(first_index, second_index))

	pairs.sort()


func get_candidate_check_count() -> int:
	return _candidate_check_count


func get_cell_count() -> int:
	return _cell_count


func get_allocated_bucket_count() -> int:
	return _allocated_bucket_count


func get_new_bucket_count() -> int:
	return _new_bucket_count


func _position_to_cell(position: Vector2) -> Vector2i:
	return Vector2i(floori(position.x / cell_size), floori(position.y / cell_size))
