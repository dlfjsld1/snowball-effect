extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")
const STAGE_WORLD_SCENE := preload("res://scenes/backgrounds/stage_world.tscn")

var _completed_ids: Array[int] = []


func _ready() -> void:
	var background: BackgroundManager = STAGE_WORLD_SCENE.instantiate()
	add_child(background)
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	add_child(frame)
	var presenter: PresentationManager = frame.get_node("PresentationManager")
	presenter.shift_duration = 0.05
	presenter.configure(background, null, null)
	presenter.stage_shift_presentation_finished.connect(_on_shift_finished)

	_assert_background_assets(background)
	var planetary := StageDefinition.new()
	planetary.stage_index = 1
	planetary.background_id = &"planetary"
	presenter.play_stage_shift(planetary, 17)
	assert(presenter.is_shift_active())
	assert(frame.profile_index == 0, "Logical profile must remain old until Presentation completes.")
	assert(background.target_background_id == &"planetary")

	var timeout_at := Time.get_ticks_msec() + 1000
	while presenter.is_shift_active() and Time.get_ticks_msec() < timeout_at:
		await get_tree().process_frame
	assert(not presenter.is_shift_active())
	assert(frame.profile_index == 1)
	assert(background.current_background_id == &"planetary")
	assert(_completed_ids == [17])

	presenter.play_stage_shift(planetary, 17)
	await get_tree().process_frame
	assert(_completed_ids == [17], "Duplicate shift IDs must not emit twice.")
	assert(background.ambient.stage_id == &"planetary")
	print("S5_G4_STAGE_WORLD_SHIFT_VERIFIED backgrounds=3 dynamic_ambient=true shift_once=true")
	get_tree().quit()


func _assert_background_assets(background: BackgroundManager) -> void:
	for background_id in [&"ground", &"planetary", &"galactic"]:
		background.set_background(background_id)
		var texture := background.layer_a.texture
		assert(texture != null)
		assert(texture.get_size() == Vector2(1600.0, 900.0))
		assert(background.current_background_id == background_id)
	background.set_background(&"ground")


func _on_shift_finished(shift_id: int) -> void:
	_completed_ids.append(shift_id)
