extends Node

const STAGE_WORLD_SCENE := preload("res://scenes/backgrounds/stage_world.tscn")
const GROUND_TEXTURE := preload("res://assets/backgrounds/stage_world/runtime/background_ground_1600x900.png")
const PLANETARY_TEXTURE := preload("res://assets/backgrounds/stage_world/runtime/background_planetary_1600x900.png")
const GALACTIC_PLATE := preload("res://assets/backgrounds/stage_world/runtime/background_galactic_plate_1600x900.png")
const GALACTIC_STARS := preload("res://assets/backgrounds/stage_world/runtime/background_galactic_stars_1600x900.png")
const GALACTIC_GALAXY := preload("res://assets/backgrounds/stage_world/runtime/background_galactic_galaxy_1600x900.png")
const GALACTIC_NEBULA := preload("res://assets/backgrounds/stage_world/runtime/background_galactic_nebula_1600x900.png")

const CANVAS_SIZE := Vector2i(1600, 900)
const L2_RECT := Rect2i(360, 50, 880, 800)
const L3_RECT := Rect2i(280, 50, 1040, 800)
const VOID_COLOR := Color("090c13")
const PADDLE_COLOR := Color("f4f5e8")
const BLACK_HOLE_HORIZON_COLOR := Color("74fff0")
const ALLOWED_ALPHA_BYTES := [0, 64, 96, 128, 160, 192, 224, 255]
const GALACTIC_PALETTE := [
	Color("050718"),
	Color("0b1235"),
	Color("174c56"),
	Color("1b7f79"),
	Color("2aa69a"),
	Color("5fd0c4"),
	Color("4b3d8f"),
	Color("6a54b8"),
	Color("a47be8"),
	Color("d8d5ff"),
	Color("f2f5ff"),
]


func _ready() -> void:
	_assert_opaque_background(GROUND_TEXTURE, "ground")
	_assert_opaque_background(PLANETARY_TEXTURE, "planetary")
	var plate_metrics := _assert_alpha_layer(GALACTIC_PLATE, "plate")
	var stars_metrics := _assert_alpha_layer(GALACTIC_STARS, "stars")
	var galaxy_metrics := _assert_alpha_layer(GALACTIC_GALAXY, "galaxy")
	var nebula_metrics := _assert_alpha_layer(GALACTIC_NEBULA, "nebula")
	assert(plate_metrics["visible_blocks"] == 0, "Galactic plate must be fully transparent.")
	for metrics in [stars_metrics, galaxy_metrics, nebula_metrics]:
		assert(metrics["visible_blocks"] > 0)
		assert(metrics["transparent_blocks"] > metrics["visible_blocks"], "Each Galactic identity layer must retain transparent negative space.")
		assert(metrics["partial_alpha_blocks"] > 0, "Each Galactic identity layer must use alpha composition.")

	var background: BackgroundManager = STAGE_WORLD_SCENE.instantiate()
	add_child(background)
	background.set_background(&"ground")
	var ground_metrics := background.get_current_layer_metrics()
	assert(ground_metrics["texture_count"] == 1)
	assert((ground_metrics["plate_texture"] as Texture2D).resource_path == GROUND_TEXTURE.resource_path)
	background.set_background(&"planetary")
	var planetary_metrics := background.get_current_layer_metrics()
	assert(planetary_metrics["texture_count"] == 1)
	assert((planetary_metrics["plate_texture"] as Texture2D).resource_path == PLANETARY_TEXTURE.resource_path)

	background.set_background(&"galactic")
	var normal_metrics := background.get_current_layer_metrics()
	assert(normal_metrics["texture_count"] == 4)
	assert((normal_metrics["plate_texture"] as Texture2D).resource_path == GALACTIC_PLATE.resource_path)
	assert((normal_metrics["stars_texture"] as Texture2D).resource_path == GALACTIC_STARS.resource_path)
	assert((normal_metrics["galaxy_texture"] as Texture2D).resource_path == GALACTIC_GALAXY.resource_path)
	assert((normal_metrics["nebula_texture"] as Texture2D).resource_path == GALACTIC_NEBULA.resource_path)
	assert(normal_metrics["ambient_motion_enabled"])

	var images: Array[Image] = [GALACTIC_STARS.get_image(), GALACTIC_GALAXY.get_image(), GALACTIC_NEBULA.get_image()]
	var layer_alphas := PackedFloat32Array([
		float(normal_metrics["stars_alpha"]),
		float(normal_metrics["galaxy_alpha"]),
		float(normal_metrics["nebula_alpha"]),
	])
	var l2_metrics := _measure_composite(images, layer_alphas, L2_RECT)
	var l3_metrics := _measure_composite(images, layer_alphas, L3_RECT)
	_assert_readable_field(l2_metrics, "L2")
	_assert_readable_field(l3_metrics, "L3")

	background.set_reduced_effects(true)
	var reduced_metrics := background.get_current_layer_metrics()
	assert(reduced_metrics["reduced_effects"])
	assert(not reduced_metrics["ambient_motion_enabled"], "Reduced Effects must stop dynamic ambient motion.")
	assert(reduced_metrics["stars_alpha"] < normal_metrics["stars_alpha"])
	assert(reduced_metrics["galaxy_alpha"] < normal_metrics["galaxy_alpha"])
	assert(reduced_metrics["nebula_alpha"] < normal_metrics["nebula_alpha"])
	background.set_reduced_effects(false)
	assert(background.ambient.is_processing())

	print("S5_G7_VERIFIED alpha_layers=4 plate_visible_blocks=%d stars=%d galaxy=%d nebula=%d l2_avg_luma=%.4f l2_bright_ratio=%.4f l3_avg_luma=%.4f l3_bright_ratio=%.4f paddle_contrast_l3=%.2f horizon_contrast_l3=%.2f reduced=true ground_planetary_opaque=true" % [
		plate_metrics["visible_blocks"],
		stars_metrics["visible_blocks"],
		galaxy_metrics["visible_blocks"],
		nebula_metrics["visible_blocks"],
		l2_metrics["average_luminance"],
		l2_metrics["bright_ratio"],
		l3_metrics["average_luminance"],
		l3_metrics["bright_ratio"],
		_contrast_ratio(_relative_luminance(PADDLE_COLOR), l3_metrics["average_luminance"]),
		_contrast_ratio(_relative_luminance(BLACK_HOLE_HORIZON_COLOR), l3_metrics["average_luminance"]),
	])
	get_tree().quit()


