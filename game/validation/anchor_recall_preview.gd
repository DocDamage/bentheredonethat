extends Node

var main: Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Armory")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.build_facility(4, "Haunted Mansion")
	for flag in [
		&"opening_complete", &"town_entered", &"mansion_entered", &"mansion_foyer_cleared",
		&"mansion_clock_examined", &"mansion_ledger_found", &"mansion_first_room_complete",
		&"mansion_archive_save_found", &"mansion_gallery_ambush_cleared", &"mansion_hour_hand_found",
		&"mansion_nursery_ambush_cleared", &"mansion_minute_hand_found", &"mansion_ballroom_open",
		&"mansion_archive_boss_defeated", &"haunted_mansion_scenario_complete", &"first_universe_stabilized",
	]:
		CampaignState.story_flags[flag] = true
	CampaignState.add_item(&"anchor_core", 1, false)
	CampaignState.sync_quests()
	CampaignState.craft_invention(&"continuity_kite")
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	main._place_player(Vector2i(4, 38))
	main.get_node("CampaignMenu").open_menu(&"recall")
