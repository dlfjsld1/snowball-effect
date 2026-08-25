extends Node

const CUTIN_SCENE := preload("res://scenes/effects/first_contact_cutin.tscn")
const FIELD_RECT := Rect2(500.0, 0.0, 600.0, 900.0)

var _failures := 0
var _activation_cues: Array[int] = []


func _ready() -> void:
	var controller := CUTIN_SCENE.instantiate() as CutInController
	add_child(controller)
	controller.configure_field_visual_rect(FIELD_RECT)
	controller.item_cutin_activation_cue.connect(func(event_id: int): _activation_cues.append(event_id))
	await get_tree().process_frame

	_expect(controller.play_item_cutin(201, &"blizzard", Vector2(800.0, 420.0)), "Blizzard must start the shared item CUT-IN banner.")
	_expect(not controller.play_item_cutin(201, &"blizzard", Vector2.ZERO), "An active duplicate event must be rejected.")
	await get_tree().process_frame
	var metrics := controller.get_visual_metrics()
	_expect(metrics["visible"] and metrics["active"], "Blizzard CUT-IN must be visible and active.")
	_expect(metrics["item_type"] == &"blizzard" and int(metrics["item_event_id"]) == 201, "Metrics must retain the Blizzard event identity.")
	_expect((metrics["field_clip_rect"] as Rect2).is_equal_approx(FIELD_RECT), "The banner must remain inside the active Play Field.")
	_expect(absf(float(metrics["total_duration"]) - 2.0) <= 0.001, "Blizzard must reuse the exact shared 2.00 second profile.")
	_expect((controller.get_node("FieldClip/CardRoot/ItemTitleLabel") as Label).text == "Blizzard Orb", "The title must use the user-approved text.")
	_expect((controller.get_node("FieldClip/CardRoot/ItemEffectLabel") as Label).text == "SPAWN RATE ×3", "The effect line must describe Blizzard.")
	var portrait := controller.get_node("FieldClip/CardRoot/BlizzardPortrait") as TextureRect
	_expect(portrait.visible and portrait.texture.resource_path.ends_with("blizzard_crystal.png"), "The shared banner must show the Blizzard portrait.")

	await get_tree().create_timer(CutInController.ENTER_DURATION + 0.10).timeout
	_expect(_activation_cues == [201], "Banner enter must emit one matching activation cue.")
	await get_tree().create_timer(CutInController.HOLD_DURATION + CutInController.EXIT_DURATION + 0.10).timeout
	_expect(not controller.visible and not controller.is_cutin_active(), "The shared banner must hide after its full timeline.")

	if _failures == 0:
		print("S7_G2_BLIZZARD_CUTIN_VERIFIED shared_banner=true title=Blizzard_Orb duration=2 cue=once")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S7-G2 Blizzard CUT-IN verification failed: %s" % message)
