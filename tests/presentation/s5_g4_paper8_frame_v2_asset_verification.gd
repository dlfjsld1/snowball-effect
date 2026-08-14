extends Node

const KIT_ROOT := "res://assets/sprites/ui/frame/paper8_lab_v2"
const EXPECTED_ASSET_COUNT := 9


func _ready() -> void:
	var manifest_text := FileAccess.get_file_as_string(KIT_ROOT + "/manifest.json")
	var manifest = JSON.parse_string(manifest_text)
	assert(manifest is Dictionary)
	assert(manifest["schema"] == 2)
	assert(manifest["palette"].size() == 8)
	assert(manifest["assets"].size() == EXPECTED_ASSET_COUNT)

	for asset in manifest["assets"]:
		var path := KIT_ROOT + "/runtime/" + str(asset["path"])
		var texture := load(path) as Texture2D
		assert(texture != null, "v2 frame asset must load as Texture2D: %s" % path)
		var expected_size := Vector2(float(asset["size"][0]), float(asset["size"][1]))
		assert(texture.get_size() == expected_size, "Unexpected v2 frame asset size: %s" % path)

	print("S5-G4 Paper-8 frame v2 assets verified: assets=9 palette=8 Texture2D=true")
	get_tree().quit()
