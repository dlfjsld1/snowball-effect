extends Node

const VOID_CATHEDRAL_RESOURCE := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres"
const EFFECT_SOURCE := "res://scripts/presentation/black_hole_phase_effect.gd"
const CAPTURE_ROOT := "res://docs/design/mockups/drafts/galactic-black-hole-redesign-v1"
const FIELD_RECT := Rect2(Vector2(280.0, 50.0), Vector2(1040.0, 818.0))
const BACKGROUND_COLOR := Color("080d17")
const PIXEL_EPSILON := 0.025

var _pixel_oracle_ran := false


class CueSource extends Node:
	var positions := PackedVector2Array([Vector2(680.0, 430.0)])
	var radii := PackedFloat32Array([16.0])

	func get_black_hole_snapshot() -> Dictionary:
		return {
			"count": positions.size(),
			"positions": positions.duplicate(),
			"radii": radii.duplicate(),
		}


func _ready() -> void:
	var background := ColorRect.new()
	background.color = BACKGROUND_COLOR
	background.size = Vector2(1600.0, 900.0)
	add_child(background)

	var source := CueSource.new()
	add_child(source)
	var effect := BlackHolePhaseEffect.new()
	effect.size = Vector2(1600.0, 900.0)
	add_child(effect)
	effect.set_simulation_source(source)
	await get_tree().process_frame

	await _verify_normal_one(effect, source)
	await _verify_normal_two(effect, source)
	await _verify_reduced_one(effect, source)
	await _verify_reduced_two(effect, source)
	var frame_sample := await _measure_frames(60)

	var effect_source := FileAccess.get_file_as_string(EFFECT_SOURCE)
	assert(not effect_source.contains("_draw_dashed_ring"), "S8-G7 must remove the 300-unit dashed influence ring draw path.")
	assert(not effect_source.contains("_draw_orbit_pixels"), "S8-G7 must remove the orbiting square-dot draw path.")
	assert(not effect_source.contains("DEFAULT_INFLUENCE_RADIUS"), "Presentation must not advertise the old non-authoritative 300-unit radius.")

	effect.reset_effect()
	var reset_metrics := effect.get_visual_metrics()
	assert(not reset_metrics["visible"] and reset_metrics["black_hole_count"] == 0)
	assert(reset_metrics["lensing_arc_count"] == 0 and reset_metrics["trail_stroke_count"] == 0)
	print("S8_G7_VERIFIED influence_rings=0 orbit_squares=0 arcs_per_entity=2 trail_strokes_per_entity=2 reduced_trails=0 one_two_entities=true reset=true pixel_oracle=%s sample_frames=60 avg_fps=%.2f max_frame_ms=%.2f resource=%s" % [_pixel_oracle_ran, frame_sample["average_fps"], frame_sample["max_frame_ms"], VOID_CATHEDRAL_RESOURCE])
	get_tree().quit()


func _verify_normal_one(effect: BlackHolePhaseEffect, source: CueSource) -> void:
	source.positions = PackedVector2Array([Vector2(680.0, 430.0)])
	source.radii = PackedFloat32Array([16.0])
	effect.begin_phase(false)
	effect.set_phase_progress(1.0, FIELD_RECT)
	source.positions[0] = Vector2(692.0, 430.0)
	await _sync_snapshot(effect)
	var metrics := effect.get_visual_metrics()
	_assert_common_metrics(metrics, 1, 2)
	assert(metrics["trail_stroke_count"] == 2 and metrics["trail_marker_count"] == 0)
	var directions: PackedVector2Array = metrics["trail_directions"]
	assert(directions.size() == 1 and directions[0].dot(Vector2.LEFT) > 0.99, "Trail strokes must remain behind the latest movement direction.")
	if DisplayServer.get_name() != "headless":
		var image := await _capture_rendered_image()
		_assert_near_field_pixels(image, source.positions)
		assert(_count_non_background_pixels(image, Rect2i(638, 426, 15, 9)) > 0, "Normal mode must render the short rear motion trail.")
		_assert_no_distant_cue_pixels(image, source.positions)
		_pixel_oracle_ran = true
	await _save_capture_if_native("s8-g7-cue-normal-one-1600x900.png")


