extends Node

const BallCatalogScript = preload("res://scripts/data/ball_catalog.gd")
const BallDefinition = preload("res://scripts/data/ball_definition.gd")

const EXPECTED_NAMES := [
	"Snowflake",
	"Snowball",
	"Big Snowball",
	"Giant Snowball",
	"Lunar Snowball",
	"Earth Snowball",
	"Solar Snowball",
	"Supernova Snowball",
	"Nebula Snowball",
	"Galaxy Snowball",
	"Black Hole",
	"Big Bang",
	"Universe",
	"Multiverse",
	"Omega Snowball",
]
const EXPECTED_SCORES := [1.0, 100.0, 10000.0, 1000000.0, 100000000.0, 50000000000.0, 10000000000000.0, 5000000000000000.0, 2.5e18, 1.25e21, 6.25e23, 3.125e26, 1.5625e29, 7.8125e31, 3.90625e34]
const EXPECTED_RADII := [4.0, 8.0, 16.0, 32.0, 64.0, 128.0, 256.0, 512.0, 1024.0, 2048.0, 4096.0, 8192.0, 16384.0, 32768.0, 65536.0]
const EXPECTED_MASSES := [1.0, 4.0, 16.0, 64.0, 256.0, 1024.0, 4096.0, 16384.0, 65536.0, 262144.0, 1048576.0, 4194304.0, 16777216.0, 67108864.0, 268435456.0]
const EXPECTED_VISUAL_KEYS := [&"snowflake", &"snowball", &"big_snowball", &"giant_snowball", &"lunar_snowball", &"earth_snowball", &"solar_snowball", &"supernova_snowball", &"nebula_snowball", &"galaxy_snowball", &"black_hole", &"big_bang", &"universe", &"multiverse", &"omega_snowball"]

var _failures := 0


func _ready() -> void:
	var catalog = BallCatalogScript.new()
	var late_game_probe = BallDefinition.new()
	late_game_probe.score_value = 1.0e36
	_expect(late_game_probe.score_value > 1.0e35, "Score data must retain the planned 1e36 late-game range.")

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
		_expect(not _has_property(definition, &"time_bonus"), "Time Bonus must remain StageDefinition data.")

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
