class_name GameManager
extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const PaddleScript = preload("res://scripts/gameplay/paddle.gd")
const StageManagerScript = preload("res://scripts/core/stage_manager.gd")
const HudScript = preload("res://scripts/ui/hud.gd")
const PauseMenuScript = preload("res://scripts/ui/pause_menu.gd")
const TitleScreenScript = preload("res://scripts/ui/title_screen.gd")
const ResultPanelScript = preload("res://scripts/ui/result_panel.gd")
const StageClearPanelScript = preload("res://scripts/ui/stage_clear_panel.gd")
const GameplayFrameScript = preload("res://scripts/presentation/gameplay_frame.gd")
const AudioManagerScript = preload("res://scripts/presentation/audio_manager.gd")

signal black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2)
signal terminal_result_available(result_snapshot: Dictionary)
signal item_cutin_requested(event_id: int, item_type: StringName, world_position: Vector2)
signal item_effect_activation_requested(event_id: int, item_type: StringName, world_position: Vector2)
signal first_contact_cutin_requested(payload: Dictionary)

@export var simulation_path: NodePath
@export var paddle_path: NodePath
@export var stage_manager_path: NodePath
@export var hud_path: NodePath
@export var pause_menu_path: NodePath
@export var title_screen_path: NodePath
@export var result_panel_path: NodePath
@export var stage_clear_panel_path: NodePath
@export var gameplay_frame_path: NodePath
@export var play_field_backdrop_path: NodePath
@export var background_manager_path: NodePath
@export var presentation_manager_path: NodePath
@export var audio_manager_path: NodePath
@export var item_manager_path: NodePath
@export var item_effect_gateway_path: NodePath
@export var spawn_rate := 6.0
@export var lv1_ball_radius := 4.0
@export var lv1_spawn_speed_world_units_per_second := 160.0
@export_range(0.0, 89.0, 0.1) var lv1_spawn_angle_degrees := 20.0

var retry_count := 0

var _simulation: SimulationManager
var _paddle: PaddleScript
var _stage_manager: StageManagerScript
var _hud: HudScript
var _pause_menu: PauseMenuScript
var _title_screen: TitleScreenScript
var _result_panel: ResultPanelScript
var _stage_clear_panel: StageClearPanelScript
var _gameplay_frame: GameplayFrameScript
var _play_field_backdrop: Polygon2D
var _background_manager: BackgroundManager
var _presentation_manager: PresentationManager
var _audio_manager: AudioManagerScript
var _item_manager: Node
var _item_effect_gateway: Node
var _spawn_accumulator := 0.0
var _random := RandomNumberGenerator.new()
var _initialized := false
var _terminal_result_snapshot: Dictionary = {}
var _terminal_result_published := false
var _next_first_contact_run_epoch := 1
var _first_contact_run_epoch := -1
var _first_contact_queue: Array[Dictionary] = []
var _active_first_contact_payload: Dictionary = {}
var _first_contact_pause_locked := false
var _first_contact_arbitration_queued := false
var _black_hole_phase_ready := false
var _first_contact_cutin_consumer: Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_simulation = get_node(simulation_path) as SimulationManager
	_paddle = get_node(paddle_path) as PaddleScript
	_stage_manager = get_node(stage_manager_path) as StageManagerScript
	_hud = get_node(hud_path) as HudScript
	_pause_menu = get_node(pause_menu_path) as PauseMenuScript
	_title_screen = get_node(title_screen_path) as TitleScreenScript
	_result_panel = get_node(result_panel_path) as ResultPanelScript
	_stage_clear_panel = get_node(stage_clear_panel_path) as StageClearPanelScript
	_gameplay_frame = get_node(gameplay_frame_path) as GameplayFrameScript
	_play_field_backdrop = get_node(play_field_backdrop_path) as Polygon2D
	_background_manager = get_node(background_manager_path) as BackgroundManager
	_presentation_manager = get_node(presentation_manager_path) as PresentationManager
	_audio_manager = get_node(audio_manager_path) as AudioManagerScript
	_item_manager = get_node(item_manager_path)
	_item_effect_gateway = get_node(item_effect_gateway_path)
	call_deferred("_initialize_runtime")


