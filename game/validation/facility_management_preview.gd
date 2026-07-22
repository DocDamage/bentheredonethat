extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_foyer_cleared"] = true
	CampaignState.duckets = 184
	CampaignState.owned_inventions.append(&"serving_automaton")
	CampaignState.assign_to_facility(&"fighter", "Cafe")
	CampaignState.start_facility_job("Cafe", &"cafe_founders_supper", true)

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	menu.management_location_override = 1
	menu.open_menu(&"facilities")
