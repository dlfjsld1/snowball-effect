extends Node

const TitleScreenScene = preload("res://scenes/ui/title_screen.tscn")

var _failures := 0


func _ready() -> void:
	var title: TitleScreen = TitleScreenScene.instantiate()
	add_child(title)
	title.show_title()
	await get_tree().process_frame

	var button := title.help_button
	_expect(button is Button, "Title help control must be a real Godot Button.")
	_expect(title.help_visual is Control, "Title help control must separate the hit area from its fixed circular visual.")
	_expect(button.mouse_filter == Control.MOUSE_FILTER_STOP, "Title help control must own its pointer hit area.")
	_expect(button.size.is_equal_approx(Vector2(36.0, 36.0)), "Title help control must keep a compact 36x36 circular hit area.")
	_expect(button.position.x >= 1550.0 and button.position.y <= 24.0, "Title help control must remain in the dark upper-right edge outside the brass pipe detail.")

	var visual := title.help_visual
	var circle := visual.get_node("Circle") as Panel
	var mark := visual.get_node("QuestionMark") as Label
	_expect(visual.size.is_equal_approx(Vector2(36.0, 36.0)), "Title help visual must remain an exact square independently of Button content sizing.")
	var circle_style := circle.get_theme_stylebox(&"panel") as StyleBoxFlat
	_expect(circle_style != null, "Title help visual must define a circle style.")
	if circle_style != null:
		_expect(circle_style.corner_radius_top_left == 18 and circle_style.border_width_left == 4, "Title help visual must use a thick true circle.")
		_expect(circle_style.border_color.is_equal_approx(Color.WHITE), "Title help circle must be opaque white at rest.")
	_expect(mark.text == "?" and mark.get_theme_constant(&"outline_size") == 1, "Title help question mark must use a reinforced one-pixel outline.")
	button.mouse_entered.emit()
	_expect(is_equal_approx(visual.modulate.a, 0.45), "Title help circle and question mark must become translucent together while hovered.")
	button.mouse_exited.emit()
	_expect(is_equal_approx(visual.modulate.a, 1.0), "Title help visual must return to full opacity after hover.")

	_expect(not title.help_modal.visible, "Title help modal must start hidden.")
	button.pressed.emit()
	_expect(title.help_modal.visible, "Title help button must open the guide modal.")
	_expect(title.help_modal.mouse_filter == Control.MOUSE_FILTER_STOP, "Title help modal must block the title actions behind it.")
	_expect(title.help_image.texture != null and title.help_image.texture.resource_path.ends_with("title_controls_guide.png"), "Title help modal must show the approved guide image.")
	_expect(title.help_image.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, "Title help image must preserve its aspect ratio.")
	title.help_dismiss_button.pressed.emit()
	_expect(not title.help_modal.visible, "Title help modal must close through its dismiss surface.")

	if _failures == 0:
		print("S8_G3_TITLE_HELP_VERIFIED button=true true_circle=36px guide_modal=true dismiss=true aspect=preserved hover_alpha=0.45")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S8-G3 Title help verification failed: %s" % message)
