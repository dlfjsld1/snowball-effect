class_name AudioEventDefinition
extends Resource

## Content-owned mapping from a stable event key to one imported audio asset.
## Playback policy belongs to S6-G4; this resource only describes the asset.

@export var event_key: StringName
@export var stream: AudioStream
@export var loop := false


func is_valid_definition() -> bool:
	return not event_key.is_empty() and stream != null
