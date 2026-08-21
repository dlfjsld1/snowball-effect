class_name ItemDefinition
extends Resource

## Content-owned balance data for a single optional item.  The producer layer
## only selects and delivers an item; activation belongs to S7-G1.

@export var item_type: StringName = &""
@export_range(0.0, 1000.0, 0.01, "or_greater") var spawn_weight := 1.0
@export_range(0.0, 3600.0, 0.01, "or_greater") var duration := 0.0
@export var magnitude := 0.0
@export_range(1, 99, 1) var required_break_hits := 5
@export_range(1.0, 512.0, 1.0, "or_greater") var planet_radius := 24.0
@export_range(1.0, 2000.0, 1.0, "or_greater") var orb_speed := 160.0
