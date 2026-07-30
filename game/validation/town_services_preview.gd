extends Node

var main: Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.duckets = 240
	CampaignState.hire_recruit(&"fighter")
	CampaignState.assign_to_facility(&"fighter", "Cafe")
	CampaignState.loot_inventory.append({
		"instance_id": "preview-saber", "id": &"iron_saber", "display_name": "Rare Iron Saber of Celerity",
		"slot": "weapon", "rarity": "Rare", "rarity_color": "#58a6ff", "modifiers": [{"stat": "speed", "value": 4}],
		"kind": "gear", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png",
	})
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	main._place_player(Vector2i(45, 9))
	show_service("Cafe")


func show_service(facility_name: String) -> void:
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	if menu.visible:
		menu.close_menu()
	menu.open_service(facility_name)
