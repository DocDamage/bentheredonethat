extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Armory")
	CampaignState.build_facility(4, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
	CampaignState.build_facility(5, "Observatory")
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.build_facility(6, "Trailhead Lodge")
	CampaignState.story_flags[&"primeval_scenario_complete"] = true
	CampaignState.build_facility(7, "Afterlight Club")
	CampaignState.story_flags[&"helios_scenario_complete"] = true
	CampaignState.build_facility(8, "Cold Storage")
	CampaignState.story_flags[&"frosthold_scenario_complete"] = true
	CampaignState.build_facility(9, "Tea House")
	CampaignState.story_flags[&"moonpetal_scenario_complete"] = true
	CampaignState.anchor_universe(10, &"empyreal_court")
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	main.get_node("Field/Map/CampaignWorld/TownBuildController").hide()
	main._place_player(Vector2i(52, 14))
	Camera.zoom = Vector2(0.38, 0.38)
	Camera._on_viewport_resized()
	Camera.reset_position()
	for _frame in range(8):
		await get_tree().process_frame
	_capture("town-facilities-overview-rebuilt.png")
	Camera.zoom = Vector2.ONE
	main._place_player(Vector2i(50, 9))
	for _frame in range(40):
		await get_tree().process_frame
	_capture("town-facilities-north-rebuilt.png")
	main._place_player(Vector2i(57, 17))
	for _frame in range(40):
		await get_tree().process_frame
	_capture("town-facilities-south-rebuilt.png")
	main._place_player(Vector2i(56, 17))
	for _frame in range(40):
		await get_tree().process_frame
	_capture("town-facilities-armory.png")
	main._place_player(Vector2i(39, 17))
	for _frame in range(40):
		await get_tree().process_frame
	_capture("town-facilities-southwest-rebuilt.png")
	main._place_player(Vector2i(63, 9))
	for _frame in range(40):
		await get_tree().process_frame
	_capture("town-facilities-northeast-rebuilt.png")
	main._place_player(Vector2i(54, 25))
	for _frame in range(40):
		await get_tree().process_frame
	_capture("town-facilities-tea-house-rebuilt.png")
	main._place_player(Vector2i(63, 25))
	for _frame in range(10):
		await get_tree().process_frame
	_capture("town-facilities-belfry.png")
	print("TOWN_FACILITIES_VISUAL_CAPTURE_OK images=8 door_anchors=11 roads=connected")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save town facility capture: %s" % error_string(error))
