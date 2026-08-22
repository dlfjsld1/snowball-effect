class_name BrassPopupToggle
extends Button

## User-selected sliding breaker artwork for the Value Popups binary setting.

const OFF_TEXTURE: Texture2D = preload("res://assets/sprites/ui/settings/value_popups_toggle_off.png")
const ON_TEXTURE: Texture2D = preload("res://assets/sprites/ui/settings/value_popups_toggle_on.png")


func _ready() -> void:
	toggle_mode = true
	flat = true
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	toggled.connect(func(_enabled: bool) -> void: queue_redraw())
	queue_redraw()


func _draw() -> void:
	var texture := ON_TEXTURE if button_pressed else OFF_TEXTURE
	var display_size := Vector2(size.x, minf(size.y, 22.0))
	var display_origin := Vector2(0.0, (size.y - display_size.y) * 0.5)
	draw_texture_rect(texture, Rect2(display_origin, display_size), false)
