class_name ResultPanel
extends Control

## Displays a copied terminal snapshot. The Core snapshot remains read-only.

const ScoreFormatter = preload("res://scripts/utils/score_formatter.gd")
const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")

const SCORE_MAX_FONT_SIZE := 86
const SCORE_MIN_FONT_SIZE := 16
const SCORE_MAX_LINES := 3
const SCORE_HORIZONTAL_PADDING := 40.0
const SCORE_VERTICAL_PADDING := 18.0
const SCORE_THREE_LINE_GROUP_THRESHOLD := 10

signal retry_requested
signal main_menu_requested

@onready var slide_panel: Control = %SlidePanel
@onready var mechanical_motion: Control = %MechanicalMotion
@onready var score_label: Label = %ScoreLabel
@onready var highest_stage_label: Label = %HighestStageValue
@onready var highest_ball_label: Label = %HighestBallValue
@onready var ground_stage_art: TextureRect = %GroundStageArt
@onready var planetary_stage_art: TextureRect = %PlanetaryStageArt
@onready var stage_preview_mask: ColorRect = $SlidePanel/StagePreviewMask
@onready var ball_preview_backdrop: ColorRect = $SlidePanel/BallPreviewBackdrop
@onready var ball_preview: TextureRect = %BallPreview
@onready var stats_row: Control = %StatsRow
@onready var merge_count_label: Label = $SlidePanel/StatsRow/MergeCount
@onready var run_time_label: Label = $SlidePanel/StatsRow/RunTime
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainButton

var _result_snapshot: Dictionary = {}
var _entrance_tween: Tween
var _ball_catalog = BallCatalogScript.new()
var _stage_catalog = StageCatalogScript.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	retry_button.pressed.connect(_request_retry)
	main_menu_button.pressed.connect(_request_main_menu)


func show_result(result_snapshot: Dictionary) -> void:
	_result_snapshot = result_snapshot.duplicate(true)
	var run_score := float(_result_snapshot.get("run_score", 0.0))
	_fit_full_score(ScoreFormatter.format_score_full(run_score))
	_update_summary()
	_update_optional_stats()
	visible = true
	mechanical_motion.set_process(true)
	_play_entrance()
	retry_button.grab_focus()


func hide_result() -> void:
	if _entrance_tween != null and _entrance_tween.is_valid():
		_entrance_tween.kill()
	visible = false
	mechanical_motion.set_process(false)
	slide_panel.position = Vector2.ZERO
	_result_snapshot.clear()


func get_result_snapshot() -> Dictionary:
	return _result_snapshot.duplicate(true)


static func format_run_time(seconds: float) -> String:
	var total_seconds := maxi(int(floor(maxf(seconds, 0.0))), 0)
	var hours := total_seconds / 3600
	var minutes := (total_seconds % 3600) / 60
	var remaining_seconds := total_seconds % 60
	if hours > 0:
		return "%d:%02d:%02d" % [hours, minutes, remaining_seconds]
	return "%02d:%02d" % [minutes, remaining_seconds]


func _play_entrance() -> void:
	if _entrance_tween != null and _entrance_tween.is_valid():
		_entrance_tween.kill()
	slide_panel.position = Vector2(0.0, size.y + 48.0)
	_entrance_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_entrance_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_entrance_tween.tween_property(slide_panel, "position:y", 0.0, 0.82)


func _update_optional_stats() -> void:
	var raw_stats = _result_snapshot.get("optional_stats", {})
	var optional_stats: Dictionary = raw_stats if raw_stats is Dictionary else {}
	var has_merge_count := optional_stats.has("merge_count")
	var has_run_time := optional_stats.has("run_time_seconds")
	merge_count_label.visible = has_merge_count
	run_time_label.visible = has_run_time
	stats_row.visible = has_merge_count or has_run_time
	if has_merge_count:
		merge_count_label.text = "%d" % maxi(int(optional_stats["merge_count"]), 0)
	if has_run_time:
		run_time_label.text = format_run_time(float(optional_stats["run_time_seconds"]))


func _update_summary() -> void:
	ground_stage_art.visible = false
	planetary_stage_art.visible = false
	stage_preview_mask.visible = false
	ball_preview_backdrop.visible = false
	ball_preview.visible = false
	ball_preview.texture = null
	var stage_index := int(_result_snapshot.get("stage_index", -1))
	var stage = _stage_catalog.get_stage(stage_index)
	if stage == null:
		highest_stage_label.text = "--"
	else:
		highest_stage_label.text = String(stage.display_name).to_upper()
		if stage_index == 0:
			stage_preview_mask.visible = true
			ground_stage_art.visible = true
		elif stage_index == 1:
			stage_preview_mask.visible = true
			planetary_stage_art.visible = true

	var highest_ball_global_level := int(_result_snapshot.get("highest_ball_global_level", -1))
	var ball = _ball_catalog.get_definition(highest_ball_global_level)
	if ball == null:
		highest_ball_label.text = "--"
		return
	highest_ball_label.text = String(ball.display_name).to_upper()
	if highest_ball_global_level == 14:
		return
	ball_preview_backdrop.visible = true
	ball_preview.texture = ball.texture
	ball_preview.visible = ball_preview.texture != null


func _fit_full_score(formatted_score: String) -> void:
	var score_font := score_label.get_theme_font(&"font")
	var available_width := maxf(score_label.size.x - SCORE_HORIZONTAL_PADDING, 1.0)
	var available_height := maxf(score_label.size.y - SCORE_VERTICAL_PADDING, 1.0)
	var group_count := formatted_score.count(",") + 1
	var candidate_limit := mini(SCORE_MAX_LINES, group_count)
	var minimum_lines := 3 if group_count >= SCORE_THREE_LINE_GROUP_THRESHOLD else 1
	var best_text := formatted_score
	var best_font_size := SCORE_MIN_FONT_SIZE

	for line_count in range(minimum_lines, candidate_limit + 1):
		var candidate := _balance_score_lines(formatted_score, line_count)
		var candidate_font_size := _largest_fitting_font_size(
			candidate,
			score_font,
			available_width,
			available_height
		)
		if candidate_font_size > best_font_size:
			best_text = candidate
			best_font_size = candidate_font_size

	score_label.text = best_text
	score_label.add_theme_font_size_override(&"font_size", best_font_size)


func _largest_fitting_font_size(text: String, font: Font, available_width: float, available_height: float) -> int:
	var lines := text.split("\n")
	for font_size in range(SCORE_MAX_FONT_SIZE, SCORE_MIN_FONT_SIZE - 1, -1):
		var widest_line := 0.0
		for line in lines:
			widest_line = maxf(widest_line, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)
		var text_height := font.get_height(font_size) * lines.size()
		if widest_line <= available_width and text_height <= available_height:
			return font_size
	return SCORE_MIN_FONT_SIZE


func _balance_score_lines(formatted_score: String, line_count: int) -> String:
	var groups := formatted_score.split(",")
	var base_groups_per_line := groups.size() / line_count
	var extra_group_lines := groups.size() % line_count
	var cursor := 0
	var lines: PackedStringArray = []
	for line_index in line_count:
		var groups_this_line := base_groups_per_line + (1 if line_index < extra_group_lines else 0)
		var line_groups: PackedStringArray = []
		for group_index in groups_this_line:
			line_groups.append(groups[cursor + group_index])
		lines.append(",".join(line_groups))
		cursor += groups_this_line
	return "\n".join(lines)


func _request_retry() -> void:
	retry_requested.emit()


func _request_main_menu() -> void:
	main_menu_requested.emit()