func _verify_normal_two(effect: BlackHolePhaseEffect, source: CueSource) -> void:
	source.positions = PackedVector2Array([Vector2(692.0, 430.0), Vector2(948.0, 430.0)])
	source.radii = PackedFloat32Array([16.0, 16.0])
	await _sync_snapshot(effect)
	var metrics := effect.get_visual_metrics()
	_assert_common_metrics(metrics, 2, 4)
	assert(metrics["trail_stroke_count"] == 4 and metrics["trail_marker_count"] == 0)
	if DisplayServer.get_name() != "headless":
		var image := await _capture_rendered_image()
		_assert_near_field_pixels(image, source.positions)
		_assert_no_distant_cue_pixels(image, source.positions)
	await _save_capture_if_native("s8-g7-cue-normal-two-1600x900.png")


func _verify_reduced_one(effect: BlackHolePhaseEffect, source: CueSource) -> void:
	effect.reset_effect()
	source.positions = PackedVector2Array([Vector2(680.0, 430.0)])
	source.radii = PackedFloat32Array([16.0])
	effect.begin_phase(true)
	effect.set_phase_progress(1.0, FIELD_RECT)
	source.positions[0] = Vector2(692.0, 430.0)
	await _sync_snapshot(effect)
	var metrics := effect.get_visual_metrics()
	_assert_common_metrics(metrics, 1, 2)
	assert(metrics["reduced_effects"] and metrics["trail_stroke_count"] == 0)
	if DisplayServer.get_name() != "headless":
		var image := await _capture_rendered_image()
		_assert_near_field_pixels(image, source.positions)
		assert(_count_non_background_pixels(image, Rect2i(638, 426, 15, 9)) == 0, "Reduced Effects must omit the rear motion trail pixels.")
		_assert_no_distant_cue_pixels(image, source.positions)
	await _save_capture_if_native("s8-g7-cue-reduced-one-1600x900.png")


func _verify_reduced_two(effect: BlackHolePhaseEffect, source: CueSource) -> void:
	source.positions = PackedVector2Array([Vector2(692.0, 430.0), Vector2(948.0, 430.0)])
	source.radii = PackedFloat32Array([16.0, 16.0])
	await _sync_snapshot(effect)
	var metrics := effect.get_visual_metrics()
	_assert_common_metrics(metrics, 2, 4)
	assert(metrics["trail_stroke_count"] == 0 and metrics["trail_marker_count"] == 0)
	if DisplayServer.get_name() != "headless":
		var image := await _capture_rendered_image()
		_assert_near_field_pixels(image, source.positions)
		_assert_no_distant_cue_pixels(image, source.positions)
	await _save_capture_if_native("s8-g7-cue-reduced-two-1600x900.png")


func _assert_common_metrics(metrics: Dictionary, expected_entities: int, expected_arcs: int) -> void:
	assert(metrics["black_hole_count"] == expected_entities)
	assert(metrics["core_count"] == expected_entities)
	assert(metrics["black_hole_visual_resource"] == VOID_CATHEDRAL_RESOURCE)
	assert(metrics["influence_ring_count"] == 0)
	assert(metrics["orbit_square_count"] == 0)
	assert(metrics["horizon_ring_count"] == 0)
	assert(metrics["lensing_arc_count"] == expected_arcs)


