extends Node

const TitleScreenScene := preload("res://scenes/ui/title_screen.tscn")


func _ready() -> void:
	var title_screen = TitleScreenScene.instantiate()
	add_child(title_screen)
	await get_tree().process_frame
	title_screen.show_title()
