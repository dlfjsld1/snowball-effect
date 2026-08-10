class_name BallCatalog
extends RefCounted

## Read-only catalog consumed by Core. Resource values remain the single source
## of truth so balance changes do not require simulation code edits.

const _DEFINITIONS: Array[BallDefinition] = [
	preload("res://resources/balls/ball_00_snowflake.tres"),
	preload("res://resources/balls/ball_01_snowball.tres"),
	preload("res://resources/balls/ball_02_big_snowball.tres"),
	preload("res://resources/balls/ball_03_giant_snowball.tres"),
	preload("res://resources/balls/ball_04_lunar_snowball.tres"),
	preload("res://resources/balls/ball_05_earth_snowball.tres"),
	preload("res://resources/balls/ball_06_solar_snowball.tres"),
]


static func get_definition(global_level: int) -> BallDefinition:
	if global_level < 0 or global_level >= _DEFINITIONS.size():
		return null
	return _DEFINITIONS[global_level]


static func has_definition(global_level: int) -> bool:
	return get_definition(global_level) != null


static func get_all_definitions() -> Array[BallDefinition]:
	return _DEFINITIONS.duplicate()
