extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallRendererScript = preload("res://scripts/simulation/ball_renderer.gd")
const BallTextureLodCatalogScript = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")
const SimulationManagerScript = preload("res://scripts/simulation/ball_simulation_manager.gd")

const KIT_ROOT := "res://assets/sprites/balls/galactic"
const MANIFEST_PATH := KIT_ROOT + "/manifest.json"
const PLANETARY_GALAXY_PATH := "res://assets/sprites/balls/planetary/runtime/ball_lv10_galaxy_128.png"
const PLANETARY_GALAXY_ACTIVE_PATH := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.tres"
const GROUND_MOON_PATH := "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_128.png"
const PLANETARY_MOON_ACTIVE_PATH := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.tres"
const EVENT_HORIZON_CUTIN_PATH := "res://assets/sprites/cutins/first_contact/event-horizon-portrait-v1.png"
const EVENT_HORIZON_CUTIN_DRAFT_PATH := "res://docs/design/mockups/drafts/s6-g2-cutin-d-components/event-horizon-portrait-v1.png"
const BLACK_HOLE_CUTIN_PATH := "res://assets/sprites/cutins/first_contact/black-hole-portrait-v1.png"
const BLACK_HOLE_CUTIN_DRAFT_PATH := "res://docs/design/mockups/drafts/s6-g2-cutin-d-components/black-hole-portrait-v1.png"
const EXPECTED_LEVELS := [10, 11, 12, 13, 14]
const EXPECTED_SIZES := [8, 16, 32, 64, 128]
const EXPECTED_IDENTITIES := ["galaxy", "galaxy_cluster", "quasar", "event_horizon", "black_hole"]
const ACTIVE_GALACTIC_PATHS := [
	"res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.tres",
	"res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png",
	"res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv02_quasar_polar_beacon_32.tres",
	"res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.tres",
	"res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres",
]

var _failures := 0


func _ready() -> void:
	var manifest_text := FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed = JSON.parse_string(manifest_text)
	_expect(parsed is Dictionary, "Galactic manifest must parse as a Dictionary.")
	if not parsed is Dictionary:
		get_tree().quit(_failures)
		return
	var manifest: Dictionary = parsed
	_expect(manifest.get("schema") == 1, "Galactic manifest schema must remain 1.")
	_expect(manifest.get("family") == "galactic", "Manifest must describe only the Galactic family.")
	_expect(manifest.get("owner") == "Presentation", "Galactic assets must remain Presentation-owned.")
	_expect(manifest.get("generation") == "deterministic_hand_authored_native_grid", "Production assets must identify the deterministic native-grid source.")
	_expect(manifest.get("imagegen_used") == false, "Raw ImageGen output must not be used as a production Galactic texture.")
	_expect(manifest.get("pixel_grid") == 1, "Galactic masters must use the canonical one-logical-pixel grid.")
	_expect(manifest.get("texture_filter") == "nearest", "Manifest must require nearest filtering.")
	_expect(manifest.get("mipmaps") == false, "Pixel sprites must disable mipmaps.")

	var palette_lookup := {}
	for color_hex in manifest.get("palette", []):
		palette_lookup[String(color_hex).to_upper()] = true
	var assets: Array = manifest.get("assets", [])
	_expect(assets.size() == 5, "Galactic manifest must contain exactly five ordered local LODs.")
	var images: Array[Image] = []
	var color_counts := PackedInt32Array()
	var opaque_counts := PackedInt32Array()
	color_counts.resize(assets.size())
	opaque_counts.resize(assets.size())
	for local_level in range(assets.size()):
		var asset: Dictionary = assets[local_level]
		var global_level: int = EXPECTED_LEVELS[local_level]
		var expected_size: int = EXPECTED_SIZES[local_level]
		var runtime_path: String = KIT_ROOT + "/" + String(asset.get("path", ""))
		_expect(asset.get("global_level") == global_level and asset.get("local_level") == local_level, "Galactic asset order must match [10,11,12,13,14].")
		_expect(asset.get("visual_identity") == EXPECTED_IDENTITIES[local_level], "Galactic visual identity must match the authoritative local chain.")
		_expect(asset.get("runtime_diameter") == expected_size, "Runtime diameter must match the native sprite size for local Lv%d." % local_level)
		_expect(Vector2i(int(asset["size"][0]), int(asset["size"][1])) == Vector2i(expected_size, expected_size), "Manifest dimensions must match local Lv%d." % local_level)
		var image := _load_png(runtime_path, "local Lv%d" % local_level)
		images.append(image)
		if image.is_empty():
			continue
		_expect(image.get_width() == expected_size and image.get_height() == expected_size, "PNG dimensions must be %dx%d for local Lv%d." % [expected_size, expected_size, local_level])
		var audit := _validate_pixels(image, palette_lookup, local_level)
		color_counts[local_level] = audit["colors"]
		opaque_counts[local_level] = audit["opaque"]
		_expect(audit["colors"] <= int(manifest.get("maximum_opaque_colors_per_asset", 13)), "Local Lv%d exceeds the bounded opaque color count." % local_level)
		_expect(image.get_used_rect() == Rect2i(0, 0, expected_size, expected_size), "Local Lv%d silhouette must establish the full collision-scale extent." % local_level)
		_expect(image.get_pixel(0, 0).a < 0.01 and image.get_pixel(expected_size - 1, expected_size - 1).a < 0.01, "Local Lv%d corners must remain open rather than forming a generic circular container." % local_level)
		var import_text := FileAccess.get_file_as_string(runtime_path + ".import")
		_expect(import_text.contains("mipmaps/generate=false"), "Local Lv%d import must not generate mipmaps." % local_level)
		_expect(import_text.contains("compress/mode=0"), "Local Lv%d import must preserve lossless pixel colors." % local_level)

	if images.size() == 5:
		_validate_visual_intent(images, opaque_counts)
	_validate_bindings(assets)
	await _validate_renderer()

	if _failures == 0:
		print("GALACTIC_BALL_ASSETS_VERIFIED chain=10/11/12/13/14 sizes=8/16/32/64/128 alpha=binary palette_colors=%s opaque_pixels=%s nearest=true galaxy_native=true bindings=5 black_hole_special_unchanged=true ground_planetary_unchanged=true" % [str(color_counts), str(opaque_counts)])
	get_tree().quit(_failures)


