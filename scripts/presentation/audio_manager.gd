class_name AudioManager
extends Node

## Content-owned audio consumer for the S6 catalog.
##
## This node reads existing gameplay/UI signals only. It never changes score,
## timer, stage state, or simulation state. Main passes event sources through
## configure_sources() after mounting this node.

const AudioCatalogResource = preload("res://resources/audio/audio_catalog.tres")
const BallCatalog = preload("res://scripts/data/ball_catalog.gd")

const STAGE_PLAYING: StringName = &"PLAYING"
const STAGE_READY: StringName = &"READY"
const STAGE_CLEAR_LOCKED: StringName = &"CLEAR_LOCKED"
const STAGE_CLEARED: StringName = &"CLEARED"
const STAGE_FAILED: StringName = &"FAILED"

const BGM_TITLE: StringName = &"bgm_title"
const BGM_GROUND: StringName = &"bgm_ground"
const BGM_PLANETARY: StringName = &"bgm_planetary"
const BGM_GALACTIC: StringName = &"bgm_galactic"
const BGM_PAUSE: StringName = &"bgm_pause"
const BGM_RESULT: StringName = &"bgm_result"

## Audio policy is intentionally independent from the visual FX budget.
## `gameplay` sounds can be suppressed by a transition, while terminal sounds
## clear lower-priority playback and remain audible.
const EVENT_POLICIES := {
	&"merge_t0": {"group": &"merge_t0", "priority": 10, "polyphony": 2, "cooldown": 0.10, "volume_db": -12.0, "gameplay": true},
	&"merge_t1": {"group": &"merge_t1", "priority": 20, "polyphony": 2, "cooldown": 0.14, "volume_db": -10.0, "gameplay": true},
	&"merge_t2": {"group": &"merge_t2", "priority": 30, "polyphony": 1, "cooldown": 0.20, "volume_db": -8.0, "gameplay": true},
	&"merge_t3": {"group": &"merge_t3", "priority": 45, "polyphony": 1, "cooldown": 0.28, "volume_db": -6.0, "gameplay": true},
	&"cashout_t0": {"group": &"cashout_t0", "priority": 25, "polyphony": 2, "cooldown": 0.14, "volume_db": -7.0, "gameplay": true},
	&"cashout_high": {"group": &"cashout_high", "priority": 50, "polyphony": 1, "cooldown": 0.22, "volume_db": -4.0, "gameplay": true},
	&"settlement_start": {"group": &"settlement", "priority": 70, "polyphony": 1, "cooldown": 0.0, "volume_db": -3.0},
	&"settlement_finish": {"group": &"settlement", "priority": 72, "polyphony": 1, "cooldown": 0.0, "volume_db": -2.0},
	&"stage_clear": {"group": &"stage_clear", "priority": 80, "polyphony": 1, "cooldown": 0.0, "volume_db": -1.0},
	&"scale_shift": {"group": &"scale_shift", "priority": 85, "polyphony": 1, "cooldown": 0.0, "volume_db": -7.0},
	&"black_hole_loop": {"group": &"black_hole_loop", "priority": 88, "polyphony": 1, "cooldown": 0.0, "volume_db": -14.0},
	&"black_hole_phase": {"group": &"black_hole_phase", "priority": 90, "polyphony": 1, "cooldown": 0.0, "volume_db": -4.0},
	&"stage_fail": {"group": &"terminal", "priority": 95, "polyphony": 1, "cooldown": 0.0, "volume_db": 0.0, "terminal": true},
	&"run_end": {"group": &"terminal", "priority": 95, "polyphony": 1, "cooldown": 0.0, "volume_db": 0.0, "terminal": true},
	&"black_hole_finale": {"group": &"terminal", "priority": 100, "polyphony": 1, "cooldown": 0.0, "volume_db": 0.0, "terminal": true},
	&"black_hole_absorb": {"group": &"black_hole_absorb", "priority": 55, "polyphony": 2, "cooldown": 0.10, "volume_db": -6.0, "gameplay": true},
	&"item_collect": {"group": &"item_collect", "priority": 50, "polyphony": 1, "cooldown": 0.10, "volume_db": 0.0, "gameplay": true},
	&"item_cutin": {"group": &"item_cutin", "priority": 65, "polyphony": 1, "cooldown": 0.10, "volume_db": 0.0, "gameplay": true},
	&"ui_click": {"group": &"ui", "priority": 40, "polyphony": 1, "cooldown": 0.08, "volume_db": -8.0},
	&"ui_pause": {"group": &"ui", "priority": 40, "polyphony": 1, "cooldown": 0.08, "volume_db": -8.0},
	&"ui_resume": {"group": &"ui", "priority": 40, "polyphony": 1, "cooldown": 0.08, "volume_db": -8.0},
	&"ui_retry": {"group": &"ui", "priority": 40, "polyphony": 1, "cooldown": 0.08, "volume_db": -7.0},
	&"ui_start": {"group": &"ui", "priority": 40, "polyphony": 1, "cooldown": 0.08, "volume_db": -7.0},
	&"ui_menu": {"group": &"ui", "priority": 40, "polyphony": 1, "cooldown": 0.08, "volume_db": -8.0},
}

