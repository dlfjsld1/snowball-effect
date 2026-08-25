class_name Hud
extends Control

const BallCatalog = preload("res://scripts/data/ball_catalog.gd")
const BallTextureLodCatalog = preload("res://scripts/presentation/ball_texture_lod_catalog.gd")
const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")
const StageCatalog = preload("res://scripts/data/stage_catalog.gd")

const STAGE_SIGN_LOCAL_RECT := Rect2(58.0, 26.0, 84.0, 24.0)
const SCORE_SIGN_LOCAL_RECT := Rect2(55.0, 26.0, 84.0, 24.0)
# The 136x56 Stage mask has a 2px treatment inset. At the BMFont's crisp 2x
# scale, its 14px ink starts 2px into this 20px line box, yielding 19px above
# and below the glyphs inside the resulting 132x52 safe region.
const STAGE_NAME_LABEL_LOCAL_RECT := Rect2(34.0, 73.0, 132.0, 20.0)
# The 110x52 Score mask has the same 2px treatment inset. At the approved
# 20px crisp scale, score ink is 14px high, so this rect places it with exact
# 17px top and bottom margins inside the resulting 106x48 safe region.
const STAGE_SCORE_LABEL_LOCAL_RECT := Rect2(44.0, 71.0, 106.0, 20.0)
const GENEALOGY_DISPLAY_LOCAL_RECT := Rect2(48.0, 262.0, 106.0, 317.0)
const GENEALOGY_DISPLAY_INSET := 2.0
const GENEALOGY_ICON_SIZE := Vector2(24.0, 24.0)
const GENEALOGY_BASE_DIAMETER := 8
const GALAXY_CLUSTER_GENEALOGY_TEXTURE_PATH := "res://assets/sprites/balls/galactic/runtime/ball_galactic_local_lv01_galaxy_cluster_tri_spiral_core_crt_24.png"
const GENEALOGY_NODE_RADIUS := 19.0
const GENEALOGY_NODE_OUTLINE_WIDTH := 2.0
const GENEALOGY_BACKING := Color("1f244b")
const GENEALOGY_LOCKED := Color("3c6b64")
const GENEALOGY_REVEALED := Color("b6cf8e")
const GENEALOGY_REVEALED_FILL := Color("654053")

@onready var stage_name_label: Label = $Readout/StageNameLabel
@onready var time_label: Label = $Readout/TimeLabel
@onready var stage_score_label: Label = $Readout/StageScoreLabel
@onready var run_score_label: Label = $Readout/RunScoreLabel
@onready var clear_target_label: Label = $Readout/ClearTargetLabel
@onready var ball_count_label: Label = $Readout/BallCountLabel
@onready var stage_sign: Control = $StageSign
@onready var stage_sign_label: Label = $StageSign/Label
@onready var score_sign: Control = $ScoreSign
@onready var score_sign_label: Label = $ScoreSign/Label
@onready var stage_score_gauge: StageScoreGauge = $StageScoreGauge
@onready var effect_manager: EffectManager = $EffectManager
@onready var genealogy_title: Label = $Genealogy/Content/Title
@onready var genealogy_slots: Array[Label] = [
	$Genealogy/Content/Slots/Slot0,
	$Genealogy/Content/Slots/Slot1,
	$Genealogy/Content/Slots/Slot2,
	$Genealogy/Content/Slots/Slot3,
	$Genealogy/Content/Slots/Slot4,
]
@onready var genealogy_icons: Array[TextureRect] = [
	$Genealogy/Content/Slots/Icon0,
	$Genealogy/Content/Slots/Icon1,
	$Genealogy/Content/Slots/Icon2,
	$Genealogy/Content/Slots/Icon3,
	$Genealogy/Content/Slots/Icon4,
]

