extends SceneTree

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallRendererScript = preload("res://scripts/simulation/ball_renderer.gd")
const BallTextureLodCatalogScript = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")
const SimulationManagerScript = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")

const GROUND_MOON_PNG := "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.png"
const GROUND_MOON_RESOURCE := "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.tres"
const PLANETARY_MOON_PNG := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.png"
const PLANETARY_MOON_RESOURCE := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.tres"
const PLANETARY_EARTH_PNG := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv01_earth_user_authored_16.png"
const PLANETARY_EARTH_RESOURCE := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv01_earth_user_authored_16.tres"
const PLANETARY_SUN_PNG := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv02_sun_corona_crown_32.png"
const PLANETARY_SUN_RESOURCE := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv02_sun_corona_crown_32.tres"
const PLANETARY_SUPERNOVA_PNG := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv03_supernova_user_authored_64.png"
const PLANETARY_SUPERNOVA_RESOURCE := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv03_supernova_user_authored_64.tres"
const PLANETARY_GALAXY_PNG := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.png"
const PLANETARY_GALAXY_RESOURCE := "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.tres"
const GALACTIC_GALAXY_PNG := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.png"
const GALACTIC_GALAXY_RESOURCE := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.tres"
const GALACTIC_GALAXY_SOURCE_PNG := "res://docs/design/mockups/drafts/planetary-galaxy-redesign-v1/candidate-a-grand-spiral-preview-128.png"
const GALACTIC_QUASAR_DRAFT_PNG := "res://docs/design/mockups/drafts/galactic-quasar-redesign-v1/quasar-A-polar-beacon-32.png"
const GALACTIC_QUASAR_PNG := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv02_quasar_polar_beacon_32.png"
const GALACTIC_QUASAR_RESOURCE := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv02_quasar_polar_beacon_32.tres"
const GALACTIC_EVENT_HORIZON_DRAFT_PNG := "res://docs/design/mockups/drafts/galactic-event-horizon-redesign-v1/event-horizon-C-last-light-64.png"
const GALACTIC_EVENT_HORIZON_PNG := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.png"
const GALACTIC_EVENT_HORIZON_RESOURCE := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.tres"
const GALACTIC_EVENT_HORIZON_FALLBACK_PNG := "res://assets/sprites/balls/galactic/runtime/ball_lv13_event_horizon_64.png"
const GALACTIC_BLACK_HOLE_DRAFT_PNG := "res://docs/design/mockups/drafts/galactic-black-hole-redesign-v1/black-hole-C-void-cathedral-128.png"
const GALACTIC_BLACK_HOLE_PNG := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.png"
const GALACTIC_BLACK_HOLE_RESOURCE := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres"
const GALACTIC_BLACK_HOLE_FALLBACK_PNG := "res://assets/sprites/balls/galactic/runtime/ball_lv14_black_hole_128.png"
const EXPECTED_GROUND_SHA256 := "a60f9506dd041faea78d2698f3b8553de45d1cfa633bb1c70c3bca47ee7b7452"
const EXPECTED_PLANETARY_SHA256 := "7346459dfc4522ca2d5f617ad1468a9da436c17b4926e56634a275517a500ae6"
const EXPECTED_EARTH_SHA256 := "126a09594b0be32703e52d566ec1519ad2133930a30dafe7b1601dfc9a69cd5a"
const EXPECTED_SUN_SHA256 := "918b553af7eb72cc3a413eb7dd8a15da253a2d4dd9e23ae146fc27793d3f5a38"
const EXPECTED_SUPERNOVA_SHA256 := "e78e5d4abdc9fc212b88bd2d8e8afa5ed850e89f8552c3268b7abf3b4f1c93ab"
const EXPECTED_GALAXY_SHA256 := "7c343b003ea981d957a6357257356e47c6e077ab8239893142f37cf858d4b5c0"
const EXPECTED_GALACTIC_GALAXY_SHA256 := "163b67294b4fd093b99f8761e1b2668bdfae269f6671ce25582f6d1e1d28c5ad"
const EXPECTED_GALACTIC_GALAXY_SOURCE_SHA256 := "5dad927ef6c2173c9a0f89710fe3a1af2e6a56ff367f52c46a71dbcd0a1a564d"
const EXPECTED_GALACTIC_QUASAR_SHA256 := "e88c7e35696469ee30285f7c62cf4efd4b9ce4b91810781661fa5a0088146c1d"
const EXPECTED_GALAXY_CLUSTER_SHA256 := "b56ed4b3a55c94be2f7e1b54821261691cc0948f02d3bdfbb5f766e902c13947"
const EXPECTED_EVENT_HORIZON_SHA256 := "a44fe630208d653aaf53bb4346896b5c325e09bbaa6ad9fc5ffa052e535793cd"
const EXPECTED_EVENT_HORIZON_FALLBACK_SHA256 := "adbe27c795ba50a24b385c665de825612b7e9ab0134c3206774a25d029b08b42"
const EXPECTED_BLACK_HOLE_SHA256 := "6efa4ce42876759eea3fa4539b1d46e2acc89867654d2071be88c5a8243ef465"
const EXPECTED_BLACK_HOLE_FALLBACK_SHA256 := "9f77662ee56358a21d1a9e769848e381951b160dbc3fa272e7ca866966eeac51"

