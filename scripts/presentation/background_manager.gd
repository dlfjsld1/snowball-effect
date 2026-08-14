class_name BackgroundManager
extends Node2D

signal background_transition_finished(background_id: StringName)

const BACKGROUNDS := {
	&"ground": preload("res://assets/backgrounds/stage_world/runtime/background_ground_1600x900.png"),
	&"planetary": preload("res://assets/backgrounds/stage_world/runtime/background_planetary_1600x900.png"),
	&"galactic": preload("res://assets/backgrounds/stage_world/runtime/background_galactic_1600x900.png"),
}

@onready var layer_a: Sprite2D = %LayerA
@onready var layer_b: Sprite2D = %LayerB
@onready var ambient: StageAmbientLayer = %Ambient

var current_background_id: StringName = &""
var target_background_id: StringName = &""
var _front: Sprite2D
var _back: Sprite2D
var _transition: Tween


func _ready() -> void:
	_front = layer_a
	_back = layer_b
	set_background(&"ground")


func set_background(background_id: StringName) -> void:
	var resolved := _resolve_id(background_id)
	_cancel_transition()
	current_background_id = resolved
	target_background_id = resolved
	_front.texture = BACKGROUNDS[resolved]
	_front.modulate.a = 1.0
	_back.texture = null
	_back.modulate.a = 0.0
	ambient.configure(resolved)


func transition_to(background_id: StringName, duration: float) -> void:
	var resolved := _resolve_id(background_id)
	if resolved == current_background_id or duration <= 0.0:
		set_background(resolved)
		background_transition_finished.emit(resolved)
		return

	_cancel_transition()
	target_background_id = resolved
	_back.texture = BACKGROUNDS[resolved]
	_back.modulate.a = 0.0
	ambient.configure(resolved)
	_transition = create_tween()
	_transition.set_parallel(true)
	_transition.tween_property(_front, "modulate:a", 0.0, duration)
	_transition.tween_property(_back, "modulate:a", 1.0, duration)
	_transition.chain().tween_callback(_finish_transition.bind(resolved))


func _finish_transition(background_id: StringName) -> void:
	if background_id != target_background_id:
		return
	var previous_front := _front
	_front = _back
	_back = previous_front
	_back.texture = null
	_back.modulate.a = 0.0
	current_background_id = background_id
	_transition = null
	background_transition_finished.emit(background_id)


func _cancel_transition() -> void:
	if _transition != null and _transition.is_valid():
		_transition.kill()
	_transition = null


func _resolve_id(background_id: StringName) -> StringName:
	return background_id if BACKGROUNDS.has(background_id) else &"ground"
