class_name GameManager
extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const PaddleScript = preload("res://scripts/gameplay/paddle.gd")
const Ledger = preload("res://scripts/core/score_ledger.gd")
const HudScript = preload("res://scripts/ui/hud.gd")
const PauseMenuScript = preload("res://scripts/ui/pause_menu.gd")

@export var simulation_path: NodePath
@export var paddle_path: NodePath
@export var score_ledger_path: NodePath
@export var hud_path: NodePath
@export var pause_menu_path: NodePath
@export var spawn_rate := 6.0
@export var lv1_ball_radius := 4.0
@export var lv1_spawn_speed_world_units_per_second := 160.0
@export_range(0.0, 89.0, 0.1) var lv1_spawn_angle_degrees := 20.0

var retry_count := 0

var _simulation: SimulationManager
var _paddle: PaddleScript
var _score_ledger: Ledger
var _hud: HudScript
var _pause_menu: PauseMenuScript
var _spawn_accumulator := 0.0
var _random := RandomNumberGenerator.new()
var _initialized := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_simulation = get_node(simulation_path) as SimulationManager
	_paddle = get_node(paddle_path) as PaddleScript
	_score_ledger = get_node(score_ledger_path) as Ledger
	_hud = get_node(hud_path) as HudScript
	_pause_menu = get_node(pause_menu_path) as PauseMenuScript
	call_deferred("_initialize_runtime")


func _initialize_runtime() -> void:
	_simulation.set_paddle_collision_provider(_paddle)
	_simulation.cashout_completed.connect(_score_ledger.apply_score_event)
	_hud.bind_sources(_score_ledger, _simulation)
	_pause_menu.pause_requested.connect(_on_pause_requested)
	_pause_menu.retry_requested.connect(_on_retry_requested)
	_start_run()
	_initialized = true


func _physics_process(delta: float) -> void:
	if not _initialized or get_tree().paused or spawn_rate <= 0.0:
		return

	_spawn_accumulator += delta * spawn_rate
	while _spawn_accumulator >= 1.0:
		_spawn_accumulator -= 1.0
		_spawn_ball()


func get_runtime_snapshot() -> Dictionary:
	return {
		"active_count": _simulation.get_active_count(),
		"capacity": _simulation.get_capacity(),
		"stage_score": _score_ledger.stage_score,
		"run_score": _score_ledger.run_score,
		"paused": get_tree().paused,
		"retry_count": retry_count,
		"paddle_position": _paddle.position,
		"paddle_rotation": _paddle.rotation,
	}


func _start_run() -> void:
	get_tree().paused = false
	_random.seed = 1337
	_spawn_accumulator = 0.0
	_simulation.reset_runtime()
	_score_ledger.reset_runtime()
	_paddle.reset_runtime()
	_hud.reset_view()
	_pause_menu.set_paused(false)
	_spawn_ball()


func _spawn_ball() -> void:
	var field := _simulation.play_field_rect
	var spawn_position := Vector2(
		_random.randf_range(field.position.x + lv1_ball_radius, field.end.x - lv1_ball_radius),
		field.position.y + lv1_ball_radius + 12.0
	)
	var spawn_angle := deg_to_rad(_random.randf_range(-lv1_spawn_angle_degrees, lv1_spawn_angle_degrees))
	var spawn_direction := Vector2(sin(spawn_angle), cos(spawn_angle))
	var spawn_velocity := spawn_direction * lv1_spawn_speed_world_units_per_second
	_simulation.spawn_ball(spawn_position, spawn_velocity, lv1_ball_radius)


func _on_pause_requested() -> void:
	get_tree().paused = not get_tree().paused
	_pause_menu.set_paused(get_tree().paused)


func _on_retry_requested() -> void:
	retry_count += 1
	_start_run()