func _initialize_runtime() -> void:
	_simulation.stage_base_ball_radius = lv1_ball_radius
	_simulation.set_paddle_collision_provider(_paddle)
	_stage_manager.stage_changed.connect(_on_stage_changed)
	_stage_manager.stage_shift_started.connect(_presentation_manager.play_stage_shift)
	_stage_manager.stage_clear_ready.connect(_on_stage_clear_ready)
	_stage_manager.stage_run_ended.connect(_on_stage_run_ended)
	_stage_manager.final_settlement_started.connect(_on_final_settlement_started)
	_stage_manager.final_settlement_finished.connect(_on_final_settlement_finished)
	_stage_manager.black_hole_phase_started.connect(_on_black_hole_phase_started)
	_stage_manager.black_hole_phase_gameplay_resumed.connect(_on_black_hole_phase_gameplay_resumed)
	_stage_manager.black_hole_finale_locked.connect(_on_black_hole_finale_locked)
	_presentation_manager.stage_shift_presentation_finished.connect(_on_stage_shift_presentation_finished)
	_presentation_manager.visual_field_rect_changed.connect(_on_visual_field_rect_changed)
	_presentation_manager.black_hole_phase_presentation_finished.connect(_on_black_hole_phase_presentation_finished)
	_presentation_manager.black_hole_finale_presentation_finished.connect(_on_black_hole_finale_presentation_finished)
	if _presentation_manager.has_signal(&"first_contact_cutin_finished"):
		_presentation_manager.connect(&"first_contact_cutin_finished", _on_first_contact_cutin_finished)
	_simulation.first_contact_discovered.connect(_on_first_contact_discovered)
	_simulation.black_hole_phase_requested.connect(_on_black_hole_phase_requested)
	_item_manager.item_collected.connect(_on_item_collected)
	_item_effect_gateway.item_cutin_requested.connect(_on_item_cutin_requested)
	_item_effect_gateway.item_effect_activation_requested.connect(_on_item_effect_activation_requested)
	_presentation_manager.configure(_background_manager, _hud, _pause_menu)
	_audio_manager.configure_sources(_simulation, _stage_manager, _pause_menu, _title_screen)
	_hud.bind_sources(_stage_manager.get_score_ledger(), _simulation, _stage_manager)
	_pause_menu.pause_requested.connect(_on_pause_requested)
	_pause_menu.retry_requested.connect(_on_retry_requested)
	_pause_menu.resume_requested.connect(_on_resume_requested)
	_pause_menu.main_menu_requested.connect(_on_main_menu_requested)
	_title_screen.start_requested.connect(_on_start_requested)
	_result_panel.retry_requested.connect(_on_retry_requested)
	_result_panel.main_menu_requested.connect(_on_main_menu_requested)
	_stage_clear_panel.next_stage_requested.connect(_on_next_stage_requested)
	_enter_title_screen()
	_initialized = true


func _physics_process(delta: float) -> void:
	if not _initialized or get_tree().paused or _first_contact_pause_locked or not _stage_manager.is_playing() or spawn_rate <= 0.0:
		return

	_spawn_accumulator += delta * spawn_rate
	while _spawn_accumulator >= 1.0:
		_spawn_accumulator -= 1.0
		_spawn_ball()
	_process_item_runtime(delta)


func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or get_tree().paused or _first_contact_pause_locked:
		return
	match key_event.physical_keycode:
		KEY_F7:
			_stage_manager.debug_force_score_clear()


