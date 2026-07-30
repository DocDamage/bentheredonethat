extends Node

const TEST_SAVE := "user://armory_service_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Armory")
	CampaignState.duckets = 1000

	var opening_stock := CampaignState.armory_stock()
	if opening_stock.size() != 6:
		_fail("The founding Armory did not begin with six conventional equipment choices")
		return
	var stocked_slots := {}
	for item in opening_stock:
		stocked_slots[StringName(item.get("slot", ""))] = true
	for slot in CampaignState.EQUIPMENT_SLOTS:
		if not stocked_slots.has(slot):
			_fail("The Armory had no opening equipment for the %s slot" % slot)
			return
	if CampaignState.visible_facility_jobs("Armory").size() != 1:
		_fail("The Armory's information-gated refit job was visible before its field discovery")
		return

	CampaignState.hire_recruit(&"fighter")
	if not CampaignState.assign_to_facility(&"fighter", "Armory"):
		_fail("A hired specialist could not staff the Armory")
		return
	if CampaignState.armory_item_price(&"militia_saber") != 62:
		_fail("Armory staffing did not apply the promised 15-percent purchase discount")
		return

	var first_saber := CampaignState.purchase_armory_item(&"militia_saber")
	if first_saber.is_empty() or CampaignState.duckets != 938 or String(first_saber.get("source_pack", "")) != "armory":
		_fail("An Armory purchase did not create persistent supplied-asset gear at the displayed price")
		return
	var first_id := String(first_saber.get("instance_id", ""))
	if not CampaignState.equip_loot(&"ben", first_id):
		_fail("Purchased Armory gear could not be equipped from the conventional equipment system")
		return
	CampaignState.mark_story_flag(&"mansion_archive_boss_defeated")
	if CampaignState.armory_stock().size() != 8:
		_fail("Mansion progression did not unlock two deterministic Armory sidegrades")
		return
	var stronger := CampaignState.ARMORY_STOCK[&"tempered_saber"]
	var comparison := CampaignState.gear_comparison(stronger, &"ben")
	if int(comparison.get(&"attack", 0)) != 3 or int(comparison.get(&"speed", 0)) != 2:
		_fail("Live stat comparison did not measure a weapon against Ben's equipped weapon")
		return
	var timekeeper := CampaignState.purchase_armory_item(&"timekeeper_charm")
	if timekeeper.is_empty() or not CampaignState.equip_loot(&"ben", String(timekeeper.get("instance_id", ""))):
		_fail("The Mansion resistance sidegrade could not be purchased and equipped")
		return
	var ben_actor := CampaignCombatDatabase.party_actor(&"ben", CampaignState.character_progress[&"ben"])
	if not is_equal_approx(float(ben_actor.get("element_rates", {}).get(&"time", 1.0)), 0.75):
		_fail("Equipped resistance gear did not reach the battle actor's elemental damage rates")
		return
	CampaignState.mark_story_flag(&"asterion_station_complete")
	if CampaignState.armory_stock().size() != 10:
		_fail("Asterion progression did not unlock two Armory sidegrades")
		return
	CampaignState.mark_story_flag(&"primeval_scenario_complete")
	CampaignState.mark_story_flag(&"helios_scenario_complete")
	CampaignState.mark_story_flag(&"frosthold_scenario_complete")
	CampaignState.mark_story_flag(&"moonpetal_scenario_complete")
	CampaignState.mark_story_flag(&"empyreal_scenario_complete")
	if CampaignState.armory_stock().size() != 20:
		_fail("Every completed universe did not add its pair of deterministic Armory sidegrades")
		return
	CampaignState.mark_story_flag(&"mansion_foyer_cleared")
	if CampaignState.visible_facility_jobs("Armory").size() != 2:
		_fail("Discovered field information did not reveal the Armory refit assignment")
		return

	var spare_saber := CampaignState.purchase_armory_item(&"militia_saber")
	var spare_id := String(spare_saber.get("instance_id", ""))
	if spare_id.is_empty() or spare_id == first_id:
		_fail("Repeated shop purchases did not receive unique equipment instance IDs")
		return
	if CampaignState.sell_loot(first_id) != 0:
		_fail("The Armory could sell gear while it was still equipped")
		return
	CampaignState.add_item(&"anchor_dust", 1, false)
	var reforge_cost := CampaignState.armory_reforge_cost(spare_id)
	var before_reforge_duckets := CampaignState.duckets
	var reforge := CampaignState.reforge_loot(spare_id, 0)
	if reforge.is_empty() or int(reforge.get("modifier_index", -1)) != 0 or int(reforge.get("bonus", 0)) <= 0 or CampaignState.duckets != before_reforge_duckets - reforge_cost:
		_fail("The Armory could not spend materials to permanently reforge one modifier")
		return
	if not CampaignState.reforge_loot(spare_id, 0).is_empty():
		_fail("An item could receive more than one modifier reforge")
		return
	var sale_value := CampaignState.loot_sell_value(spare_id)
	var before_sale := CampaignState.duckets
	if CampaignState.sell_loot(spare_id) != sale_value or CampaignState.duckets != before_sale + sale_value:
		_fail("The Armory could not buy back an unequipped duplicate")
		return
	var salvage_saber := CampaignState.purchase_armory_item(&"militia_saber")
	var salvage_id := String(salvage_saber.get("instance_id", ""))
	var before_salvage_dust := int(CampaignState.inventory.get(&"anchor_dust", 0))
	var salvage := CampaignState.salvage_loot(salvage_id)
	if salvage.is_empty() or not CampaignState.loot_by_instance(salvage_id).is_empty() or int(CampaignState.inventory.get(&"anchor_dust", 0)) <= before_salvage_dust:
		_fail("The Armory could not safely convert unequipped gear into reusable materials")
		return
	var persistent_reforge_saber := CampaignState.purchase_armory_item(&"militia_saber")
	var persistent_reforge_id := String(persistent_reforge_saber.get("instance_id", ""))
	if CampaignState.reforge_loot(persistent_reforge_id, 0).is_empty():
		_fail("A salvaged material could not be reinvested into a fresh one-modifier reforge")
		return
	CampaignState.add_item(&"anchor_dust", 1, false)

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var world := main.get_node("Field/Map/CampaignWorld")
	var armory_service := world.get_node_or_null("ArmoryService") as TownFacilityInteraction
	if not armory_service or Gameboard.pixel_to_cell(armory_service.position) != Vector2i(56, 16) or not armory_service.get_node("ServiceMarker").texture:
		_fail("The Armory service was missing, misplaced, or lacked its supplied UI marker")
		return
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	armory_service.run()
	await get_tree().process_frame
	var compare_button := menu.find_child("BuyGear_tempered_saber", true, false) as Button
	var resistance_button := menu.find_child("BuyGear_timekeeper_charm", true, false) as Button
	if not menu.visible or menu.selected_tab != &"services" or menu.selected_service != "Armory" or not compare_button or not resistance_button:
		_fail("The Armory doorway did not open its controller-ready equipment shop")
		return
	if "VS EQUIPPED: ATK +3" not in compare_button.text:
		_fail("The shop UI did not show the live equipped-stat comparison")
		return
	if "TIME RESIST 25%" not in resistance_button.text:
		_fail("The shop UI did not state the sidegrade's elemental counterplay")
		return
	var technical_lens := CampaignState.purchase_armory_item(&"watchmakers_lens")
	if technical_lens.is_empty() or CampaignState.item_is_compatible_with_character(&"fighter", technical_lens) or CampaignState.equip_loot(&"fighter", String(technical_lens.get("instance_id", ""))):
		_fail("Role affinities did not prevent a martial recruit from equipping technical gear")
		return
	var field_cap := CampaignState.purchase_armory_item(&"copper_watch_cap")
	if field_cap.is_empty() or not CampaignState.equip_loot(&"fighter", String(field_cap.get("instance_id", ""))):
		_fail("Role affinities did not preserve compatible field gear for an inactive recruit")
		return
	var buy_button := menu.find_child("BuyGear_militia_saber", true, false) as Button
	var before_ui_purchase := CampaignState.loot_inventory.size()
	buy_button.pressed.emit()
	await get_tree().process_frame
	if CampaignState.loot_inventory.size() != before_ui_purchase + 1:
		_fail("The visible Armory purchase button was not connected to the economy")
		return
	var ui_item: Dictionary = CampaignState.loot_inventory.back()
	var ui_item_id := String(ui_item.get("instance_id", ""))
	var sell_button := menu.find_child("Sell_%s" % ui_item_id, true, false) as Button
	var salvage_button := menu.find_child("Salvage_%s" % ui_item_id, true, false) as Button
	var reforge_button := menu.find_child("Reforge_%s_0" % ui_item_id, true, false) as Button
	var equipped_sell := menu.find_child("Sell_%s" % first_id, true, false) as Button
	if not sell_button or sell_button.disabled or not salvage_button or salvage_button.disabled or not reforge_button or not equipped_sell or not equipped_sell.disabled:
		_fail("The shop UI did not expose safe sell, salvage, and reforge choices")
		return
	menu.selected_character = &"fighter"
	menu.open_menu(&"equipment")
	await get_tree().process_frame
	var unequip_all := menu.find_child("UnequipInactiveGear", true, false) as Button
	if not unequip_all or unequip_all.disabled:
		_fail("The equipment page did not expose one-click cleanup for inactive gear")
		return
	unequip_all.pressed.emit()
	await get_tree().process_frame
	if not CampaignState.character_progress[&"fighter"].get("equipment", {}).is_empty():
		_fail("The inactive equipment cleanup did not release every reserved or staffed item")
		return

	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Armory inventory and equipment state could not be saved")
		return
	var expected_duckets := CampaignState.duckets
	var expected_purchase_count := int(CampaignState.story_flags.get(&"armory_purchase_count", 0))
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Armory state could not be loaded")
		return
	if CampaignState.duckets != expected_duckets or int(CampaignState.story_flags.get(&"armory_purchase_count", 0)) != expected_purchase_count:
		_fail("Armory currency or purchase history did not survive save/load")
		return
	if CampaignState.loot_by_instance(first_id).is_empty() or CampaignState.loot_owner(first_id) != &"ben":
		_fail("Purchased and equipped Armory gear did not survive save/load")
		return
	if int(CampaignState.loot_by_instance(persistent_reforge_id).get("reforged_modifier_index", -1)) != 0:
		_fail("The permanent one-modifier reforge did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("ARMORY_SERVICE_SMOKE_OK facility=fourth_foundation plots=11 stock=6+14_sidegrades slots=6 resistance=true compare=true buy+sell+salvage+reforge=true staffing=15pct controller+mouse=true persistence=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("ARMORY_SERVICE_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
