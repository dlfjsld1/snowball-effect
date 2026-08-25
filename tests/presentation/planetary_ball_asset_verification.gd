extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallRendererScript = preload("res://scripts/simulation/ball_renderer.gd")
const BallTextureLodCatalogScript = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")
const SimulationManagerScript = preload("res://scripts/simulation/ball_simulation_manager.gd")

const KIT_ROOT := "res://assets/sprites/balls/planetary"
const MANIFEST_PATH := KIT_ROOT + "/manifest.json"
const GROUND_MOON_PATH := "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_128.png"
const GROUND_MOON_ACTIVE_PATH := "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.tres"
const SUPERNOVA_PORTRAIT_PATH := "res://assets/sprites/cutins/first_contact/supernova-portrait-v1.png"
const GALAXY_PORTRAIT_PATH := "res://assets/sprites/cutins/first_contact/galaxy-portrait-v1.png"
const SUPERNOVA_REFERENCE_PATH := "res://docs/design/mockups/drafts/s6-g2-cutin-d-components/supernova-portrait-v1.png"
const GALAXY_CUTIN_MASTER_PATH := "res://docs/design/mockups/drafts/planetary-galaxy-redesign-v1/candidate-a-grand-spiral-master.png"
const GALAXY_CUTIN_MASTER_SHA256 := "22307bd9cf7f4a31ad8aaaed7bc9ef047e62acb53050c24cee1ebe9cd5513695"
const GALAXY_CUTIN_SHA256 := "87bda6de1587bda3181af136b140c4f09e02301ee7c9590cb1af86613ca3ba25"
const EXPECTED_LEVELS := [4, 5, 6, 8, 10]
const EXPECTED_SIZES := [8, 16, 32, 64, 128]
const EXPECTED_IDENTITIES := ["moon", "earth", "sun", "supernova", "galaxy"]
const ACTIVE_PLANETARY_PATHS := [
	"res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.tres",
	"res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv01_earth_user_authored_16.tres",
	"res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv02_sun_corona_crown_32.tres",
	"res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv03_supernova_user_authored_64.tres",
	"res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.tres",
]
const GALACTIC_GALAXY_ACTIVE_PATH := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.tres"

var _failures := 0


func _ready() -> void:
	var manifest_text := FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed = JSON.parse_string(manifest_text)
	_expect(parsed is Dictionary, "Planetary manifest must parse as a Dictionary.")
	if not parsed is Dictionary:
		get_tree().quit(_failures)
		return
	var manifest: Dictionary = parsed
	_expect(manifest.get("schema") == 1, "Planetary manifest schema must remain 1.")
	_expect(manifest.get("family") == "planetary", "Manifest must describe only the Planetary family.")
	_expect(manifest.get("generation") == "deterministic_hand_authored_native_grid", "Production assets must identify the deterministic native-grid source.")
	_expect(manifest.get("imagegen_used") == false, "Raw ImageGen output must not be used as a production Planetary texture.")
	_expect(manifest.get("pixel_grid") == 1, "Planetary masters must use the canonical one-logical-pixel grid.")
	_expect(manifest.get("texture_filter") == "nearest", "Manifest must require nearest filtering.")
	_expect(manifest.get("mipmaps") == false, "Pixel sprites must disable mipmaps.")

	var palette_lookup := {}
	for color_hex in manifest.get("palette", []):
		palette_lookup[String(color_hex).to_upper()] = true
	var assets: Array = manifest.get("assets", [])
	_expect(assets.size() == 5, "Planetary manifest must contain exactly five ordered local LODs.")
	var images: Array[Image] = []
	var color_counts := PackedInt32Array()
	color_counts.resize(assets.size())
	for local_level in range(assets.size()):
		var asset: Dictionary = assets[local_level]
		var global_level: int = EXPECTED_LEVELS[local_level]
		var expected_size: int = EXPECTED_SIZES[local_level]
		var runtime_path: String = KIT_ROOT + "/" + String(asset.get("path", ""))
		_expect(asset.get("global_level") == global_level and asset.get("local_level") == local_level, "Planetary asset order must match [4,5,6,8,10].")
		_expect(asset.get("visual_identity") == EXPECTED_IDENTITIES[local_level], "Planetary visual identity must match the approved local chain.")
		_expect(asset.get("runtime_diameter") == expected_size, "Runtime diameter must match the native sprite size for local Lv%d." % local_level)
		_expect(Vector2i(int(asset["size"][0]), int(asset["size"][1])) == Vector2i(expected_size, expected_size), "Manifest dimensions must match local Lv%d." % local_level)
		var image := _load_png(runtime_path, "local Lv%d" % local_level)
		images.append(image)
		if image.is_empty():
			continue
		_expect(image.get_width() == expected_size and image.get_height() == expected_size, "PNG dimensions must be %dx%d for local Lv%d." % [expected_size, expected_size, local_level])
		var colors := _validate_pixels(image, palette_lookup, local_level)
		color_counts[local_level] = colors
		_expect(colors <= int(manifest.get("maximum_opaque_colors_per_asset", 11)), "Local Lv%d exceeds the bounded opaque color count." % local_level)
		var import_text := FileAccess.get_file_as_string(runtime_path + ".import")
		_expect(import_text.contains("mipmaps/generate=false"), "Local Lv%d import must not generate mipmaps." % local_level)
		_expect(import_text.contains("compress/mode=0"), "Local Lv%d import must preserve lossless pixel colors." % local_level)

	if images.size() == 5:
		_validate_visual_intent(images)
		_validate_cutin_identity(images)
	_validate_bindings(assets)
	await _validate_renderer()

	if _failures == 0:
		print("PLANETARY_BALL_ASSETS_VERIFIED chain=4/5/6/8/10 sizes=8/16/32/64/128 alpha=binary palette_colors=%s nearest=true moon_native=true bindings=5 ground_primary_unchanged=true galactic_lod_separate=true" % str(color_counts))
	get_tree().quit(_failures)