func get_runtime_snapshot() -> Dictionary:
	return {
		"active_count": _simulation.get_active_count(),
		"capacity": _simulation.get_capacity(),
		"stage_score": _stage_manager.get_score_ledger().stage_score,
		"run_score": _stage_manager.get_score_ledger().run_score,
		"stage_state": _stage_manager.current_state,
		"stage_time_left": _stage_manager.get_runtime_snapshot()["stage_time_left"],
		"paused": get_tree().paused,
		"retry_count": retry_count,
		"paddle_position": _paddle.position,
		"paddle_rotation": _paddle.rotation,
		"terminal_result": get_terminal_result_snapshot(),
		"first_contact_run_epoch": _first_contact_run_epoch,
		"first_contact_queue_size": _first_contact_queue.size(),
		"first_contact_active_event_id": int(_active_first_contact_payload.get("event_id", -1)),
		"first_contact_pause_locked": _first_contact_pause_locked,
	}


func get_terminal_result_snapshot() -> Dictionary:
	return _terminal_result_snapshot.duplicate(true)


func accept_item_cutin_activation_cue(event_id: int) -> bool:
	return _item_effect_gateway.accept_cutin_activation_cue(event_id)


func skip_item_cutin(event_id: int) -> bool:
	return _item_effect_gateway.skip_cutin(event_id)


func set_first_contact_cutin_consumer_for_verification(consumer: Node) -> void:
	_first_contact_cutin_consumer = consumer
	_schedule_first_contact_arbitration()


func accept_first_contact_discovery(payload: Dictionary) -> bool:
	if not _is_current_first_contact_payload(payload):
		return false
	var event_id := int(payload["event_id"])
	if not _active_first_contact_payload.is_empty() and int(_active_first_contact_payload["event_id"]) == event_id:
		return false
	for queued_payload in _first_contact_queue:
		if int(queued_payload["event_id"]) == event_id:
			return false
	if _first_contact_queue.size() >= 6:
		return false
	_first_contact_queue.append(payload.duplicate(true))
	_schedule_first_contact_arbitration()
	return true


func accept_first_contact_cutin_finished(event_id: int, run_epoch: int) -> bool:
	if not _first_contact_pause_locked or _active_first_contact_payload.is_empty():
		return false
	if run_epoch != _first_contact_run_epoch or event_id != int(_active_first_contact_payload["event_id"]):
		return false
	var completed_payload := _active_first_contact_payload
	_active_first_contact_payload = {}
	if not _first_contact_queue.is_empty() and int(_first_contact_queue[0]["event_id"]) == event_id:
		_first_contact_queue.pop_front()
	if completed_payload["handoff_kind"] == &"BLACK_HOLE_PHASE":
		if not _black_hole_phase_ready or _stage_manager.current_state != StageManager.PLAYING:
			_active_first_contact_payload = completed_payload
			_first_contact_queue.push_front(completed_payload)
			return false
		var from_rect := _simulation.play_field_rect
		var to_rect := _gameplay_frame.get_field_rect_for_profile(3)
		_stage_manager.set_first_contact_pause_locked(false)
		if not _stage_manager.begin_black_hole_phase(from_rect, to_rect):
			_stage_manager.set_first_contact_pause_locked(true)
			_active_first_contact_payload = completed_payload
			_first_contact_queue.push_front(completed_payload)
			return false
		_first_contact_pause_locked = false
		_black_hole_phase_ready = false
		return true
	if _first_contact_queue.is_empty():
		_release_first_contact_pause()
	else:
		_schedule_first_contact_arbitration()
	return true


func _start_run() -> void:
	get_tree().paused = false
	_random.seed = 1337
	_spawn_accumulator = 0.0
	_terminal_result_snapshot.clear()
	_terminal_result_published = false
	_reset_first_contact_runtime(true)
	_first_contact_run_epoch = _next_first_contact_run_epoch
	_next_first_contact_run_epoch += 1
	_simulation.begin_first_contact_run(_first_contact_run_epoch)
	_item_effect_gateway.reset_runtime()
	_presentation_manager.reset_black_hole_presentation()
	_stage_manager.start_run()
	_paddle.reset_runtime()
	_paddle.set_physics_process(true)
	_title_screen.hide_title()
	_result_panel.hide_result()
	_stage_clear_panel.reset_for_new_run()
	_hud.visible = true
	_pause_menu.visible = true
	_hud.reset_view()
	_pause_menu.set_paused(false)
	_spawn_ball()


