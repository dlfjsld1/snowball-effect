extends SceneTree

## Deterministic, hand-authored native-size Ground ball sprite generator.
##
## Every output pixel is selected from the fixed palette below. The script
## draws directly at the runtime diameter; it never rescales or filters an
## intermediate image.

const OUTPUT_ROOT := "res://assets/sprites/balls/ground/runtime"

const OUTLINE := Color8(11, 23, 48, 255) # #0B1730
const GROUND_NIGHT := Color8(31, 40, 93, 255) # #1F285D
const ICE_DEEP := Color8(46, 85, 119, 255) # #2E5577
const GIANT_BLUE := Color8(58, 141, 255, 255) # #3A8DFF
const ICE_MID := Color8(75, 132, 154, 255) # #4B849A
const ICE_BLUE := Color8(114, 216, 255, 255) # #72D8FF
const FROST := Color8(152, 216, 177, 255) # #98D8B1
const MOON_MID := Color8(200, 201, 216, 255) # #C8C9D8
const GROUND_SNOW := Color8(236, 242, 203, 255) # #ECF2CB
const SNOW_LIGHT := Color8(234, 248, 255, 255) # #EAF8FF
const SNOW_PEAK := Color8(244, 252, 255, 255) # #F4FCFF

const JOBS := [
	{"level": 0, "size": 8, "file": "ball_lv00_snowflake_8.png"},
	{"level": 1, "size": 16, "file": "ball_lv01_snowball_16.png"},
	{"level": 2, "size": 32, "file": "ball_lv02_big_snowball_32.png"},
	{"level": 3, "size": 64, "file": "ball_lv03_giant_snowball_64.png"},
	{"level": 4, "size": 128, "file": "ball_lv04_moon_128.png"},
]


func _initialize() -> void:
	var output_dir := ProjectSettings.globalize_path(OUTPUT_ROOT)
	var make_error := DirAccess.make_dir_recursive_absolute(output_dir)
	if make_error != OK:
		push_error("Could not create Ground ball output directory: %s" % make_error)
		quit(1)
		return

	for job in JOBS:
		var image := _build_sprite(int(job["level"]), int(job["size"]))
		var path := "%s/%s" % [OUTPUT_ROOT, job["file"]]
		var save_error := image.save_png(path)
		if save_error != OK:
			push_error("Could not save %s: %s" % [path, save_error])
			quit(1)
			return
		print("GROUND_BALL_WRITTEN level=%d size=%dx%d path=%s" % [job["level"], job["size"], job["size"], path])
	quit(0)


func _build_sprite(level: int, size: int) -> Image:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	match level:
		0:
			_paint_sphere(image, 1.0, [ICE_MID, ICE_BLUE, SNOW_LIGHT, SNOW_PEAK])
			_paint_snowflake_pellet(image)
		1:
			_paint_sphere(image, 1.0, [ICE_DEEP, ICE_MID, ICE_BLUE, SNOW_LIGHT, SNOW_PEAK])
			_paint_snowball(image)
		2:
			_paint_sphere(image, 2.0, [GROUND_NIGHT, ICE_DEEP, GIANT_BLUE, ICE_MID, ICE_BLUE, SNOW_LIGHT])
			_paint_big_snowball(image)
		3:
			_paint_sphere(image, 2.0, [GROUND_NIGHT, ICE_DEEP, GIANT_BLUE, ICE_MID, ICE_BLUE, SNOW_LIGHT, SNOW_PEAK])
			_paint_giant_snowball(image)
		4:
			_paint_sphere(image, 2.0, [GROUND_NIGHT, ICE_DEEP, ICE_MID, MOON_MID, GROUND_SNOW, SNOW_LIGHT])
			_paint_moon(image)
	return image


