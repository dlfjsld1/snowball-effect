class_name GameManager
extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const PaddleScript = preload("res://scripts/gameplay/paddle.gd")
const StageManagerScript = preload("res://scripts/core/stage_manager.gd")
const HudScript = preload("res://scripts/ui/hud.gd")
const PauseMenuScript = preload("res://scripts/ui/pause_menu.gd")
const GameplayFrameScript = preload("res://scripts/presentation/gameplay_frame.gd")

@export var simulation_path: NodePath
@export var paddle_path: NodePath
@export var stage_manager_path: NodePath
@export var hud_path: NodePath
@export var pause_menu_path: NodePath
@export var gameplay_frame_path: NodePath
@export var play_field_backdrop_path: NodePath
@export var background_manager_path: NodePath
@export var presentation_manager_path: NodePath
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
var _gameplay_frame: GameplayFrameScript
var _play_field_backdrop: Polygon2D
var _background_manager: BackgroundManager
var _presentation_manager: PresentationManager
var _spawn_accumulator := 0.0
var _random := RandomNumberGenerator.new()
var _initialized := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_simulation = get_node(simulation_path) as SimulationManager
	_paddle = get_node(paddle_path) as PaddleScript
	_stage_manager = get_node(stage_manager_path) as StageManagerScript
	_hud = get_node(hud_path) as HudScript
	_pause_menu = get_node(pause_menu_path) as PauseMenuScript
	_gameplay_frame = get_node(gameplay_frame_path) as GameplayFrameScript
	_play_field_backdrop = get_node(play_field_backdrop_path) as Polygon2D
	_background_manager = get_node(background_manager_path) as BackgroundManager
	_presentation_manager = get_node(presentation_manager_path) as PresentationManager
	call_deferred("_initialize_runtime")


func _initialize_runtime() -> void:
	_simulation.stage_base_ball_radius = lv1_ball_radius
	_simulation.set_paddle_collision_provider(_paddle)
	_stage_manager.stage_changed.connect(_on_stage_changed)
	_stage_manager.stage_shift_started.connect(_presentation_manager.play_stage_shift)
	_presentation_manager.stage_shift_presentation_finished.connect(_on_stage_shift_presentation_finished)
	_presentation_manager.configure(_background_manager, _hud, _pause_menu)
	_hud.bind_sources(_stage_manager.get_score_ledger(), _simulation, _stage_manager)
	_pause_menu.pause_requested.connect(_on_pause_requested)
	_pause_menu.retry_requested.connect(_on_retry_requested)
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
	}


func _start_run() -> void:
	get_tree().paused = false
	_random.seed = 1337
	_spawn_accumulator = 0.0
	_stage_manager.start_run()
	_paddle.reset_runtime()
	_hud.reset_view()
	_pause_menu.set_paused(false)
	_spawn_ball()


func _on_stage_changed(definition: StageDefinition) -> void:
	spawn_rate = definition.spawn_rate
	_apply_stage_frame(definition.stage_index)
	_presentation_manager.apply_stage(definition)


func _on_stage_shift_presentation_finished(shift_id: int) -> void:
	_stage_manager.accept_stage_shift_presentation_finished(shift_id)


func _apply_stage_frame(stage_index: int) -> void:
	var profile_index := clampi(stage_index, 0, 2)
	_gameplay_frame.set_profile(profile_index)
	var field_rect := _gameplay_frame.get_field_rect()
	var visual_field_rect := _gameplay_frame.get_field_visual_rect()
	_simulation.play_field_rect = field_rect
	_paddle.play_field_rect = field_rect
	_paddle.position.x = clampf(_paddle.position.x, field_rect.position.x, field_rect.end.x)
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


func _on_retry_requested() -> void:
	retry_count += 1
	_start_run()