@export var player_pool_size := 8
@export var audio_bus: StringName = &"Master"
@export_range(-40.0, 0.0, 0.5) var sfx_volume_offset_db := -6.0
@export_range(-40.0, 0.0, 0.5) var music_volume_db := -14.0

var catalog: AudioCatalog = AudioCatalogResource
var audio_unlocked := false
var _settings_bgm_volume := 5
var _settings_sfx_volume := 5

var _ball_catalog := BallCatalog.new()
var _players: Array[AudioStreamPlayer] = []
var _simulation_source: Node
var _stage_source: Node
var _pause_menu_source: Node
var _title_screen_source: Node
var _stage_clear_played := false
var _black_hole_loop_player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _current_music_key: StringName = &""
var _paused_stage_music_key: StringName = &""
var _paused_stage_music_position := 0.0
var _last_play_time_by_group: Dictionary = {}
var _gameplay_suppressed := false
var _dropped_event_count := 0
var _preempted_event_count := 0
var _pause_toggle_is_paused := false
var _pending_settlement_finish := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_player_pool()
	_ensure_music_player()


func _input(event: InputEvent) -> void:
	if audio_unlocked or not _is_user_activation(event):
		return
	audio_unlocked = true
	_play_current_music()


func configure_sources(
	simulation_source: Node,
	stage_source: Node,
	pause_menu_source: Node,
	title_screen_source: Node = null
) -> void:
	_disconnect_sources()
	_simulation_source = simulation_source
	_stage_source = stage_source
	_pause_menu_source = pause_menu_source
	_title_screen_source = title_screen_source
	_connect_simulation_source()
	_connect_stage_source()
	_connect_pause_menu_source()
	_connect_title_screen_source()
	_request_music(BGM_TITLE)


func apply_volume_settings(bgm_volume: int, sfx_volume: int) -> bool:
	if bgm_volume < 0 or bgm_volume > 10 or sfx_volume < 0 or sfx_volume > 10:
		return false
	_settings_bgm_volume = bgm_volume
	_settings_sfx_volume = sfx_volume
	for player in _players:
		if player.playing:
			player.volume_db = _get_event_volume_db(StringName(player.get_meta(&"audio_event_key", &"")))
	if _music_player != null and is_instance_valid(_music_player):
		_music_player.volume_db = _get_music_volume_db()
	return true


