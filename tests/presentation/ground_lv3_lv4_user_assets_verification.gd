extends SceneTree

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallRendererScript = preload("res://scripts/simulation/ball_renderer.gd")
const BallTextureLodCatalogScript = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")
const SimulationManagerScript = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")

const LV3_PNG := "res://assets/sprites/balls/ground/runtime/ball_lv03_giant_snowball_user_authored_64_v2.png"
const LV3_RESOURCE := "res://assets/sprites/balls/ground/runtime/ball_lv03_giant_snowball_user_authored_64_v2.tres"
const LV3_FALLBACK_RESOURCE := "res://assets/sprites/balls/ground/runtime/ball_lv03_giant_snowball_user_authored_64.tres"
const LV4_PNG := "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.png"
const LV4_RESOURCE := "res://assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.tres"
const EXPECTED_LV3_SHA256 := "ec00642cc45595e2484abfa0c20c388b4f7434f138aeee093bedf320796a4cd7"
const EXPECTED_LV4_SHA256 := "a60f9506dd041faea78d2698f3b8553de45d1cfa633bb1c70c3bca47ee7b7452"

const EXPECTED_UNCHANGED_LODS := [
	[0, 8.0, "res://assets/sprites/balls/ground/runtime/ball_lv00_snowflake_frost_blossom_preview_32.tres"],
	[1, 16.0, "res://assets/sprites/balls/ground/runtime/ball_lv01_snowball_user_authored_16.tres"],
	[2, 32.0, "res://assets/sprites/balls/ground/runtime/ball_lv02_big_snowball_user_authored_32.tres"],
	[4, 8.0, "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.tres"],
	[5, 16.0, "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv01_earth_user_authored_16.tres"],
	[6, 32.0, "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv02_sun_corona_crown_32.tres"],
	[8, 64.0, "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv03_supernova_user_authored_64.tres"],
	[10, 128.0, "res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.tres"],
	[10, 8.0, "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.tres"],
	[11, 16.0, "res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png"],
	[12, 32.0, "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv02_quasar_polar_beacon_32.tres"],
	[13, 64.0, "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.tres"],
	[14, 128.0, "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres"],
]

var _failures := 0


func _initialize() -> void:
	call_deferred("_run_verification")


func _run_verification() -> void:
	_verify_png(LV3_PNG, Vector2i(64, 64), EXPECTED_LV3_SHA256, "Lv3 Giant Snowball v2")
	_verify_png(LV4_PNG, Vector2i(128, 128), EXPECTED_LV4_SHA256, "Lv4 Moon")
	_verify_canvas_texture(LV3_RESOURCE, LV3_PNG, Vector2i(64, 64), "Lv3 Giant Snowball v2")
	_verify_canvas_texture(LV4_RESOURCE, LV4_PNG, Vector2i(128, 128), "Lv4 Moon")
	_expect(ResourceLoader.exists(LV3_FALLBACK_RESOURCE), "The previous Lv3 CanvasTexture must remain available as a fallback.")
	_expect(load(LV3_FALLBACK_RESOURCE) is CanvasTexture, "The previous Lv3 fallback must still load as a CanvasTexture.")

	var catalog = BallCatalogScript.new()
	var lod_catalog = BallTextureLodCatalogScript.new()
	var lv3_definition = catalog.get_definition(3)
	var lv4_definition = catalog.get_definition(4)
	_expect(lv3_definition.texture.resource_path.ends_with("ball_lv03_giant_snowball_64.png"), "Lv3 Content primary texture must remain unchanged.")
	_expect(lv4_definition.texture.resource_path.ends_with("ball_lv04_moon_128.png"), "Lv4 Content primary texture must remain unchanged.")
	_expect(lod_catalog.resolve_texture(3, 64.0, lv3_definition.texture).resource_path == LV3_RESOURCE, "Only Ground global/local Lv3 at diameter 64 must bind Giant Snowball v2.")
	_expect(lod_catalog.resolve_texture(4, 128.0, lv4_definition.texture).resource_path == LV4_RESOURCE, "Only Ground global/local Lv4 at diameter 128 must bind the user-authored Moon.")
	for expected in EXPECTED_UNCHANGED_LODS:
		var definition = catalog.get_definition(int(expected[0]))
		var resolved: Texture2D = lod_catalog.resolve_texture(int(expected[0]), float(expected[1]), definition.texture)
		_expect(resolved != null and resolved.resource_path == String(expected[2]), "Existing mapping %d@%d must remain unchanged." % [int(expected[0]), int(expected[1])])

	var simulation = SimulationManagerScript.new()
	simulation.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(simulation)
	simulation.apply_stage_definition(StageCatalogScript.new().get_stage(0))
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(3), 32.0), "Ground Lv3 gameplay radius must remain 32.")
	_expect(is_equal_approx(simulation.get_runtime_radius_for_level(4), 64.0), "Ground Lv4 gameplay radius must remain 64.")

	var renderer = BallRendererScript.new()
	renderer.process_mode = Node.PROCESS_MODE_DISABLED
	root.add_child(renderer)
	renderer.set_simulation_manager(simulation)
	for level in range(5):
		var radius := simulation.get_runtime_radius_for_level(level)
		simulation.spawn_ball(Vector2(620.0 + level * 80.0, 300.0), Vector2.ZERO, radius, level)
	renderer.refresh_render_snapshot()
	await process_frame
	_verify_renderer_batch(renderer, 0, "res://assets/sprites/balls/ground/runtime/ball_lv00_snowflake_frost_blossom_preview_32.tres", 4.0)
	_verify_renderer_batch(renderer, 1, "res://assets/sprites/balls/ground/runtime/ball_lv01_snowball_user_authored_16.tres", 8.0)
	_verify_renderer_batch(renderer, 2, "res://assets/sprites/balls/ground/runtime/ball_lv02_big_snowball_user_authored_32.tres", 16.0)
	_verify_renderer_batch(renderer, 3, LV3_RESOURCE, 32.0)
	_verify_renderer_batch(renderer, 4, LV4_RESOURCE, 64.0)
	var shader_source := FileAccess.get_file_as_string("res://scripts/simulation/ball_renderer_circle.gdshader")
	_expect(shader_source.contains("texture(TEXTURE, vec2(UV.x, 1.0 - UV.y))"), "The upright UV correction must remain active for textured batches.")

	if _failures == 0:
		print("GROUND_LV3_LV4_USER_ASSETS_VERIFIED hashes=exact dimensions=64x64/128x128 rgba=true alpha=true import=lossless_alpha_border_no_mipmaps filter=nearest repeat=disabled bindings=lv3_v2+lv4_moon radii=32/64 lv0_lv2=unchanged other_lods=unchanged upright_shader=true fallback_lv3=true")
	quit(_failures)