func _enter_title_screen() -> void:
	get_tree().paused = false
	_terminal_result_snapshot.clear()
	_terminal_result_published = false
	_reset_first_contact_runtime(true)
	_item_manager.reset_runtime()
	_item_effect_gateway.reset_runtime()
	_presentation_manager.reset_black_hole_presentation()
	_stage_manager.end_run_to_main_menu()
	_paddle.set_physics_process(false)
	_hud.reset_view()
	_hud.visible = false
	_pause_menu.visible = false
	_pause_menu.set_paused(false)
	_result_panel.hide_result()
	_stage_clear_panel.reset_for_new_run()
	_title_screen.show_title()


func _on_stage_changed(definition: StageDefinition) -> void:
	spawn_rate = definition.spawn_rate
	_apply_stage_frame(definition.stage_index)
	_presentation_manager.apply_stage(definition)
	_item_manager.enter_stage(
		definition,
		_simulation.play_field_rect,
		_simulation.get_runtime_radius_for_level(definition.local_ball_levels[2])
	)
	_paddle.set_physics_process(true)
	_pause_menu.visible = true


func _on_stage_shift_presentation_finished(shift_id: int) -> void:
	_stage_manager.accept_stage_shift_presentation_finished(shift_id)


func _on_stage_clear_ready(clear_snapshot: Dictionary, clear_id: int) -> void:
	_reset_first_contact_runtime(false)
	_paddle.set_physics_process(false)
	_pause_menu.visible = false
	_stage_clear_panel.show_stage_clear(clear_snapshot, clear_id)


func _on_next_stage_requested(clear_id: int) -> void:
	if _stage_manager.request_next_stage(clear_id):
		_stage_clear_panel.hide_stage_clear(clear_id)


func _on_stage_run_ended(result_snapshot: Dictionary) -> void:
	_reset_first_contact_runtime(true)
	_paddle.set_physics_process(false)
	_hud.visible = false
	_pause_menu.visible = false
	_stage_clear_panel.reset_for_new_run()
	_result_panel.show_result(result_snapshot)


func _on_visual_field_rect_changed(visual_field_rect: Rect2) -> void:
	_apply_backdrop_visual_rect(visual_field_rect)


func accept_black_hole_phase_presentation_finished(phase_id: int) -> bool:
	return _stage_manager.accept_black_hole_phase_presentation_finished(phase_id)


func _on_final_settlement_started(_amount: float) -> void:
	_audio_manager.play_event(&"settlement_start")


func _on_final_settlement_finished(_amount: float) -> void:
	_audio_manager.play_event(&"settlement_finish")


func _on_black_hole_phase_requested() -> void:
	if not _initialized or _first_contact_run_epoch < 0 or _stage_manager.current_state != StageManager.PLAYING:
		return
	_black_hole_phase_ready = true
	_schedule_first_contact_arbitration()


func _on_black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2) -> void:
	_paddle.set_physics_process(false)
	black_hole_phase_started.emit(phase_id, from_rect, to_rect)
	_presentation_manager.play_black_hole_phase(phase_id, from_rect, to_rect)


func _on_black_hole_phase_presentation_finished(phase_id: int) -> void:
	accept_black_hole_phase_presentation_finished(phase_id)


func _on_black_hole_phase_gameplay_resumed(_phase_id: int, logical_rect: Rect2) -> void:
	_gameplay_frame.set_profile(3)
	_apply_play_field_layout(logical_rect)
	_paddle.set_physics_process(true)
	_paddle.set_process_unhandled_input(true)


