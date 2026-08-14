extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const OUTPUT_PATH := "res://docs/design/mockups/drafts/frame-paper8-scale-shift-preview.png"


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame
	var presenter: PresentationManager = main.get_node("UI/GameplayFrame/PresentationManager")
	presenter.shift_duration = 1.2
	var stage_manager: StageManager = main.get_node("StageManager")
	stage_manager._on_end_decision_requested(&"TOP_BALL_CLEAR")
	await get_tree().create_timer(0.42).timeout
	var image := get_viewport().get_texture().get_image()
	assert(image != null and image.get_size() == Vector2i(1600, 900))
	var error := image.save_png(OUTPUT_PATH)
	assert(error == OK)
	print("S5-G4 Scale Shift capture saved: %s" % OUTPUT_PATH)
	get_tree().quit()
