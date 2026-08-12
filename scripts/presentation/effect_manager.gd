class_name EffectManager
extends Control

const BallCatalog = preload("res://scripts/data/ball_catalog.gd")
const MergeEffectScene = preload("res://scenes/effects/merge_effect.tscn")

signal merge_effect_spawned(result_level: int, world_position: Vector2)

var merge_effect_count := 0

var _simulation_source: Node
var _ball_catalog = BallCatalog.new()


func set_simulation_source(simulation_source: Node) -> void:
	if is_instance_valid(_simulation_source) and _simulation_source.ball_merged.is_connected(_on_ball_merged):
		_simulation_source.ball_merged.disconnect(_on_ball_merged)
	_simulation_source = simulation_source
	if is_instance_valid(_simulation_source):
		_simulation_source.ball_merged.connect(_on_ball_merged)


func get_active_merge_effect_count() -> int:
	return get_child_count()


func _on_ball_merged(result_level: int, world_position: Vector2) -> void:
	var definition = _ball_catalog.get_definition(result_level)
	if definition == null:
		return
	var effect = MergeEffectScene.instantiate()
	add_child(effect)
	effect.setup(world_position, definition.display_name, definition.score_value, definition.base_color, definition.fx_tier)
	merge_effect_count += 1
	merge_effect_spawned.emit(result_level, world_position)


func _exit_tree() -> void:
	set_simulation_source(null)