const EXPECTED_STAGE_LODS := [
	[0, 8.0, "res://assets/sprites/balls/ground/runtime/ball_lv00_snowflake_frost_blossom_preview_32.tres"],
	[1, 16.0, "res://assets/sprites/balls/ground/runtime/ball_lv01_snowball_user_authored_16.tres"],
	[2, 32.0, "res://assets/sprites/balls/ground/runtime/ball_lv02_big_snowball_user_authored_32.tres"],
	[3, 64.0, "res://assets/sprites/balls/ground/runtime/ball_lv03_giant_snowball_user_authored_64_v2.tres"],
	[4, 128.0, GROUND_MOON_RESOURCE],
	[4, 8.0, PLANETARY_MOON_RESOURCE],
	[5, 16.0, PLANETARY_EARTH_RESOURCE],
	[6, 32.0, PLANETARY_SUN_RESOURCE],
	[8, 64.0, PLANETARY_SUPERNOVA_RESOURCE],
	[10, 128.0, PLANETARY_GALAXY_RESOURCE],
	[10, 8.0, GALACTIC_GALAXY_RESOURCE],
	[11, 16.0, "res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png"],
	[12, 32.0, GALACTIC_QUASAR_RESOURCE],
	[13, 64.0, GALACTIC_EVENT_HORIZON_RESOURCE],
	[14, 128.0, GALACTIC_BLACK_HOLE_RESOURCE],
]

var _failures := 0


func _initialize() -> void:
	call_deferred("_run_verification")


