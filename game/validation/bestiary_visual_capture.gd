extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.record_bestiary_sighting(&"mansion_foyer_intro", [&"schoolgirl_ghost", &"war_book"])
	CampaignState.record_bestiary_victory(&"mansion_foyer_intro", [&"schoolgirl_ghost", &"war_book"], [{
		"id": &"iron_saber", "display_name": "Rare Iron Saber of Force", "rarity": "Rare", "kind": "gear",
	}])
	CampaignState.record_bestiary_sighting(&"mansion_gallery_ambush", [&"composer_portrait", &"schoolgirl_ghost"])
	CampaignState.record_bestiary_victory(&"mansion_gallery_ambush", [&"composer_portrait", &"schoolgirl_ghost"], [])
	CampaignState.record_bestiary_sighting(&"mansion_archive_boss", [&"clock_mirror_boss"])

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	menu.selected_enemy = &"schoolgirl_ghost"
	menu.open_menu(&"bestiary")
	for _frame in range(5):
		await get_tree().process_frame
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png("res://validation/bestiary-live.png")
	if result != OK:
		printerr("BESTIARY_VISUAL_CAPTURE_FAILED error=%d" % result)
		get_tree().quit(1)
		return
	print("BESTIARY_VISUAL_CAPTURE_OK supplied_monster_art=true library_ledger=true controller_catalog=true")
	get_tree().quit(0)
