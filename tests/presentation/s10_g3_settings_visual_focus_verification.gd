extends Node

const PANEL_SCENE := preload("res://scenes/ui/settings_panel.tscn")
const SNAPSHOT := {
	"master_volume": 100,
	"bgm_volume": 100,
	"sfx_volume": 100,
	"value_popups_enabled": true,
}

var _failures := 0


func _ready() -> void:
	var panel = PANEL_SCENE.instantiate()
	add_child(panel)
	await get_tree().process_frame

	_expect(panel.show_for_session(1, SNAPSHOT, &"title"), "The visual panel must open from the title return view.")
	var content: Control = panel.get_node("Center/Panel/Margin/Content")
	var shell: Control = panel.get_node("Center/Panel")
	_expect(shell.custom_minimum_size.x <= 1280.0 and shell.custom_minimum_size.y <= 720.0, "The panel minimum size must fit a 1280x720 viewport.")
	_expect(content.get_combined_minimum_size().x <= shell.custom_minimum_size.x - 84.0, "The content width must remain inside the panel margins.")
	_expect(content.get_combined_minimum_size().y <= shell.custom_minimum_size.y - 68.0, "The content height must remain inside the panel margins.")
	_expect(panel.volume_minus_button.focus_neighbor_top == NodePath("../../Actions/CloseButton"), "Master decrement must wrap to Close on upward navigation.")
	_expect(panel.volume_minus_button.focus_neighbor_bottom == NodePath("../../BgmRow/BgmMinusButton"), "Master decrement must lead to BGM decrement.")
	_expect(panel.bgm_minus_button.focus_neighbor_bottom == NodePath("../../SfxRow/SfxMinusButton"), "BGM decrement must lead to SFX decrement.")
	_expect(panel.sfx_minus_button.focus_neighbor_bottom == NodePath("../../ValuePopupsRow/ValuePopupsToggle"), "SFX decrement must lead to Value Popups.")
	_expect(panel.value_popups_toggle.focus_neighbor_bottom == NodePath("../Actions/ApplyButton"), "Value Popups must lead to Apply.")
	_expect(panel.apply_button.focus_neighbor_bottom == NodePath("../CloseButton"), "Apply must lead to Close.")
	_expect(panel.close_button.focus_neighbor_bottom == NodePath("../../VolumeRow/VolumeMinusButton"), "Close must wrap back to Master decrement.")
	_expect(get_viewport().gui_get_focus_owner() == panel.volume_minus_button, "Opening the panel must focus Master decrement.")
	var close_requests := 0
	panel.settings_close_requested.connect(func(_session_id: int) -> void: close_requests += 1)
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	panel._input(escape)
	_expect(close_requests == 1, "Escape must request the same Close path exactly once.")
	panel._input(escape)
	_expect(close_requests == 1, "Repeated Escape before close acceptance must be ignored.")

	if _failures == 0:
		print("S10_G3_SETTINGS_VISUAL_FOCUS_VERIFIED viewport_fit=true focus_cycle=true entry_focus=true escape_close=true")
	await get_tree().create_timer(0.2).timeout
	get_tree().quit(_failures)


func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failures += 1
	push_error("S10-G3 settings visual/focus verification failed: %s" % message)
