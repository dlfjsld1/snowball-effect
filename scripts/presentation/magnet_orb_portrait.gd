class_name MagnetOrbPortrait
extends Control

## Approved compact C-style Magnet Orb, manually redrawn on a 64px grid.
## Every filled rectangle lands on integer pixels; the transparent edge is
## untouched so the CUT-IN and the world renderer remain crisp at nearest scale.

const PIXELS := [
	[10, 8, 18, 4, "081735"], [36, 8, 18, 4, "081735"],
	[8, 12, 22, 20, "081735"], [34, 12, 22, 20, "081735"],
	[10, 32, 18, 4, "081735"], [36, 32, 18, 4, "081735"],
	[12, 32, 16, 18, "081735"], [36, 32, 16, 18, "081735"],
	[16, 46, 32, 10, "081735"], [22, 56, 20, 2, "081735"],
	[11, 12, 16, 18, "df332a"], [13, 14, 12, 14, "f24425"],
	[13, 14, 4, 12, "ff8554"], [19, 15, 4, 4, "ffe8a8"], [23, 22, 4, 5, "c21c31"],
	[37, 12, 16, 18, "075bdb"], [39, 14, 12, 14, "147def"],
	[39, 14, 4, 12, "23c8ff"], [45, 15, 4, 4, "dff9ff"], [37, 23, 4, 5, "0646ba"],
	[15, 34, 10, 12, "e9d6a2"], [17, 34, 5, 12, "fff1bf"],
	[39, 34, 10, 12, "e9d6a2"], [42, 34, 5, 12, "c6b482"],
	[18, 44, 10, 8, "d8c493"], [36, 44, 10, 8, "d8c493"],
	[22, 48, 20, 6, "ead8a9"], [26, 52, 12, 3, "fff3c9"],
	[22, 46, 20, 2, "ffffff"], [18, 46, 6, 2, "fff3c9"], [40, 46, 6, 2, "baa979"],
	[24, 54, 16, 2, "ad9e7b"],
	[30, 22, 4, 12, "7fe4ff"], [26, 26, 12, 4, "7fe4ff"],
	[31, 20, 2, 16, "dfffff"], [24, 27, 16, 2, "dfffff"], [31, 26, 2, 4, "ffffff"],
]


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func _draw() -> void:
	var scale_factor := minf(size.x, size.y) / 64.0
	var origin := (size - Vector2(64.0, 64.0) * scale_factor) * 0.5
	for pixel: Array in PIXELS:
		var rect := Rect2(
			origin + Vector2(float(pixel[0]), float(pixel[1])) * scale_factor,
			Vector2(float(pixel[2]), float(pixel[3])) * scale_factor
		)
		draw_rect(rect, Color(String(pixel[4])))
