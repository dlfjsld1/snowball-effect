class_name BallTextureLodCatalog
extends RefCounted

## Presentation-owned exact-size LODs for Stage-local Ball rendering.
##
## BallDefinition.texture remains the primary texture for Balls with one
## authored runtime size. Shared boundary Balls and Presentation-only masters
## can resolve here without replacing, filtering, or mutating Content data.

const GROUND_SNOWFLAKE_FROST_BLOSSOM_PREVIEW_32 := preload("res://assets/sprites/balls/ground/runtime/ball_lv00_snowflake_frost_blossom_preview_32.tres")
const GROUND_SNOWBALL_USER_AUTHORED_16 := preload("res://assets/sprites/balls/ground/runtime/ball_lv01_snowball_user_authored_16.tres")
const GROUND_BIG_SNOWBALL_USER_AUTHORED_32 := preload("res://assets/sprites/balls/ground/runtime/ball_lv02_big_snowball_user_authored_32.tres")
const GROUND_GIANT_SNOWBALL_USER_AUTHORED_64 := preload("res://assets/sprites/balls/ground/runtime/ball_lv03_giant_snowball_user_authored_64.tres")
const GROUND_GIANT_SNOWBALL_USER_AUTHORED_64_V2 := preload("res://assets/sprites/balls/ground/runtime/ball_lv03_giant_snowball_user_authored_64_v2.tres")
const GROUND_MOON_USER_AUTHORED_128 := preload("res://assets/sprites/balls/ground/runtime/ball_lv04_moon_user_authored_128.tres")
const PLANETARY_MOON_USER_AUTHORED_8 := preload("res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv00_moon_user_authored_8.tres")
const PLANETARY_EARTH_USER_AUTHORED_16 := preload("res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv01_earth_user_authored_16.tres")
const PLANETARY_SUN_CORONA_CROWN_32 := preload("res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv02_sun_corona_crown_32.tres")
const PLANETARY_SUPERNOVA_USER_AUTHORED_64 := preload("res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv03_supernova_user_authored_64.tres")
const PLANETARY_GALAXY_USER_AUTHORED_128 := preload("res://assets/sprites/balls/planetary/runtime/ball_planetary_local_lv04_galaxy_user_authored_128.tres")
const GALACTIC_GALAXY_USER_AUTHORED_8 := preload("res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv00_galaxy_user_authored_8.tres")
const GALACTIC_GALAXY_CLUSTER_16 := preload("res://assets/sprites/balls/galactic/runtime/ball_lv11_galaxy_cluster_16.png")
const GALACTIC_QUASAR_POLAR_BEACON_32 := preload("res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv02_quasar_polar_beacon_32.tres")
const GALACTIC_EVENT_HORIZON_64 := preload("res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv03_event_horizon_last_light_64.tres")
const GALACTIC_BLACK_HOLE_VOID_CATHEDRAL_128 := preload("res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv04_black_hole_void_cathedral_128.tres")

## Temporary approved-candidate preview. CanvasTexture owns linear sampling so
## the Core renderer and every other exact-size/pixel-filtered Ball stay intact.
const _TEMPORARY_PREVIEW_TEXTURES := {
	0: {
		8: GROUND_SNOWFLAKE_FROST_BLOSSOM_PREVIEW_32,
	},
}

const _APPROVED_RUNTIME_TEXTURES := {
	1: {
		16: GROUND_SNOWBALL_USER_AUTHORED_16,
	},
	2: {
		32: GROUND_BIG_SNOWBALL_USER_AUTHORED_32,
	},
	3: {
		64: GROUND_GIANT_SNOWBALL_USER_AUTHORED_64_V2,
	},
	4: {
		128: GROUND_MOON_USER_AUTHORED_128,
	},
}

const _EXACT_SIZE_TEXTURES := {
	4: {
		8: PLANETARY_MOON_USER_AUTHORED_8,
	},
	5: {
		16: PLANETARY_EARTH_USER_AUTHORED_16,
	},
	6: {
		32: PLANETARY_SUN_CORONA_CROWN_32,
	},
	8: {
		64: PLANETARY_SUPERNOVA_USER_AUTHORED_64,
	},
	10: {
		128: PLANETARY_GALAXY_USER_AUTHORED_128,
		8: GALACTIC_GALAXY_USER_AUTHORED_8,
	},
	11: {
		16: GALACTIC_GALAXY_CLUSTER_16,
	},
	12: {
		32: GALACTIC_QUASAR_POLAR_BEACON_32,
	},
	13: {
		64: GALACTIC_EVENT_HORIZON_64,
	},
	14: {
		128: GALACTIC_BLACK_HOLE_VOID_CATHEDRAL_128,
	},
}


func resolve_texture(global_level: int, runtime_diameter: float, primary_texture: Texture2D) -> Texture2D:
	var diameter := roundi(runtime_diameter)
	if not is_equal_approx(float(diameter), runtime_diameter):
		return null
	var preview_lods: Dictionary = _TEMPORARY_PREVIEW_TEXTURES.get(global_level, {})
	var preview_texture: Texture2D = preview_lods.get(diameter)
	if preview_texture != null:
		return preview_texture
	var approved_lods: Dictionary = _APPROVED_RUNTIME_TEXTURES.get(global_level, {})
	var approved_texture: Texture2D = approved_lods.get(diameter)
	if approved_texture != null:
		return approved_texture
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
