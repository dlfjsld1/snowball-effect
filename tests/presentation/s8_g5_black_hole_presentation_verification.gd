extends Node

const FRAME_SCENE := preload("res://scenes/backgrounds/gameplay_frame.tscn")

var _phase_finished_ids: Array[int] = []
var _finale_finished_count := 0


func _ready() -> void:
	var frame: GameplayFrame = FRAME_SCENE.instantiate()
	add_child(frame)
	var presenter: PresentationManager = frame.get_node("PresentationManager")
	presenter.black_hole_phase_duration = 0.05
	presenter.black_hole_finale_duration = 0.05
	presenter.black_hole_phase_presentation_finished.connect(_on_phase_finished)
	presenter.black_hole_finale_presentation_finished.connect(_on_finale_finished)

	frame.set_profile(2)
	var from_rect := frame.get_field_rect()
	var to_rect := frame.get_field_rect_for_profile(3)
	_expect(from_rect.size.x == 880.0 and to_rect.size.x == 1040.0, "S8-G5 must animate the L2 880 to L3 1040 field profiles.")
	_expect(presenter.play_black_hole_phase(31, from_rect, to_rect), "A fresh phase ID must start the presentation.")
	_expect(not presenter.play_black_hole_phase(31, from_rect, to_rect), "An active phase ID must not start twice.")
	await _wait_until(func() -> bool: return not presenter.is_black_hole_phase_active())
	_expect(frame.profile_index == 3, "The visual frame must reach L3 before completion is published.")
	_expect(_phase_finished_ids == [31], "Exactly one matching phase completion must be emitted.")
	_expect(not presenter.play_black_hole_phase(31, from_rect, to_rect), "A completed phase ID must not be reused.")

	var snapshot := {
		"contact_position": Vector2(800.0, 450.0),
		"black_holes": [{"position": Vector2(740.0, 450.0)}, {"position": Vector2(860.0, 450.0)}],
	}
	_expect(presenter.play_black_hole_finale(snapshot), "A terminal snapshot must start the finale overlay.")
	_expect(not presenter.play_black_hole_finale(snapshot), "Finale must be single-flight.")
	await _wait_until(func() -> bool: return not presenter.is_black_hole_finale_active())
	_expect(_finale_finished_count == 1, "Finale completion must be emitted exactly once.")

	presenter.reset_black_hole_presentation()
	_expect(presenter.play_black_hole_phase(32, to_rect, to_rect), "Retry reset must permit a fresh phase ID.")
	await _wait_until(func() -> bool: return not presenter.is_black_hole_phase_active())
	_expect(_phase_finished_ids == [31, 32], "Reset must preserve only new-run completion behavior.")
	print("S8_G5_BLACK_HOLE_PRESENTATION_VERIFIED l2_to_l3=true phase_ids=true finale_once=true")
	get_tree().quit()


func _wait_until(predicate: Callable) -> void:
	var timeout_at := Time.get_ticks_msec() + 1000
	while not predicate.call() and Time.get_ticks_msec() < timeout_at:
		await get_tree().process_frame
	_expect(predicate.call(), "Presentation animation did not finish before timeout.")


func _on_phase_finished(phase_id: int) -> void:
	_phase_finished_ids.append(phase_id)


func _on_finale_finished() -> void:
	_finale_finished_count += 1


func _expect(condition: bool, message: String) -> void:
	assert(condition, message)