func _validate_visual_intent(images: Array[Image]) -> void:
	var moon := images[0]
	var ground_moon := _load_png(GROUND_MOON_PATH, "Ground Moon hero")
	var resized_ground_moon := ground_moon.duplicate() as Image
	resized_ground_moon.resize(8, 8, Image.INTERPOLATE_NEAREST)
	_expect(moon.get_data() != resized_ground_moon.get_data(), "Planetary Moon must be separately authored, not a nearest resize of the Ground hero Moon.")
	_expect(_body_is_grayscale(moon), "Moon body colors must remain grayscale outside the shared outline.")
	_expect(_contains_earth_colors(images[1]), "Earth must contain blue ocean, green land, and white cloud/ice pixels.")
	_expect(_contains_sun_colors(images[2]), "Sun must contain a compact warm corona and pale core.")
	_expect(_contains_supernova_colors(images[3]), "Supernova must contain a pale core with warm magenta-gold shock petals.")
	var galaxy := images[4]
	var opaque_pixels := _count_opaque_pixels(galaxy)
	_expect(opaque_pixels > 900 and opaque_pixels < 16000, "Galaxy must read as a substantial folded phenomenon without filling the square canvas.")
	_expect(galaxy.get_pixel(0, 0).a < 0.01 and galaxy.get_pixel(127, 127).a < 0.01, "Galaxy corners must remain transparent instead of forming a flat enclosing circle.")
	_expect(galaxy.get_pixel(64, 64).a > 0.99, "Galaxy must retain a bright central astronomical nucleus.")


func _validate_bindings(assets: Array) -> void:
	var catalog = BallCatalogScript.new()
	var lod_catalog = BallTextureLodCatalogScript.new()
	var moon_definition = catalog.get_definition(4)
	_expect(moon_definition.texture != null and moon_definition.texture.resource_path == GROUND_MOON_PATH, "Moon BallDefinition must keep the Ground 128px hero as its primary texture.")
	var planetary_moon := lod_catalog.resolve_texture(4, 8.0, moon_definition.texture)
	_expect(planetary_moon != null and planetary_moon.resource_path == ACTIVE_PLANETARY_PATHS[0], "Planetary Moon must resolve through its approved exact-size 8px LOD.")
	var ground_moon := lod_catalog.resolve_texture(4, 128.0, moon_definition.texture)
	_expect(ground_moon != null and ground_moon.resource_path == GROUND_MOON_ACTIVE_PATH, "Ground Moon must keep its approved exact 128px runtime binding.")
	for local_level in range(1, assets.size()):
		var global_level: int = EXPECTED_LEVELS[local_level]
		var definition = catalog.get_definition(global_level)
		var runtime_path: String = ACTIVE_PLANETARY_PATHS[local_level]
		_expect(definition != null and definition.texture != null, "Global Lv%d BallDefinition must retain a Content-owned primary texture." % global_level)
		if definition != null and definition.texture != null:
			var planetary_texture := lod_catalog.resolve_texture(global_level, float(EXPECTED_SIZES[local_level]), definition.texture)
			_expect(planetary_texture != null and planetary_texture.resource_path == runtime_path, "Planetary local Lv%d must resolve its approved exact-size master before the Content fallback." % local_level)
	var galactic_galaxy := lod_catalog.resolve_texture(10, 8.0, catalog.get_definition(10).texture)
	_expect(galactic_galaxy != null and galactic_galaxy.resource_path == GALACTIC_GALAXY_ACTIVE_PATH, "Galactic base Galaxy must use its approved separately authored 8px LOD without replacing the Planetary hero.")


