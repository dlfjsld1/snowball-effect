class_name StageCatalog
extends RefCounted

## Read-only catalog for Core, Presentation, and Integration consumers.
## Stage resources, rather than runtime formulas, are the balance source.

const _STAGES := [
	preload("res://resources/stages/stage_00_ground.tres"),
	preload("res://resources/stages/stage_01_planetary.tres"),
	preload("res://resources/stages/stage_02_galactic.tres"),
]


func get_stage(index: int):
	if index < 0 or index >= _STAGES.size():
		return null
	return _STAGES[index]


func has_stage(index: int) -> bool:
	return get_stage(index) != null


func get_all_stages() -> Array:
	return _STAGES.duplicate()
