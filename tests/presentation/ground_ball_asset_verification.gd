extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallRendererScript = preload("res://scripts/simulation/ball_renderer.gd")
const SimulationManagerScript = preload("res://scripts/simulation/ball_simulation_manager.gd")

const KIT_ROOT := "res://assets/sprites/balls/ground"
const MANIFEST_PATH := KIT_ROOT + "/manifest.json"
const EXPECTED_SIZES := [8, 16, 32, 64, 128]

var _failures := 0


func _ready() -> void:
	var manifest_text := FileAccess.get_file_as_string(MANIFEST_PATH)
	var parsed = JSON.parse_string(manifest_text)
	_expect(parsed is Dictionary, "Ground manifest must parse as a Dictionary.")
	if not parsed is Dictionary:
		get_tree().quit(_failures)
		return
	var manifest: Dictionary = parsed
	_expect(manifest.get("schema") == 1, "Ground manifest schema must remain 1.")
	_expect(manifest.get("family") == "ground", "Manifest must describe only the Ground family.")
	_expect(manifest.get("generation") == "deterministic_hand_authored_native_grid", "Production assets must identify the deterministic hand-authored source.")
	_expect(manifest.get("imagegen_used") == false, "ImageGen output must not be used as a production Ground texture.")
	_expect(manifest.get("pixel_grid") == 1, "Ground masters must use the canonical one-logical-pixel grid.")
	_expect(manifest.get("texture_filter") == "nearest", "Manifest must require nearest filtering.")
	_expect(manifest.get("mipmaps") == false, "Pixel sprites must disable mipmaps.")

	var palette_lookup := {}
	for color_hex in manifest.get("palette", []):
		palette_lookup[String(color_hex).to_upper()] = true
	var assets: Array = manifest.get("assets", [])
	_expect(assets.size() == 5, "Ground manifest must contain exactly Lv0 through Lv4.")
	var catalog = BallCatalogScript.new()
	var color_counts := PackedInt32Array()
	color_counts.resize(assets.size())

	for level in range(assets.size()):
		var asset: Dictionary = assets[level]
		var expected_size: int = EXPECTED_SIZES[level]
		var runtime_path: String = KIT_ROOT + "/" + String(asset.get("path", ""))
		_expect(asset.get("global_level") == level and asset.get("local_level") == level, "Ground asset order must match Lv0-Lv4.")
		_expect(asset.get("runtime_diameter") == expected_size, "Runtime diameter must match the native sprite size for Lv%d." % level)
		_expect(Vector2i(int(asset["size"][0]), int(asset["size"][1])) == Vector2i(expected_size, expected_size), "Manifest dimensions must match the Ground LOD table for Lv%d." % level)
		var image := Image.new()
		var png_file := FileAccess.open(runtime_path, FileAccess.READ)
		_expect(png_file != null, "PNG source must be readable for Lv%d." % level)
		if png_file != null:
			var load_error := image.load_png_from_buffer(png_file.get_buffer(png_file.get_length()))
			_expect(load_error == OK, "PNG bytes must decode for Lv%d." % level)
		_expect(not image.is_empty(), "PNG must load for Lv%d." % level)
		if image.is_empty():
			continue
		_expect(image.get_width() == expected_size and image.get_height() == expected_size, "PNG dimensions must be %dx%d for Lv%d." % [expected_size, expected_size, level])
		var colors: int = _validate_pixels(image, palette_lookup, level)
		color_counts[level] = colors
		_expect(colors <= int(manifest.get("maximum_opaque_colors_per_asset", 9)), "Lv%d exceeds the bounded opaque color count." % level)
		_expect(image.get_pixel(expected_size / 2, 0).a > 0.99, "Lv%d sphere must reach the top of its collision diameter." % level)
		_expect(image.get_pixel(expected_size / 2, expected_size - 1).a > 0.99, "Lv%d sphere must reach the bottom of its collision diameter." % level)
		_expect(image.get_pixel(0, expected_size / 2).a > 0.99, "Lv%d sphere must reach the left of its collision diameter." % level)
		_expect(image.get_pixel(expected_size - 1, expected_size / 2).a > 0.99, "Lv%d sphere must reach the right of its collision diameter." % level)
		_expect(image.get_pixel(0, 0).a < 0.01 and image.get_pixel(expected_size - 1, expected_size - 1).a < 0.01, "Lv%d corners must stay transparent around the rounded silhouette." % level)

		var definition = catalog.get_definition(level)
		_expect(definition != null and definition.texture != null, "Ground BallDefinition Lv%d must bind its production texture." % level)
		if definition != null and definition.texture != null:
			_expect(definition.texture.resource_path == runtime_path, "BallDefinition Lv%d must bind the manifest runtime path." % level)
		var import_text := FileAccess.get_file_as_string(runtime_path + ".import")
		_expect(import_text.contains("mipmaps/generate=false"), "Lv%d import must not generate mipmaps." % level)
		_expect(import_text.contains("compress/mode=0"), "Lv%d import must preserve lossless pixel colors." % level)

	var renderer = BallRendererScript.new()
	add_child(renderer)
	await get_tree().process_frame
	_expect(renderer.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "BallRenderer must enforce nearest filtering.")
	for level in range(assets.size()):
		var batch := renderer.get_node_or_null("LevelBatch%d" % level) as MultiMeshInstance2D
		_expect(batch != null, "Ground level batch %d must exist." % level)
		if batch == null:
			continue
		var runtime_path: String = KIT_ROOT + "/" + String((assets[level] as Dictionary).get("path", ""))
		_expect(batch.texture != null and batch.texture.resource_path == runtime_path, "Ground batch %d must consume its BallDefinition texture." % level)
		var textured_material := batch.material as ShaderMaterial
		_expect(textured_material != null and textured_material.get_shader_parameter("use_texture") == true, "Textured Ground batches must retain the clipping/upright shader in texture mode.")
		_expect(batch.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Ground batch %d must sample with nearest filtering." % level)
	var galactic_batch := renderer.get_node_or_null("LevelBatch11") as MultiMeshInstance2D
	var galactic_material := galactic_batch.material as ShaderMaterial if galactic_batch != null else null
	_expect(galactic_batch != null and galactic_batch.texture != null and galactic_batch.texture.resource_path.ends_with("ball_lv11_galaxy_cluster_16.png"), "Produced Galactic Lv11 must retain its approved Galaxy Cluster texture.")
	_expect(galactic_material != null and galactic_material.get_shader_parameter("use_texture") == true, "Produced Galactic Lv11 must retain the clipping/upright shader in texture mode.")
	var simulation = SimulationManagerScript.new()
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	add_child(simulation)
	renderer.set_simulation_manager(simulation)
	simulation.spawn_ball(Vector2(100, 100), Vector2.ZERO, 4.0, 4)
	renderer.refresh_render_snapshot()
	var moon_batch := renderer.get_node("LevelBatch4") as MultiMeshInstance2D
	_expect(moon_batch.texture != null and moon_batch.texture.resource_path.ends_with("ball_planetary_local_lv00_moon_user_authored_8.tres"), "Planetary-base Moon must use its approved separate 8px LOD instead of shrinking the Ground hero LOD.")
	simulation.reset_runtime()
	simulation.spawn_ball(Vector2(100, 100), Vector2.ZERO, 64.0, 4)
	renderer.refresh_render_snapshot()
	_expect(moon_batch.texture != null and moon_batch.texture.resource_path.ends_with("ball_lv04_moon_user_authored_128.tres"), "Ground hero Moon must restore its approved exact 128px texture binding.")
	simulation.queue_free()
	renderer.queue_free()

	if _failures == 0:
		print("GROUND_BALL_ASSETS_VERIFIED sizes=8/16/32/64/128 alpha=binary palette_colors=%s nearest=true mipmaps=false bindings=5 moon_lods=8+128 ground_unchanged=true" % str(color_counts))
	get_tree().quit(_failures)


func _validate_pixels(image: Image, palette_lookup: Dictionary, level: int) -> int:
	var opaque_colors := {}
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var pixel := image.get_pixel(x, y)
			var alpha_is_binary := pixel.a < 0.001 or pixel.a > 0.999
			_expect(alpha_is_binary, "Lv%d contains non-binary alpha at %d,%d." % [level, x, y])
			if pixel.a < 0.001:
				_expect(pixel.r < 0.001 and pixel.g < 0.001 and pixel.b < 0.001, "Lv%d transparent pixel contains matte RGB at %d,%d." % [level, x, y])
				continue
			var color_hex := "#" + pixel.to_html(false).to_upper()
			opaque_colors[color_hex] = true
			_expect(palette_lookup.has(color_hex), "Lv%d uses undeclared palette color %s at %d,%d." % [level, color_hex, x, y])
	return opaque_colors.size()


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("Ground ball asset verification failed: %s" % message)
