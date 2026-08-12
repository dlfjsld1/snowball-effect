class_name Hud
extends Control

const BallCatalog = preload("res://scripts/data/ball_catalog.gd")
const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")

@onready var stage_name_label: Label = $Readout/StageNameLabel
@onready var time_label: Label = $Readout/TimeLabel
@onready var stage_score_label: Label = $Readout/StageScoreLabel
@onready var run_score_label: Label = $Readout/RunScoreLabel
@onready var clear_target_label: Label = $Readout/ClearTargetLabel
@onready var ball_count_label: Label = $Readout/BallCountLabel
@onready var effect_manager: EffectManager = $EffectManager
@onready var genealogy_slots: Array[Label] = [
	$Genealogy/Content/Slots/Slot0,
	$Genealogy/Content/Slots/Slot1,
	$Genealogy/Content/Slots/Slot2,
	$Genealogy/Content/Slots/Slot3,
	$Genealogy/Content/Slots/Slot4,
]

var _score_source: Node
var _ball_source: Node
var _stage_source: Node
var _ball_catalog = BallCatalog.new()
var _ordered_global_levels := PackedInt32Array()
var _revealed_count := 0


func bind_sources(score_source: Node, ball_source: Node, stage_source: Node = null) -> void:
	_unbind_sources()
	_score_source = score_source
	_ball_source = ball_source
	_stage_source = stage_source
	if is_instance_valid(_score_source):
		_score_source.score_changed.connect(_on_score_changed)
		_on_score_changed(_score_source.stage_score, _score_source.run_score)
	if is_instance_valid(_ball_source):
		_ball_source.ball_count_changed.connect(_on_ball_count_changed)
		_ball_source.ball_merged.connect(_on_ball_merged)
		_on_ball_count_changed(_ball_source.get_active_count())
	effect_manager.set_simulation_source(_ball_source)
	if is_instance_valid(_stage_source):
		_stage_source.stage_changed.connect(_on_stage_changed)
		_on_stage_changed(_stage_source.get_current_stage())


func _ready() -> void:
	call_deferred("_bind_main_stage_source")


func _process(_delta: float) -> void:
	if is_instance_valid(_stage_source):
		var snapshot: Dictionary = _stage_source.get_runtime_snapshot()
		time_label.text = "TIME %.1f" % snapshot["stage_time_left"]


func reset_view() -> void:
	_on_score_changed(0.0, 0.0)
	_on_ball_count_changed(0)
	time_label.text = "TIME 0.0"


func _exit_tree() -> void:
	_unbind_sources()


func _on_score_changed(stage_score: float, run_score: float) -> void:
	stage_score_label.text = "STAGE SCORE %s" % ScoreFormatter.format_score(stage_score)
	run_score_label.text = "RUN SCORE %s" % ScoreFormatter.format_score(run_score)


func _on_ball_count_changed(active_count: int) -> void:
	ball_count_label.text = "BALLS %d" % active_count


func _on_stage_changed(definition: StageDefinition) -> void:
	if definition == null:
		return
	stage_name_label.text = "STAGE %s" % definition.display_name.to_upper()
	clear_target_label.text = "TARGET %s" % ScoreFormatter.format_score(definition.clear_score)
	_ordered_global_levels = definition.local_ball_levels.duplicate()
	_revealed_count = 1
	_update_genealogy()


func _on_ball_merged(result_level: int, _world_position: Vector2) -> void:
	var local_level := _ordered_global_levels.find(result_level)
	if local_level < 0:
		return
	var next_revealed_count := local_level + 1
	if next_revealed_count <= _revealed_count:
		return
	_revealed_count = next_revealed_count
	_update_genealogy()


func _update_genealogy() -> void:
	for slot_index in range(genealogy_slots.size()):
		var slot := genealogy_slots[slot_index]
		if slot_index >= _revealed_count or slot_index >= _ordered_global_levels.size():
			slot.text = ""
			continue
		var definition = _ball_catalog.get_definition(_ordered_global_levels[slot_index])
		slot.text = definition.display_name if definition != null else ""


func _bind_main_stage_source() -> void:
	if is_instance_valid(_stage_source) or get_tree().current_scene == null:
		return
	var stage_source := get_tree().current_scene.get_node_or_null("StageManager")
	if stage_source != null:
		bind_sources(_score_source, _ball_source, stage_source)


func _unbind_sources() -> void:
	effect_manager.set_simulation_source(null)
	if is_instance_valid(_score_source) and _score_source.score_changed.is_connected(_on_score_changed):
		_score_source.score_changed.disconnect(_on_score_changed)
	if is_instance_valid(_ball_source) and _ball_source.ball_count_changed.is_connected(_on_ball_count_changed):
		_ball_source.ball_count_changed.disconnect(_on_ball_count_changed)
	if is_instance_valid(_ball_source) and _ball_source.ball_merged.is_connected(_on_ball_merged):
		_ball_source.ball_merged.disconnect(_on_ball_merged)
	if is_instance_valid(_stage_source) and _stage_source.stage_changed.is_connected(_on_stage_changed):
		_stage_source.stage_changed.disconnect(_on_stage_changed)
	_score_source = null
	_ball_source = null
	_stage_source = null