func _run_verification() -> void:
	_verify_png(GROUND_MOON_PNG, Vector2i(128, 128), EXPECTED_GROUND_SHA256, 3492, "Ground Moon")
	_verify_png(PLANETARY_MOON_PNG, Vector2i(8, 8), EXPECTED_PLANETARY_SHA256, 12, "Planetary Moon")
	_verify_png(PLANETARY_EARTH_PNG, Vector2i(16, 16), EXPECTED_EARTH_SHA256, 48, "Planetary Earth")
	_verify_sun_png()
	_verify_png(PLANETARY_SUPERNOVA_PNG, Vector2i(64, 64), EXPECTED_SUPERNOVA_SHA256, 1267, "Planetary Supernova")
	_verify_png(PLANETARY_GALAXY_PNG, Vector2i(128, 128), EXPECTED_GALAXY_SHA256, 5879, "Planetary Galaxy")
	_verify_galactic_galaxy_png()
	_verify_quasar_png()
	_verify_event_horizon_png()
	_verify_black_hole_png()
	_verify_canvas_texture(GROUND_MOON_RESOURCE, GROUND_MOON_PNG, Vector2i(128, 128), "Ground Moon")
	_verify_canvas_texture(PLANETARY_MOON_RESOURCE, PLANETARY_MOON_PNG, Vector2i(8, 8), "Planetary Moon")
	_verify_canvas_texture(PLANETARY_EARTH_RESOURCE, PLANETARY_EARTH_PNG, Vector2i(16, 16), "Planetary Earth")
	_verify_canvas_texture(PLANETARY_SUN_RESOURCE, PLANETARY_SUN_PNG, Vector2i(32, 32), "Planetary Sun")
	_verify_canvas_texture(PLANETARY_SUPERNOVA_RESOURCE, PLANETARY_SUPERNOVA_PNG, Vector2i(64, 64), "Planetary Supernova")
	_verify_canvas_texture(PLANETARY_GALAXY_RESOURCE, PLANETARY_GALAXY_PNG, Vector2i(128, 128), "Planetary Galaxy")
	_verify_canvas_texture(GALACTIC_GALAXY_RESOURCE, GALACTIC_GALAXY_PNG, Vector2i(8, 8), "Galactic Galaxy")
	_verify_canvas_texture(GALACTIC_QUASAR_RESOURCE, GALACTIC_QUASAR_PNG, Vector2i(32, 32), "Galactic Quasar Polar Beacon")
	_verify_canvas_texture(GALACTIC_EVENT_HORIZON_RESOURCE, GALACTIC_EVENT_HORIZON_PNG, Vector2i(64, 64), "Galactic Event Horizon Last Light")
	_verify_canvas_texture(GALACTIC_BLACK_HOLE_RESOURCE, GALACTIC_BLACK_HOLE_PNG, Vector2i(128, 128), "Galactic Black Hole Void Cathedral")
	_verify_authored_planetary_orientation()
	_verify_authored_galactic_galaxy_orientation()

	var stage_catalog = StageCatalogScript.new()
	var ground_stage = stage_catalog.get_stage(0)
	var planetary_stage = stage_catalog.get_stage(1)
	var galactic_stage = stage_catalog.get_stage(2)
	_expect(ground_stage.local_ball_levels == PackedInt32Array([0, 1, 2, 3, 4]), "Ground ordered levels must remain unchanged.")
	_expect(planetary_stage.local_ball_levels == PackedInt32Array([4, 5, 6, 8, 10]), "Planetary ordered levels must remain unchanged.")
	_expect(galactic_stage.local_ball_levels == PackedInt32Array([10, 11, 12, 13, 14]), "Galactic ordered levels must remain unchanged.")
	_expect(ground_stage.local_ball_levels[4] == 4, "Ground Moon must remain local Lv4/global Lv4.")
	_expect(planetary_stage.local_ball_levels[0] == 4, "Planetary Moon must remain local Lv0/global Lv4.")
	_expect(planetary_stage.local_ball_levels[1] == 5, "Planetary Earth must remain local Lv1/global Lv5.")
	_expect(planetary_stage.local_ball_levels[2] == 6, "Planetary Sun must remain local Lv2/global Lv6.")
	_expect(planetary_stage.local_ball_levels[3] == 8, "Planetary Supernova must remain local Lv3/global Lv8.")
	_expect(planetary_stage.local_ball_levels[4] == 10, "Planetary Galaxy must remain local Lv4/global Lv10.")
	_expect(galactic_stage.local_ball_levels[0] == 10, "Galactic Galaxy must remain local Lv0/global Lv10.")
	_expect(galactic_stage.local_ball_levels[2] == 12, "Galactic Quasar must remain local Lv2/global Lv12.")
	_expect(galactic_stage.local_ball_levels[3] == 13, "Galactic Event Horizon must remain local Lv3/global Lv13.")
	_expect(galactic_stage.local_ball_levels[4] == 14, "Galactic Black Hole must remain local Lv4/global Lv14.")

	var catalog = BallCatalogScript.new()
	var lod_catalog = BallTextureLodCatalogScript.new()
	var moon_definition = catalog.get_definition(4)
	var earth_definition = catalog.get_definition(5)
	var sun_definition = catalog.get_definition(6)
	var supernova_definition = catalog.get_definition(8)
	var galaxy_definition = catalog.get_definition(10)
	var quasar_definition = catalog.get_definition(12)
	var event_horizon_definition = catalog.get_definition(13)
	var black_hole_definition = catalog.get_definition(14)
	_expect(moon_definition.texture.resource_path.ends_with("ball_lv04_moon_128.png"), "Content's global Lv4 primary texture must remain unchanged.")
	_expect(earth_definition.texture.resource_path.ends_with("ball_planetary_local_lv01_earth_user_authored_16.png"), "Content's global Lv5 primary texture must use the approved Planetary Earth asset.")
	_expect(sun_definition.texture.resource_path.ends_with("ball_planetary_local_lv02_sun_corona_crown_32.png"), "Content's global Lv6 primary texture must use the approved Planetary Sun asset.")
	_expect(supernova_definition.texture.resource_path.ends_with("ball_planetary_local_lv03_supernova_user_authored_64.png"), "Content's global Lv8 primary texture must use the approved Planetary Supernova asset.")
	_expect(galaxy_definition.texture.resource_path.ends_with("ball_lv10_galaxy_128.png"), "Content's global Lv10 primary texture must remain unchanged.")
	_expect(quasar_definition.texture != null and quasar_definition.texture.resource_path == GALACTIC_QUASAR_RESOURCE, "Content's global Lv12 primary texture must use the approved Galactic Quasar asset.")
	_expect(event_horizon_definition.global_level == 13 and event_horizon_definition.visual_key == &"event_horizon", "Content's global Lv13 identity must remain unchanged.")
	_expect(black_hole_definition.global_level == 14 and black_hole_definition.visual_key == &"black_hole", "Content's global Lv14 identity must remain unchanged.")
	for expected in EXPECTED_STAGE_LODS:
		var definition = catalog.get_definition(int(expected[0]))
		var resolved: Texture2D = lod_catalog.resolve_texture(int(expected[0]), float(expected[1]), definition.texture)
		_expect(resolved != null and resolved.resource_path == String(expected[2]), "Stage-local mapping %d@%d must resolve to %s." % [int(expected[0]), int(expected[1]), String(expected[2])])

	var simulation = SimulationManagerScript.new()
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(simulation)
	var renderer = BallRendererScript.new()
	renderer.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(renderer)
	renderer.set_simulation_manager(simulation)

	simulation.apply_stage_definition(ground_stage)
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(4), 64.0), "Ground global Lv4 gameplay radius must remain 64.")
	simulation.spawn_ball(Vector2(700.0, 300.0), Vector2.ZERO, 64.0, 4)
	renderer.refresh_render_snapshot()
	await process_frame
	_verify_renderer_moon(renderer, GROUND_MOON_RESOURCE, 64.0, "Ground")

	simulation.reset_runtime()
	simulation.apply_stage_definition(planetary_stage)
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(4), 4.0), "Planetary global Lv4 gameplay radius must remain 4.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(5), 8.0), "Planetary global Lv5 gameplay radius must remain 8.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(6), 16.0), "Planetary global Lv6 gameplay radius must remain 16.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(8), 32.0), "Planetary global Lv8 gameplay radius must remain 32.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(10), 64.0), "Planetary global Lv10 gameplay radius must remain 64.")
	simulation.spawn_ball(Vector2(700.0, 300.0), Vector2.ZERO, 4.0, 4)
	simulation.spawn_ball(Vector2(760.0, 300.0), Vector2.ZERO, 8.0, 5)
	simulation.spawn_ball(Vector2(840.0, 300.0), Vector2.ZERO, 16.0, 6)
	simulation.spawn_ball(Vector2(940.0, 300.0), Vector2.ZERO, 32.0, 8)
	simulation.spawn_ball(Vector2(1050.0, 300.0), Vector2.ZERO, 64.0, 10)
	renderer.refresh_render_snapshot()
	await process_frame
	_verify_renderer_ball(renderer, 4, PLANETARY_MOON_RESOURCE, 4.0, "Planetary Moon")
	_verify_renderer_ball(renderer, 5, PLANETARY_EARTH_RESOURCE, 8.0, "Planetary Earth")
	_verify_renderer_ball(renderer, 6, PLANETARY_SUN_RESOURCE, 16.0, "Planetary Sun")
	_verify_renderer_ball(renderer, 8, PLANETARY_SUPERNOVA_RESOURCE, 32.0, "Planetary Supernova")
	_verify_renderer_ball(renderer, 10, PLANETARY_GALAXY_RESOURCE, 64.0, "Planetary Galaxy")

	simulation.reset_runtime()
	simulation.apply_stage_definition(galactic_stage)
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(10), 4.0), "Galactic global Lv10 gameplay radius must remain 4.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(11), 8.0), "Galactic global Lv11 gameplay radius must remain 8.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(12), 16.0), "Galactic global Lv12 gameplay radius must remain 16.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(13), 32.0), "Galactic global Lv13 gameplay radius must remain 32.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(14), 64.0), "Galactic global Lv14 initial gameplay radius must remain 64.")
	simulation.spawn_ball(Vector2(700.0, 300.0), Vector2.ZERO, 4.0, 10)
	simulation.spawn_ball(Vector2(760.0, 300.0), Vector2.ZERO, 8.0, 11)
	simulation.spawn_ball(Vector2(840.0, 300.0), Vector2.ZERO, 16.0, 12)
	simulation.spawn_ball(Vector2(1000.0, 300.0), Vector2.ZERO, 32.0, 13)
	renderer.refresh_render_snapshot()
	await process_frame
	_verify_renderer_ball(renderer, 10, GALACTIC_GALAXY_RESOURCE, 4.0, "Galactic Galaxy")
	_verify_renderer_ball(renderer, 11, "res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png", 8.0, "Galactic Galaxy Cluster TRI-SPIRAL CORE")
	_verify_renderer_ball(renderer, 12, GALACTIC_QUASAR_RESOURCE, 16.0, "Galactic Quasar Polar Beacon")
	_verify_renderer_ball(renderer, 13, GALACTIC_EVENT_HORIZON_RESOURCE, 32.0, "Galactic Event Horizon Last Light")

	var shader_source := FileAccess.get_file_as_string("res://scripts/simulation/ball_renderer_circle.gdshader")
	_expect(shader_source.contains("texture(TEXTURE, vec2(UV.x, 1.0 - UV.y))"), "The upright UV correction must remain active for textured batches.")
	_expect(FileAccess.get_sha256("res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png") == EXPECTED_GALAXY_CLUSTER_SHA256, "Galaxy Cluster bytes must match selected A TRI-SPIRAL CORE.")
	_expect(FileAccess.get_sha256(GALACTIC_EVENT_HORIZON_FALLBACK_PNG) == EXPECTED_EVENT_HORIZON_FALLBACK_SHA256, "The previous Event Horizon fallback bytes must remain available and unchanged.")
	_expect(FileAccess.get_sha256(GALACTIC_BLACK_HOLE_FALLBACK_PNG) == EXPECTED_BLACK_HOLE_FALLBACK_SHA256, "The previous Black Hole fallback bytes must remain available and unchanged.")

	if _failures == 0:
		print("PLANETARY_GALACTIC_STAGE_SPECIFIC_ASSETS_VERIFIED hashes=approved_exact dimensions=stage_native rgba=true alpha=galaxy+cluster+quasar+event_horizon+black_hole_smooth import=lossless_alpha_border_no_mipmaps filter=nearest repeat=disabled ground=isolated planetary=stage_specific galactic=grand_spiral_128to8@r4+cluster_tri_spiral_core@r8+quasar_polar_beacon@r16+event_horizon_last_light@r32+black_hole_void_cathedral@r64 native=1to1 upright=true")
	quit(_failures)


