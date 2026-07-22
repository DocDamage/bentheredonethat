extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.anchor_universe(3, &"haunted_mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.anchor_universe(4, &"asterion_station")
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.anchor_universe(5, &"primeval_expanse")
	CampaignState.story_flags[&"primeval_scenario_complete"] = true
	if not CampaignState.anchor_universe(6, &"helios_arcology"):
		_fail("Helios Arcology could not be anchored after Primeval")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	for transition_name in ["HeliosArcologyEntrance", "HeliosArcologyExit", "HeliosSkybridgeToMarket", "HeliosMarketToSkybridge", "HeliosMarketToTransit", "HeliosTransitToMarket"]:
		if not world.has_node(transition_name):
			_fail("Missing Helios transition: " + transition_name)
			return
	if not Gameboard.pathfinder.has_cell(main.HELIOS_ORIGIN + Vector2i(3, 6)):
		_fail("The expanded gameboard did not register Helios movement cells")
		return
	if main._navigation.get_cell_atlas_coords(main.HELIOS_MARKET_TO_CLINIC) != Vector2i(1, 4):
		_fail("The Recovery Clinic route was not invention-gated")
		return
	if not world.has_node("RecruitableNeonViper"):
		_fail("Neon Viper did not appear in the Public Market")
		return

	var controller: HeliosEncounterController = world.get_node("HeliosEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	controller.suppress_persistence = true
	battle.suppress_persistence = true
	await _trigger_and_win(controller, battle, main.HELIOS_ORIGIN + Vector2i(3, 5), &"helios_skybridge_intro")
	if not CampaignState.story_flags.get(&"helios_skybridge_cleared", false):
		return
	var viper = world.get_node("RecruitableNeonViper/RecruitInteraction")
	viper.apply_interaction(false)
	if CampaignState.recruit_status.get(&"neon_viper") != &"available":
		_fail("Meeting Neon Viper did not discover the supplied recruit")
		return
	world.get_node("HeliosOrdinanceTerminal").apply_interaction(false)
	CampaignState.duckets = 500
	CampaignState.add_item(&"research_notes", 1, false)
	CampaignState.add_item(&"anchor_dust", 1, false)
	if not CampaignState.craft_invention(&"night_phase_inverter"):
		_fail("The ordinance did not unlock Ben's Nocturnal Phase Inverter")
		return
	await get_tree().process_frame
	if main._navigation.get_cell_atlas_coords(main.HELIOS_MARKET_TO_CLINIC) != Vector2i(2, 2) or not world.has_node("HeliosMarketToClinic"):
		_fail("The Phase Inverter did not open the Recovery Clinic route")
		return
	world.get_node("HeliosTransitNode").apply_interaction(false)
	await _trigger_and_win(controller, battle, main.HELIOS_ORIGIN + Vector2i(13, 15), &"helios_clinic_ambush")
	world.get_node("HeliosClinicNode").apply_interaction(false)
	await get_tree().process_frame
	if main._navigation.get_cell_atlas_coords(main.HELIOS_TRANSIT_TO_CORE) != Vector2i(2, 2) or not world.has_node("HeliosTransitToCore"):
		_fail("Disabling both daylight nodes did not open the Solar Core")
		return
	await _trigger_and_win(controller, battle, main.HELIOS_ORIGIN + Vector2i(23, 15), &"helios_civic_sun")
	if not CampaignState.story_flags.get(&"helios_scenario_complete", false):
		_fail("The Civic Sun did not stabilize Helios")
		return
	viper.apply_interaction(false)
	if CampaignState.recruit_status.get(&"neon_viper") not in [&"party", &"reserve"]:
		_fail("Neon Viper did not become a permanent recruit")
		return
	var found_capacitor := false
	for item in CampaignState.loot_inventory:
		found_capacitor = found_capacitor or item.get("id") == &"midnight_capacitor"
	if not found_capacitor:
		_fail("The Civic Sun did not drop the epic Midnight Capacitor")
		return
	if CampaignState._location_name_for_cell(main.HELIOS_ORIGIN + Vector2i(23, 15)) != "Helios Arcology — Solar Core":
		_fail("Helios save metadata was mislabeled")
		return

	print("HELIOS_SCENARIO_SMOKE_OK rooms=5 movement=true art=authored_panels puzzle=phase_nodes battles=ATB recruit=neon_viper loot=epic_capacitor")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _trigger_and_win(controller: HeliosEncounterController, battle: CampaignBattle, cell: Vector2i, expected: StringName) -> void:
	var player: Gamepiece = Player.gamepiece
	player.position = Gameboard.cell_to_pixel(cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, cell)
	controller._on_player_arrived()
	await get_tree().process_frame
	if not battle.active or battle.model.encounter_id != expected:
		_fail("Expected %s but the scripted encounter did not start" % expected)
		return
	battle.debug_force_victory()
	await get_tree().process_frame
	battle._leave_battle(true)
	await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("HELIOS_SCENARIO_SMOKE_FAILED: " + message)
	get_tree().quit(1)

