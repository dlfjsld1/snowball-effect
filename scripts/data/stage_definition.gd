class_name StageDefinition
extends Resource

## Canonical balance and presentation data for one playable stage.
##
## Catalog identity remains global. Runtime visual/collision radius follows the
## ball's index in this Stage's local progression so each Stage restarts small.

@export_range(0, 99, 1) var stage_index := 0
@export var display_name := ""
@export_range(0, 99, 1) var base_global_level := 0
@export_range(0, 99, 1) var top_global_level := 0
## Each default stage uses exactly five ordered global levels. The IDs may be
## noncontiguous, and the previous stage top becomes the next stage base.
@export var local_ball_levels := PackedInt32Array()

@export_range(0.0, 3600.0, 0.01, "or_greater") var base_time := 0.0
@export_range(0.0, 1.0e50, 0.000001, "or_greater") var clear_score := 0.0
@export var time_bonus_by_local_level := PackedFloat64Array()
@export_range(0.0, 1000.0, 0.01, "or_greater") var spawn_rate := 0.0

## Reserved for the later Scale Shift presentation. Gameplay balls keep visual
## and collision radius aligned; this field must not create a mismatch.
@export_range(0.001, 1000.0, 0.001, "or_greater") var visual_radius_scale := 1.0
@export var background_id: StringName = &""

## Reserved for explicit stage gameplay effects. These fields do not create a
## default downward gravity rule.
@export var global_force_scale := 0.0
@export var black_hole_enabled := false
