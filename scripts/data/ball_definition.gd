class_name BallDefinition
extends Resource

## Canonical gameplay and presentation source data for one global ball level.
##
## Stage-local rules, including Time Bonus, deliberately do not belong here:
## a global ball can have a different local level in each stage.

@export_range(0, 99, 1) var global_level := 0
@export var display_name := ""
@export_range(0.0, 1.0e50, 0.000001, "or_greater") var score_value := 0.0
@export_range(0.001, 100000.0, 0.001, "or_greater") var radius := 1.0
@export_range(0.001, 1000000000.0, 0.001, "or_greater") var mass := 1.0

@export var visual_key: StringName = &""
@export var base_color := Color.WHITE
@export var texture: Texture2D
@export_range(0, 4, 1) var fx_tier := 0

## Reserved for a future spawn-only tuning pass. Zero means shared simulation
## tuning; it must never be used to overwrite runtime velocity every tick.
@export_range(0.0, 100000.0, 0.001, "or_greater") var base_speed_override := 0.0