func _verify_galactic_galaxy_png() -> void:
	_expect(FileAccess.get_sha256(GALACTIC_GALAXY_SOURCE_PNG) == EXPECTED_GALACTIC_GALAXY_SOURCE_SHA256, "Galactic Galaxy approved Grand Spiral source hash must remain exact.")
	_expect(FileAccess.get_sha256(GALACTIC_GALAXY_PNG) == EXPECTED_GALACTIC_GALAXY_SHA256, "Galactic Galaxy runtime bytes must match the approved 8px downscale.")
	var file := FileAccess.open(GALACTIC_GALAXY_PNG, FileAccess.READ)
	_expect(file != null, "Galactic Galaxy PNG must be readable.")
	if file == null:
		return
	var image := Image.new()
	_expect(image.load_png_from_buffer(file.get_buffer(file.get_length())) == OK and image.get_size() == Vector2i(8, 8), "Galactic Galaxy must decode at exactly 8x8.")
	_expect(image.get_format() == Image.FORMAT_RGBA8, "Galactic Galaxy must decode as RGBA8.")
	var transparent := 0
	var opaque := 0
	var partial := 0
	for y in range(8):
		for x in range(8):
			var pixel := image.get_pixel(x, y)
			if is_zero_approx(pixel.a):
				transparent += 1
				_expect(pixel.r < 0.001 and pixel.g < 0.001 and pixel.b < 0.001, "Galactic Galaxy transparent pixels must not contain matte RGB.")
			elif is_equal_approx(pixel.a, 1.0):
				opaque += 1
			else:
				partial += 1
	_expect(transparent == 14 and opaque == 8 and partial == 42, "Galactic Galaxy smooth-alpha footprint must remain 14/8/42.")
	var source_file := FileAccess.open(GALACTIC_GALAXY_SOURCE_PNG, FileAccess.READ)
	_expect(source_file != null, "Galactic Galaxy approved source must be readable.")
	if source_file == null:
		return
	var expected := Image.new()
	_expect(expected.load_png_from_buffer(source_file.get_buffer(source_file.get_length())) == OK, "Galactic Galaxy approved source must decode.")
	expected.convert(Image.FORMAT_RGBA8)
	expected.resize(8, 8, Image.INTERPOLATE_LANCZOS)
	for y in range(8):
		for x in range(8):
			if is_zero_approx(expected.get_pixel(x, y).a):
				expected.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
	_expect(image.get_data() == expected.get_data(), "Galactic Galaxy must remain the deterministic Lanczos reduction of approved Grand Spiral A.")