func play_event(event_key: StringName) -> bool:
	if not audio_unlocked or catalog == null:
		return false
	var definition: AudioEventDefinition = catalog.get_event(event_key) as AudioEventDefinition
	if definition == null or definition.stream == null:
		return false
	var policy := get_event_policy(event_key)
	if policy.is_empty():
		return false
	if _gameplay_suppressed and bool(policy.get("gameplay", false)):
		_drop_event()
		return false
	var group: StringName = policy["group"]
	var now := _now_seconds()
	var cooldown: float = policy["cooldown"]
	if now - float(_last_play_time_by_group.get(group, -INF)) < cooldown:
		_drop_event()
		return false
	if bool(policy.get("terminal", false)):
		_prepare_terminal_playback(int(policy["priority"]))
	if event_key == &"settlement_finish" and _is_group_playing(&"settlement"):
		_pending_settlement_finish = true
		return true
	if _count_playing_in_group(group) >= int(policy["polyphony"]):
		_drop_event()
		return false
	var player := _find_available_player(int(policy["priority"]))
	if player == null:
		_drop_event()
		return false
	player.stream = definition.stream
	player.bus = audio_bus
	player.volume_db = _get_event_volume_db(event_key)
	player.set_meta(&"audio_event_key", event_key)
	player.set_meta(&"audio_event_loop", definition.loop)
	player.set_meta(&"audio_event_group", group)
	player.set_meta(&"audio_event_priority", int(policy["priority"]))
	player.set_meta(&"audio_event_terminal", bool(policy.get("terminal", false)))
	player.play()
	_last_play_time_by_group[group] = now
	if definition.loop:
		_black_hole_loop_player = player
	return true


func start_loop(event_key: StringName) -> bool:
	if _black_hole_loop_player != null and is_instance_valid(_black_hole_loop_player) and _black_hole_loop_player.playing:
		return false
	return play_event(event_key)


func stop_loop() -> void:
	if _black_hole_loop_player != null and is_instance_valid(_black_hole_loop_player):
		_black_hole_loop_player.stop()
	_black_hole_loop_player = null


func reset_runtime() -> void:
	stop_loop()
	_stop_music()
	_current_music_key = &""
	_paused_stage_music_key = &""
	_paused_stage_music_position = 0.0
	_stage_clear_played = false
	_gameplay_suppressed = false
	_last_play_time_by_group.clear()
	_dropped_event_count = 0
	_preempted_event_count = 0
	_pause_toggle_is_paused = false
	_pending_settlement_finish = false
	for player in _players:
		player.stop()


func get_debug_snapshot() -> Dictionary:
	var playing_count := 0
	var active_event_keys: Array[StringName] = []
	for player in _players:
		if player.playing:
			playing_count += 1
			active_event_keys.append(StringName(player.get_meta(&"audio_event_key", &"")))
	return {
		"audio_unlocked": audio_unlocked,
		"player_count": _players.size(),
		"playing_count": playing_count,
		"active_event_keys": active_event_keys,
		"black_hole_loop_playing": _black_hole_loop_player != null and is_instance_valid(_black_hole_loop_player) and _black_hole_loop_player.playing,
		"music_playing": _music_player != null and is_instance_valid(_music_player) and _music_player.playing,
		"current_music_key": _current_music_key,
		"sfx_volume_offset_db": sfx_volume_offset_db,
		"music_volume_db": music_volume_db,
		"settings_bgm_volume": _settings_bgm_volume,
		"settings_sfx_volume": _settings_sfx_volume,
		"music_player_volume_db": _music_player.volume_db if _music_player != null and is_instance_valid(_music_player) else 0.0,
		"paused_stage_music_key": _paused_stage_music_key,
		"paused_stage_music_position": _paused_stage_music_position,
		"gameplay_suppressed": _gameplay_suppressed,
		"dropped_event_count": _dropped_event_count,
		"preempted_event_count": _preempted_event_count,
		"pause_toggle_is_paused": _pause_toggle_is_paused,
		"pending_settlement_finish": _pending_settlement_finish,
	}


func get_event_policy(event_key: StringName) -> Dictionary:
	var policy: Dictionary = EVENT_POLICIES.get(event_key, {})
	return policy.duplicate(true)


