extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallDefinition = preload("res://scripts/data/ball_definition.gd")

const EXPECTED_NAMES := [
	"Snowflake",
	"Snowball",
	"Big Snowball",
	"Giant Snowball",
	"Moon",
	"Earth",
	"Sun",
	"Red Giant",
	"Supernova",
	"Nebula",
	"Galaxy",
	"Galaxy Cluster",
	"Quasar",
	"Event Horizon",
	"Black Hole",
]
const EXPECTED_SCORES := [1.0, 100.0, 10000.0, 1000000.0, 1.0e8, 5.0e10, 1.0e13, 1.0e15, 5.0e17, 1.0e21, 1.0e25, 1.0e30, 1.0e36, 1.0e43, 1.0e50]
const EXPECTED_RADII := [2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0, 256.0, 512.0, 1024.0, 2048.0, 4096.0, 8192.0, 16384.0, 32768.0]
const EXPECTED_MASSES := [1.0, 4.0, 16.0, 64.0, 256.0, 1024.0, 4096.0, 16384.0, 65536.0, 262144.0, 1048576.0, 4194304.0, 16777216.0, 67108864.0, 268435456.0]
const EXPECTED_VISUAL_KEYS := [&"snowflake", &"snowball", &"big_snowball", &"giant_snowball", &"moon", &"earth", &"sun", &"red_giant", &"supernova", &"nebula", &"galaxy", &"galaxy_cluster", &"quasar", &"event_horizon", &"black_hole"]
const EXPECTED_FX_TIERS := [0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4]
const EXPECTED_BASE_COLORS := [Color(0.95686275, 0.9882353, 1, 1), Color(0.91764706, 0.97254902, 1, 1), Color(0.44705882, 0.84705882, 1, 1), Color(0.22745098, 0.55294118, 1, 1), Color(0.78431373, 0.78823529, 0.84705882, 1), Color(0.15686275, 0.47058824, 0.83137255, 1), Color(1, 0.76078431, 0.27843137, 1), Color(0.85098039, 0.29411765, 0.21176471, 1), Color(1, 0.41960784, 0.20784314, 1), Color(0.70588235, 0.39215686, 0.78431373, 1), Color(0.30196078, 0.25882353, 0.72156863, 1), Color(0.50196078, 0.36078431, 1, 1), Color(0.90980392, 0.90196078, 1, 1), Color(0.22745098, 0.10196078, 0.38039216, 1), Color(0.0627451, 0.03529412, 0.12156863, 1)]

var _failures := 0


func _ready() -> void:
	var catalog = BallCatalogScript.new()
	var late_game_probe = BallDefinition.new()
	late_game_probe.score_value = 1.0e50
	_expect(late_game_probe.score_value > 1.0e49, "Score data must retain the planned 1e50 late-game range.")

	for global_level in range(EXPECTED_NAMES.size()):
		var definition = catalog.get_definition(global_level)
		_expect(definition != null, "Each initial global level must load from the catalog.")
		if definition == null:
			continue
		_expect(definition.global_level == global_level, "Definition global level must match its catalog index.")
		_expect(definition.display_name == EXPECTED_NAMES[global_level], "Definition display name must match the initial seed table.")
		_expect(is_equal_approx(definition.score_value, EXPECTED_SCORES[global_level]), "Definition base score must match the initial seed table.")
		_expect(is_equal_approx(definition.radius, EXPECTED_RADII[global_level]), "Definition radius must match its balance data.")
		_expect(is_equal_approx(definition.mass, EXPECTED_MASSES[global_level]), "Definition mass must match its balance data.")
		_expect(definition.visual_key == EXPECTED_VISUAL_KEYS[global_level], "Definition visual key must match its resource data.")
		_expect(definition.fx_tier == EXPECTED_FX_TIERS[global_level], "Definition FX tier must match its documented event tier.")
		_expect(definition.base_color.is_equal_approx(EXPECTED_BASE_COLORS[global_level]), "Definition base color must match its documented color seed.")
		_expect(not _has_property(definition, &"time_bonus"), "Time Bonus must remain StageDefinition data.")
		_expect(not _has_property(definition, &"radius_scale"), "Visual radius scaling must remain StageDefinition data.")

	_expect(not catalog.has_definition(-1), "Negative global levels must not resolve.")
	_expect(not catalog.has_definition(EXPECTED_NAMES.size()), "Undefined global levels must not resolve.")
	_expect(catalog.get_all_definitions().size() == EXPECTED_NAMES.size(), "Catalog must expose exactly the initial fifteen definitions.")

	if _failures == 0:
		print("S2_G1_VERIFIED definitions=15 levels=0-14 time_bonus=absent")
	get_tree().quit(_failures)


func _has_property(instance: Object, property_name: StringName) -> bool:
	for property_info in instance.get_property_list():
		if property_info.name == property_name:
			return true
	return false


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S2-G1 verification failed: %s" % message)
