extends Node

const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")

const EXPECTED_NAMES := ["Ground", "Planetary", "Galactic"]
const EXPECTED_BASE_LEVELS := [0, 4, 10]
const EXPECTED_TOP_LEVELS := [4, 10, 14]
const EXPECTED_LOCAL_LEVELS := [
	[0, 1, 2, 3, 4],
	[4, 5, 6, 8, 10],
	[10, 11, 12, 13, 14],
]
const EXPECTED_TIMES := [45.0, 40.0, 35.0]
const EXPECTED_CLEAR_SCORES := [4.0e6, 2.0e18, 0.0]
const EXPECTED_SPAWN_RATES := [6.0, 15.0, 35.0]
const EXPECTED_BACKGROUND_IDS := [&"ground", &"planetary", &"galactic"]
const EXPECTED_TIME_BONUSES := [
	[0.0, 0.25, 0.5, 1.0, 2.0],
	[0.0, 0.25, 0.5, 1.0, 2.0],
	[0.0, 0.25, 0.5, 1.0, 2.0],
]

var _failures := 0


func _ready() -> void:
	var catalog = StageCatalogScript.new()
	_expect(catalog.get_all_stages().size() == EXPECTED_NAMES.size(), "Catalog must expose exactly three initial stages.")

	for index in range(EXPECTED_NAMES.size()):
		var stage = catalog.get_stage(index)
		_expect(stage != null, "Each stage index must load from the catalog.")
		if stage == null:
			continue
		_expect(stage.stage_index == index, "Stage index must match its catalog index.")
		_expect(stage.display_name == EXPECTED_NAMES[index], "Stage display name must match the seed.")
		_expect(stage.base_global_level == EXPECTED_BASE_LEVELS[index], "Stage base global level must match the seed.")
		_expect(stage.top_global_level == EXPECTED_TOP_LEVELS[index], "Stage top global level must match the seed.")
		_expect(_matches_local_levels(stage.local_ball_levels, EXPECTED_LOCAL_LEVELS[index]), "Stage local progression must match its ordered global-level chain.")
		_expect(stage.local_ball_levels.size() == 5, "Each default stage must expose exactly five local levels.")
		_expect(stage.local_ball_levels[0] == stage.base_global_level, "Local progression must begin at the base global level.")
		_expect(stage.local_ball_levels[stage.local_ball_levels.size() - 1] == stage.top_global_level, "Local progression must end at the top global level.")
		_expect(is_equal_approx(stage.base_time, EXPECTED_TIMES[index]), "Base time must match the stage seed.")
		_expect(is_equal_approx(stage.clear_score, EXPECTED_CLEAR_SCORES[index]), "Clear score must match the stage seed.")
		_expect(is_equal_approx(stage.spawn_rate, EXPECTED_SPAWN_RATES[index]), "Spawn rate must match the stage seed.")
		_expect(_matches_time_bonuses(stage.time_bonus_by_local_level, EXPECTED_TIME_BONUSES[index]), "Time Bonus must be stage-local data.")
		_expect(is_equal_approx(stage.visual_radius_scale, 1.0), "Initial visual radius scale must remain render-only neutral.")
		_expect(stage.background_id == EXPECTED_BACKGROUND_IDS[index], "Background ID must match the stage seed.")

	var ground = catalog.get_stage(0)
	var planetary = catalog.get_stage(1)
	var galactic = catalog.get_stage(2)
	_expect(ground.top_global_level == planetary.base_global_level, "Ground top must become Planetary base.")
	_expect(planetary.top_global_level == galactic.base_global_level, "Planetary top must become Galactic base.")
	_expect(not planetary.local_ball_levels.has(7) and not planetary.local_ball_levels.has(9), "Catalog-only Lv7 and Lv9 must stay outside the default Planetary chain.")
	_expect(not ground.black_hole_enabled and not planetary.black_hole_enabled and galactic.black_hole_enabled, "Only Galactic may enable the future Black Hole map gimmick.")
	_expect(not catalog.has_stage(-1) and not catalog.has_stage(3), "Undefined stage indices must not resolve.")

	if _failures == 0:
		print("S3_G1_VERIFIED stages=3 chains=0-4,4-5-6-8-10,10-14")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S3-G1 verification failed: %s" % message)


func _matches_time_bonuses(actual: PackedFloat64Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in range(actual.size()):
		if not is_equal_approx(actual[index], expected[index]):
			return false
	return true


func _matches_local_levels(actual: PackedInt32Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in range(actual.size()):
		if actual[index] != expected[index]:
			return false
	return true