func _verify_png(path: String, expected_size: Vector2i, expected_hash: String, expected_transparent_pixels: int, label: String) -> void:
	_expect(FileAccess.get_sha256(path) == expected_hash, "%s repository bytes must match the approved source hash." % label)
	var file := FileAccess.open(path, FileAccess.READ)
	_expect(file != null, "%s PNG must be readable." % label)
	if file == null:
		return
	var image := Image.new()
	var load_error := image.load_png_from_buffer(file.get_buffer(file.get_length()))
	_expect(load_error == OK and image.get_size() == expected_size, "%s must decode at its exact authored dimensions." % label)
	_expect(image.get_format() == Image.FORMAT_RGBA8, "%s must decode as RGBA8." % label)
	var transparent_pixels := 0
	var opaque_pixels := 0
	for y in range(expected_size.y):
		for x in range(expected_size.x):
			var alpha := image.get_pixel(x, y).a
			if is_zero_approx(alpha):
				transparent_pixels += 1
			elif is_equal_approx(alpha, 1.0):
				opaque_pixels += 1
			else:
				_expect(false, "%s alpha must remain binary without resampling." % label)
	_expect(transparent_pixels == expected_transparent_pixels, "%s transparent pixel count must remain exact." % label)
	_expect(transparent_pixels + opaque_pixels == expected_size.x * expected_size.y, "%s every pixel must remain transparent or opaque." % label)
	for corner in [Vector2i.ZERO, Vector2i(expected_size.x - 1, 0), Vector2i(0, expected_size.y - 1), expected_size - Vector2i.ONE]:
		_expect(image.get_pixelv(corner).a == 0.0, "%s corners must remain transparent." % label)


func _verify_canvas_texture(resource_path: String, png_path: String, expected_size: Vector2i, label: String) -> void:
	var texture := load(resource_path) as CanvasTexture
	_expect(texture != null, "%s must use its dedicated CanvasTexture resource." % label)
	if texture == null:
		return
	_expect(texture.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "%s must use nearest filtering." % label)
	_expect(texture.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "%s must disable repeat." % label)
	_expect(texture.diffuse_texture != null and texture.diffuse_texture.resource_path == png_path, "%s CanvasTexture must bind the exact PNG." % label)
	_expect(Vector2i(texture.get_width(), texture.get_height()) == expected_size, "%s CanvasTexture must preserve native dimensions." % label)
	var import_text := FileAccess.get_file_as_string(png_path + ".import")
	_expect(import_text.contains("compress/mode=0"), "%s import must be lossless." % label)
	_expect(import_text.contains("process/channel_remap/alpha=3"), "%s import must preserve alpha." % label)
	_expect(import_text.contains("process/fix_alpha_border=true"), "%s import must enable alpha-border fixing." % label)
	_expect(import_text.contains("mipmaps/generate=false"), "%s import must disable mipmaps." % label)
	_expect(import_text.contains("process/size_limit=0"), "%s import must not resize authored pixels." % label)
	_expect(_texture_alpha_matches_png(texture, png_path), "%s imported texture cache must match the current PNG alpha footprint." % label)


func _texture_alpha_matches_png(texture: CanvasTexture, png_path: String) -> bool:
	if texture.diffuse_texture == null:
		return false
	var imported_image := texture.diffuse_texture.get_image()
	var source_file := FileAccess.open(png_path, FileAccess.READ)
	if imported_image == null or source_file == null:
		return false
	var source_image := Image.new()
	if source_image.load_png_from_buffer(source_file.get_buffer(source_file.get_length())) != OK:
		return false
	if imported_image.get_size() != source_image.get_size():
		return false
	imported_image.convert(Image.FORMAT_RGBA8)
	for y in range(source_image.get_height()):
		for x in range(source_image.get_width()):
			if imported_image.get_pixel(x, y).a8 != source_image.get_pixel(x, y).a8:
				return false
	return true


