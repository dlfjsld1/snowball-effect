extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallRendererScript = preload("res://scripts/simulation/ball_renderer.gd")
const BallTextureLodCatalogScript = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")
const SimulationManagerScript = preload("res://scripts/simulation/ball_simulation_manager.gd")

const KIT_ROOT := "res://assets/sprites/balls/galactic"
const MANIFEST_PATH := KIT_ROOT + "/manifest.json"
const PLANETARY_GALAXY_PATH := "res://assets/sprites/balls/planetary/runtime/ball_lv10_galaxy_128.png"
const PLANETARY_GALAXY_ACTIVE_PATH := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.tres"
const GALACTIC_GALAXY_GAMEPLAY_PATH := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.png"
const GALACTIC_GALAXY_SOURCE_PATH := "res://docs/design/mockups/drafts/planetary-galaxy-redesign-v1/candidate-a-grand-spiral-preview-128.png"
const GALACTIC_GALAXY_SOURCE_SHA256 := "5dad927ef6c2173c9a0f89710fe3a1af2e6a56ff367f52c46a71dbcd0a1a564d"
const GALACTIC_GALAXY_GAMEPLAY_SHA256 := "163b67294b4fd093b99f8761e1b2668bdfae269f6671ce25582f6d1e1d28c5ad"
const GROUND_MOON_PATH := "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_128.png"
const PLANETARY_MOON_ACTIVE_PATH := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.tres"
const EVENT_HORIZON_CUTIN_PATH := "res://assets/sprites/cutins/first_contact/event-horizon-portrait-v1.png"
const EVENT_HORIZON_CUTIN_MASTER_PATH := "res://docs/design/mockups/drafts/galactic-event-horizon-redesign-v1/event-horizon-C-last-light-master.png"
const BLACK_HOLE_CUTIN_PATH := "res://assets/sprites/cutins/first_contact/black-hole-portrait-v1.png"
const BLACK_HOLE_CUTIN_MASTER_PATH := "res://docs/design/mockups/drafts/galactic-black-hole-redesign-v1/black-hole-C-void-cathedral-master.png"
const GALAXY_CLUSTER_GAMEPLAY_PATH := "res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png"
const GALAXY_CLUSTER_CRT_PATH := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv01_galaxy_cluster_tri_spiral_core_crt_24.png"
const GALAXY_CLUSTER_GAMEPLAY_SHA256 := "b56ed4b3a55c94be2f7e1b54821261691cc0948f02d3bdfbb5f766e902c13947"
const GALAXY_CLUSTER_CRT_SHA256 := "0018b474579832cf0d8a29c3b154acf148f33744ace3cdb83cbcc9dac198af6c"
const EVENT_HORIZON_GAMEPLAY_PATH := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.png"
const EVENT_HORIZON_SOURCE_PATH := "res://docs/design/mockups/drafts/galactic-event-horizon-redesign-v1/event-horizon-C-last-light-64.png"
const EVENT_HORIZON_GAMEPLAY_SHA256 := "a44fe630208d653aaf53bb4346896b5c325e09bbaa6ad9fc5ffa052e535793cd"
const BLACK_HOLE_GAMEPLAY_PATH := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.png"
const BLACK_HOLE_SOURCE_PATH := "res://docs/design/mockups/drafts/galactic-black-hole-redesign-v1/black-hole-C-void-cathedral-128.png"
const BLACK_HOLE_GAMEPLAY_SHA256 := "6efa4ce42876759eea3fa4539b1d46e2acc89867654d2071be88c5a8243ef465"
const EXPECTED_LEVELS := [10, 11, 12, 13, 14]
const EXPECTED_SIZES := [8, 16, 32, 64, 128]
const EXPECTED_IDENTITIES := ["galaxy", "galaxy_cluster", "quasar", "event_horizon", "black_hole"]
const ACTIVE_GALACTIC_PATHS := [
	"res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.tres",
	GALAXY_CLUSTER_GAMEPLAY_PATH,
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
	_expect(manifest.get("deterministic_source") == "res://tools/presentation/galactic_ball_assets/generate_galactic_ball_assets.py", "Unchanged legacy family rows must retain their deterministic source identity.")
	_expect(manifest.get("generation") == "mixed_approved_user_selected_and_hand_authored", "Production assets must identify their mixed approved sources.")
	_expect(manifest.get("imagegen_used") == true, "The manifest must record the selected generated Galaxy Cluster source accurately.")
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
		var audit: Dictionary
		if local_level == 0:
			audit = _validate_selected_galactic_galaxy(image, asset)
		elif local_level == 1:
			audit = _validate_selected_galaxy_cluster(image, asset)
		elif local_level == 3:
			audit = _validate_selected_native_runtime(image, asset, EVENT_HORIZON_SOURCE_PATH, EVENT_HORIZON_GAMEPLAY_PATH, EVENT_HORIZON_GAMEPLAY_SHA256, 64, 1176, 133, 2787, "Event Horizon")
		elif local_level == 4:
			audit = _validate_selected_native_runtime(image, asset, BLACK_HOLE_SOURCE_PATH, BLACK_HOLE_GAMEPLAY_PATH, BLACK_HOLE_GAMEPLAY_SHA256, 128, 9494, 2415, 4475, "Black Hole")
		else:
			audit = _validate_pixels(image, palette_lookup, local_level)
		color_counts[local_level] = audit["colors"]
		opaque_counts[local_level] = audit["opaque"]
		if local_level == 2:
			_expect(audit["colors"] <= int(manifest.get("maximum_opaque_colors_per_hand_authored_asset", 13)), "Local Lv%d exceeds the bounded opaque color count." % local_level)
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
		print("GALACTIC_BALL_ASSETS_VERIFIED chain=10/11/12/13/14 sizes=8/16/32/64/128 galaxy=grand_spiral_lanczos_128to8 galaxy_cluster=tri_spiral_core event_horizon=last_light_native64 black_hole=void_cathedral_native128 gameplay=16x16 crt=24x24 hashes=selected alpha=mixed nearest=true upright_clip=true bindings=5 black_hole_special_unchanged=true other_stage_mappings_unchanged=true")
	get_tree().quit(_failures)


func _validate_visual_intent(images: Array[Image], opaque_counts: PackedInt32Array) -> void:
	var galaxy := images[0]
	var approved_source := _load_png(GALACTIC_GALAXY_SOURCE_PATH, "approved Grand Spiral source")
	var expected_galaxy := approved_source.duplicate() as Image
	expected_galaxy.convert(Image.FORMAT_RGBA8)
	expected_galaxy.resize(8, 8, Image.INTERPOLATE_LANCZOS)
	for y in range(expected_galaxy.get_height()):
		for x in range(expected_galaxy.get_width()):
			if is_zero_approx(expected_galaxy.get_pixel(x, y).a):
				expected_galaxy.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
	_expect(galaxy.get_data() == expected_galaxy.get_data(), "Galactic Galaxy must remain the deterministic Lanczos 8px reduction of approved Grand Spiral A.")
	_expect(opaque_counts[0] == 50, "The 8px Grand Spiral must retain its exact visible footprint.")
	_expect(FileAccess.get_sha256(GALAXY_CLUSTER_GAMEPLAY_PATH) == GALAXY_CLUSTER_GAMEPLAY_SHA256, "Galaxy Cluster must use the selected TRI-SPIRAL CORE gameplay bytes.")

	var quasar := images[2]
	_expect(quasar.get_pixel(16, 0).a > 0.99 and quasar.get_pixel(17, 31).a > 0.99, "Quasar must keep opposing polar jets across its full native diameter.")
	_expect(quasar.get_pixel(16, 16).a > 0.99, "Quasar must retain a compact radiant nucleus.")

	var event_horizon := images[3]
	var black_hole := images[4]
	_expect(FileAccess.get_file_as_bytes(EVENT_HORIZON_CUTIN_PATH) == FileAccess.get_file_as_bytes(EVENT_HORIZON_CUTIN_MASTER_PATH), "Event Horizon CUT-IN portrait must use the approved Last Light master exactly.")
	_expect(FileAccess.get_file_as_bytes(BLACK_HOLE_CUTIN_PATH) == FileAccess.get_file_as_bytes(BLACK_HOLE_CUTIN_MASTER_PATH), "Black Hole CUT-IN portrait must use the approved Void Cathedral master exactly.")
	_expect(opaque_counts[4] > opaque_counts[3] * 3, "Black Hole hero must deliver a genuine scale increase over Event Horizon.")
	var event_center := event_horizon.get_pixel(32, 32)
	_expect(event_center.r8 == 0 and event_center.g8 == 0 and event_center.b8 == 0 and event_center.a8 >= 253, "Event Horizon must contain an imposing uninterrupted matte void.")
	_expect(_count_color(black_hole, Color8(0, 0, 0, 255)) >= 2100, "Black Hole hero must contain the family's most overwhelming opaque void.")


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
		if local_level in [0, 3, 4] and texture is CanvasTexture:
			var imported_image := (texture as CanvasTexture).diffuse_texture.get_image()
			var source_path := KIT_ROOT + "/" + String(assets[local_level].get("path", ""))
			var source_image := _load_png(source_path, "Galactic local Lv%d current source" % local_level)
			_expect(_alpha_footprint_matches(imported_image, source_image), "Galactic local Lv%d imported texture cache must match the current PNG alpha footprint, not stale pre-replacement bytes." % local_level)

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


func _validate_selected_galactic_galaxy(image: Image, asset: Dictionary) -> Dictionary:
	_expect(asset.get("path") == "runtime/ball_galactic_local_lv00_galaxy_user_authored_8.png", "Galactic Galaxy manifest must bind the active gameplay PNG.")
	_expect(asset.get("source_path") == GALACTIC_GALAXY_SOURCE_PATH, "Galactic Galaxy manifest must name approved Grand Spiral A as its source.")
	_expect(asset.get("source_sha256") == GALACTIC_GALAXY_SOURCE_SHA256, "Galactic Galaxy manifest must pin the approved source hash.")
	_expect(asset.get("runtime_sha256") == GALACTIC_GALAXY_GAMEPLAY_SHA256, "Galactic Galaxy manifest must pin the 8px runtime hash.")
	var source_size: Array = asset.get("source_size", [])
	_expect(source_size.size() == 2 and int(source_size[0]) == 128 and int(source_size[1]) == 128 and asset.get("downscale_filter") == "lanczos", "Galactic Galaxy manifest must record the exact 128px-to-8px Lanczos handoff.")
	_expect(FileAccess.get_sha256(GALACTIC_GALAXY_SOURCE_PATH) == GALACTIC_GALAXY_SOURCE_SHA256, "Approved Grand Spiral source bytes must remain unchanged.")
	_expect(FileAccess.get_sha256(GALACTIC_GALAXY_GAMEPLAY_PATH) == GALACTIC_GALAXY_GAMEPLAY_SHA256, "Galactic Galaxy gameplay bytes must match the approved downscale.")
	_expect(image.get_used_rect() == Rect2i(0, 0, 8, 8), "Galactic Galaxy must use its full 8px gameplay footprint.")
	return _validate_smooth_alpha(image, 14, 8, 42, "Galactic Galaxy gameplay")


func _validate_selected_native_runtime(image: Image, asset: Dictionary, source_path: String, runtime_path: String, runtime_hash: String, target_size: int, expected_transparent: int, expected_opaque: int, expected_partial: int, label: String) -> Dictionary:
	_expect(asset.get("path") == "runtime/" + runtime_path.get_file(), "%s manifest must bind the active gameplay PNG." % label)
	_expect(asset.get("source_path") == source_path, "%s manifest must name its approved native source." % label)
	_expect(asset.get("source_sha256") == runtime_hash and asset.get("runtime_sha256") == runtime_hash, "%s manifest must pin the byte-identical source and runtime hashes." % label)
	var source_size: Array = asset.get("source_size", [])
	_expect(source_size.size() == 2 and int(source_size[0]) == target_size and int(source_size[1]) == target_size, "%s manifest must record its exact native runtime size." % label)
	_expect(FileAccess.get_sha256(source_path) == runtime_hash, "%s approved native source bytes must remain unchanged." % label)
	_expect(FileAccess.get_sha256(runtime_path) == runtime_hash, "%s gameplay bytes must remain byte-identical to the approved native source." % label)
	_expect(FileAccess.get_file_as_bytes(source_path) == FileAccess.get_file_as_bytes(runtime_path), "%s source and gameplay PNG must remain byte-identical." % label)
	var audit := _validate_smooth_alpha(image, expected_transparent, expected_opaque, expected_partial, "%s gameplay" % label)
	audit["opaque"] = expected_opaque
	return audit


func _validate_smooth_alpha(image: Image, expected_transparent: int, expected_opaque: int, expected_partial: int, label: String) -> Dictionary:
	var transparent := 0
	var opaque := 0
	var partial := 0
	var visible_colors := {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if is_zero_approx(pixel.a):
				transparent += 1
				_expect(pixel.r < 0.001 and pixel.g < 0.001 and pixel.b < 0.001, "%s transparent pixel contains matte RGB at %d,%d." % [label, x, y])
			elif is_equal_approx(pixel.a, 1.0):
				opaque += 1
				visible_colors[pixel.to_html()] = true
			else:
				partial += 1
				visible_colors[pixel.to_html()] = true
	_expect(transparent == expected_transparent, "%s transparent pixel count must remain exact." % label)
	_expect(opaque == expected_opaque, "%s opaque pixel count must remain exact." % label)
	_expect(partial == expected_partial, "%s partial-alpha pixel count must remain exact." % label)
	return {"colors": visible_colors.size(), "opaque": opaque + partial}


func _validate_selected_galaxy_cluster(image: Image, asset: Dictionary) -> Dictionary:
	_expect(asset.get("source") == "approved A — TRI-SPIRAL CORE (2026-08-25)", "Galaxy Cluster manifest must name the selected A source.")
	_expect(asset.get("source_sha256") == GALAXY_CLUSTER_GAMEPLAY_SHA256, "Galaxy Cluster manifest must pin the selected gameplay hash.")
	_expect(asset.get("crt_path") == "runtime/ball_galactic_local_lv01_galaxy_cluster_tri_spiral_core_crt_24.png", "Galaxy Cluster manifest must expose the dedicated CRT icon.")
	_expect(Vector2i(int(asset["crt_size"][0]), int(asset["crt_size"][1])) == Vector2i(24, 24), "Galaxy Cluster CRT icon contract must remain 24x24.")
	_expect(asset.get("crt_sha256") == GALAXY_CLUSTER_CRT_SHA256, "Galaxy Cluster manifest must pin the selected CRT hash.")
	_expect(FileAccess.get_sha256(GALAXY_CLUSTER_GAMEPLAY_PATH) == GALAXY_CLUSTER_GAMEPLAY_SHA256, "Galaxy Cluster gameplay bytes must match selected A.")
	var gameplay_audit := _validate_selected_alpha(image, 157, 28, 71, "Galaxy Cluster gameplay")
	var crt_image := _load_png(GALAXY_CLUSTER_CRT_PATH, "Galaxy Cluster CRT")
	_expect(crt_image.get_size() == Vector2i(24, 24), "Galaxy Cluster CRT source must decode at its exact display size.")
	_expect(FileAccess.get_sha256(GALAXY_CLUSTER_CRT_PATH) == GALAXY_CLUSTER_CRT_SHA256, "Galaxy Cluster CRT bytes must match selected A.")
	_validate_selected_alpha(crt_image, 362, 44, 170, "Galaxy Cluster CRT")
	for path in [GALAXY_CLUSTER_GAMEPLAY_PATH, GALAXY_CLUSTER_CRT_PATH]:
		var import_text := FileAccess.get_file_as_string(path + ".import")
		_expect(import_text.contains("mipmaps/generate=false"), "%s must disable mipmaps." % path)
		_expect(import_text.contains("compress/mode=0"), "%s must preserve lossless RGBA." % path)
	return gameplay_audit


func _validate_selected_alpha(image: Image, expected_transparent: int, expected_opaque: int, expected_partial: int, label: String) -> Dictionary:
	var transparent := 0
	var opaque := 0
	var partial := 0
	var visible_colors := {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			if is_zero_approx(pixel.a):
				transparent += 1
			elif is_equal_approx(pixel.a, 1.0):
				opaque += 1
				visible_colors[pixel.to_html()] = true
			else:
				partial += 1
				visible_colors[pixel.to_html()] = true
	_expect(transparent == expected_transparent, "%s transparent pixel count must match selected A." % label)
	_expect(opaque == expected_opaque, "%s opaque pixel count must match selected A." % label)
	_expect(partial == expected_partial, "%s partial-alpha pixel count must match selected A." % label)
	for x in range(image.get_width()):
		_expect(is_zero_approx(image.get_pixel(x, 0).a) and is_zero_approx(image.get_pixel(x, image.get_height() - 1).a), "%s must keep transparent top/bottom edges." % label)
	for y in range(image.get_height()):
		_expect(is_zero_approx(image.get_pixel(0, y).a) and is_zero_approx(image.get_pixel(image.get_width() - 1, y).a), "%s must keep transparent left/right edges." % label)
	return {"colors": visible_colors.size(), "opaque": opaque + partial}


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


func _alpha_footprint_matches(imported_image: Image, source_image: Image) -> bool:
	if imported_image == null or imported_image.get_size() != source_image.get_size():
		return false
	imported_image.convert(Image.FORMAT_RGBA8)
	for y in range(source_image.get_height()):
		for x in range(source_image.get_width()):
			var source_pixel := source_image.get_pixel(x, y)
			var imported_pixel := imported_image.get_pixel(x, y)
			if not is_equal_approx(source_pixel.a, imported_pixel.a):
				return false
	return true


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("Galactic ball asset verification failed: %s" % message)