var _score_source: Node
var _ball_source: Node
var _stage_source: Node
var _ball_catalog = BallCatalog.new()
var _ball_texture_lod_catalog = BallTextureLodCatalog.new()
var _stage_catalog = StageCatalog.new()
var _ordered_global_levels := PackedInt32Array()
var _current_stage_index := -1
var _revealed_count := 0
var _authoritative_stage_score := 0.0
var _authoritative_run_score := 0.0
var _current_clear_score := 0.0
var _settlement_score_start := 0.0
var _settlement_elapsed := 0.0
var _settlement_duration := 0.0
var _settlement_counting := false


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
	effect_manager.set_stage_source(_stage_source)
	effect_manager.set_settlement_target(stage_score_label)
	if is_instance_valid(_stage_source):
		_stage_source.stage_changed.connect(_on_stage_changed)
		_on_stage_changed(_stage_source.get_current_stage())


func _ready() -> void:
	effect_manager.final_settlement_visual_started.connect(_on_final_settlement_visual_started)
	effect_manager.final_settlement_presentation_finished.connect(_on_final_settlement_presentation_finished)
	queue_redraw()
	call_deferred("_bind_main_stage_source")


func _draw() -> void:
	var centers := _get_genealogy_node_centers()
	for connector_index in range(maxi(centers.size() - 1, 0)):
		var lower_center: Vector2 = centers[connector_index]
		var upper_center: Vector2 = centers[connector_index + 1]
		var connector_color := GENEALOGY_REVEALED if connector_index + 1 < _revealed_count else GENEALOGY_LOCKED
		draw_line(
			lower_center - Vector2(0.0, GENEALOGY_NODE_RADIUS),
			upper_center + Vector2(0.0, GENEALOGY_NODE_RADIUS),
			connector_color,
			GENEALOGY_NODE_OUTLINE_WIDTH,
			false
		)
	for slot_index in range(centers.size()):
		var revealed := slot_index < _revealed_count and slot_index < _ordered_global_levels.size()
		var fill_color := GENEALOGY_REVEALED_FILL if revealed else GENEALOGY_BACKING
		var outline_color := GENEALOGY_REVEALED if revealed else GENEALOGY_LOCKED
		draw_circle(centers[slot_index], GENEALOGY_NODE_RADIUS, fill_color, true, -1.0, false)
		draw_circle(centers[slot_index], GENEALOGY_NODE_RADIUS, outline_color, false, GENEALOGY_NODE_OUTLINE_WIDTH, false)


func _process(delta: float) -> void:
	if is_instance_valid(_stage_source):
		var snapshot: Dictionary = _stage_source.get_runtime_snapshot()
		time_label.text = "TIME %.1f" % snapshot["stage_time_left"]
	if _settlement_counting:
		_settlement_elapsed = minf(_settlement_elapsed + delta, _settlement_duration)
		var progress := _settlement_elapsed / maxf(_settlement_duration, 0.001)
		var displayed_score := lerpf(_settlement_score_start, _authoritative_stage_score, progress)
		stage_score_label.text = ScoreFormatter.format_score(displayed_score).to_upper()
		_update_stage_score_gauge(displayed_score)


func reset_view() -> void:
	_settlement_counting = false
	_on_score_changed(0.0, 0.0)
	_on_ball_count_changed(0)
	time_label.text = "TIME 0.0"
	_update_stage_score_gauge(0.0)


func apply_frame_layout(left_wing: Rect2, right_wing: Rect2) -> void:
	stage_sign.position = left_wing.position + STAGE_SIGN_LOCAL_RECT.position
	score_sign.position = right_wing.position + SCORE_SIGN_LOCAL_RECT.position
	stage_name_label.position = left_wing.position + STAGE_NAME_LABEL_LOCAL_RECT.position
	stage_name_label.size = STAGE_NAME_LABEL_LOCAL_RECT.size
	time_label.position = left_wing.position + Vector2(24.0, 154.0)
	$Genealogy.position = left_wing.position + GENEALOGY_DISPLAY_LOCAL_RECT.position
	$Genealogy.size = GENEALOGY_DISPLAY_LOCAL_RECT.size
	stage_score_label.position = right_wing.position + STAGE_SCORE_LABEL_LOCAL_RECT.position
	stage_score_label.size = STAGE_SCORE_LABEL_LOCAL_RECT.size
	stage_score_gauge.position = right_wing.position + Vector2(48.0, 194.0)
	queue_redraw()


func _exit_tree() -> void:
	_unbind_sources()


