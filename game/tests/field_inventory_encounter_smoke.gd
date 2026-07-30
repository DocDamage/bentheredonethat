extends Node

const TEST_SAVE := "user://field_inventory_encounter_smoke.json"


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.duckets = 200
	var ward_stocked := false
	for item in CampaignState.service_stock("Cafe"):
		ward_stocked = ward_stocked or StringName(item.get("id", &"")) == &"rift_ward"
	if not ward_stocked:
		_fail("The Café does not stock the campaign's random-encounter ward")
		return
	if not CampaignState.purchase_service_item("Cafe", &"rift_ward", 2) or int(CampaignState.inventory.get(&"rift_ward", 0)) != 2:
		_fail("Rift Wards could not be purchased through the normal town service")
		return

	CampaignState.set_character_vitals(&"ben", 10, 0, 140, 36)
	var tonic := CampaignState.use_field_item(&"tonic", &"ben")
	if not bool(tonic.get("used", false)) or int(CampaignState.character_progress[&"ben"]["hp"]) != 80 or int(CampaignState.inventory.get(&"tonic", 0)) != 2:
		_fail("The field inventory did not apply and consume a Tonic")
		return
	var ether := CampaignState.use_field_item(&"ether", &"ben")
	if not bool(ether.get("used", false)) or int(CampaignState.character_progress[&"ben"]["mp"]) != 24 or int(CampaignState.inventory.get(&"ether", 0)) != 0:
		_fail("The field inventory did not apply and consume Leyden Ether")
		return
	CampaignState.set_character_vitals(&"ben", 0, 24, 140, 36)
	var revival := CampaignState.use_field_item(&"phoenix_tonic", &"ben")
	if not bool(revival.get("used", false)) or int(CampaignState.character_progress[&"ben"]["hp"]) != 35:
		_fail("Phoenix Tonic did not revive a knocked-out field target at 25 percent HP")
		return
	if bool(CampaignState.field_item_use_preview(&"phoenix_tonic", &"ben").get("usable", false)):
		_fail("The field inventory allowed Phoenix Tonic on a living target")
		return

	CampaignState.discover_recruit(&"fighter")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	var ward := CampaignState.use_field_item(&"rift_ward")
	if not bool(ward.get("used", false)) or CampaignState.encounter_ward_steps != 40:
		_fail("Rift Ward did not create 40 protected danger steps")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var menu := main.get_node("CampaignMenu") as CampaignMenu
	menu.suppress_persistence = true
	menu.open_menu(&"inventory")
	await get_tree().process_frame
	var ward_button := menu.find_child("UseFieldRiftWard", true, false) as Button
	if not ward_button or ward_button.disabled or not "40 dangerous steps" in ward_button.tooltip_text:
		_fail("The supplied-asset inventory page did not expose a controller-ready Rift Ward action")
		return
	ward_button.pressed.emit()
	await get_tree().process_frame
	if CampaignState.encounter_ward_steps != 80 or int(CampaignState.inventory.get(&"rift_ward", 0)) != 0:
		_fail("Activating Rift Ward from the actual menu did not update the expedition")
		return
	menu.close_menu()

	var world: Node = main.get_node("Field/Map/CampaignWorld")
	var controller := world.get_node("EncounterLayer/MansionEncounters") as MansionEncounterController
	var battle := main.get_node("CampaignBattle") as CampaignBattle
	controller.suppress_persistence = true
	battle.suppress_persistence = true
	controller._encounter_threshold = 100
	CampaignState.story_flags[&"mansion_foyer_cleared"] = true
	var danger_cell: Vector2i = main.MANSION_ORIGIN + Vector2i(2, 4)
	var player: Gamepiece = Player.gamepiece
	player.position = Gameboard.cell_to_pixel(danger_cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, danger_cell)
	controller._on_player_arrived()
	await get_tree().process_frame
	if battle.active or CampaignState.encounter_ward_steps != 79 or not bool(CampaignState.encounter_pressure.get("suppressed", false)):
		_fail("A warded random-encounter step was not suppressed and reported")
		return

	CampaignState.story_flags[&"mansion_foyer_cleared"] = false
	controller._on_player_arrived()
	await get_tree().process_frame
	if not battle.active or battle.model.encounter_id != &"mansion_foyer_intro" or CampaignState.encounter_ward_steps != 79:
		_fail("Rift Ward incorrectly suppressed the mandatory scripted Mansion encounter")
		return
	battle.debug_force_victory()
	await get_tree().process_frame
	battle._leave_battle(true)
	await get_tree().process_frame

	CampaignState.encounter_ward_steps = 0
	CampaignState.report_encounter_pressure(&"haunted_mansion", 8, 10, true)
	await get_tree().process_frame
	var pressure_panel := world.get_node("TownBuildController/EncounterPressurePanel") as PanelContainer
	var pressure_label := pressure_panel.find_child("PressureLabel", true, false) as Label
	var pressure_bar := pressure_panel.find_child("PressureBar", true, false) as ProgressBar
	if not pressure_panel.visible or not "IMMINENT" in pressure_label.text or int(pressure_bar.value) != 8 or int(pressure_bar.max_value) != 10:
		_fail("The supplied-UI encounter-pressure gauge did not show imminent risk accurately")
		return

	CampaignState.encounter_ward_steps = 17
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("The active Rift Ward could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.encounter_ward_steps != 17:
		_fail("Rift Ward duration did not survive save/load")
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("FIELD_INVENTORY_ENCOUNTER_SMOKE_OK healing+ether+revive=true ward=40_steps menu=controller_ready random=suppressed scripted=mandatory pressure=visible persistence=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("FIELD_INVENTORY_ENCOUNTER_SMOKE_FAILED: " + message)
	get_tree().quit(1)
