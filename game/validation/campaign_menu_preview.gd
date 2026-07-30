extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.duckets = 284
	CampaignState.character_progress[&"ben"]["level"] = 3
	CampaignState.character_progress[&"ben"]["skill_points"] = 2
	CampaignState.character_progress[&"fighter"]["level"] = 2
	CampaignState.character_progress[&"fighter"]["skill_points"] = 1
	var examples := [
		["preview-saber", "Rare Iron Saber of Force", "weapon", "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png", "Rare", "#58a6ff", "attack", 6],
		["preview-cap", "Mourning Cap of Celerity", "head", "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon9.png", "Uncommon", "#62d67b", "speed", 3],
		["preview-coat", "Dusty Waistcoat of Resolve", "body", "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon20.png", "Common", "#d8d3c5", "defense", 4],
		["preview-gloves", "Moth-Eaten Gloves of Sparks", "hands", "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon31.png", "Rare", "#58a6ff", "magic", 5],
		["preview-clock", "Epic Anchored Chronometer of Borrowed Time", "accessory", "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon15.png", "Epic", "#bd77ff", "speed", 7],
		["preview-key", "House-Key Fragment of Continuity", "charm", "res://game_assets/items/resources_items_artifacts_loot/PNG/Transperent/Icon42.png", "Rare", "#58a6ff", "spirit", 5],
	]
	for data in examples:
		var item := {
			"instance_id": data[0], "display_name": data[1], "base_name": data[1], "slot": data[2], "icon": data[3],
			"rarity": data[4], "rarity_color": data[5], "modifiers": [{"stat": data[6], "value": data[7], "name": "Preview"}],
			"kind": "gear", "source_pack": "armory" if data[2] == "weapon" else "resources_items_artifacts_loot",
		}
		if data[2] == "accessory":
			item["granted_action"] = &"borrowed_second"
		CampaignState.loot_inventory.append(item)
	CampaignState.equip_loot(&"ben", "preview-saber")

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var menu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	menu.open_menu()
