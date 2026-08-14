extends Node

const MANIFEST_PATH := "res://assets/sprites/ui/frame/paper8_lab_v1/manifest.json"
const KIT_ROOT := "res://assets/sprites/ui/frame/paper8_lab_v1/"


func _ready() -> void:
	print("S5-G4 Paper-8 frame asset kit verification started")
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		_fail("manifest could not be opened")
		return
	var manifest: Dictionary = JSON.parse_string(file.get_as_text())
	if not _matches_size(manifest.get("authoring_canvas") as Array, 1600, 900):
		_fail("unexpected authoring canvas")
		return
	if not _matches_size(manifest.get("logical_source") as Array, 800, 450):
		_fail("unexpected logical source")
		return
	if manifest.get("render_scale") != 2:
		_fail("unexpected render scale")
		return
	if (manifest.get("palette") as Array).size() != 8:
		_fail("unexpected palette size")
		return

	var assets := manifest.get("assets") as Array
	if assets.size() != 46:
		_fail("unexpected asset count")
		return
	for entry_variant in assets:
		var entry := entry_variant as Dictionary
		var path := KIT_ROOT + String(entry.get("path"))
		if not FileAccess.file_exists(path):
			_fail("missing asset: %s" % path)
			return
		var texture := load(path) as Texture2D
		var size := entry.get("size") as Array
		if texture == null or texture.get_width() != int(size[0]) or texture.get_height() != int(size[1]):
			_fail("unreadable asset or unexpected size: %s" % path)
			return

	print("S5-G4 Paper-8 frame asset kit verification passed: 46 assets, 8 colors, 1600x900")
	get_tree().quit()


func _fail(message: String) -> void:
	push_error("S5-G4 Paper-8 frame asset kit verification failed: %s" % message)
	get_tree().quit(1)


func _matches_size(values: Array, width: int, height: int) -> bool:
	return values.size() == 2 and int(values[0]) == width and int(values[1]) == height
