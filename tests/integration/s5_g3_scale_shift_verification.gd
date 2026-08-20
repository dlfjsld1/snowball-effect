extends Node

const SimulationManager = preload("res://scripts/simulation/ball_simulation_manager.gd")
const StageManager = preload("res://scripts/core/stage_manager.gd")

@onready var simulation: SimulationManager = $BallSimulationManager
@onready var stage_manager: StageManager = $StageManager

var _failures := 0
var _states: Array[StringName] = []
var _stage_changed_count := 0
var _shift_id := -1


func _ready() -> void:
	stage_manager.stage_state_changed.connect(_on_stage_state_changed)
	stage_manager.stage_changed.connect(_on_stage_changed)
	stage_manager.stage_shift_started.connect(_on_stage_shift_started)
	stage_manager.start_run()
	_verify_score_clear_enters_shift_once()
	if _failures == 0:
		print("S5_G3_VERIFIED clear_to_shifting=true duplicate_safe=true planetary_entered=true")
	get_tree().quit(_failures)


func _verify_score_clear_enters_shift_once() -> void:
	stage_manager.get_score_ledger().apply_score_event(stage_manager.get_current_stage().clear_score)
	stage_manager._physics_process(0.1)

	_expect(_states.has(StageManager.CLEARED), "Score Clear must enter CLEARED before presentation handoff.")
	_expect(stage_manager.current_state == StageManager.SHIFTING, "Ground clear must start Scale Shift immediately.")
	_expect(_shift_id > 0, "SHIFTING must issue a positive shift id.")
	_expect(simulation.get_active_count() == 0, "Settlement must remove active balls before the presentation wait.")
	var frozen_time: float = stage_manager.get_runtime_snapshot()["stage_time_left"]
	stage_manager._physics_process(1.0)
	_expect(is_equal_approx(stage_manager.get_runtime_snapshot()["stage_time_left"], frozen_time), "Timer must stop while SHIFTING.")
	_expect(not stage_manager.accept_stage_shift_presentation_finished(_shift_id + 1), "Wrong shift id must not enter the next Stage.")
	_expect(stage_manager.current_state == StageManager.SHIFTING, "Wrong shift id must keep SHIFTING locked.")
	_expect(stage_manager.accept_stage_shift_presentation_finished(_shift_id), "Matching shift id must enter the next Stage.")
	_expect(stage_manager.current_state == StageManager.PLAYING, "Matching completion must start the next Stage.")
	_expect(stage_manager.current_stage_index == 1, "Ground must advance to Planetary exactly once.")
	_expect(stage_manager.get_current_stage().display_name == "Planetary", "Next Stage must use the ordered StageCatalog entry.")
	_expect(is_equal_approx(stage_manager.get_score_ledger().stage_score, 0.0), "Next Stage score must reset.")
	_expect(is_equal_approx(stage_manager.get_score_ledger().run_score, 4000000.0), "Run score must preserve the cleared Ground score.")
	_expect(not stage_manager.accept_stage_shift_presentation_finished(_shift_id), "Duplicate completion must be ignored.")
	_expect(_stage_changed_count == 2, "Initial Ground and one Planetary entry are the only Stage changes.")


func _on_stage_state_changed(state: StringName) -> void:
	_states.append(state)


func _on_stage_changed(_definition: StageDefinition) -> void:
	_stage_changed_count += 1


func _on_stage_shift_started(_definition: StageDefinition, shift_id: int) -> void:
	_shift_id = shift_id


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S5-G3 verification failed: %s" % message)
