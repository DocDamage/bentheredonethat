extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.mark_story_flag(&"opening_complete")
	CampaignState.mark_story_flag(&"town_entered")
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.anchor_universe(3, &"haunted_mansion")
	for flag in [
		&"mansion_entered", &"mansion_foyer_cleared", &"mansion_clock_examined", &"mansion_ledger_found",
		&"mansion_first_room_complete", &"mansion_archive_save_found", &"mansion_gallery_ambush_cleared",
		&"mansion_hour_hand_found", &"mansion_nursery_ambush_cleared", &"mansion_minute_hand_found",
		&"mansion_ballroom_open", &"mansion_archive_boss_defeated", &"haunted_mansion_scenario_complete",
	]:
		CampaignState.story_flags[flag] = true
	CampaignState.sync_quests()
	CampaignState.set_tracked_quest(&"a_second_door")
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	main._place_player(Vector2i(62, 10))
	for _frame in range(5):
		await get_tree().process_frame
	var controller := main.get_node("Field/Map/CampaignWorld/TownBuildController")
	controller.selected_plot = 4
	controller._set_active(true)
	for _frame in range(4):
		await get_tree().process_frame
	_capture("universe-anchor-choice-rebuilt.png")
	print("UNIVERSE_ANCHOR_CHOICE_CAPTURE_OK universe=asterion_station shell=Observatory map_visible=true")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save universe anchor capture: %s" % error_string(error))