func _validate_visual_intent(images: Array[Image], opaque_counts: PackedInt32Array) -> void:
	var galaxy := images[0]
	var planetary_galaxy := _load_png(PLANETARY_GALAXY_PATH, "Planetary Galaxy hero")
	var resized_planetary_galaxy := planetary_galaxy.duplicate() as Image
	resized_planetary_galaxy.resize(8, 8, Image.INTERPOLATE_NEAREST)
	_expect(galaxy.get_data() != resized_planetary_galaxy.get_data(), "Galactic Galaxy must be separately authored, not a nearest resize of the Planetary hero Galaxy.")
	_expect(opaque_counts[0] >= 20 and opaque_counts[0] <= 40, "The 8px Galaxy must remain a sparse readable spiral symbol.")
	_expect(opaque_counts[1] > opaque_counts[0] * 4, "Galaxy Cluster must add distinct compact bodies at its native scale.")

	var quasar := images[2]
	_expect(quasar.get_pixel(16, 0).a > 0.99 and quasar.get_pixel(17, 31).a > 0.99, "Quasar must keep opposing polar jets across its full native diameter.")
	_expect(quasar.get_pixel(16, 16).a > 0.99, "Quasar must retain a compact radiant nucleus.")

	var event_horizon := images[3]
	var black_hole := images[4]
	_expect(FileAccess.get_file_as_bytes(EVENT_HORIZON_CUTIN_PATH) == FileAccess.get_file_as_bytes(EVENT_HORIZON_CUTIN_DRAFT_PATH), "Event Horizon CUT-IN portrait must remain byte-identical to its approved draft.")
	_expect(FileAccess.get_file_as_bytes(BLACK_HOLE_CUTIN_PATH) == FileAccess.get_file_as_bytes(BLACK_HOLE_CUTIN_DRAFT_PATH), "Black Hole CUT-IN portrait must remain byte-identical to its approved draft.")
	_expect(_count_color(event_horizon, Color8(2, 4, 12, 255)) > 600, "Event Horizon must contain an imposing opaque void rather than an illustrated inner badge.")
	_expect(_count_color(black_hole, Color8(2, 4, 12, 255)) > 3500, "Black Hole hero must contain the family's most overwhelming opaque void.")
	_expect(opaque_counts[4] > opaque_counts[3] * 3, "Black Hole hero must deliver a genuine scale increase over Event Horizon.")
	_expect(black_hole.get_pixel(64, 64).is_equal_approx(Color8(2, 4, 12, 255)), "Black Hole center must remain an opaque void with no baked glow.")
	_expect(event_horizon.get_pixel(63, 29).is_equal_approx(Color8(247, 250, 255, 255)), "Event Horizon must preserve the CUT-IN's bright right-side lens flare.")
	_expect(black_hole.get_pixel(63, 2).is_equal_approx(Color8(255, 241, 184, 255)), "Black Hole must preserve the CUT-IN's cardinal starburst silhouette.")


