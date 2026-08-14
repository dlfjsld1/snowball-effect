extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")
const OUTPUT_PATH := "res://docs/design/mockups/drafts/frame-paper8-stage-world-preview.png"


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	assert(image.get_size() == Vector2i(1600, 900))
	var error := image.save_png(OUTPUT_PATH)
	assert(error == OK)
	print("S5-G4 runtime frame capture saved: %s" % OUTPUT_PATH)
	get_tree().quit()
