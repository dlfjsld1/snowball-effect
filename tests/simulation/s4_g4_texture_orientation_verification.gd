extends SceneTree

const BallRendererScript = preload("res://scripts/simulation/ball_renderer.gd")

const VIEWPORT_SIZE := Vector2i(320, 128)
const RAW_CENTER := Vector2(80.0, 64.0)
const CANVAS_CENTER := Vector2(240.0, 64.0)
const QUAD_RADIUS := 48.0
const SAMPLE_OFFSET := 24

const TOP_LEFT := Color(1.0, 0.0, 0.0, 1.0)
const TOP_RIGHT := Color(0.0, 1.0, 0.0, 1.0)
const BOTTOM_LEFT := Color(0.0, 0.0, 1.0, 1.0)
const BOTTOM_RIGHT := Color(1.0, 1.0, 0.0, 1.0)

var _failures := 0


func _initialize() -> void:
	call_deferred("_run_verification")


func _run_verification() -> void:
	var viewport := SubViewport.new()
	viewport.size = VIEWPORT_SIZE
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	viewport.transparent_bg = false
	root.add_child(viewport)

	var background := ColorRect.new()
	background.color = Color(0.02, 0.02, 0.02, 1.0)
	background.size = Vector2(VIEWPORT_SIZE)
	viewport.add_child(background)

	var renderer = BallRendererScript.new()
	renderer.process_mode = Node.PROCESS_MODE_DISABLED
	viewport.add_child(renderer)

	var raw_texture := ImageTexture.create_from_image(_create_four_corner_image())
	var canvas_texture := CanvasTexture.new()
	canvas_texture.diffuse_texture = raw_texture
	canvas_texture.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	_configure_batch(renderer, 0, raw_texture, RAW_CENTER)
	_configure_batch(renderer, 1, canvas_texture, CANVAS_CENTER)

	for _frame in range(4):
		await process_frame

	var rendered := viewport.get_texture().get_image()
	_expect(rendered.get_size() == VIEWPORT_SIZE, "The native render target must preserve the deterministic fixture size.")
	_verify_binding(rendered, "raw_texture2d", Vector2i(RAW_CENTER))
	_verify_binding(rendered, "canvas_texture", Vector2i(CANVAS_CENTER))

	if _failures == 0:
		print("S4_G4_TEXTURE_ORIENTATION_VERIFIED raw=true canvas=true corners=TL/TR/BL/BR horizontal=preserved vertical=preserved")
	quit(_failures)


func _create_four_corner_image() -> Image:
	var image := Image.create(4, 4, false, Image.FORMAT_RGBA8)
	for y in range(4):
		for x in range(4):
			var color := TOP_LEFT if y < 2 and x < 2 else TOP_RIGHT if y < 2 else BOTTOM_LEFT if x < 2 else BOTTOM_RIGHT
			image.set_pixel(x, y, color)
	return image


func _configure_batch(renderer, global_level: int, texture: Texture2D, center: Vector2) -> void:
	var batch: MultiMeshInstance2D = renderer._batches[global_level]
	var material := batch.material as ShaderMaterial
	batch.texture = texture
	batch.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	batch.visible = true
	material.set_shader_parameter("use_texture", true)
	material.set_shader_parameter("play_field_rect", Vector4(0.0, 0.0, VIEWPORT_SIZE.x, VIEWPORT_SIZE.y))
	batch.multimesh.instance_count = 1
	batch.multimesh.visible_instance_count = 1
	batch.multimesh.set_instance_color(0, Color.WHITE)
	batch.multimesh.set_instance_transform_2d(
		0,
		Transform2D(Vector2(QUAD_RADIUS, 0.0), Vector2(0.0, QUAD_RADIUS), center)
	)


func _verify_binding(image: Image, binding: String, center: Vector2i) -> void:
	_expect_sample(image, binding, "TL", center + Vector2i(-SAMPLE_OFFSET, -SAMPLE_OFFSET), TOP_LEFT)
	_expect_sample(image, binding, "TR", center + Vector2i(SAMPLE_OFFSET, -SAMPLE_OFFSET), TOP_RIGHT)
	_expect_sample(image, binding, "BL", center + Vector2i(-SAMPLE_OFFSET, SAMPLE_OFFSET), BOTTOM_LEFT)
	_expect_sample(image, binding, "BR", center + Vector2i(SAMPLE_OFFSET, SAMPLE_OFFSET), BOTTOM_RIGHT)


func _expect_sample(image: Image, binding: String, corner: String, position: Vector2i, expected: Color) -> void:
	var actual := image.get_pixelv(position)
	print("S4_G4_TEXTURE_ORIENTATION_SAMPLE binding=%s corner=%s actual=%s expected=%s" % [binding, corner, actual, expected])
	_expect(_colors_match(actual, expected), "%s %s must preserve the authored corner color; got %s instead of %s." % [binding, corner, actual, expected])


func _colors_match(actual: Color, expected: Color) -> bool:
	return (
		absf(actual.r - expected.r) < 0.05
		and absf(actual.g - expected.g) < 0.05
		and absf(actual.b - expected.b) < 0.05
		and absf(actual.a - expected.a) < 0.05
	)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S4-G4 texture orientation verification failed: %s" % message)
