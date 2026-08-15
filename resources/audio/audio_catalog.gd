class_name AudioCatalog
extends Resource

## Single source of truth for S6 audio event keys and their imported streams.

@export var events: Array[Resource] = []


func get_event(event_key: StringName) -> Resource:
	for event in events:
		if event != null and event.event_key == event_key:
			return event
	return null


func has_event(event_key: StringName) -> bool:
	return get_event(event_key) != null
