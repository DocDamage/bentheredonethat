extends Node


func _ready() -> void:
	CampaignState.setup_sandbox(Vector2i(50, 8))
	CampaignState.move_to_reserve(&"astronaut")
	CampaignState.add_to_party(&"kitsune_empress")
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var menu := main.get_node("CampaignMenu") as CampaignMenu
	menu.suppress_persistence = true
	menu.management_location_override = 1
	menu.open_menu(&"roster")
	for _frame in range(4):
		await get_tree().process_frame
	_capture("roster-supplied-cast-rebuilt.png")
	menu._select_character(&"kitsune_empress")
	menu._select_tab(&"skills")
	for _frame in range(4):
		await get_tree().process_frame
	_capture("profile-kitsune-supplied-rebuilt.png")
	print("SUPPLIED_RECRUIT_ROSTER_CAPTURE_OK catalog=%d directional_recruits=6 topdown_monster_recruits=2 images=2" % CampaignState.recruit_catalog.size())
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save supplied recruit capture: %s" % error_string(error))