func _paint_sphere(image: Image, outline_width: float, fills: Array) -> void:
	var size := image.get_width()
	var center := Vector2(float(size - 1) * 0.5, float(size - 1) * 0.5)
	# Pixel centers at the four cardinal edges remain inside the nominal
	# collision diameter while corner pixels stay transparent.
	var radius := float(size) * 0.5 - 0.01
	for y in range(size):
		for x in range(size):
			var delta := Vector2(float(x), float(y)) - center
			var distance := delta.length()
			if distance > radius:
				continue
			var edge_depth := radius - distance
			if edge_depth < outline_width:
				# A broken ice-light rim on the upper-left and a deep, collision-
				# readable edge on the lower-right establish one shared light source.
				if delta.x + delta.y < -radius * 0.28:
					image.set_pixel(x, y, fills[fills.size() - 1])
				else:
					image.set_pixel(x, y, OUTLINE)
				continue

			# Quantized spherical lighting: broad curved value masses, never a
			# continuous gradient. The upper-left light direction is shared by all
			# five native masters.
			var normal_xy := delta / maxf(radius, 1.0)
			var normal_z := sqrt(maxf(0.0, 1.0 - normal_xy.length_squared()))
			var light := 0.38 - normal_xy.x * 0.22 - normal_xy.y * 0.25 + normal_z * 0.22
			var fill_index := clampi(int(floor(light * float(fills.size()))), 0, fills.size() - 1)
			image.set_pixel(x, y, fills[fill_index])


func _paint_snowflake_pellet(image: Image) -> void:
	# One crystalline compression seam, drawn as surface facets rather than an
	# icon floating inside a circle.
	_set_if_sphere(image, 3, 2, SNOW_PEAK)
	_set_if_sphere(image, 2, 3, SNOW_PEAK)
	_set_if_sphere(image, 3, 3, SNOW_LIGHT)
	_set_if_sphere(image, 4, 3, FROST)
	_set_if_sphere(image, 3, 4, FROST)
	_set_if_sphere(image, 5, 5, ICE_MID)


func _paint_snowball(image: Image) -> void:
	_fill_rect_if_sphere(image, Rect2i(4, 4, 3, 2), SNOW_PEAK)
	_fill_rect_if_sphere(image, Rect2i(8, 5, 2, 2), SNOW_LIGHT)
	_draw_line_if_sphere(image, Vector2i(4, 10), Vector2i(11, 10), ICE_MID)
	_draw_line_if_sphere(image, Vector2i(6, 12), Vector2i(10, 12), ICE_DEEP)
	_set_if_sphere(image, 4, 7, ICE_BLUE)
	_set_if_sphere(image, 11, 8, ICE_BLUE)


func _paint_big_snowball(image: Image) -> void:
	# Broad packed-snow shelves and a few angular ice facets increase mass
	# without introducing Moon-like circular pits.
	_fill_rect_if_sphere(image, Rect2i(8, 7, 7, 3), SNOW_PEAK)
	_fill_rect_if_sphere(image, Rect2i(16, 9, 5, 2), SNOW_LIGHT)
	_draw_line_if_sphere(image, Vector2i(5, 19), Vector2i(25, 19), ICE_MID)
	_draw_line_if_sphere(image, Vector2i(7, 20), Vector2i(23, 20), ICE_BLUE)
	_draw_line_if_sphere(image, Vector2i(8, 24), Vector2i(23, 24), ICE_DEEP)
	_draw_line_if_sphere(image, Vector2i(11, 25), Vector2i(20, 25), ICE_MID)
	_fill_polygon_if_sphere(image, [Vector2(23, 12), Vector2(27, 15), Vector2(25, 20), Vector2(21, 17)], ICE_BLUE)
	_draw_line_if_sphere(image, Vector2i(22, 12), Vector2i(26, 16), SNOW_LIGHT)
	_set_if_sphere(image, 8, 13, SNOW_LIGHT)
	_set_if_sphere(image, 14, 14, FROST)
	_set_if_sphere(image, 18, 15, ICE_MID)


