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
	for flag in [&"opening_complete", &"town_entered", &"mansion_entered", &"mansion_foyer_cleared", &"mansion_clock_examined", &"mansion_ledger_found", &"mansion_first_room_complete", &"mansion_archive_save_found", &"mansion_gallery_ambush_cleared", &"mansion_hour_hand_found", &"mansion_nursery_ambush_cleared", &"mansion_minute_hand_found", &"mansion_ballroom_open"]:
		CampaignState.story_flags[flag] = true
	CampaignState.sync_quests()
	CampaignState.tracked_quest = &"the_house_keeps_time"
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(4):
		await get_tree().process_frame
	show_room("gallery")


func show_room(room_name: String) -> void:
	var cells := {
		"foyer": Vector2i(4, 38),
		"archive": Vector2i(14, 37),
		"gallery": Vector2i(4, 47),
		"nursery": Vector2i(14, 47),
		"ballroom": Vector2i(23, 43),
	}
	main._place_player(cells.get(room_name, cells["gallery"]))
