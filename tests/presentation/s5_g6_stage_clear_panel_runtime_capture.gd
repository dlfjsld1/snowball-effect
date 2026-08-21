extends Node

const SAMPLE_FRAMES := 120

@onready var panel: StageClearPanel = $StageClearPanel


func _ready() -> void:
	panel.show_stage_clear({
		"stage_index": 0,
		"stage_display_name": "Ground",
		"stage_score": 400000000.0,
		"run_score": 525000000.0,
		"outcome": &"CLEARED",
		"is_final_stage": false,
	}, 1)
	await get_tree().create_timer(0.3).timeout
	var sample_started_usec := Time.get_ticks_usec()
	var previous_frame_usec := sample_started_usec
	var maximum_frame_usec := 0
	for _frame_index in SAMPLE_FRAMES:
		await get_tree().process_frame
		var current_frame_usec := Time.get_ticks_usec()
		maximum_frame_usec = maxi(maximum_frame_usec, current_frame_usec - previous_frame_usec)
		previous_frame_usec = current_frame_usec
	var sample_elapsed_usec := maxi(Time.get_ticks_usec() - sample_started_usec, 1)
	var average_fps := float(SAMPLE_FRAMES) * 1000000.0 / float(sample_elapsed_usec)
	var maximum_frame_msec := float(maximum_frame_usec) / 1000.0
	await RenderingServer.frame_post_draw
	var capture_path := "user://s5_g6_stage_clear_panel_capture.png"
	var error := get_viewport().get_texture().get_image().save_png(capture_path)
	print("S5_G6_CAPTURE path=%s error=%d frames=%d avg_fps=%.1f max_frame_ms=%.2f" % [ProjectSettings.globalize_path(capture_path), error, SAMPLE_FRAMES, average_fps, maximum_frame_msec])
	get_tree().quit(error)