func _ensure_player_pool() -> void:
	var required_count := maxi(player_pool_size, 1)
	while _players.size() < required_count:
		var player := AudioStreamPlayer.new()
		player.finished.connect(_on_player_finished.bind(player))
		add_child(player)
		_players.append(player)


func _ensure_music_player() -> void:
	if _music_player != null and is_instance_valid(_music_player):
		return
	_music_player = AudioStreamPlayer.new()
	_music_player.finished.connect(_on_music_finished)
	add_child(_music_player)


func _find_available_player(priority: int) -> AudioStreamPlayer:
	_ensure_player_pool()
	for player in _players:
		if not player.playing:
			return player
	var candidate: AudioStreamPlayer
	var candidate_priority := priority
	for player in _players:
		if bool(player.get_meta(&"audio_event_terminal", false)):
			continue
		var player_priority := int(player.get_meta(&"audio_event_priority", 0))
		if player_priority < candidate_priority:
			candidate = player
			candidate_priority = player_priority
	if candidate != null:
		candidate.stop()
		if candidate == _black_hole_loop_player:
			_black_hole_loop_player = null
		_preempted_event_count += 1
	return candidate


func _count_playing_in_group(group: StringName) -> int:
	var count := 0
	for player in _players:
		if player.playing and StringName(player.get_meta(&"audio_event_group", &"")) == group:
			count += 1
	return count


func _prepare_terminal_playback(priority: int) -> void:
	var stopped_count := 0
	for player in _players:
		if player.playing and int(player.get_meta(&"audio_event_priority", 0)) < priority:
			player.stop()
			stopped_count += 1
	_preempted_event_count += stopped_count
	if _black_hole_loop_player != null and not _black_hole_loop_player.playing:
		_black_hole_loop_player = null


func _drop_event() -> void:
	_dropped_event_count += 1


func _now_seconds() -> float:
	return float(Time.get_ticks_msec()) / 1000.0


func _connect_simulation_source() -> void:
	if not is_instance_valid(_simulation_source):
		return
	_connect_signal(_simulation_source, &"ball_merged", _on_ball_merged)
	_connect_signal(_simulation_source, &"cashout_completed", _on_cashout_completed)
	_connect_signal(_simulation_source, &"black_hole_phase_requested", _on_black_hole_phase_requested)
	_connect_signal(_simulation_source, &"black_hole_absorbed", _on_black_hole_absorbed)
	_connect_signal(_simulation_source, &"black_hole_finale_started", _on_black_hole_finale_started)


func _connect_stage_source() -> void:
	if not is_instance_valid(_stage_source):
		return
	_connect_signal(_stage_source, &"stage_state_changed", _on_stage_state_changed)
	_connect_signal(_stage_source, &"stage_shift_started", _on_stage_shift_started)
	_connect_signal(_stage_source, &"stage_changed", _on_stage_changed)


func _connect_pause_menu_source() -> void:
	if not is_instance_valid(_pause_menu_source):
		return
	_connect_signal(_pause_menu_source, &"pause_requested", _on_pause_requested)
	_connect_signal(_pause_menu_source, &"resume_requested", _on_resume_requested)
	_connect_signal(_pause_menu_source, &"retry_requested", _on_retry_requested)
	_connect_signal(_pause_menu_source, &"settings_requested", _on_settings_requested)
	_connect_signal(_pause_menu_source, &"main_menu_requested", _on_main_menu_requested)


func _connect_title_screen_source() -> void:
	if not is_instance_valid(_title_screen_source):
		return
	_connect_signal(_title_screen_source, &"start_requested", _on_start_requested)