func _paint_giant_snowball(image: Image) -> void:
	# Heavy compressed mass: asymmetric shelves, slab facets, and an irregular
	# frozen rim. Deliberately no circular crater vocabulary is used here.
	_fill_polygon_if_sphere(image, [Vector2(12, 12), Vector2(24, 8), Vector2(32, 12), Vector2(27, 18), Vector2(15, 18)], SNOW_LIGHT)
	_draw_line_if_sphere(image, Vector2i(15, 11), Vector2i(24, 9), SNOW_PEAK)
	_fill_polygon_if_sphere(image, [Vector2(35, 14), Vector2(47, 12), Vector2(54, 21), Vector2(48, 28), Vector2(38, 23)], ICE_MID)
	_draw_line_if_sphere(image, Vector2i(8, 32), Vector2i(51, 32), ICE_MID)
	_draw_line_if_sphere(image, Vector2i(12, 34), Vector2i(45, 34), ICE_BLUE)
	_draw_line_if_sphere(image, Vector2i(9, 42), Vector2i(31, 42), ICE_DEEP)
	_draw_line_if_sphere(image, Vector2i(34, 43), Vector2i(53, 43), GROUND_NIGHT)
	_fill_polygon_if_sphere(image, [Vector2(13, 37), Vector2(27, 34), Vector2(33, 43), Vector2(25, 51), Vector2(12, 47)], GIANT_BLUE)
	_fill_polygon_if_sphere(image, [Vector2(35, 29), Vector2(50, 26), Vector2(57, 37), Vector2(48, 47), Vector2(36, 42)], ICE_DEEP)
	_fill_polygon_if_sphere(image, [Vector2(27, 46), Vector2(40, 42), Vector2(46, 52), Vector2(37, 59), Vector2(25, 55)], ICE_MID)
	_draw_line_if_sphere(image, Vector2i(15, 36), Vector2i(27, 34), SNOW_LIGHT)
	_draw_line_if_sphere(image, Vector2i(36, 29), Vector2i(49, 27), ICE_BLUE)
	_draw_line_if_sphere(image, Vector2i(28, 46), Vector2i(39, 43), ICE_BLUE)
	_fill_rect_if_sphere(image, Rect2i(8, 26, 3, 2), ICE_BLUE)
	_fill_rect_if_sphere(image, Rect2i(19, 23, 4, 2), ICE_BLUE)
	_fill_rect_if_sphere(image, Rect2i(27, 27, 3, 2), SNOW_LIGHT)
	_fill_rect_if_sphere(image, Rect2i(48, 32, 4, 2), ICE_MID)
	_fill_rect_if_sphere(image, Rect2i(16, 52, 4, 2), ICE_DEEP)
	_fill_rect_if_sphere(image, Rect2i(45, 50, 3, 2), GROUND_NIGHT)
	# Sparse cold atmosphere stays subordinate to the main collision sphere.
	_set_atmosphere_pixel(image, 4, 18, ICE_BLUE)
	_set_atmosphere_pixel(image, 58, 15, SNOW_LIGHT)
	_set_atmosphere_pixel(image, 3, 44, ICE_BLUE)
	_set_atmosphere_pixel(image, 59, 48, ICE_BLUE)


func _paint_moon(image: Image) -> void:
	# Large stepped craters are the unique celestial motif. Their broad spacing
	# avoids photographic noise and keeps the sphere readable at collision size.
	_draw_crater(image, Vector2i(82, 82), 15)
	_draw_crater(image, Vector2i(91, 40), 10)
	_draw_crater(image, Vector2i(45, 49), 9)
	_draw_crater(image, Vector2i(51, 91), 8)
	_draw_crater(image, Vector2i(72, 24), 6)
	_draw_crater(image, Vector2i(108, 64), 6)
	_draw_crater(image, Vector2i(28, 69), 5)
	_draw_crater(image, Vector2i(73, 57), 4)
	_draw_crater(image, Vector2i(101, 101), 4)
	# A few angular ejecta scars preserve the project's icy pixel language.
	_draw_line_if_sphere(image, Vector2i(30, 35), Vector2i(43, 30), SNOW_LIGHT)
	_draw_line_if_sphere(image, Vector2i(31, 36), Vector2i(39, 40), FROST)
	_draw_line_if_sphere(image, Vector2i(56, 109), Vector2i(72, 113), ICE_DEEP)
	_set_if_sphere(image, 62, 37, GROUND_SNOW)
	_set_if_sphere(image, 66, 36, SNOW_PEAK)
	_set_if_sphere(image, 36, 78, GROUND_SNOW)
	_set_if_sphere(image, 112, 83, ICE_MID)
	_fill_rect_if_sphere(image, Rect2i(22, 47, 3, 2), GROUND_SNOW)
	_fill_rect_if_sphere(image, Rect2i(54, 18, 4, 2), SNOW_LIGHT)
	_fill_rect_if_sphere(image, Rect2i(79, 18, 3, 2), FROST)
	_fill_rect_if_sphere(image, Rect2i(105, 49, 4, 2), ICE_MID)
	_fill_rect_if_sphere(image, Rect2i(24, 97, 3, 2), ICE_MID)
	_fill_rect_if_sphere(image, Rect2i(75, 107, 4, 2), ICE_DEEP)
	_fill_rect_if_sphere(image, Rect2i(95, 113, 3, 2), GROUND_NIGHT)
	_set_atmosphere_pixel(image, 8, 28, SNOW_LIGHT)
	_set_atmosphere_pixel(image, 119, 34, FROST)
	_set_atmosphere_pixel(image, 5, 92, ICE_MID)
	_set_atmosphere_pixel(image, 116, 105, SNOW_LIGHT)