func _save_capture_if_native(file_name: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var image := await _capture_rendered_image()
	assert(image != null and image.get_size() == Vector2i(1600, 900))
	assert(image.save_png("%s/%s" % [CAPTURE_ROOT, file_name]) == OK)


func _capture_rendered_image() -> Image:
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image := get_viewport().get_texture().get_image()
	assert(image != null and image.get_size() == Vector2i(1600, 900), "S8-G7 pixel oracle requires the rendered 1600x900 viewport.")
	return image


func _assert_near_field_pixels(image: Image, positions: PackedVector2Array) -> void:
	for center in positions:
		var near_field_count := _count_non_background_annulus(image, center, 25.0, 40.0, PackedVector2Array(), 0.0)
		assert(near_field_count >= 16, "Each Black Hole must render visible close-range lensing arcs outside the bitmap core.")


func _assert_no_distant_cue_pixels(image: Image, positions: PackedVector2Array) -> void:
	for center in positions:
		assert(_count_non_background_annulus(image, center, 70.0, 260.0, positions, 64.0) == 0, "Legacy orbit/reticle pixels must not remain outside the approved near field.")
		assert(_count_non_background_annulus(image, center, 270.0, 330.0, positions, 64.0) == 0, "Legacy 300-unit influence ring pixels must not remain.")


func _count_non_background_annulus(image: Image, center: Vector2, inner_radius: float, outer_radius: float, excluded_centers: PackedVector2Array, excluded_radius: float) -> int:
	var count := 0
	var min_x := maxi(int(floor(center.x - outer_radius)), 0)
	var max_x := mini(int(ceil(center.x + outer_radius)), image.get_width() - 1)
	var min_y := maxi(int(floor(center.y - outer_radius)), 0)
	var max_y := mini(int(ceil(center.y + outer_radius)), image.get_height() - 1)
	var inner_squared := inner_radius * inner_radius
	var outer_squared := outer_radius * outer_radius
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var distance_squared := Vector2(float(x), float(y)).distance_squared_to(center)
			if distance_squared < inner_squared or distance_squared > outer_squared:
				continue
			var excluded := false
			for excluded_center in excluded_centers:
				if excluded_radius > 0.0 and Vector2(float(x), float(y)).distance_squared_to(excluded_center) < excluded_radius * excluded_radius:
					excluded = true
					break
			if excluded:
				continue
			if not image.get_pixel(x, y).is_equal_approx(BACKGROUND_COLOR):
				var color_distance := image.get_pixel(x, y) - BACKGROUND_COLOR
				if absf(color_distance.r) > PIXEL_EPSILON or absf(color_distance.g) > PIXEL_EPSILON or absf(color_distance.b) > PIXEL_EPSILON:
					count += 1
	return count


func _count_non_background_pixels(image: Image, rect: Rect2i) -> int:
	var count := 0
	for y in range(maxi(rect.position.y, 0), mini(rect.end.y, image.get_height())):
		for x in range(maxi(rect.position.x, 0), mini(rect.end.x, image.get_width())):
			var color_distance := image.get_pixel(x, y) - BACKGROUND_COLOR
			if absf(color_distance.r) > PIXEL_EPSILON or absf(color_distance.g) > PIXEL_EPSILON or absf(color_distance.b) > PIXEL_EPSILON:
				count += 1
	return count


func _sync_snapshot(effect: BlackHolePhaseEffect) -> void:
	effect.call("_refresh_snapshot")
	effect.queue_redraw()
	await get_tree().process_frame


func _measure_frames(frame_count: int) -> Dictionary:
	var started_usec := Time.get_ticks_usec()
	var previous_usec := started_usec
	var max_frame_usec := 0
	for frame in range(frame_count):
		await get_tree().process_frame
		var current_usec := Time.get_ticks_usec()
		max_frame_usec = maxi(max_frame_usec, current_usec - previous_usec)
		previous_usec = current_usec
	var elapsed_seconds := maxf(float(previous_usec - started_usec) / 1000000.0, 0.000001)
	return {
		"average_fps": float(frame_count) / elapsed_seconds,
		"max_frame_ms": float(max_frame_usec) / 1000.0,
	}
