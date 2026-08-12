class_name StageDefinition
extends Resource

## Canonical balance and presentation data for one playable stage.
##
## Physical BallDefinition values remain global. Stage-local progression, time
## rewards, and render-only scale normalization belong here instead.

@export_range(0, 99, 1) var stage_index := 0
@export var display_name := ""
@export_range(0, 99, 1) var base_global_level := 0
@export_range(0, 99, 1) var top_global_level := 0
@export var local_ball_levels := PackedInt32Array()

@export_range(0.0, 3600.0, 0.01, "or_greater") var base_time := 0.0
@export_range(0.0, 1.0e50, 0.000001, "or_greater") var clear_score := 0.0
@export var time_bonus_by_local_level := PackedFloat64Array()
@export_range(0.0, 1000.0, 0.01, "or_greater") var spawn_rate := 0.0

## Render-only normalization; it must not alter BallDefinition.radius or
## collision behavior.
@export_range(0.001, 1000.0, 0.001, "or_greater") var visual_radius_scale := 1.0
@export var background_id: StringName = &""

## Reserved for explicit stage gameplay effects. These fields do not create a
## default downward gravity rule.
@export var global_force_scale := 0.0
@export var black_hole_enabled := false
