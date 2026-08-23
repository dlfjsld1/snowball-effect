class_name PipeVolumeGauge
extends Control

## Read-only 0..10 pipe sight-glass. Interaction belongs to its adjacent step buttons.
## The selected artwork supplies the brass shell; every chamber is redrawn so the
## source image's example fill level never leaks into the runtime state.

const PIPE_TEXTURE: Texture2D = preload("res://assets/sprites/ui/settings/volume_pipe_selected.png")
## The source meter is eleven pitches wide. Shift the ten-cell bank right by
## half a pitch, leaving one half-cell gutter on each side at level 10.
const CELL_LEFT_RATIO := 0.213
const CELL_TOP_RATIO := 0.358
## Deliberately narrower than the 10.67px pitch so all ten chambers retain a
## visible separator instead of merging into an apparent eleven-cell bar.
const CELL_WIDTH_RATIO := 0.043
const CELL_HEIGHT_RATIO := 0.358
const CELL_PITCH_RATIO := 0.055
## Clear the whole source-meter window, including its former final dark cell.
const GLASS_LEFT_RATIO := 0.180
const GLASS_TOP_RATIO := 0.320
const GLASS_WIDTH_RATIO := 0.610
const GLASS_HEIGHT_RATIO := 0.420

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

	# The reference texture already contains a sample meter. Clear its entire
	# sight-glass first: masking individual source cells leaves its intervening
	# dividers visible and makes the meter read as eleven chambers.
	var glass := Rect2(
		display_origin.x + display_size.x * GLASS_LEFT_RATIO,
		display_origin.y + display_size.y * GLASS_TOP_RATIO,
		display_size.x * GLASS_WIDTH_RATIO,
		display_size.y * GLASS_HEIGHT_RATIO
	)
	draw_rect(glass, Color("140d09"), true)
	draw_line(glass.position, Vector2(glass.end.x, glass.position.y), Color("5f3517"), 1.0)
	draw_line(Vector2(glass.position.x, glass.end.y), glass.end, Color("28140a"), 1.0)

	# Render exactly the ten discrete levels used by the settings contract.
	for index in range(10):
		var cell := Rect2(
			display_origin.x + display_size.x * (CELL_LEFT_RATIO + CELL_PITCH_RATIO * index),
			display_origin.y + display_size.y * CELL_TOP_RATIO,
			display_size.x * CELL_WIDTH_RATIO,
			display_size.y * CELL_HEIGHT_RATIO
		)
		if index < level:
			draw_rect(cell, Color("f08a18"), true)
			draw_line(cell.position + Vector2(1.0, 1.0), Vector2(cell.end.x - 1.0, cell.position.y + 1.0), Color("ffd36b"), 1.0)
			draw_line(Vector2(cell.position.x + 1.0, cell.end.y - 1.0), Vector2(cell.end.x - 1.0, cell.end.y - 1.0), Color("a9460c"), 1.0)
		else:
			draw_rect(cell, Color("382319"), true)
			draw_line(cell.position + Vector2(1.0, 1.0), Vector2(cell.end.x - 1.0, cell.position.y + 1.0), Color("6c482b"), 1.0)