func _on_score_changed(stage_score: float, run_score: float) -> void:
	_authoritative_stage_score = stage_score
	_authoritative_run_score = run_score
	if not _settlement_counting:
		stage_score_label.text = ScoreFormatter.format_score(stage_score).to_upper()
		_update_stage_score_gauge(stage_score)
	run_score_label.text = "RUN SCORE %s" % ScoreFormatter.format_score(run_score)


func _on_final_settlement_visual_started(duration: float) -> void:
	_settlement_score_start = _authoritative_stage_score
	_settlement_elapsed = 0.0
	_settlement_duration = duration
	_settlement_counting = true
	_update_stage_score_gauge(_settlement_score_start)


func _on_final_settlement_presentation_finished() -> void:
	_settlement_counting = false
	stage_score_label.text = ScoreFormatter.format_score(_authoritative_stage_score).to_upper()
	_update_stage_score_gauge(_authoritative_stage_score)


func _on_ball_count_changed(active_count: int) -> void:
	ball_count_label.text = "BALLS %d" % active_count


func _on_stage_changed(definition: StageDefinition) -> void:
	if definition == null:
		return
	stage_name_label.text = definition.display_name.to_upper()
	_current_clear_score = definition.clear_score
	clear_target_label.text = "TARGET %s" % ScoreFormatter.format_score(definition.clear_score)
	_update_stage_score_gauge(_authoritative_stage_score)
	_current_stage_index = definition.stage_index
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


func set_value_popups_enabled(enabled: bool) -> void:
	effect_manager.set_value_popups_enabled(enabled)


func _update_genealogy() -> void:
	for slot_index in range(genealogy_slots.size()):
		var slot := genealogy_slots[slot_index]
		var icon := genealogy_icons[slot_index]
		var revealed := slot_index < _revealed_count and slot_index < _ordered_global_levels.size()
		if not revealed:
			slot.text = ""
			icon.texture = null
			icon.visible = false
			continue
		var definition = _ball_catalog.get_definition(_ordered_global_levels[slot_index])
		var primary_texture: Texture2D = definition.texture if definition != null else null
		var runtime_texture := _resolve_genealogy_texture(_ordered_global_levels[slot_index], slot_index, primary_texture)
		icon.texture = runtime_texture
		icon.texture_filter = (runtime_texture as CanvasTexture).texture_filter if runtime_texture is CanvasTexture else CanvasItem.TEXTURE_FILTER_NEAREST
		icon.visible = icon.texture != null
		slot.text = definition.display_name.to_upper() if definition != null else ""
	queue_redraw()


func _resolve_genealogy_texture(global_level: int, local_level: int, primary_texture: Texture2D) -> Texture2D:
	var source_local_level := local_level
	if local_level == 0 and _current_stage_index > 0:
		var previous_stage: StageDefinition = _stage_catalog.get_stage(_current_stage_index - 1)
		if previous_stage != null and not previous_stage.local_ball_levels.is_empty():
			var previous_final_local_level := previous_stage.local_ball_levels.size() - 1
			if previous_stage.local_ball_levels[previous_final_local_level] == global_level:
				source_local_level = previous_final_local_level
	var source_diameter := float(GENEALOGY_BASE_DIAMETER * (1 << source_local_level))
	var fallback := _ball_texture_lod_catalog.resolve_texture(global_level, source_diameter, primary_texture)
	# The selected 16px gameplay sprite has a separately authored 24px CRT read.
	if _current_stage_index == 2 and global_level == 11 and local_level == 1:
		return _resolve_optional_genealogy_texture(GALAXY_CLUSTER_GENEALOGY_TEXTURE_PATH, fallback)
	return fallback


func _resolve_optional_genealogy_texture(path: String, fallback: Texture2D) -> Texture2D:
	if not ResourceLoader.exists(path, "Texture2D"):
		return fallback
	var texture := ResourceLoader.load(path, "Texture2D") as Texture2D
	return texture if texture != null else fallback


