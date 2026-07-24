extends Node

const TEST_SAVE := "user://town_services_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.duckets = 240
	CampaignState.hire_recruit(&"fighter")
	if not CampaignState.assign_to_facility(&"fighter", "Cafe"):
		_fail("A hired specialist could not staff the Café service")
		return
	if CampaignState.service_item_price("Cafe", &"tonic") != 16:
		_fail("Staffing did not apply the promised 15-percent Café discount")
		return
	var tonic_before := int(CampaignState.inventory.get(&"tonic", 0))
	var duckets_before := CampaignState.duckets
	if not CampaignState.purchase_service_item("Cafe", &"tonic"):
		_fail("The Café could not sell an item from its own stock")
		return
	if CampaignState.duckets != duckets_before - 16 or int(CampaignState.inventory.get(&"tonic", 0)) != tonic_before + 1:
		_fail("Café purchase did not exchange the correct Duckets and item quantity")
		return
	if CampaignState.purchase_service_item("Cafe", &"phoenix_tonic"):
		_fail("A facility sold stock assigned to a different service")
		return

	var equipped := {
		"instance_id": "service-equipped", "id": &"test_saber", "display_name": "Rare Test Saber",
		"slot": "weapon", "rarity": "Rare", "rarity_color": "#58a6ff", "modifiers": [{"stat": "attack", "value": 4}],
		"kind": "gear", "icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png",
	}
	var spare := equipped.duplicate(true)
	spare["instance_id"] = "service-spare"
	spare["display_name"] = "Rare Spare Saber"
	CampaignState.loot_inventory.append(equipped)
	CampaignState.loot_inventory.append(spare)
	CampaignState.equip_loot(&"ben", "service-equipped")
	if CampaignState.sell_loot("service-equipped") != 0:
		_fail("The shop sold gear that was still equipped")
		return
	var sale_value := CampaignState.loot_sell_value("service-spare")
	duckets_before = CampaignState.duckets
	if CampaignState.sell_loot("service-spare") != sale_value or CampaignState.duckets != duckets_before + sale_value:
		_fail("Gear buyback did not remove unequipped loot for its rarity/modifier value")
		return

	CampaignState.release_facility_worker("Cafe")
	CampaignState.assign_to_facility(&"fighter", "Clinic")
	if CampaignState.clinic_service_cost() != 17:
		_fail("Clinic staffing did not discount full treatment")
		return
	CampaignState.character_progress[&"ben"]["hp"] = 1
	CampaignState.character_progress[&"ben"]["mp"] = 0
	duckets_before = CampaignState.duckets
	if not CampaignState.use_clinic_service():
		_fail("The Clinic refused an affordable full treatment")
		return
	if int(CampaignState.character_progress[&"ben"]["hp"]) != 140 or int(CampaignState.character_progress[&"ben"]["mp"]) != 36 or CampaignState.duckets != duckets_before - 17:
		_fail("Clinic treatment did not fully restore the party for the displayed cost")
		return
	var records := CampaignState.library_record_summary()
	if int(records.get("quests_discovered", 0)) <= 0 or int(records.get("recruits", 0)) != 3:
		_fail("The Library could not summarize persistent company records")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var world := main.get_node("Field/Map/CampaignWorld")
	for service_data in [["CafeService", Vector2i(45, 8)], ["LibraryService", Vector2i(56, 8)], ["ClinicService", Vector2i(45, 16)]]:
		var service := world.get_node_or_null(service_data[0]) as TownFacilityInteraction
		if not service or Gameboard.pixel_to_cell(service.position) != service_data[1] or not service.get_node("ServiceMarker").texture:
			_fail("Built facility service was missing, misplaced, or not marked with supplied UI art: " + service_data[0])
			return

	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	var cafe_service: TownFacilityInteraction = world.get_node("CafeService")
	cafe_service.run()
	await get_tree().process_frame
	if not menu.visible or menu.selected_tab != &"services" or menu.selected_service != "Cafe" or not menu.find_child("Buy_tonic", true, false):
		_fail("Interacting at the Café doorway did not open its controller-ready service page")
		return
	menu.close_menu()
	await get_tree().process_frame
	if Cutscene.is_cutscene_in_progress():
		_fail("Closing a facility service did not return control to the JRPG field")
		return

	menu.open_service("Clinic")
	var treatment := menu.find_child("ClinicFullTreatment", true, false) as Button
	if not treatment:
		_fail("Clinic service UI did not expose full treatment")
		return
	CampaignState.character_progress[&"ben"]["hp"] = 2
	CampaignState.character_progress[&"ben"]["mp"] = 1
	treatment.pressed.emit()
	await get_tree().process_frame
	if int(CampaignState.character_progress[&"ben"]["hp"]) != 140 or int(CampaignState.character_progress[&"ben"]["mp"]) != 36:
		_fail("Clinic UI action was not connected to treatment")
		return
	menu.close_menu()
	menu.open_service("Library")
	var archive := menu.find_child("LibraryArchiveSave", true, false) as Button
	if not archive:
		_fail("Library service UI did not expose record archival")
		return
	archive.pressed.emit()
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"library_records_archived", false):
		_fail("Library record action did not update persistent company state")
		return
	if StringName(CampaignState.quest_state(&"open_for_business").get("status", "")) != &"complete":
		_fail("Using all three town services did not complete their guided side quest")
		return

	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Town service state could not be saved")
		return
	var expected_purchases := int(CampaignState.story_flags.get(&"town_service_purchase_count", 0))
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or int(CampaignState.story_flags.get(&"town_service_purchase_count", 0)) != expected_purchases or not CampaignState.story_flags.get(&"library_records_archived", false):
		_fail("Town purchases, services, or Library records did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("TOWN_SERVICES_SMOKE_OK doors=cafe+library+clinic ui=provided_assets buy=true sell=unequipped_only staffing=15pct clinic=revive+restore library=records+save persistence=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("TOWN_SERVICES_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
