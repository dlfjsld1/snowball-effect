class_name GameManager
extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const PaddleScript = preload("res://scripts/gameplay/paddle.gd")
const StageManagerScript = preload("res://scripts/core/stage_manager.gd")
const HudScript = preload("res://scripts/ui/hud.gd")
const PauseMenuScript = preload("res://scripts/ui/pause_menu.gd")
const TitleScreenScript = preload("res://scripts/ui/title_screen.gd")
const ResultPanelScript = preload("res://scripts/ui/result_panel.gd")
const GameplayFrameScript = preload("res://scripts/presentation/gameplay_frame.gd")
const AudioManagerScript = preload("res://scripts/presentation/audio_manager.gd")

signal black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2)
signal terminal_result_available(result_snapshot: Dictionary)

@export var simulation_path: NodePath
@export var paddle_path: NodePath
@export var stage_manager_path: NodePath
@export var hud_path: NodePath
@export var pause_menu_path: NodePath
@export var title_screen_path: NodePath
@export var result_panel_path: NodePath
@export var gameplay_frame_path: NodePath
@export var play_field_backdrop_path: NodePath
@export var background_manager_path: NodePath
@export var presentation_manager_path: NodePath
@export var audio_manager_path: NodePath
@export var spawn_rate := 6.0
@export var lv1_ball_radius := 4.0
@export var lv1_spawn_speed_world_units_per_second := 160.0
@export_range(0.0, 89.0, 0.1) var lv1_spawn_angle_degrees := 20.0
@export var auto_complete_black_hole_phase_presentation := true

var retry_count := 0

var _simulation: SimulationManager
var _paddle: PaddleScript
var _stage_manager: StageManagerScript
var _hud: HudScript
var _pause_menu: PauseMenuScript
var _title_screen: TitleScreenScript
var _result_panel: ResultPanelScript
var _gameplay_frame: GameplayFrameScript
var _play_field_backdrop: Polygon2D
var _background_manager: BackgroundManager
var _presentation_manager: PresentationManager
var _audio_manager: AudioManagerScript
var _spawn_accumulator := 0.0
var _random := RandomNumberGenerator.new()
var _initialized := false
var _terminal_result_snapshot: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_simulation = get_node(simulation_path) as SimulationManager
	_paddle = get_node(paddle_path) as PaddleScript
	_stage_manager = get_node(stage_manager_path) as StageManagerScript
	_hud = get_node(hud_path) as HudScript
	_pause_menu = get_node(pause_menu_path) as PauseMenuScript
	_title_screen = get_node(title_screen_path) as TitleScreenScript
	_result_panel = get_node(result_panel_path) as ResultPanelScript
	_gameplay_frame = get_node(gameplay_frame_path) as GameplayFrameScript
	_play_field_backdrop = get_node(play_field_backdrop_path) as Polygon2D
	_background_manager = get_node(background_manager_path) as BackgroundManager
	_presentation_manager = get_node(presentation_manager_path) as PresentationManager
	_audio_manager = get_node(audio_manager_path) as AudioManagerScript
	call_deferred("_initialize_runtime")


func _initialize_runtime() -> void:
	_simulation.stage_base_ball_radius = lv1_ball_radius
	_simulation.set_paddle_collision_provider(_paddle)
	_stage_manager.stage_changed.connect(_on_stage_changed)
	_stage_manager.stage_shift_started.connect(_presentation_manager.play_stage_shift)
	_stage_manager.final_settlement_started.connect(_on_final_settlement_started)
	_stage_manager.final_settlement_finished.connect(_on_final_settlement_finished)
	_stage_manager.black_hole_phase_started.connect(_on_black_hole_phase_started)
	_stage_manager.black_hole_phase_gameplay_resumed.connect(_on_black_hole_phase_gameplay_resumed)
	_stage_manager.black_hole_finale_locked.connect(_on_black_hole_finale_locked)
	_presentation_manager.stage_shift_presentation_finished.connect(_on_stage_shift_presentation_finished)
	_simulation.black_hole_phase_requested.connect(_on_black_hole_phase_requested)
	_presentation_manager.configure(_background_manager, _hud, _pause_menu)
	_audio_manager.configure_sources(_simulation, _stage_manager, _pause_menu, _title_screen)
	_hud.bind_sources(_stage_manager.get_score_ledger(), _simulation, _stage_manager)
	_pause_menu.pause_requested.connect(_on_pause_requested)
	_pause_menu.retry_requested.connect(_on_retry_requested)
	_pause_menu.resume_requested.connect(_on_resume_requested)
	_pause_menu.main_menu_requested.connect(_on_main_menu_requested)
	_title_screen.start_requested.connect(_on_start_requested)
	_result_panel.main_menu_requested.connect(_on_main_menu_requested)
	_start_run()
	_initialized = true