func get_genealogy_visual_metrics() -> Dictionary:
	var revealed: Array[bool] = []
	var texture_paths: Array[String] = []
	var icon_bounds: Array[Rect2] = []
	var label_bounds: Array[Rect2] = []
	for slot_index in range(genealogy_icons.size()):
		var is_revealed := slot_index < _revealed_count and slot_index < _ordered_global_levels.size()
		revealed.append(is_revealed)
		var texture := genealogy_icons[slot_index].texture
		texture_paths.append(texture.resource_path if texture != null else "")
		icon_bounds.append(_get_control_rect_in_hud(genealogy_icons[slot_index]))
		label_bounds.append(_get_control_rect_in_hud(genealogy_slots[slot_index]))
	var node_centers := _get_genealogy_node_centers()
	var node_bounds: Array[Rect2] = []
	var connector_bounds: Array[Rect2] = []
	var node_visual_radius := GENEALOGY_NODE_RADIUS + GENEALOGY_NODE_OUTLINE_WIDTH * 0.5
	for center in node_centers:
		node_bounds.append(Rect2(
			center - Vector2.ONE * node_visual_radius,
			Vector2.ONE * node_visual_radius * 2.0
		))
	for connector_index in range(maxi(node_centers.size() - 1, 0)):
		var start: Vector2 = node_centers[connector_index] - Vector2(0.0, GENEALOGY_NODE_RADIUS)
		var end: Vector2 = node_centers[connector_index + 1] + Vector2(0.0, GENEALOGY_NODE_RADIUS)
		var half_width := GENEALOGY_NODE_OUTLINE_WIDTH * 0.5
		connector_bounds.append(Rect2(
			Vector2(start.x - half_width, minf(start.y, end.y) - half_width),
			Vector2(GENEALOGY_NODE_OUTLINE_WIDTH, absf(start.y - end.y) + GENEALOGY_NODE_OUTLINE_WIDTH)
		))
	var display_bounds := _get_control_rect_in_hud($Genealogy)
	return {
		"node_count": genealogy_icons.size(),
		"connector_count": maxi(genealogy_icons.size() - 1, 0),
		"flow": &"bottom_to_top",
		"display_bounds": display_bounds,
		"safe_bounds": display_bounds.grow(-GENEALOGY_DISPLAY_INSET),
		"title": genealogy_title.text,
		"title_bounds": _get_control_rect_in_hud(genealogy_title),
		"node_centers": node_centers,
		"node_bounds": node_bounds,
		"connector_bounds": connector_bounds,
		"icon_bounds": icon_bounds,
		"label_bounds": label_bounds,
		"revealed_count": mini(_revealed_count, _ordered_global_levels.size()),
		"revealed": revealed,
		"texture_paths": texture_paths,
		"icon_size": GENEALOGY_ICON_SIZE,
		"node_radius": GENEALOGY_NODE_RADIUS,
		"node_outline_width": GENEALOGY_NODE_OUTLINE_WIDTH,
	}


func _get_genealogy_node_centers() -> PackedVector2Array:
	var centers := PackedVector2Array()
	var slots_origin: Vector2 = $Genealogy.position + $Genealogy/Content.position + $Genealogy/Content/Slots.position
	for icon in genealogy_icons:
		centers.append(slots_origin + icon.position + icon.size * 0.5)
	return centers


func _get_control_rect_in_hud(control: Control) -> Rect2:
	var top_left := control.position
	var ancestor := control.get_parent()
	while ancestor != self and ancestor is Control:
		top_left += (ancestor as Control).position
		ancestor = ancestor.get_parent()
	return Rect2(top_left, control.size)


func get_stage_score_gauge_progress() -> float:
	return stage_score_gauge.get_progress()


func _update_stage_score_gauge(displayed_stage_score: float) -> void:
	stage_score_gauge.set_score_progress(displayed_stage_score, _current_clear_score)


func _bind_main_stage_source() -> void:
	if is_instance_valid(_stage_source) or get_tree().current_scene == null:
		return
	var stage_source := get_tree().current_scene.get_node_or_null("StageManager")
	if stage_source != null:
		bind_sources(_score_source, _ball_source, stage_source)


func _unbind_sources() -> void:
	effect_manager.set_simulation_source(null)
	effect_manager.set_stage_source(null)
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