func _validate_bindings(assets: Array) -> void:
	var catalog = BallCatalogScript.new()
	var lod_catalog = BallTextureLodCatalogScript.new()
	var galaxy_definition = catalog.get_definition(10)
	_expect(galaxy_definition.texture != null and galaxy_definition.texture.resource_path == PLANETARY_GALAXY_PATH, "Galaxy BallDefinition must keep the Planetary 128px hero as its primary texture.")
	var planetary_galaxy := lod_catalog.resolve_texture(10, 128.0, galaxy_definition.texture)
	_expect(planetary_galaxy != null and planetary_galaxy.resource_path == PLANETARY_GALAXY_ACTIVE_PATH, "Planetary Galaxy must use its approved exact-size runtime binding.")

	for local_level in range(assets.size()):
		var global_level: int = EXPECTED_LEVELS[local_level]
		var runtime_path: String = ACTIVE_GALACTIC_PATHS[local_level]
		var definition = catalog.get_definition(global_level)
		var primary_texture: Texture2D = definition.texture if definition != null else null
		var texture := lod_catalog.resolve_texture(global_level, float(EXPECTED_SIZES[local_level]), primary_texture)
		_expect(texture != null and texture.resource_path == runtime_path, "Global Lv%d must resolve its exact Galactic runtime texture." % global_level)
		_expect(lod_catalog.resolve_texture(global_level, float(EXPECTED_SIZES[local_level]) + 1.0, primary_texture) == null, "Global Lv%d must reject filtered or mismatched runtime sizes." % global_level)

	var moon_definition = catalog.get_definition(4)
	_expect(moon_definition.texture != null and moon_definition.texture.resource_path == GROUND_MOON_PATH, "Ground Moon primary texture must remain untouched.")
	var planetary_moon := lod_catalog.resolve_texture(4, 8.0, moon_definition.texture)
	_expect(planetary_moon != null and planetary_moon.resource_path == PLANETARY_MOON_ACTIVE_PATH, "Planetary Moon must use its approved exact-size runtime binding.")


func _validate_renderer() -> void:
	var renderer = BallRendererScript.new()
	add_child(renderer)
	var simulation = SimulationManagerScript.new()
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(simulation)
	renderer.set_simulation_manager(simulation)
	for local_level in range(4):
		simulation.spawn_ball(Vector2(180 + local_level * 220, 320), Vector2.ZERO, float(EXPECTED_SIZES[local_level]) * 0.5, EXPECTED_LEVELS[local_level])
	renderer.refresh_render_snapshot()
	await get_tree().process_frame
	_expect(renderer.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "BallRenderer must retain nearest filtering.")
	for local_level in range(4):
		var global_level: int = EXPECTED_LEVELS[local_level]
		var batch := renderer.get_node_or_null("LevelBatch%d" % global_level) as MultiMeshInstance2D
		var runtime_path: String = ACTIVE_GALACTIC_PATHS[local_level]
		_expect(batch != null, "Galactic global level batch %d must exist." % global_level)
		if batch == null:
			continue
		_expect(batch.texture != null and batch.texture.resource_path == runtime_path, "Galactic batch %d must consume its exact-size texture." % global_level)
		var textured_material := batch.material as ShaderMaterial
		_expect(textured_material != null and textured_material.get_shader_parameter("use_texture") == true, "Textured Galactic batch %d must retain the clipping/upright shader in texture mode." % global_level)
		_expect(batch.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Galactic batch %d must sample with nearest filtering." % global_level)
		var transform := renderer.get_batch_instance_transform(global_level, 0)
		var expected_radius := float(EXPECTED_SIZES[local_level]) * 0.5
		_expect(is_equal_approx(transform.x.length(), expected_radius) and is_equal_approx(transform.y.length(), expected_radius), "Galactic batch %d must preserve the authoritative runtime radius." % global_level)

	simulation.reset_runtime()
	simulation.spawn_ball(Vector2(400, 320), Vector2.ZERO, 64.0, 14)
	renderer.refresh_render_snapshot()
	var metrics: Dictionary = renderer.get_render_metrics()
	_expect(metrics["standard_ball_count"] == 0 and metrics["special_fallback_count"] == 1, "Lv14 must remain outside the standard MultiMesh path so Black Hole Core mechanics and dedicated presentation stay unchanged.")
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


func _validate_pixels(image: Image, palette_lookup: Dictionary, local_level: int) -> Dictionary:
	var opaque_colors := {}
	var opaque_count := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			var alpha_is_binary := pixel.a < 0.001 or pixel.a > 0.999
			_expect(alpha_is_binary, "Local Lv%d contains non-binary alpha at %d,%d." % [local_level, x, y])
			if pixel.a < 0.001:
				_expect(pixel.r < 0.001 and pixel.g < 0.001 and pixel.b < 0.001, "Local Lv%d transparent pixel contains matte RGB at %d,%d." % [local_level, x, y])
				continue
			opaque_count += 1
			var color_hex := "#" + pixel.to_html(false).to_upper()
			opaque_colors[color_hex] = true
			_expect(palette_lookup.has(color_hex), "Local Lv%d uses undeclared palette color %s at %d,%d." % [local_level, color_hex, x, y])
	return {"colors": opaque_colors.size(), "opaque": opaque_count}


func _count_color(image: Image, target: Color) -> int:
	var count := 0
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).is_equal_approx(target):
				count += 1
	return count


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("Galactic ball asset verification failed: %s" % message)