func _verify_sun_png() -> void:
	_expect(FileAccess.get_sha256(PLANETARY_SUN_PNG) == EXPECTED_SUN_SHA256, "Planetary Sun repository bytes must match approved candidate A.")
	var file := FileAccess.open(PLANETARY_SUN_PNG, FileAccess.READ)
	_expect(file != null, "Planetary Sun PNG must be readable.")
	if file == null:
		return
	var image := Image.new()
	var load_error := image.load_png_from_buffer(file.get_buffer(file.get_length()))
	_expect(load_error == OK and image.get_size() == Vector2i(32, 32), "Planetary Sun must decode at the approved 32x32 runtime size.")
	_expect(image.get_format() == Image.FORMAT_RGBA8, "Planetary Sun must decode as RGBA8.")
	var transparent_pixels := 0
	var partial_pixels := 0
	var opaque_pixels := 0
	for y in range(32):
		for x in range(32):
			var alpha := image.get_pixel(x, y).a
			if is_zero_approx(alpha):
				transparent_pixels += 1
			elif is_equal_approx(alpha, 1.0):
				opaque_pixels += 1
			else:
				partial_pixels += 1
	_expect(transparent_pixels == 332, "Planetary Sun transparent pixel count must remain exact.")
	_expect(partial_pixels == 645, "Planetary Sun partial-alpha crown must remain exact.")
	_expect(opaque_pixels == 47, "Planetary Sun opaque core pixel count must remain exact.")
	for corner in [Vector2i.ZERO, Vector2i(31, 0), Vector2i(0, 31), Vector2i(31, 31)]:
		_expect(image.get_pixelv(corner).a == 0.0, "Planetary Sun corners must remain transparent.")


func _verify_quasar_png() -> void:
	_expect(FileAccess.get_sha256(GALACTIC_QUASAR_DRAFT_PNG) == EXPECTED_GALACTIC_QUASAR_SHA256, "Approved Polar Beacon draft bytes must remain unchanged.")
	_expect(FileAccess.get_sha256(GALACTIC_QUASAR_PNG) == EXPECTED_GALACTIC_QUASAR_SHA256, "Runtime Quasar must remain byte-identical to approved candidate A.")
	var file := FileAccess.open(GALACTIC_QUASAR_PNG, FileAccess.READ)
	_expect(file != null, "Galactic Quasar PNG must be readable.")
	if file == null:
		return
	var image := Image.new()
	var load_error := image.load_png_from_buffer(file.get_buffer(file.get_length()))
	_expect(load_error == OK and image.get_size() == Vector2i(32, 32), "Galactic Quasar must decode at the authoritative 32x32 runtime size.")
	_expect(image.get_format() == Image.FORMAT_RGBA8, "Galactic Quasar must decode as RGBA8.")
	_expect(image.get_used_rect() == Rect2i(3, 2, 26, 28), "Galactic Quasar alpha bbox must retain transparent margins and remain unclipped.")
	var transparent_pixels := 0
	var partial_pixels := 0
	var opaque_pixels := 0
	for y in range(32):
		for x in range(32):
			var alpha := image.get_pixel(x, y).a
			if is_zero_approx(alpha):
				transparent_pixels += 1
			elif is_equal_approx(alpha, 1.0):
				opaque_pixels += 1
			else:
				partial_pixels += 1
	_expect(transparent_pixels == 666, "Galactic Quasar transparent pixel count must remain exact.")
	_expect(partial_pixels == 280, "Galactic Quasar partial-alpha antialiasing must remain exact.")
	_expect(opaque_pixels == 78, "Galactic Quasar opaque core and jet pixel count must remain exact.")
	for edge_index in range(32):
		_expect(image.get_pixel(edge_index, 0).a == 0.0, "Galactic Quasar top edge must remain transparent.")
		_expect(image.get_pixel(edge_index, 31).a == 0.0, "Galactic Quasar bottom edge must remain transparent.")
		_expect(image.get_pixel(0, edge_index).a == 0.0, "Galactic Quasar left edge must remain transparent.")
		_expect(image.get_pixel(31, edge_index).a == 0.0, "Galactic Quasar right edge must remain transparent.")


func _verify_event_horizon_png() -> void:
	_expect(FileAccess.get_sha256(GALACTIC_EVENT_HORIZON_DRAFT_PNG) == EXPECTED_EVENT_HORIZON_SHA256, "Approved Last Light draft bytes must remain unchanged.")
	_expect(FileAccess.get_sha256(GALACTIC_EVENT_HORIZON_PNG) == EXPECTED_EVENT_HORIZON_SHA256, "Runtime Event Horizon must be byte-identical to approved candidate C.")
	var file := FileAccess.open(GALACTIC_EVENT_HORIZON_PNG, FileAccess.READ)
	_expect(file != null, "Galactic Event Horizon PNG must be readable.")
	if file == null:
		return
	var image := Image.new()
	var load_error := image.load_png_from_buffer(file.get_buffer(file.get_length()))
	_expect(load_error == OK and image.get_size() == Vector2i(64, 64), "Galactic Event Horizon must decode at the authoritative 64x64 runtime size.")
	_expect(image.get_format() == Image.FORMAT_RGBA8, "Galactic Event Horizon must decode as RGBA8.")
	_expect(image.get_used_rect() == Rect2i(2, 2, 59, 60), "Galactic Event Horizon alpha bbox must retain L/T/R/B margins 2/2/3/2 and remain unclipped.")
	var transparent_pixels := 0
	var partial_pixels := 0
	var opaque_pixels := 0
	for y in range(64):
		for x in range(64):
			var alpha := image.get_pixel(x, y).a
			if is_zero_approx(alpha):
				transparent_pixels += 1
			elif is_equal_approx(alpha, 1.0):
				opaque_pixels += 1
			else:
				partial_pixels += 1
	_expect(transparent_pixels == 1176, "Galactic Event Horizon transparent pixel count must remain exact.")
	_expect(partial_pixels == 2787, "Galactic Event Horizon partial-alpha antialiasing must remain exact.")
	_expect(opaque_pixels == 133, "Galactic Event Horizon opaque rim pixel count must remain exact.")
	for edge_index in range(64):
		_expect(image.get_pixel(edge_index, 0).a == 0.0, "Galactic Event Horizon top edge must remain transparent.")
		_expect(image.get_pixel(edge_index, 63).a == 0.0, "Galactic Event Horizon bottom edge must remain transparent.")
		_expect(image.get_pixel(0, edge_index).a == 0.0, "Galactic Event Horizon left edge must remain transparent.")
		_expect(image.get_pixel(63, edge_index).a == 0.0, "Galactic Event Horizon right edge must remain transparent.")
	for y in range(20, 44):
		for x in range(20, 44):
			var core_pixel := image.get_pixel(x, y)
			_expect(core_pixel.r8 == 0 and core_pixel.g8 == 0 and core_pixel.b8 == 0 and core_pixel.a8 >= 253, "Galactic Event Horizon core must remain an uninterrupted matte void without internal detail.")
	_expect(image.get_pixel(58, 32).is_equal_approx(Color8(255, 255, 255, 251)), "Last Light's white-gold crescent landmark must remain on the right edge.")
	_expect(image.get_pixel(6, 32).is_equal_approx(Color8(3, 6, 13, 253)), "Last Light's faint blue-black lensing echo must remain on the opposite edge.")


