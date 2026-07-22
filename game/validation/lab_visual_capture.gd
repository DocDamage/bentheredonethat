extends Node


var main: Node


func _ready() -> void:
	CampaignState.reset_new_game()
	# Mark a campaign as underway using the same deterministic setup as the room
	# capture harnesses. This bypasses title/opening presentation without awaiting
	# a Dialogic timeline that can remain paused in an unattended validation run.
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Haunted Mansion")
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	main._place_player(Vector2i(10, 9))
	await _settle()
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/laboratory-layout-rebuilt.png")
	if error != OK:
		push_error("Could not save laboratory capture: %s" % error_string(error))
	else:
		print("LAB_VISUAL_CAPTURE_OK exact_islands=true")
	get_tree().quit()


func _settle() -> void:
	for _frame in range(8):
		await get_tree().process_frame
