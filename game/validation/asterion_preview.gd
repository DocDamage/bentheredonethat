extends Node

var main: Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
	for flag in [&"opening_complete", &"town_entered", &"mansion_entered", &"mansion_foyer_cleared", &"mansion_clock_examined", &"mansion_ledger_found", &"mansion_first_room_complete", &"mansion_archive_save_found", &"mansion_gallery_ambush_cleared", &"mansion_hour_hand_found", &"mansion_nursery_ambush_cleared", &"mansion_minute_hand_found", &"mansion_ballroom_open"]:
		CampaignState.story_flags[flag] = true
	CampaignState.build_facility(4, "Observatory")
	CampaignState.story_flags[&"asterion_dock_cleared"] = true
	CampaignState.story_flags[&"asterion_astronaut_met"] = true
	CampaignState.discover_recruit(&"astronaut")
	CampaignState.sync_quests()
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	show_town_anchor()


func show_room(index: int) -> void:
	var cells := [Vector2i(40, 37), Vector2i(50, 37), Vector2i(60, 37), Vector2i(50, 47), Vector2i(60, 47)]
	main._place_player(cells[clampi(index, 0, cells.size() - 1)])


func show_battle() -> void:
	main.get_node("CampaignBattle").begin(&"asterion_mother_computer", 777)


func show_town_anchor() -> void:
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	if battle.active:
		battle._leave_battle(true)
	main._place_player(main.TOWN_ORIGIN + Vector2i(24, 18))
