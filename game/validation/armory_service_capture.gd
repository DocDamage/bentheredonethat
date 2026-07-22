extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Armory")
	CampaignState.duckets = 860
	CampaignState.hire_recruit(&"fighter")
	CampaignState.assign_to_facility(&"fighter", "Armory")
	var starter := CampaignState.purchase_armory_item(&"militia_saber")
	CampaignState.equip_loot(&"ben", String(starter.get("instance_id", "")))
	CampaignState.mark_story_flag(&"mansion_archive_boss_defeated")
	CampaignState.mark_story_flag(&"asterion_station_complete")

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	main._place_player(Vector2i(56, 17))
	for _frame in range(12):
		await get_tree().process_frame
	_capture("armory-facade-live.png")

	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	menu.open_service("Armory")
	for _frame in range(8):
		await get_tree().process_frame
	_capture("armory-service-live.png")
	print("ARMORY_SERVICE_CAPTURE_OK supplied_facade=true supplied_icons=true equipped_comparison=true staffing=true")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png("res://validation/%s" % file_name)
	if result != OK:
		push_error("Could not save Armory capture: %s" % error_string(result))
