extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	var main: Node = load("res://src/main.tscn").instantiate()
	add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	main.get_node("CampaignTitleScreen").choose_mode(&"new")
	for _frame in range(90):
		await get_tree().process_frame
	_capture("opening-in-world-rebuilt.png")
	await Dialogic.end_timeline(true)
	for _frame in range(180):
		await get_tree().process_frame
	_capture("opening-ready-to-play-rebuilt.png")
	print("OPENING_VISUAL_CAPTURE_OK images=2")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save opening capture: %s" % error_string(error))