func _physics_process(delta: float) -> void:
	if not _initialized or get_tree().paused or not _stage_manager.is_playing() or spawn_rate <= 0.0:
		return

	_spawn_accumulator += delta * spawn_rate
	while _spawn_accumulator >= 1.0:
		_spawn_accumulator -= 1.0
		_spawn_ball()


func _unhandled_key_input(event: InputEvent) -> void:
	if not OS.is_debug_build() or not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or get_tree().paused:
		return
	match key_event.physical_keycode:
		KEY_F6:
			_stage_manager.debug_force_top_ball_clear()
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
	}


func get_terminal_result_snapshot() -> Dictionary:
	return _terminal_result_snapshot.duplicate(true)


func _start_run() -> void:
	get_tree().paused = false
	_random.seed = 1337
	_spawn_accumulator = 0.0
	_terminal_result_snapshot.clear()
	_stage_manager.start_run()
	_paddle.reset_runtime()
	_paddle.set_physics_process(true)
	_title_screen.hide_title()
	_result_panel.hide_result()
	_hud.visible = true
	_pause_menu.visible = true
	_hud.reset_view()
	_pause_menu.set_paused(false)
	_spawn_ball()


func _on_stage_changed(definition: StageDefinition) -> void:
	spawn_rate = definition.spawn_rate
	_apply_stage_frame(definition.stage_index)
	_presentation_manager.apply_stage(definition)


func _on_stage_shift_presentation_finished(shift_id: int) -> void:
	_stage_manager.accept_stage_shift_presentation_finished(shift_id)


func accept_black_hole_phase_presentation_finished(phase_id: int) -> bool:
	return _stage_manager.accept_black_hole_phase_presentation_finished(phase_id)


func _on_final_settlement_started(_amount: float) -> void:
	_audio_manager.play_event(&"settlement_start")


func _on_final_settlement_finished(_amount: float) -> void:
	_audio_manager.play_event(&"settlement_finish")


func _on_black_hole_phase_requested() -> void:
	if not _initialized or _stage_manager.current_state != StageManager.PLAYING:
		return
	var from_rect := _simulation.play_field_rect
	var to_rect := _gameplay_frame.get_field_rect_for_profile(3)
	_stage_manager.begin_black_hole_phase(from_rect, to_rect)


func _on_black_hole_phase_started(phase_id: int, from_rect: Rect2, to_rect: Rect2) -> void:
	_paddle.set_physics_process(false)
	black_hole_phase_started.emit(phase_id, from_rect, to_rect)
	if auto_complete_black_hole_phase_presentation:
		call_deferred("_complete_temporary_black_hole_phase", phase_id)


func _complete_temporary_black_hole_phase(phase_id: int) -> void:
	accept_black_hole_phase_presentation_finished(phase_id)


func _on_black_hole_phase_gameplay_resumed(_phase_id: int, logical_rect: Rect2) -> void:
	_gameplay_frame.set_profile(3)
	_apply_play_field_layout(logical_rect)
	_paddle.set_physics_process(true)


func _on_black_hole_finale_locked(result_snapshot: Dictionary) -> void:
	_terminal_result_snapshot = result_snapshot.duplicate(true)
	_paddle.set_physics_process(false)
	_hud.visible = false
	_pause_menu.visible = false
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
	_play_field_backdrop.polygon = PackedVector2Array([
		visual_field_rect.position,
		Vector2(visual_field_rect.end.x, visual_field_rect.position.y),
		visual_field_rect.end,
		Vector2(visual_field_rect.position.x, visual_field_rect.end.y),
	])
	_hud.apply_frame_layout(_gameplay_frame.get_left_wing_rect(), _gameplay_frame.get_right_wing_rect())
	_pause_menu.apply_frame_layout(_gameplay_frame.get_right_bottom_panel_rect())


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
	get_tree().paused = false
	_terminal_result_snapshot.clear()
	_stage_manager.end_run_to_main_menu()
	_paddle.set_physics_process(false)
	_hud.reset_view()
	_hud.visible = false
	_pause_menu.visible = false
	_pause_menu.set_paused(false)
	_result_panel.hide_result()
	_title_screen.show_title()
