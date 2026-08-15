extends Node

const AudioCatalogResource = preload("res://resources/audio/audio_catalog.tres")

const EXPECTED_EVENT_KEYS := [
	&"merge_t0", &"merge_t1", &"merge_t2", &"merge_t3",
	&"cashout_t0", &"cashout_high",
	&"settlement_start", &"settlement_finish", &"stage_clear", &"stage_fail", &"scale_shift",
	&"ui_click", &"ui_pause", &"ui_resume", &"ui_retry", &"ui_start", &"ui_menu",
	&"black_hole_phase", &"black_hole_loop", &"black_hole_absorb", &"black_hole_finale", &"run_end",
]

var _failures := 0


func _ready() -> void:
	var catalog = AudioCatalogResource
	_expect(catalog.events.size() == EXPECTED_EVENT_KEYS.size(), "Catalog must contain every selected audio event exactly once.")

	var seen_keys: Dictionary = {}
	for event: Variant in catalog.events:
		_expect(event != null, "Catalog entries must not be null.")
		if event == null:
			continue
		_expect(event.is_valid_definition(), "Every event must have a non-empty key and imported stream.")
		_expect(not seen_keys.has(event.event_key), "Event keys must be unique.")
		seen_keys[event.event_key] = true
		_expect(event.stream is AudioStreamOggVorbis, "Each event must load as an Ogg Vorbis stream.")
		_expect(event.stream.resource_path.ends_with(".ogg"), "Each event must reference a Web-supported OGG source asset.")
		_expect(event.loop == (event.event_key == &"black_hole_loop"), "Only black_hole_loop may be marked for looping.")

	for event_key in EXPECTED_EVENT_KEYS:
		_expect(catalog.has_event(event_key), "Every required event key must resolve from the catalog.")
		var event: Variant = catalog.get_event(event_key)
		if event != null:
			_expect(event.stream.resource_path.get_file().get_basename() == event_key, "Event key must match its OGG filename.")

	_expect(not catalog.has_event(&"missing_event"), "Unknown keys must not resolve.")
	if _failures == 0:
		print("S6_G3_VERIFIED audio_events=%d ogg_streams=%d" % [catalog.events.size(), EXPECTED_EVENT_KEYS.size()])
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G3 verification failed: %s" % message)