func _assert_opaque_background(texture: Texture2D, label: String) -> void:
	var image := texture.get_image()
	assert(image != null and image.get_size() == CANVAS_SIZE)
	for y in range(0, CANVAS_SIZE.y, 2):
		for x in range(0, CANVAS_SIZE.x, 2):
			var pixel := image.get_pixel(x, y)
			assert(is_equal_approx(pixel.a, 1.0), "%s background lost opacity at %d,%d" % [label, x, y])
			_assert_2x2_block(image, x, y, pixel, label)


func _assert_alpha_layer(texture: Texture2D, label: String) -> Dictionary:
	var image := texture.get_image()
	assert(image != null and image.get_size() == CANVAS_SIZE)
	var visible_blocks := 0
	var transparent_blocks := 0
	var partial_alpha_blocks := 0
	for y in range(0, CANVAS_SIZE.y, 2):
		for x in range(0, CANVAS_SIZE.x, 2):
			var pixel := image.get_pixel(x, y)
			var alpha_byte := roundi(pixel.a * 255.0)
			assert(alpha_byte in ALLOWED_ALPHA_BYTES, "%s layer has unquantized alpha %d at %d,%d" % [label, alpha_byte, x, y])
			_assert_2x2_block(image, x, y, pixel, label)
			if alpha_byte == 0:
				transparent_blocks += 1
			else:
				visible_blocks += 1
				partial_alpha_blocks += int(alpha_byte < 255)
				assert(_is_galactic_palette_color(pixel), "%s layer has an off-palette pixel at %d,%d" % [label, x, y])
	return {
		"visible_blocks": visible_blocks,
		"transparent_blocks": transparent_blocks,
		"partial_alpha_blocks": partial_alpha_blocks,
	}


func _assert_2x2_block(image: Image, x: int, y: int, expected: Color, label: String) -> void:
	for sample in [image.get_pixel(x + 1, y), image.get_pixel(x, y + 1), image.get_pixel(x + 1, y + 1)]:
		assert(is_equal_approx(sample.a, expected.a), "%s layer broke the 2x2 alpha grid at %d,%d" % [label, x, y])
		if expected.a > 0.0:
			assert(sample.is_equal_approx(expected), "%s layer broke the visible 2x2 color grid at %d,%d" % [label, x, y])


func _is_galactic_palette_color(pixel: Color) -> bool:
	for palette_color in GALACTIC_PALETTE:
		if is_equal_approx(pixel.r, palette_color.r) and is_equal_approx(pixel.g, palette_color.g) and is_equal_approx(pixel.b, palette_color.b):
			return true
	return false


func _measure_composite(images: Array[Image], layer_alphas: PackedFloat32Array, rect: Rect2i) -> Dictionary:
	var luminance_sum := 0.0
	var bright_samples := 0
	var sample_count := 0
	for y in range(rect.position.y, rect.end.y, 4):
		for x in range(rect.position.x, rect.end.x, 4):
			var composite := VOID_COLOR
			for layer_index in range(images.size()):
				var source := images[layer_index].get_pixel(x, y)
				composite = composite.lerp(Color(source.r, source.g, source.b, 1.0), source.a * layer_alphas[layer_index])
			var luminance := _relative_luminance(composite)
			luminance_sum += luminance
			bright_samples += int(luminance > 0.18)
			sample_count += 1
	return {
		"average_luminance": luminance_sum / maxf(float(sample_count), 1.0),
		"bright_ratio": float(bright_samples) / maxf(float(sample_count), 1.0),
	}


func _assert_readable_field(metrics: Dictionary, label: String) -> void:
	var average_luminance: float = metrics["average_luminance"]
	assert(average_luminance < 0.08, "%s Galactic composite is too bright for gameplay." % label)
	assert(metrics["bright_ratio"] < 0.12, "%s Galactic composite has too many bright decorative pixels." % label)
	assert(_contrast_ratio(_relative_luminance(PADDLE_COLOR), average_luminance) >= 4.5)
	assert(_contrast_ratio(_relative_luminance(BLACK_HOLE_HORIZON_COLOR), average_luminance) >= 3.0)


func _relative_luminance(color: Color) -> float:
	return 0.2126 * _linear_channel(color.r) + 0.7152 * _linear_channel(color.g) + 0.0722 * _linear_channel(color.b)


func _linear_channel(value: float) -> float:
	return value / 12.92 if value <= 0.04045 else pow((value + 0.055) / 1.055, 2.4)


func _contrast_ratio(first_luminance: float, second_luminance: float) -> float:
	return (maxf(first_luminance, second_luminance) + 0.05) / (minf(first_luminance, second_luminance) + 0.05)
