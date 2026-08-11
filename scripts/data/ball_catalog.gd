class_name BallCatalog
extends RefCounted

## Read-only catalog consumed by Core. Resource values remain the single source
## of truth so balance changes do not require simulation code edits.

const _DEFINITIONS := [
	preload("res://resources/balls/ball_00_snowflake.tres"),
	preload("res://resources/balls/ball_01_snowball.tres"),
	preload("res://resources/balls/ball_02_big_snowball.tres"),
	preload("res://resources/balls/ball_03_giant_snowball.tres"),
	preload("res://resources/balls/ball_04_lunar_snowball.tres"),
	preload("res://resources/balls/ball_05_earth_snowball.tres"),
	preload("res://resources/balls/ball_06_solar_snowball.tres"),
	preload("res://resources/balls/ball_07_supernova_snowball.tres"),
	preload("res://resources/balls/ball_08_nebula_snowball.tres"),
	preload("res://resources/balls/ball_09_galaxy_snowball.tres"),
	preload("res://resources/balls/ball_10_black_hole.tres"),
	preload("res://resources/balls/ball_11_big_bang.tres"),
	preload("res://resources/balls/ball_12_universe.tres"),
	preload("res://resources/balls/ball_13_multiverse.tres"),
	preload("res://resources/balls/ball_14_omega_snowball.tres"),
]


func get_definition(global_level: int):
	if global_level < 0 or global_level >= _DEFINITIONS.size():
		return null
	return _DEFINITIONS[global_level]


func has_definition(global_level: int) -> bool:
	return get_definition(global_level) != null


func get_all_definitions() -> Array:
	return _DEFINITIONS.duplicate()
