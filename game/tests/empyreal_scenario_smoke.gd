extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.build_facility(4, "Observatory")
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.build_facility(5, "Trailhead Lodge")
	CampaignState.story_flags[&"primeval_scenario_complete"] = true
	CampaignState.build_facility(6, "Afterlight Club")
	CampaignState.story_flags[&"helios_scenario_complete"] = true
	CampaignState.build_facility(7, "Cold Storage")
	CampaignState.story_flags[&"frosthold_scenario_complete"] = true
	CampaignState.build_facility(8, "Tea House")
	CampaignState.story_flags[&"moonpetal_scenario_complete"] = true
	if not CampaignState.anchor_universe(9, &"empyreal_court"):
		_fail("Empyreal Court could not be anchored after Moonpetal")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	for transition_name in ["EmpyrealCourtEntrance", "EmpyrealCourtExit", "EmpyrealLandingToGarden", "EmpyrealGardenToLanding", "EmpyrealGardenToForum", "EmpyrealForumToGarden"]:
		if not world.has_node(transition_name):
			_fail("Missing Empyreal transition: " + transition_name)
			return
	if not Gameboard.pathfinder.has_cell(main.EMPYREAL_ORIGIN + Vector2i(3, 6)):
		_fail("The expanded gameboard did not register Empyreal movement cells")
		return
	if main._navigation.get_cell_atlas_coords(main.EMPYREAL_GARDEN_TO_AERIE) != Vector2i(1, 4):
		_fail("The Reliquary Aerie route was not invention-gated")
		return
	if not world.has_node("RecruitableArchangel"):
		_fail("The supplied Archangel Commander did not appear in the Garden")
		return

	var controller: EmpyrealEncounterController = world.get_node("EmpyrealEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	controller.suppress_persistence = true
	battle.suppress_persistence = true
	await _trigger_and_win(controller, battle, main.EMPYREAL_ORIGIN + Vector2i(3, 5), &"empyreal_landing_intro")
	var archangel = world.get_node("RecruitableArchangel/RecruitInteraction")
	archangel.apply_interaction(false)
	if not CampaignState.story_flags.get(&"archangel_commander_met", false):
		_fail("Meeting the Archangel did not begin the scenario")
		return
	world.get_node("EmpyrealGravityOrdinance").apply_interaction(false)
	CampaignState.duckets = 1000
	CampaignState.add_item(&"research_notes", 2, false)
	CampaignState.add_item(&"anchor_dust", 2, false)
	if not CampaignState.craft_invention(&"galvanic_counterweight"):
		_fail("Ordinance 9-G did not unlock Ben's Galvanic Counterweight")
		return
	world.get_node("EmpyrealAerieSeal").apply_interaction(false)
	await get_tree().process_frame
	if main._navigation.get_cell_atlas_coords(main.EMPYREAL_GARDEN_TO_AERIE) != Vector2i(2, 2) or not world.has_node("EmpyrealGardenToAerie"):
		_fail("The Counterweight did not open the Reliquary Aerie")
		return
	await _trigger_and_win(controller, battle, main.EMPYREAL_ORIGIN + Vector2i(13, 15), &"empyreal_aerie_ambush")
	world.get_node("EmpyrealTribunalSeal").apply_interaction(false)
	await get_tree().process_frame
	if main._navigation.get_cell_atlas_coords(main.EMPYREAL_FORUM_TO_TRIBUNAL) != Vector2i(2, 2) or not world.has_node("EmpyrealForumToTribunal"):
		_fail("The final gravity seal did not open the Tribunal")
		return
	await _trigger_and_win(controller, battle, main.EMPYREAL_ORIGIN + Vector2i(23, 15), &"empyreal_high_comptroller")
	if not CampaignState.story_flags.get(&"empyreal_scenario_complete", false):
		_fail("The High Comptroller's defeat did not stabilize Empyreal Court")
		return
	archangel.apply_interaction(false)
	if CampaignState.recruit_status.get(&"archangel_commander") not in [&"party", &"reserve"]:
		_fail("The Archangel Commander did not become a permanent recruit")
		return
	var found_aegis := false
	for item in CampaignState.loot_inventory:
		found_aegis = found_aegis or item.get("id") == &"charter_aegis"
	if not found_aegis:
		_fail("The High Comptroller did not drop the epic Charter Aegis")
		return
	if CampaignState._location_name_for_cell(main.EMPYREAL_ORIGIN + Vector2i(23, 15)) != "Empyreal Court — Seraph Tribunal":
		_fail("Empyreal save metadata was mislabeled")
		return

	print("EMPYREAL_SCENARIO_SMOKE_OK rooms=5 movement=true layout=floating_terraces puzzle=galvanic_counterweight battles=ATB recruit=archangel loot=epic_aegis")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _trigger_and_win(controller: EmpyrealEncounterController, battle: CampaignBattle, cell: Vector2i, expected: StringName) -> void:
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
	printerr("EMPYREAL_SCENARIO_SMOKE_FAILED: " + message)
	get_tree().quit(1)
