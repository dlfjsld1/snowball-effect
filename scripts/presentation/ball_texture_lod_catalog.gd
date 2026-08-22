class_name BallTextureLodCatalog
extends RefCounted

## Presentation-owned exact-size LODs for Stage-local Ball rendering.
##
## BallDefinition.texture remains the primary texture for Balls with one
## authored runtime size. Shared boundary Balls and Presentation-only masters
## can resolve here without replacing, filtering, or mutating Content data.

const PLANETARY_MOON_8 := preload("res://assets/sprites/balls/planetary/runtime/ball_lv04_moon_8.png")
const PLANETARY_EARTH_16 := preload("res://assets/sprites/balls/planetary/runtime/ball_lv05_earth_16.png")
const PLANETARY_SUN_32 := preload("res://assets/sprites/balls/planetary/runtime/ball_lv06_sun_32.png")
const PLANETARY_SUPERNOVA_64 := preload("res://assets/sprites/balls/planetary/runtime/ball_lv08_supernova_64.png")
const PLANETARY_GALAXY_128 := preload("res://assets/sprites/balls/planetary/runtime/ball_lv10_galaxy_128.png")
const GALACTIC_GALAXY_8 := preload("res://assets/sprites/balls/galactic/runtime/ball_lv10_galaxy_8.png")
const GALACTIC_GALAXY_CLUSTER_16 := preload("res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png")
const GALACTIC_QUASAR_32 := preload("res://assets/sprites/balls/galactic/runtime/ball_lv12_quasar_32.png")
const GALACTIC_EVENT_HORIZON_64 := preload("res://assets/sprites/balls/galactic/runtime/ball_lv13_event_horizon_64.png")
const GALACTIC_BLACK_HOLE_128 := preload("res://assets/sprites/balls/galactic/runtime/ball_lv14_black_hole_128.png")

const _EXACT_SIZE_TEXTURES := {
	4: {
		8: PLANETARY_MOON_8,
	},
	5: {
		16: PLANETARY_EARTH_16,
	},
	6: {
		32: PLANETARY_SUN_32,
	},
	8: {
		64: PLANETARY_SUPERNOVA_64,
	},
	10: {
		128: PLANETARY_GALAXY_128,
		8: GALACTIC_GALAXY_8,
	},
	11: {
		16: GALACTIC_GALAXY_CLUSTER_16,
	},
	12: {
		32: GALACTIC_QUASAR_32,
	},
	13: {
		64: GALACTIC_EVENT_HORIZON_64,
	},
	14: {
		128: GALACTIC_BLACK_HOLE_128,
	},
}


func resolve_texture(global_level: int, runtime_diameter: float, primary_texture: Texture2D) -> Texture2D:
	var diameter := roundi(runtime_diameter)
	if not is_equal_approx(float(diameter), runtime_diameter):
		return null
	var level_lods: Dictionary = _EXACT_SIZE_TEXTURES.get(global_level, {})
	var texture: Texture2D = level_lods.get(diameter)
	if _matches_runtime_size(texture, runtime_diameter):
		return texture
	return primary_texture if _matches_runtime_size(primary_texture, runtime_diameter) else null


func _matches_runtime_size(texture: Texture2D, runtime_diameter: float) -> bool:
	return (
		texture != null
		and is_equal_approx(float(texture.get_width()), runtime_diameter)
		and is_equal_approx(float(texture.get_height()), runtime_diameter)
	)