func _on_black_hole_finale_locked(result_snapshot: Dictionary) -> void:
	if not _terminal_result_snapshot.is_empty():
		return
	_terminal_result_snapshot = result_snapshot.duplicate(true)
	_paddle.set_physics_process(false)
	_presentation_manager.play_black_hole_finale(get_terminal_result_snapshot())


func _on_black_hole_finale_presentation_finished() -> void:
	if _terminal_result_snapshot.is_empty() or _terminal_result_published:
		return
	_terminal_result_published = true
	_result_panel.show_result(get_terminal_result_snapshot())
	terminal_result_available.emit(get_terminal_result_snapshot())


func _apply_stage_frame(stage_index: int) -> void:
	var profile_index := clampi(stage_index, 0, 2)
	_gameplay_frame.set_profile(profile_index)
	_apply_play_field_layout(_gameplay_frame.get_field_rect())


func _apply_play_field_layout(field_rect: Rect2) -> void:
	var visual_field_rect := _gameplay_frame.get_field_visual_rect()
	_simulation.play_field_rect = field_rect
	_paddle.play_field_rect = field_rect
	_paddle.clamp_to_play_field()
	_apply_backdrop_visual_rect(visual_field_rect)
	_hud.apply_frame_layout(_gameplay_frame.get_left_wing_rect(), _gameplay_frame.get_right_wing_rect())
	_pause_menu.apply_frame_layout(_gameplay_frame.get_right_bottom_panel_rect())


func _apply_backdrop_visual_rect(visual_field_rect: Rect2) -> void:
	_play_field_backdrop.polygon = PackedVector2Array([
		visual_field_rect.position,
		Vector2(visual_field_rect.end.x, visual_field_rect.position.y),
		visual_field_rect.end,
		Vector2(visual_field_rect.position.x, visual_field_rect.end.y),
	])


func _spawn_ball() -> void:
	var current_stage := _stage_manager.get_current_stage()
	var spawn_global_level: int = current_stage.base_global_level if current_stage != null else 0
	var spawn_radius := _simulation.get_runtime_radius_for_level(spawn_global_level)
	var field := _simulation.play_field_rect
	var spawn_position := Vector2(
		_random.randf_range(field.position.x + spawn_radius, field.end.x - spawn_radius),
		field.position.y + spawn_radius + 12.0
	)
	var spawn_angle := deg_to_rad(_random.randf_range(-lv1_spawn_angle_degrees, lv1_spawn_angle_degrees))
	var spawn_direction := Vector2(sin(spawn_angle), cos(spawn_angle))
	var spawn_velocity := spawn_direction * lv1_spawn_speed_world_units_per_second
	_simulation.spawn_ball(spawn_position, spawn_velocity, spawn_radius, spawn_global_level)


func _process_item_runtime(delta: float) -> void:
	_item_manager.advance(delta)
	if not _item_manager.get_item_ball_snapshot().is_empty():
		_item_manager.process_ball_snapshots(_simulation.get_active_item_collision_snapshots())
	_try_collect_item_orb()


func _try_collect_item_orb() -> void:
	var orb: Dictionary = _item_manager.get_item_orb_snapshot()
	if orb.is_empty():
		return
	var orb_position: Vector2 = orb["position"]
	var orb_radius: float = orb["radius"]
	var local_position := _paddle.to_local(orb_position)
	var closest := Vector2(
		clampf(local_position.x, -_paddle.paddle_width * 0.5, _paddle.paddle_width * 0.5),
		clampf(local_position.y, -_paddle.paddle_thickness * 0.5, _paddle.paddle_thickness * 0.5)
	)
	if local_position.distance_squared_to(closest) <= orb_radius * orb_radius:
		_item_manager.try_collect_orb(orb_position, 0.0)


func _on_item_collected(item_type: StringName, world_position: Vector2) -> void:
	_item_effect_gateway.queue_item_collected(item_type, world_position)


func _on_item_cutin_requested(event_id: int, item_type: StringName, world_position: Vector2) -> void:
	item_cutin_requested.emit(event_id, item_type, world_position)