func _draw_crater(image: Image, center: Vector2i, radius: int) -> void:
	var radius_squared := radius * radius
	var inner_radius := maxi(radius - 2, 1)
	var inner_squared := inner_radius * inner_radius
	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if not _has_sphere_pixel(image, x, y):
				continue
			var dx := x - center.x
			var dy := y - center.y
			var distance_squared := dx * dx + dy * dy
			if distance_squared > radius_squared:
				continue
			if distance_squared > inner_squared:
				image.set_pixel(x, y, GROUND_SNOW if dx + dy < 0 else ICE_DEEP)
			elif dx + dy > radius / 3:
				image.set_pixel(x, y, GROUND_NIGHT)
			else:
				image.set_pixel(x, y, ICE_MID)


func _fill_rect_if_sphere(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			_set_if_sphere(image, x, y, color)


func _draw_line_if_sphere(image: Image, from: Vector2i, to: Vector2i, color: Color) -> void:
	var x0 := from.x
	var y0 := from.y
	var x1 := to.x
	var y1 := to.y
	var dx := absi(x1 - x0)
	var sx := 1 if x0 < x1 else -1
	var dy := -absi(y1 - y0)
	var sy := 1 if y0 < y1 else -1
	var error := dx + dy
	while true:
		_set_if_sphere(image, x0, y0, color)
		if x0 == x1 and y0 == y1:
			break
		var twice_error := error * 2
		if twice_error >= dy:
			error += dy
			x0 += sx
		if twice_error <= dx:
			error += dx
			y0 += sy


func _fill_polygon_if_sphere(image: Image, points: Array, color: Color) -> void:
	var min_x := image.get_width()
	var min_y := image.get_height()
	var max_x := 0
	var max_y := 0
	for point in points:
		min_x = mini(min_x, int(floor(point.x)))
		min_y = mini(min_y, int(floor(point.y)))
		max_x = maxi(max_x, int(ceil(point.x)))
		max_y = maxi(max_y, int(ceil(point.y)))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if _point_in_polygon(Vector2(float(x) + 0.5, float(y) + 0.5), points):
				_set_if_sphere(image, x, y, color)


func _point_in_polygon(point: Vector2, polygon: Array) -> bool:
	var inside := false
	var previous := polygon.size() - 1
	for current in range(polygon.size()):
		var a: Vector2 = polygon[current]
		var b: Vector2 = polygon[previous]
		if (a.y > point.y) != (b.y > point.y):
			var edge_x := (b.x - a.x) * (point.y - a.y) / (b.y - a.y) + a.x
			if point.x < edge_x:
				inside = not inside
		previous = current
	return inside


func _set_if_sphere(image: Image, x: int, y: int, color: Color) -> void:
	if _has_sphere_pixel(image, x, y):
		image.set_pixel(x, y, color)


func _set_atmosphere_pixel(image: Image, x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
		return
	if image.get_pixel(x, y).a == 0.0:
		image.set_pixel(x, y, color)


func _has_sphere_pixel(image: Image, x: int, y: int) -> bool:
	return x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height() and image.get_pixel(x, y).a > 0.5
