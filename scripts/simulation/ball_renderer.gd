class_name BallRenderer
extends Node2D

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")

@export var simulation_path: NodePath
@export var ball_color := Color(0.86, 0.92, 1.0, 1.0)

var _simulation: SimulationManager


func _ready() -> void:
	if not simulation_path.is_empty():
		set_simulation_manager(get_node_or_null(simulation_path) as SimulationManager)


func _process(_delta: float) -> void:
	if is_instance_valid(_simulation):
		queue_redraw()


func _draw() -> void:
	if not is_instance_valid(_simulation):
		return

	var snapshot: Dictionary = _simulation.get_render_snapshot()
	var snapshot_positions: PackedVector2Array = snapshot["positions"]
	var snapshot_radii: PackedFloat32Array = snapshot["radii"]
	var snapshot_count: int = snapshot["count"]
	for index in range(snapshot_count):
		draw_circle(snapshot_positions[index], snapshot_radii[index], ball_color)


func set_simulation_manager(simulation: SimulationManager) -> void:
	_simulation = simulation
	queue_redraw()