func _verify_black_hole_png() -> void:
	_expect(FileAccess.get_sha256(GALACTIC_BLACK_HOLE_DRAFT_PNG) == EXPECTED_BLACK_HOLE_SHA256, "Approved Void Cathedral draft bytes must remain unchanged.")
	_expect(FileAccess.get_sha256(GALACTIC_BLACK_HOLE_PNG) == EXPECTED_BLACK_HOLE_SHA256, "Runtime Black Hole must be byte-identical to approved candidate C.")
	var file := FileAccess.open(GALACTIC_BLACK_HOLE_PNG, FileAccess.READ)
	_expect(file != null, "Galactic Black Hole PNG must be readable.")
	if file == null:
		return
	var image := Image.new()
	var load_error := image.load_png_from_buffer(file.get_buffer(file.get_length()))
	_expect(load_error == OK and image.get_size() == Vector2i(128, 128), "Galactic Black Hole must decode at the authoritative 128x128 runtime size.")
	_expect(image.get_format() == Image.FORMAT_RGBA8, "Galactic Black Hole must decode as RGBA8.")
	_expect(image.get_used_rect() == Rect2i(4, 14, 120, 100), "Galactic Black Hole alpha bbox must retain L/T/R/B margins 4/14/4/14 and remain unclipped.")
	var transparent_pixels := 0
	var partial_pixels := 0
	var opaque_pixels := 0
	var opaque_black_pixels := 0
	var bright_upper_pixels := 0
	var bright_lower_pixels := 0
	var bright_equatorial_pixels := 0
	var equatorial_min_x := 128
	var equatorial_max_x := -1
	for y in range(128):
		for x in range(128):
			var pixel := image.get_pixel(x, y)
			if pixel.a8 == 0:
				transparent_pixels += 1
			elif pixel.a8 == 255:
				opaque_pixels += 1
			else:
				partial_pixels += 1
			if pixel.a8 == 255 and pixel.r8 == 0 and pixel.g8 == 0 and pixel.b8 == 0:
				opaque_black_pixels += 1
			var luminance := 0.2126 * pixel.r8 + 0.7152 * pixel.g8 + 0.0722 * pixel.b8
			if pixel.a8 >= 64 and luminance >= 60.0:
				if y < 56:
					bright_upper_pixels += 1
				elif y > 72:
					bright_lower_pixels += 1
				if absi(y - 64) <= 10:
					bright_equatorial_pixels += 1
					equatorial_min_x = mini(equatorial_min_x, x)
					equatorial_max_x = maxi(equatorial_max_x, x)
	_expect(transparent_pixels == 9494, "Galactic Black Hole transparent pixel count must remain exact.")
	_expect(partial_pixels == 4475, "Galactic Black Hole partial-alpha lensing must remain exact.")
	_expect(opaque_pixels == 2415, "Galactic Black Hole opaque shadow and disk pixel count must remain exact.")
	_expect(opaque_black_pixels >= 2100, "Galactic Black Hole must preserve at least 2,100 fully opaque pure-black shadow pixels.")
	_expect(bright_upper_pixels == 1255 and bright_lower_pixels == 1247, "Galactic Black Hole upper and lower gravitational lens images must remain readable at 128px.")
	_expect(bright_equatorial_pixels == 1008 and equatorial_max_x - equatorial_min_x + 1 == 120, "Galactic Black Hole equatorial accretion disk must retain its 120px bright span.")
	for edge_index in range(128):
		_expect(image.get_pixel(edge_index, 0).a8 == 0, "Galactic Black Hole top edge must remain transparent.")
		_expect(image.get_pixel(edge_index, 127).a8 == 0, "Galactic Black Hole bottom edge must remain transparent.")
		_expect(image.get_pixel(0, edge_index).a8 == 0, "Galactic Black Hole left edge must remain transparent.")
		_expect(image.get_pixel(127, edge_index).a8 == 0, "Galactic Black Hole right edge must remain transparent.")
	for sample_y in [47, 81]:
		for y in range(sample_y - 2, sample_y + 3):
			for x in range(59, 70):
				_expect(image.get_pixel(x, y).is_equal_approx(Color8(0, 0, 0, 255)), "Galactic Black Hole center shadow samples must remain opaque, pure black, and detail-free.")


