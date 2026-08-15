extends Node

const MAIN_SCENE := preload("res://scenes/main/main.tscn")

var _settlement_started_count := 0
var _settlement_finished_count := 0
var _failures := 0


func _ready() -> void:
	var main := MAIN_SCENE.instantiate()
	add_child(main)
	await get_tree().process_frame
	await get_tree().process_frame

	var game_manager: GameManager = main.get_node("GameManager")
	var stage_manager: StageManager = main.get_node("StageManager")
	var audio_manager: AudioManager = main.get_node("AudioManager")
	stage_manager.final_settlement_started.connect(_on_settlement_started)
	stage_manager.final_settlement_finished.connect(_on_settlement_finished)

	_expect(stage_manager.final_settlement_started.is_connected(game_manager._on_final_settlement_started), "GameManager must receive forwarded settlement-start events.")
	_expect(stage_manager.final_settlement_finished.is_connected(game_manager._on_final_settlement_finished), "GameManager must receive forwarded settlement-finish events.")
	_expect(audio_manager._simulation_source == main.get_node("PlayField/SimulationMount/BallSimulationManager"), "AudioManager must receive Main's simulation source.")
	_expect(audio_manager._stage_source == stage_manager, "AudioManager must receive Main's StageManager source.")
	audio_manager.audio_unlocked = true

	stage_manager._on_end_decision_requested(&"TOP_BALL_CLEAR")
	_expect(_settlement_started_count == 1, "One settlement must forward exactly one start event.")
	_expect(_settlement_finished_count == 1, "One settlement must forward exactly one finish event.")
	_expect(_active_keys(audio_manager).has(&"settlement_start"), "Settlement-start event must reach AudioManager through Main wiring.")

	if _failures == 0:
		print("S6_G4_AUDIO_WIRING_VERIFIED settlement_forward=1 main_audio_mount=true")
	main.free()
	get_tree().quit(_failures)


func _active_keys(audio_manager: AudioManager) -> Array:
	return audio_manager.get_debug_snapshot()["active_event_keys"]


func _on_settlement_started(_amount: float) -> void:
	_settlement_started_count += 1


func _on_settlement_finished(_amount: float) -> void:
	_settlement_finished_count += 1


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S6-G4 audio wiring verification failed: %s" % message)