func _disconnect_sources() -> void:
	_disconnect_signal(_simulation_source, &"ball_merged", _on_ball_merged)
	_disconnect_signal(_simulation_source, &"cashout_completed", _on_cashout_completed)
	_disconnect_signal(_simulation_source, &"black_hole_phase_requested", _on_black_hole_phase_requested)
	_disconnect_signal(_simulation_source, &"black_hole_absorbed", _on_black_hole_absorbed)
	_disconnect_signal(_simulation_source, &"black_hole_finale_started", _on_black_hole_finale_started)
	_disconnect_signal(_stage_source, &"stage_state_changed", _on_stage_state_changed)
	_disconnect_signal(_stage_source, &"stage_shift_started", _on_stage_shift_started)
	_disconnect_signal(_stage_source, &"stage_changed", _on_stage_changed)
	_disconnect_signal(_pause_menu_source, &"pause_requested", _on_pause_requested)
	_disconnect_signal(_pause_menu_source, &"resume_requested", _on_resume_requested)
	_disconnect_signal(_pause_menu_source, &"retry_requested", _on_retry_requested)
	_disconnect_signal(_pause_menu_source, &"settings_requested", _on_settings_requested)
	_disconnect_signal(_pause_menu_source, &"main_menu_requested", _on_main_menu_requested)
	_disconnect_signal(_title_screen_source, &"start_requested", _on_start_requested)


func _connect_signal(source: Node, signal_name: StringName, callback: Callable) -> void:
	if source.has_signal(signal_name) and not source.is_connected(signal_name, callback):
		source.connect(signal_name, callback)


func _disconnect_signal(source: Node, signal_name: StringName, callback: Callable) -> void:
	if is_instance_valid(source) and source.has_signal(signal_name) and source.is_connected(signal_name, callback):
		source.disconnect(signal_name, callback)


func _on_ball_merged(result_level: int, _world_position: Vector2) -> void:
	var definition = _ball_catalog.get_definition(result_level)
	if definition == null:
		return
	play_event(StringName("merge_t%d" % clampi(definition.fx_tier, 0, 3)))


func _on_cashout_completed(_score_amount: float, global_level: int, _world_position: Vector2) -> void:
	var definition = _ball_catalog.get_definition(global_level)
	if definition == null:
		return
	play_event(&"cashout_high" if definition.fx_tier >= 2 else &"cashout_t0")


func _on_stage_state_changed(state: StringName) -> void:
	_gameplay_suppressed = state != STAGE_PLAYING
	if state == STAGE_READY:
		_pause_toggle_is_paused = false
		_paused_stage_music_key = &""
		_paused_stage_music_position = 0.0
		stop_loop()
		_request_music(BGM_TITLE)
	elif state == STAGE_CLEAR_LOCKED:
		_play_stage_clear_once()
	elif state == STAGE_CLEARED:
		_play_stage_clear_once()
	elif state == STAGE_FAILED:
		play_event(&"stage_fail")
	elif state == &"RUN_ENDED":
		play_event(&"run_end")
	elif state == STAGE_PLAYING:
		_stage_clear_played = false


func _on_stage_shift_started(_next_definition: Resource, _shift_id: int) -> void:
	_gameplay_suppressed = true
	play_event(&"scale_shift")


func _on_stage_changed(definition: Resource) -> void:
	_stage_clear_played = false
	_gameplay_suppressed = false
	var stage_music_key := _get_stage_music_key(definition)
	if stage_music_key != &"":
		_request_music(stage_music_key)


func _on_pause_requested() -> void:
	if _pause_toggle_is_paused:
		return
	_pause_toggle_is_paused = true
	play_event(&"ui_pause")
	_pause_stage_music()


func _on_resume_requested() -> void:
	if not _pause_toggle_is_paused:
		return
	_pause_toggle_is_paused = false
	play_event(&"ui_resume")
	_resume_stage_music()


func _on_retry_requested() -> void:
	reset_runtime()
	play_event(&"ui_retry")
	_request_music(BGM_GROUND)


func _on_settings_requested() -> void:
	play_event(&"ui_click")


func _on_main_menu_requested() -> void:
	play_event(&"ui_menu")
	_request_music(BGM_TITLE)


func _on_start_requested() -> void:
	play_event(&"ui_start")
	_request_music(BGM_GROUND)


func _on_black_hole_phase_requested() -> void:
	_stop_music()
	_current_music_key = &""
	play_event(&"black_hole_phase")
	start_loop(&"black_hole_loop")


