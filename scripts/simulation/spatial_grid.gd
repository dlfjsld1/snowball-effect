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


## Returns the number of bounded local candidates inspected. The caller supplies
## a reusable output array so Magnet never allocates or performs an all-pairs
## search. Results are the closest eligible entries among the sampled local
## candidates and are stable by distance, then slot index.
func fill_same_level_magnet_neighbors(
		positions: PackedVector2Array,
		first_index: int,
		global_level: int,
		influence_radius: float,
		neighbor_limit: int,
		candidate_sample_limit: int,
		neighbors: Array[int]
) -> int:
	neighbors.clear()
	if influence_radius <= 0.0 or neighbor_limit < 1 or candidate_sample_limit < 1:
		return 0
	var level_cells: Dictionary = _cells_by_level.get(global_level, {})
	if level_cells.is_empty():
		return 0

	var center_cell := _position_to_cell(positions[first_index])
	var cell_range := ceili(influence_radius / cell_size)
	var closest_first := -1
	var closest_second := -1
	var closest_first_distance := INF
	var closest_second_distance := INF
	var influence_radius_squared := influence_radius * influence_radius
	var inspected := 0

	for ring in range(cell_range + 1):
		for cell_y in range(center_cell.y - ring, center_cell.y + ring + 1):
			for cell_x in range(center_cell.x - ring, center_cell.x + ring + 1):
				if ring > 0 and cell_x != center_cell.x - ring and cell_x != center_cell.x + ring and cell_y != center_cell.y - ring and cell_y != center_cell.y + ring:
					continue
				var indices: Array = level_cells.get(Vector2i(cell_x, cell_y), [])
				for second_index_value in indices:
					var second_index: int = second_index_value
					if second_index == first_index:
						continue
					inspected += 1
					var distance_squared := positions[first_index].distance_squared_to(positions[second_index])
					if distance_squared <= influence_radius_squared:
						if _is_better_neighbor(distance_squared, second_index, closest_first_distance, closest_first):
							closest_second = closest_first
							closest_second_distance = closest_first_distance
							closest_first = second_index
							closest_first_distance = distance_squared
						elif neighbor_limit > 1 and _is_better_neighbor(distance_squared, second_index, closest_second_distance, closest_second):
							closest_second = second_index
							closest_second_distance = distance_squared
					if inspected >= candidate_sample_limit:
						if closest_first >= 0:
							neighbors.append(closest_first)
						if neighbor_limit > 1 and closest_second >= 0:
							neighbors.append(closest_second)
						return inspected

	if closest_first >= 0:
		neighbors.append(closest_first)
	if neighbor_limit > 1 and closest_second >= 0:
		neighbors.append(closest_second)
	return inspected


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


func _is_better_neighbor(distance_squared: float, index: int, best_distance_squared: float, best_index: int) -> bool:
	return distance_squared < best_distance_squared or (is_equal_approx(distance_squared, best_distance_squared) and (best_index < 0 or index < best_index))