func _on_item_effect_activation_requested(event_id: int, item_type: StringName, world_position: Vector2) -> void:
	item_effect_activation_requested.emit(event_id, item_type, world_position)


func _on_pause_requested() -> void:
	get_tree().paused = not get_tree().paused
	_pause_menu.set_paused(get_tree().paused)


func _on_resume_requested() -> void:
	if get_tree().paused:
		get_tree().paused = false
	_pause_menu.set_paused(false)


func _on_retry_requested() -> void:
	retry_count += 1
	_start_run()


func _on_start_requested() -> void:
	_start_run()


func _on_main_menu_requested() -> void:
	_enter_title_screen()


func _on_first_contact_discovered(payload: Dictionary) -> void:
	accept_first_contact_discovery(payload)


func _on_first_contact_cutin_finished(event_id: int, run_epoch: int) -> void:
	accept_first_contact_cutin_finished(event_id, run_epoch)


func _schedule_first_contact_arbitration() -> void:
	if _first_contact_arbitration_queued:
		return
	_first_contact_arbitration_queued = true
	call_deferred("_process_first_contact_arbitration")


func _process_first_contact_arbitration() -> void:
	_first_contact_arbitration_queued = false
	if not _active_first_contact_payload.is_empty() or _first_contact_queue.is_empty():
		return
	if _stage_manager.current_state != StageManager.PLAYING:
		_first_contact_queue.clear()
		return
	var consumer := _first_contact_cutin_consumer if _first_contact_cutin_consumer != null else _presentation_manager
	if consumer == null or not consumer.has_method(&"play_first_contact_cutin"):
		return
	if not _first_contact_pause_locked:
		if not _stage_manager.set_first_contact_pause_locked(true):
			return
		_first_contact_pause_locked = true
		_paddle.set_physics_process(false)
		_paddle.set_process_unhandled_input(false)
	_active_first_contact_payload = _first_contact_queue[0].duplicate(true)
	first_contact_cutin_requested.emit(_active_first_contact_payload.duplicate(true))
	if not bool(consumer.call(&"play_first_contact_cutin", _active_first_contact_payload.duplicate(true))):
		_active_first_contact_payload = {}
		_release_first_contact_pause()


func _release_first_contact_pause() -> void:
	_stage_manager.set_first_contact_pause_locked(false)
	_first_contact_pause_locked = false
	if _stage_manager.current_state == StageManager.PLAYING:
		_paddle.set_physics_process(true)
		_paddle.set_process_unhandled_input(true)


func _reset_first_contact_runtime(invalidate_core: bool) -> void:
	if invalidate_core and _first_contact_run_epoch >= 0:
		_simulation.invalidate_first_contact_run(_first_contact_run_epoch)
	_first_contact_queue.clear()
	_active_first_contact_payload.clear()
	_black_hole_phase_ready = false
	_first_contact_arbitration_queued = false
	_release_first_contact_pause()
	if _presentation_manager != null and _presentation_manager.has_method(&"reset_first_contact_cutin"):
		_presentation_manager.call(&"reset_first_contact_cutin", _first_contact_run_epoch)
	if _first_contact_cutin_consumer != null and _first_contact_cutin_consumer != _presentation_manager and _first_contact_cutin_consumer.has_method(&"reset_first_contact_cutin"):
		_first_contact_cutin_consumer.call(&"reset_first_contact_cutin", _first_contact_run_epoch)
	if invalidate_core:
		_first_contact_run_epoch = -1


func _is_current_first_contact_payload(payload: Dictionary) -> bool:
	if _first_contact_run_epoch < 0 or _stage_manager.current_state != StageManager.PLAYING:
		return false
	if not _simulation.is_valid_first_contact_payload(payload):
		return false
	if int(payload["run_epoch"]) != _first_contact_run_epoch or int(payload["stage_index"]) != _stage_manager.current_stage_index:
		return false
	return _stage_manager.get_current_stage() != null
