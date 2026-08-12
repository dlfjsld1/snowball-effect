extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const StageCatalogScript = preload("res://scripts/data/stage_catalog.gd")

const EXPECTED_CHAINS := [
	[0, 1, 2, 3, 4],
	[4, 5, 6, 8, 10],
	[10, 11, 12, 13, 14],
]
const EXPECTED_SPAWN_RATES := [6.0, 15.0, 35.0]
const EXPECTED_BACKGROUNDS := [&"ground", &"planetary", &"galactic"]

var _failures := 0


func _ready() -> void:
	var stage_catalog = StageCatalogScript.new()
	var ball_catalog = BallCatalogScript.new()
	var stages = stage_catalog.get_all_stages()

	_expect(stages.size() == 3, "The default run must contain exactly three stages.")
	for stage_index in range(mini(stages.size(), EXPECTED_CHAINS.size())):
		var stage = stages[stage_index]
		var expected_chain: Array = EXPECTED_CHAINS[stage_index]
		_expect(_matches_chain(stage.local_ball_levels, expected_chain), "Each stage must expose its exact ordered five-ball chain.")
		_expect(stage.local_ball_levels.size() == 5, "Each stage must expose exactly five local ball levels.")
		_expect(stage.base_global_level == expected_chain[0], "Stage base must equal the first chain entry.")
		_expect(stage.top_global_level == expected_chain[expected_chain.size() - 1], "Stage top must equal the final chain entry.")
		_expect(is_equal_approx(stage.spawn_rate, EXPECTED_SPAWN_RATES[stage_index]), "Spawn rate must come from the Stage resource seed.")
		_expect(is_equal_approx(stage.visual_radius_scale, 1.0), "Scale Shift presentation scale must remain the neutral data seed.")
		_expect(stage.background_id == EXPECTED_BACKGROUNDS[stage_index], "Background key must come from Stage data.")

	if stages.size() == 3:
		_expect(stages[0].top_global_level == stages[1].base_global_level, "Ground top must become Planetary base.")
		_expect(stages[1].top_global_level == stages[2].base_global_level, "Planetary top must become Galactic base.")

	var active_default_levels := PackedInt32Array()
	for stage in stages:
		for global_level in stage.local_ball_levels:
			if not active_default_levels.has(global_level):
				active_default_levels.append(global_level)

	_expect(ball_catalog.has_definition(7) and ball_catalog.has_definition(9), "Lv7 and Lv9 must remain available in BallCatalog.")
	_expect(not active_default_levels.has(7) and not active_default_levels.has(9), "Lv7 and Lv9 must remain inactive in the default run chain.")
	var final_ball = ball_catalog.get_definition(14)
	_expect(final_ball != null, "Lv14 must exist in BallCatalog.")
	if final_ball != null:
		_expect(final_ball.display_name == "Black Hole", "Lv14 must be the Black Hole final ball.")
		_expect(final_ball.visual_key == &"black_hole", "Lv14 must expose the Black Hole visual key.")

	if _failures == 0:
		print("S5_G1_VERIFIED chains=0-1-2-3-4|4-5-6-8-10|10-11-12-13-14 spawn=6-15-35")
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S5-G1 verification failed: %s" % message)


func _matches_chain(actual: PackedInt32Array, expected: Array) -> bool:
	if actual.size() != expected.size():
		return false
	for index in range(actual.size()):
		if actual[index] != expected[index]:
			return false
	return true
