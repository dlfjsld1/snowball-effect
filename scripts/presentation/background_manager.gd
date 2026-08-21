class_name BackgroundManager
extends Node2D

signal background_transition_finished(background_id: StringName)

const OPAQUE_BACKGROUNDS := {
	&"ground": preload("res://assets/backgrounds/stage_world/runtime/background_ground_1600x900.png"),
	&"planetary": preload("res://assets/backgrounds/stage_world/runtime/background_planetary_1600x900.png"),
}
const GALACTIC_TEXTURES := {
	&"plate": preload("res://assets/backgrounds/stage_world/runtime/background_galactic_plate_1600x900.png"),
	&"stars": preload("res://assets/backgrounds/stage_world/runtime/background_galactic_stars_1600x900.png"),
	&"galaxy": preload("res://assets/backgrounds/stage_world/runtime/background_galactic_galaxy_1600x900.png"),
	&"nebula": preload("res://assets/backgrounds/stage_world/runtime/background_galactic_nebula_1600x900.png"),
}
const VALID_BACKGROUND_IDS := [&"ground", &"planetary", &"galactic"]
const GALACTIC_LAYER_ALPHA := {
	&"stars": 0.62,
	&"galaxy": 0.56,
	&"nebula": 0.48,
}
const GALACTIC_REDUCED_LAYER_ALPHA := {
	&"stars": 0.42,
	&"galaxy": 0.46,
	&"nebula": 0.38,
}

@export var reduced_effects := false

@onready var layer_a: Node2D = %LayerA
@onready var layer_b: Node2D = %LayerB
@onready var ambient: StageAmbientLayer = %Ambient

var current_background_id: StringName = &""
var target_background_id: StringName = &""
var _front: Node2D
var _back: Node2D
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
	_configure_layer(_front, resolved)
	_front.modulate.a = 1.0
	_clear_layer(_back)
	_back.modulate.a = 0.0
	ambient.configure(resolved)
	_apply_reduced_effects_recipe()


func transition_to(background_id: StringName, duration: float) -> void:
	var resolved := _resolve_id(background_id)
	if resolved == current_background_id or duration <= 0.0:
		set_background(resolved)
		background_transition_finished.emit(resolved)
		return

	_cancel_transition()
	target_background_id = resolved
	_configure_layer(_back, resolved)
	_back.modulate.a = 0.0
	ambient.configure(resolved)
	_apply_reduced_effects_recipe()
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
	_clear_layer(_back)
	_back.modulate.a = 0.0
	current_background_id = background_id
	_transition = null
	background_transition_finished.emit(background_id)


func _cancel_transition() -> void:
	if _transition != null and _transition.is_valid():
		_transition.kill()
	_transition = null


func _resolve_id(background_id: StringName) -> StringName:
	return background_id if background_id in VALID_BACKGROUND_IDS else &"ground"


func set_reduced_effects(enabled: bool) -> void:
	reduced_effects = enabled
	_apply_reduced_effects_recipe()


func get_current_layer_metrics() -> Dictionary:
	return get_layer_metrics(_front)


func get_layer_metrics(layer: Node2D) -> Dictionary:
	if not is_instance_valid(layer):
		return {}
	var plate := layer.get_node("Plate") as Sprite2D
	var stars := layer.get_node("Stars") as Sprite2D
	var galaxy := layer.get_node("Galaxy") as Sprite2D
	var nebula := layer.get_node("Nebula") as Sprite2D
	var textures := [plate.texture, stars.texture, galaxy.texture, nebula.texture]
	var texture_count := 0
	for texture in textures:
		texture_count += int(texture != null)
	return {
		"background_id": layer.get_meta("background_id", &""),
		"texture_count": texture_count,
		"plate_texture": plate.texture,
		"stars_texture": stars.texture,
		"galaxy_texture": galaxy.texture,
		"nebula_texture": nebula.texture,
		"stars_alpha": stars.modulate.a,
		"galaxy_alpha": galaxy.modulate.a,
		"nebula_alpha": nebula.modulate.a,
		"composite_alpha": layer.modulate.a,
		"reduced_effects": reduced_effects,
		"ambient_motion_enabled": ambient.is_processing(),
	}


func _configure_layer(layer: Node2D, background_id: StringName) -> void:
	var plate := layer.get_node("Plate") as Sprite2D
	var stars := layer.get_node("Stars") as Sprite2D
	var galaxy := layer.get_node("Galaxy") as Sprite2D
	var nebula := layer.get_node("Nebula") as Sprite2D
	layer.set_meta("background_id", background_id)
	if background_id == &"galactic":
		plate.texture = GALACTIC_TEXTURES[&"plate"]
		stars.texture = GALACTIC_TEXTURES[&"stars"]
		galaxy.texture = GALACTIC_TEXTURES[&"galaxy"]
		nebula.texture = GALACTIC_TEXTURES[&"nebula"]
	else:
		plate.texture = OPAQUE_BACKGROUNDS[background_id]
		stars.texture = null
		galaxy.texture = null
		nebula.texture = null
	_apply_layer_alpha_recipe(layer)


func _clear_layer(layer: Node2D) -> void:
	for child_name in ["Plate", "Stars", "Galaxy", "Nebula"]:
		var sprite := layer.get_node(child_name) as Sprite2D
		sprite.texture = null
	layer.set_meta("background_id", &"")


func _apply_reduced_effects_recipe() -> void:
	ambient.set_process(not reduced_effects)
	_apply_layer_alpha_recipe(layer_a)
	_apply_layer_alpha_recipe(layer_b)


func _apply_layer_alpha_recipe(layer: Node2D) -> void:
	if not is_instance_valid(layer):
		return
	var alpha_recipe: Dictionary = GALACTIC_REDUCED_LAYER_ALPHA if reduced_effects else GALACTIC_LAYER_ALPHA
	(layer.get_node("Plate") as Sprite2D).modulate = Color.WHITE
	(layer.get_node("Stars") as Sprite2D).modulate = Color(1.0, 1.0, 1.0, alpha_recipe[&"stars"])
	(layer.get_node("Galaxy") as Sprite2D).modulate = Color(1.0, 1.0, 1.0, alpha_recipe[&"galaxy"])
	(layer.get_node("Nebula") as Sprite2D).modulate = Color(1.0, 1.0, 1.0, alpha_recipe[&"nebula"])
