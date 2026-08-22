class_name PipeVolumeGauge
extends Control

## Read-only 0..10 pipe sight-glass. Interaction belongs to its adjacent step buttons.
## The shell is the user-selected brass-pipe artwork; only unfilled cells are masked.

const PIPE_TEXTURE: Texture2D = preload("res://assets/sprites/ui/settings/volume_pipe_selected.png")
const CELL_LEFT_RATIO := 0.232
const CELL_TOP_RATIO := 0.358
const CELL_WIDTH_RATIO := 0.043
const CELL_HEIGHT_RATIO := 0.358
const CELL_PITCH_RATIO := 0.055

@export_range(0, 10, 1) var level := 10:
	set(value):
		level = clampi(value, 0, 10)
		queue_redraw()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	var display_size := Vector2(size.x, minf(size.y, 32.0))
	var display_origin := Vector2(0.0, (size.y - display_size.y) * 0.5)

	# Preserve the exact selected outer pipe silhouette at every volume level.
	draw_texture_rect(PIPE_TEXTURE, Rect2(display_origin, display_size), false)

	# The source artwork represents level 10. Cover only chambers beyond the level,
	# leaving the original clamps, rails, outlines, and active chambers untouched.
	for index in range(level, 10):
		var cell := Rect2(
			display_origin.x + display_size.x * (CELL_LEFT_RATIO + CELL_PITCH_RATIO * index),
			display_origin.y + display_size.y * CELL_TOP_RATIO,
			display_size.x * CELL_WIDTH_RATIO,
			display_size.y * CELL_HEIGHT_RATIO
		)
		draw_rect(cell.grow(1.0), Color("1a100b"), true)
		draw_rect(cell, Color("382319"), true)
		draw_line(cell.position + Vector2(1.0, 1.0), Vector2(cell.end.x - 1.0, cell.position.y + 1.0), Color("6c482b"), 1.0)