func _validate_renderer() -> void:
	var renderer = BallRendererScript.new()
	add_child(renderer)
	var simulation = SimulationManagerScript.new()
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(simulation)
	renderer.set_simulation_manager(simulation)
	for local_level in range(EXPECTED_LEVELS.size()):
		simulation.spawn_ball(Vector2(160 + local_level * 180, 320), Vector2.ZERO, float(EXPECTED_SIZES[local_level]) * 0.5, EXPECTED_LEVELS[local_level])
	renderer.refresh_render_snapshot()
	await get_tree().process_frame
	_expect(renderer.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "BallRenderer must enforce nearest filtering.")
	for local_level in range(EXPECTED_LEVELS.size()):
		var global_level: int = EXPECTED_LEVELS[local_level]
		var batch := renderer.get_node_or_null("LevelBatch%d" % global_level) as MultiMeshInstance2D
		var runtime_path: String = ACTIVE_PLANETARY_PATHS[local_level]
		_expect(batch != null, "Planetary global level batch %d must exist." % global_level)
		if batch == null:
			continue
		_expect(batch.texture != null and batch.texture.resource_path == runtime_path, "Planetary batch %d must consume its exact-size texture." % global_level)
		var textured_material := batch.material as ShaderMaterial
		_expect(textured_material != null and textured_material.get_shader_parameter("use_texture") == true, "Textured Planetary batch %d must retain the clipping/upright shader in texture mode." % global_level)
		_expect(batch.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Planetary batch %d must sample with nearest filtering." % global_level)
		var transform := renderer.get_batch_instance_transform(global_level, 0)
		var expected_radius := float(EXPECTED_SIZES[local_level]) * 0.5
		_expect(is_equal_approx(transform.x.length(), expected_radius) and is_equal_approx(transform.y.length(), expected_radius), "Planetary batch %d must preserve the authoritative runtime radius." % global_level)

	simulation.reset_runtime()
	simulation.spawn_ball(Vector2(200, 200), Vector2.ZERO, 64.0, 4)
	renderer.refresh_render_snapshot()
	var ground_moon_batch := renderer.get_node("LevelBatch4") as MultiMeshInstance2D
	_expect(ground_moon_batch.texture != null and ground_moon_batch.texture.resource_path == GROUND_MOON_ACTIVE_PATH, "Ground hero Moon must remain on its approved runtime binding after Planetary rendering.")
	simulation.reset_runtime()
	simulation.spawn_ball(Vector2(200, 200), Vector2.ZERO, 4.0, 10)
	renderer.refresh_render_snapshot()
	var galactic_galaxy_batch := renderer.get_node("LevelBatch10") as MultiMeshInstance2D
	_expect(galactic_galaxy_batch.texture != null and galactic_galaxy_batch.texture.resource_path == GALACTIC_GALAXY_ACTIVE_PATH, "Galactic base Galaxy must use its approved separately authored 8px LOD rather than shrinking the Planetary hero.")
	var galactic_material := galactic_galaxy_batch.material as ShaderMaterial
	_expect(galactic_material != null and galactic_material.get_shader_parameter("use_texture") == true, "Galactic base Galaxy must retain the clipping/upright shader in texture mode.")
	simulation.queue_free()
	renderer.queue_free()


func _load_png(runtime_path: String, label: String) -> Image:
	var image := Image.new()
	var png_file := FileAccess.open(runtime_path, FileAccess.READ)
	_expect(png_file != null, "%s PNG source must be readable." % label)
	if png_file == null:
		return image
	var load_error := image.load_png_from_buffer(png_file.get_buffer(png_file.get_length()))
	_expect(load_error == OK and not image.is_empty(), "%s PNG bytes must decode." % label)
	return image


func _validate_pixels(image: Image, palette_lookup: Dictionary, local_level: int) -> int:
	var opaque_colors := {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			var alpha_is_binary := pixel.a < 0.001 or pixel.a > 0.999
			_expect(alpha_is_binary, "Local Lv%d contains non-binary alpha at %d,%d." % [local_level, x, y])
			if pixel.a < 0.001:
				_expect(pixel.r < 0.001 and pixel.g < 0.001 and pixel.b < 0.001, "Local Lv%d transparent pixel contains matte RGB at %d,%d." % [local_level, x, y])
				continue
			var color_hex := "#" + pixel.to_html(false).to_upper()
			opaque_colors[color_hex] = true
			_expect(palette_lookup.has(color_hex), "Local Lv%d uses undeclared palette color %s at %d,%d." % [local_level, color_hex, x, y])
	return opaque_colors.size()


func _body_is_grayscale(image: Image) -> bool:
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.99 or _is_shared_outline(pixel):
				continue
			if not (is_equal_approx(pixel.r, pixel.g) and is_equal_approx(pixel.g, pixel.b)):
				return false
	return true


func _contains_warm_planet_colors(image: Image) -> bool:
	var warm := 0
	var opaque := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.99 or _is_shared_outline(pixel):
				continue
			opaque += 1
			if pixel.r > pixel.b * 1.5 and pixel.r > pixel.g * 1.15:
				warm += 1
	return opaque > 0 and float(warm) / float(opaque) > 0.75


func _contains_earth_colors(image: Image) -> bool:
	var blue := 0
	var green := 0
	var white := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.99:
				continue
			if pixel.b > pixel.r * 1.25:
				blue += 1
			if pixel.g > pixel.r * 1.25 and pixel.g > pixel.b * 0.75:
				green += 1
			if pixel.r > 0.85 and pixel.g > 0.85 and pixel.b > 0.85:
				white += 1
	return blue > 12 and green > 5 and white > 4


func _contains_sun_colors(image: Image) -> bool:
	var warm := 0
	var pale := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.99:
				continue
			if pixel.r > pixel.b * 1.45 and pixel.g > pixel.b * 1.15:
				warm += 1
			if pixel.r > 0.94 and pixel.g > 0.85 and pixel.b > 0.60:
				pale += 1
	return warm > 180 and pale > 20


func _contains_supernova_colors(image: Image) -> bool:
	var warm := 0
	var magenta := 0
	var pale := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.99:
				continue
			if pixel.r > pixel.b * 1.4:
				warm += 1
			if pixel.r > pixel.g * 1.25 and pixel.b > pixel.g * 1.1:
				magenta += 1
			if pixel.r > 0.94 and pixel.g > 0.85 and pixel.b > 0.60:
				pale += 1
	return warm > 350 and magenta > 100 and pale > 50


func _validate_cutin_identity(images: Array[Image]) -> void:
	_expect(FileAccess.get_file_as_bytes(SUPERNOVA_PORTRAIT_PATH) == FileAccess.get_file_as_bytes(SUPERNOVA_REFERENCE_PATH), "Supernova CUT-IN portrait must remain byte-identical to the approved reference artwork.")
	_expect(FileAccess.get_sha256(GALAXY_CUTIN_MASTER_PATH) == GALAXY_CUTIN_MASTER_SHA256, "Galaxy CUT-IN master bytes must remain exact.")
	_expect(FileAccess.get_sha256(GALAXY_PORTRAIT_PATH) == GALAXY_CUTIN_SHA256, "Galaxy CUT-IN portrait must match the approved Grand Spiral reduction.")
	var master := _load_png(GALAXY_CUTIN_MASTER_PATH, "Galaxy CUT-IN master")
	var portrait := _load_png(GALAXY_PORTRAIT_PATH, "Galaxy CUT-IN portrait")
	master.convert(Image.FORMAT_RGBA8)
	master.resize(1254, 1254, Image.INTERPOLATE_LANCZOS)
	for y in range(1254):
		for x in range(1254):
			if is_zero_approx(master.get_pixel(x, y).a):
				master.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
	_expect(portrait.get_data() == master.get_data(), "Galaxy CUT-IN portrait must be the deterministic 1536px-to-1254px Lanczos reduction of approved Grand Spiral A.")
	_expect(_contains_supernova_colors(images[3]), "In-game Supernova must retain the CUT-IN's pale rupture core and warm-violet orbit language.")
	_expect(_contains_galaxy_ribbon_colors(images[4]), "The existing in-game Galaxy color identity must remain unchanged while only its CUT-IN portrait is replaced.")


func _contains_galaxy_ribbon_colors(image: Image) -> bool:
	var cyan := 0
	var gold := 0
	var violet := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.99:
				continue
			if pixel.b > pixel.r * 1.2 and pixel.g > pixel.r * 1.05:
				cyan += 1
			if pixel.r > 0.75 and pixel.g > 0.55 and pixel.b < pixel.g * 0.8:
				gold += 1
			if pixel.b > pixel.g * 1.12 and pixel.r > pixel.g * 0.75:
				violet += 1
	return cyan > 100 and gold > 80 and violet > 1000


func _count_opaque_pixels(image: Image) -> int:
	var count := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a > 0.99:
				count += 1
	return count


func _is_shared_outline(pixel: Color) -> bool:
	return pixel.is_equal_approx(Color8(11, 16, 38, 255))


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("Planetary ball asset verification failed: %s" % message)