func _verify_png(path: String, expected_size: Vector2i, expected_hash: String, label: String) -> void:
	_expect(FileAccess.get_sha256(path) == expected_hash, "%s repository bytes must match the approved source hash." % label)
	var file := FileAccess.open(path, FileAccess.READ)
	_expect(file != null, "%s PNG must be readable." % label)
	if file == null:
		return
	var image := Image.new()
	var load_error := image.load_png_from_buffer(file.get_buffer(file.get_length()))
	_expect(load_error == OK and image.get_size() == expected_size, "%s must decode at its exact authored dimensions." % label)
	_expect(image.get_format() == Image.FORMAT_RGBA8, "%s must decode as RGBA8." % label)
	for corner in [Vector2i.ZERO, Vector2i(expected_size.x - 1, 0), Vector2i(0, expected_size.y - 1), expected_size - Vector2i.ONE]:
		_expect(image.get_pixelv(corner).a == 0.0, "%s corners must remain transparent." % label)


func _verify_canvas_texture(resource_path: String, png_path: String, expected_size: Vector2i, label: String) -> void:
	var texture := load(resource_path) as CanvasTexture
	_expect(texture != null, "%s must use its dedicated CanvasTexture resource." % label)
	if texture == null:
		return
	_expect(texture.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "%s must use nearest filtering." % label)
	_expect(texture.texture_repeat == CanvasItem.TEXTURE_REPEAT_DISABLED, "%s must disable repeat." % label)
	_expect(texture.diffuse_texture != null and texture.diffuse_texture.resource_path == png_path, "%s CanvasTexture must bind the exact source PNG." % label)
	_expect(Vector2i(texture.get_width(), texture.get_height()) == expected_size, "%s resource must preserve native 1:1 dimensions." % label)
	var import_text := FileAccess.get_file_as_string(png_path + ".import")
	_expect(import_text.contains("compress/mode=0"), "%s import must be lossless." % label)
	_expect(import_text.contains("process/channel_remap/alpha=3"), "%s import must preserve alpha." % label)
	_expect(import_text.contains("process/fix_alpha_border=true"), "%s import must enable alpha-border fixing." % label)
	_expect(import_text.contains("mipmaps/generate=false"), "%s import must disable mipmaps." % label)
	_expect(import_text.contains("process/size_limit=0"), "%s import must not resize the authored pixels." % label)


func _verify_renderer_batch(renderer, global_level: int, expected_path: String, expected_radius: float) -> void:
	var batch := renderer.get_node("LevelBatch%d" % global_level) as MultiMeshInstance2D
	_expect(batch.texture != null and batch.texture.resource_path == expected_path, "Ground Lv%d renderer binding must match the approved resource." % global_level)
	_expect(batch.texture_filter == CanvasItem.TEXTURE_FILTER_NEAREST, "Ground Lv%d renderer sampling must remain nearest." % global_level)
	var transform: Transform2D = renderer.get_batch_instance_transform(global_level, 0)
	_expect(is_equal_approx(transform.x.length(), expected_radius) and is_equal_approx(transform.y.length(), expected_radius), "Ground Lv%d renderer must preserve gameplay radius %.0f." % [global_level, expected_radius])


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("Ground Lv3/Lv4 user asset verification failed: %s" % message)