func _on_black_hole_absorbed(_score_amount: float, _global_level: int, _world_position: Vector2) -> void:
	play_event(&"black_hole_absorb")


func _on_black_hole_finale_started(_contact_snapshot: Dictionary) -> void:
	_gameplay_suppressed = true
	stop_loop()
	play_event(&"black_hole_finale")
	_request_music(BGM_RESULT)


func _request_music(event_key: StringName, playback_position := 0.0) -> void:
	if event_key == _current_music_key and _music_player != null and is_instance_valid(_music_player) and _music_player.playing:
		return
	_stop_music()
	_current_music_key = event_key
	if audio_unlocked:
		_play_current_music(playback_position)


func _play_current_music(playback_position := 0.0) -> void:
	if not audio_unlocked or _current_music_key == &"" or catalog == null:
		return
	var definition: AudioEventDefinition = catalog.get_event(_current_music_key) as AudioEventDefinition
	if definition == null or definition.stream == null:
		return
	_ensure_music_player()
	_music_player.stream = definition.stream
	_music_player.bus = audio_bus
	_music_player.volume_db = _get_music_volume_db()
	_music_player.play(maxf(playback_position, 0.0))


func _stop_music() -> void:
	if _music_player != null and is_instance_valid(_music_player):
		_music_player.stop()


func _pause_stage_music() -> void:
	if not _is_stage_music(_current_music_key):
		return
	_paused_stage_music_key = _current_music_key
	_paused_stage_music_position = _music_player.get_playback_position() if _music_player != null and _music_player.playing else 0.0
	_request_music(BGM_PAUSE)


func _resume_stage_music() -> void:
	if _paused_stage_music_key == &"":
		return
	var resume_key := _paused_stage_music_key
	var resume_position := _paused_stage_music_position
	_paused_stage_music_key = &""
	_paused_stage_music_position = 0.0
	_request_music(resume_key, resume_position)


func _get_stage_music_key(definition: Resource) -> StringName:
	if definition == null:
		return &""
	match StringName(definition.get("background_id")):
		&"ground":
			return BGM_GROUND
		&"planetary":
			return BGM_PLANETARY
		&"galactic":
			return BGM_GALACTIC
	return &""


func _is_stage_music(event_key: StringName) -> bool:
	return event_key == BGM_GROUND or event_key == BGM_PLANETARY or event_key == BGM_GALACTIC


func _play_stage_clear_once() -> void:
	if _stage_clear_played:
		return
	_stage_clear_played = true
	play_event(&"stage_clear")


func _on_player_finished(player: AudioStreamPlayer) -> void:
	if _pending_settlement_finish and StringName(player.get_meta(&"audio_event_key", &"")) == &"settlement_start":
		player.stop()
		_pending_settlement_finish = false
		play_event(&"settlement_finish")
		return
	if not bool(player.get_meta(&"audio_event_loop", false)):
		return
	if player != _black_hole_loop_player or not audio_unlocked:
		return
	player.play()


func _on_music_finished() -> void:
	if not audio_unlocked or _current_music_key == &"":
		return
	var definition: AudioEventDefinition = catalog.get_event(_current_music_key) as AudioEventDefinition
	if definition != null and definition.loop:
		_play_current_music()


func _is_user_activation(event: InputEvent) -> bool:
	return event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch


func _is_group_playing(group: StringName) -> bool:
	return _count_playing_in_group(group) > 0


func _get_event_volume_db(event_key: StringName) -> float:
	var policy := get_event_policy(event_key)
	return float(policy.get("volume_db", 0.0)) + sfx_volume_offset_db + _percent_to_db(_settings_sfx_volume)


func _get_music_volume_db() -> float:
	return music_volume_db + _percent_to_db(_settings_bgm_volume)


func _percent_to_db(volume: int) -> float:
	# Level 5 maps to the authored channel mix (0 dB adjustment).
	return linear_to_db(maxf(float(volume) / 5.0, 0.0001))