func _verify_authored_planetary_orientation() -> void:
	var file := FileAccess.open(PLANETARY_MOON_PNG, FileAccess.READ)
	if file == null:
		_expect(false, "Planetary Moon source must be readable for orientation verification.")
		return
	var image := Image.new()
	if image.load_png_from_buffer(file.get_buffer(file.get_length())) != OK:
		_expect(false, "Planetary Moon source must decode for orientation verification.")
		return
	_expect(image.get_pixel(3, 1).is_equal_approx(Color8(252, 249, 245, 255)), "The authored upper highlight landmark must remain at the top.")
	_expect(image.get_pixel(5, 5).is_equal_approx(Color8(40, 47, 84, 255)), "The authored dark hemisphere landmark must remain at the lower right.")
	var earth_file := FileAccess.open(PLANETARY_EARTH_PNG, FileAccess.READ)
	if earth_file == null:
		_expect(false, "Planetary Earth source must be readable for orientation verification.")
		return
	var earth_image := Image.new()
	if earth_image.load_png_from_buffer(earth_file.get_buffer(earth_file.get_length())) != OK:
		_expect(false, "Planetary Earth source must decode for orientation verification.")
		return
	_expect(earth_image.get_pixel(7, 1).is_equal_approx(Color8(145, 201, 248, 255)), "Earth's pale upper-atmosphere landmark must remain at the top.")
	_expect(earth_image.get_pixel(7, 14).is_equal_approx(Color8(10, 48, 123, 255)), "Earth's dark lower-ocean landmark must remain at the bottom.")
	var supernova_file := FileAccess.open(PLANETARY_SUPERNOVA_PNG, FileAccess.READ)
	if supernova_file == null:
		_expect(false, "Planetary Supernova source must be readable for orientation verification.")
		return
	var supernova_image := Image.new()
	if supernova_image.load_png_from_buffer(supernova_file.get_buffer(supernova_file.get_length())) != OK:
		_expect(false, "Planetary Supernova source must decode for orientation verification.")
		return
	_expect(supernova_image.get_pixel(32, 6).is_equal_approx(Color8(253, 187, 155, 255)), "Supernova's pale upper filament landmark must remain at the top.")
	_expect(supernova_image.get_pixel(32, 57).is_equal_approx(Color8(251, 220, 7, 255)), "Supernova's yellow lower filament landmark must remain at the bottom.")
	var galaxy_file := FileAccess.open(PLANETARY_GALAXY_PNG, FileAccess.READ)
	if galaxy_file == null:
		_expect(false, "Planetary Galaxy source must be readable for orientation verification.")
		return
	var galaxy_image := Image.new()
	if galaxy_image.load_png_from_buffer(galaxy_file.get_buffer(galaxy_file.get_length())) != OK:
		_expect(false, "Planetary Galaxy source must decode for orientation verification.")
		return
	_expect(galaxy_image.get_pixel(64, 8).is_equal_approx(Color8(127, 126, 217, 255)), "Galaxy's violet upper-arm landmark must remain at the top.")
	_expect(galaxy_image.get_pixel(64, 64).is_equal_approx(Color8(252, 252, 252, 255)), "Galaxy's bright authored nucleus must remain centered.")
	_expect(galaxy_image.get_pixel(64, 119).is_equal_approx(Color8(103, 121, 212, 255)), "Galaxy's blue lower-arm landmark must remain at the bottom.")


func _verify_authored_galactic_galaxy_orientation() -> void:
	var file := FileAccess.open(GALACTIC_GALAXY_PNG, FileAccess.READ)
	_expect(file != null, "Galactic Galaxy source must be readable for orientation verification.")
	if file == null:
		return
	var image := Image.new()
	_expect(image.load_png_from_buffer(file.get_buffer(file.get_length())) == OK, "Galactic Galaxy source must decode for orientation verification.")
	_expect(image.get_pixel(3, 3).is_equal_approx(Color8(215, 184, 153, 248)), "Galactic Galaxy's warm core landmark must remain on the authored upper-left side.")
	_expect(image.get_pixel(4, 6).is_equal_approx(Color8(61, 78, 163, 227)), "Galactic Galaxy's blue-violet lower arm landmark must remain at the bottom.")


func _verify_renderer_moon(renderer, expected_path: String, expected_radius: float, stage_label: String) -> void:
	_verify_renderer_ball(renderer, 4, expected_path, expected_radius, "%s Moon" % stage_label)


func _verify_renderer_ball(renderer, global_level: int, expected_path: String, expected_radius: float, label: String) -> void:
	var batch := renderer.get_node("LevelBatch%d" % global_level) as MultiMeshInstance2D
	_expect(batch.texture != null and batch.texture.resource_path == expected_path, "%s renderer must use its stage-local resource." % label)
	_expect(batch.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "%s renderer sampling must remain nearest." % label)
	var transform: Transform2D = renderer.get_batch_instance_transform(global_level, 0)
	_expect(is_equal_approx(transform.x.length(), expected_radius) and is_equal_approx(transform.y.length(), expected_radius), "%s renderer must preserve gameplay radius %.0f." % [label, expected_radius])


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("Planetary Moon stage-specific user asset verification failed: %s" % message)
