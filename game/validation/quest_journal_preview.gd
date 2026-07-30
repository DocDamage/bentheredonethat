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
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.mark_story_flag(&"mansion_entered")
	CampaignState.mark_story_flag(&"mansion_foyer_cleared")
	CampaignState.mark_story_flag(&"mansion_clock_examined")

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	menu.open_menu(&"quests")
