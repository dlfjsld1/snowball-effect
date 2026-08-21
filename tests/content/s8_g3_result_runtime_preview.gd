extends Node

const ResultPanelScene := preload("res://scenes/ui/result_panel.tscn")


func _ready() -> void:
	var result_panel: ResultPanel = ResultPanelScene.instantiate()
	add_child(result_panel)
	await get_tree().process_frame
	result_panel.show_result({
		"run_score": 1.23e12,
		"optional_stats": {
			"merge_count": 148,
			"run_time_seconds": 766.0,
		},
	})
