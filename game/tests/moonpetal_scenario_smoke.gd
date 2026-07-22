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
	if not CampaignState.anchor_universe(8, &"moonpetal_court"):
		_fail("Moonpetal Court could not be anchored after Frosthold")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	for transition_name in ["MoonpetalCourtEntrance", "MoonpetalCourtExit", "MoonpetalGateToCourt", "MoonpetalCourtToGate", "MoonpetalCourtToGarden", "MoonpetalGardenToCourt"]:
		if not world.has_node(transition_name):
			_fail("Missing Moonpetal transition: " + transition_name)
			return
	if not Gameboard.pathfinder.has_cell(main.MOONPETAL_ORIGIN + Vector2i(3, 6)):
		_fail("The expanded gameboard did not register Moonpetal movement cells")
		return
	if main._navigation.get_cell_atlas_coords(main.MOONPETAL_COURT_TO_BELL_WALK) != Vector2i(1, 4):
		_fail("The Bell Walk route was not invention-gated")
		return
	if not world.has_node("RecruitableKitsune"):
		_fail("The supplied Kitsune Empress did not appear in Blossom Court")
		return

	var controller: MoonpetalEncounterController = world.get_node("MoonpetalEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	controller.suppress_persistence = true
	battle.suppress_persistence = true
	await _trigger_and_win(controller, battle, main.MOONPETAL_ORIGIN + Vector2i(3, 5), &"moonpetal_gate_intro")
	if not CampaignState.story_flags.get(&"moonpetal_gate_cleared", false):
		return
	var kitsune = world.get_node("RecruitableKitsune/RecruitInteraction")
	kitsune.apply_interaction(false)
	if CampaignState.recruit_status.get(&"kitsune_empress") != &"available":
		_fail("Meeting the Kitsune Empress did not discover the supplied recruit")
		return
	world.get_node("MoonpetalVowTablet").apply_interaction(false)
	CampaignState.duckets = 800
	CampaignState.add_item(&"research_notes", 2, false)
	CampaignState.add_item(&"anchor_dust", 2, false)
	if not CampaignState.craft_invention(&"veracity_lantern"):
		_fail("The duplicated vow did not unlock Ben's Veracity Lantern")
		return
	world.get_node("MoonpetalGardenSeal").apply_interaction(false)
	await get_tree().process_frame
	if main._navigation.get_cell_atlas_coords(main.MOONPETAL_COURT_TO_BELL_WALK) != Vector2i(2, 2) or not world.has_node("MoonpetalCourtToBellWalk"):
		_fail("The Lantern did not open the Bell Walk route")
		return
	await _trigger_and_win(controller, battle, main.MOONPETAL_ORIGIN + Vector2i(13, 15), &"moonpetal_bell_ambush")
	world.get_node("MoonpetalPalaceSeal").apply_interaction(false)
	await get_tree().process_frame
	if main._navigation.get_cell_atlas_coords(main.MOONPETAL_GARDEN_TO_PALACE) != Vector2i(2, 2) or not world.has_node("MoonpetalGardenToPalace"):
		_fail("The final vow did not open the Moon Palace")
		return
	await _trigger_and_win(controller, battle, main.MOONPETAL_ORIGIN + Vector2i(23, 15), &"moonpetal_magistrate_enma")
	if not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false):
		_fail("Magistrate Enma's defeat did not stabilize Moonpetal")
		return
	kitsune.apply_interaction(false)
	if CampaignState.recruit_status.get(&"kitsune_empress") not in [&"party", &"reserve"]:
		_fail("The Kitsune Empress did not become a permanent recruit")
		return
	var found_mirror := false
	for item in CampaignState.loot_inventory:
		found_mirror = found_mirror or item.get("id") == &"true_moon_mirror"
	if not found_mirror:
		_fail("Magistrate Enma did not drop the epic Mirror of the True Moon")
		return
	if CampaignState._location_name_for_cell(main.MOONPETAL_ORIGIN + Vector2i(23, 15)) != "Moonpetal Court — Moon Palace":
		_fail("Moonpetal save metadata was mislabeled")
		return

	print("MOONPETAL_SCENARIO_SMOKE_OK rooms=5 movement=true layout=connected_avenues art=exact_islands puzzle=veracity_lantern battles=ATB recruit=kitsune loot=epic_mirror")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _trigger_and_win(controller: MoonpetalEncounterController, battle: CampaignBattle, cell: Vector2i, expected: StringName) -> void:
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
	printerr("MOONPETAL_SCENARIO_SMOKE_FAILED: " + message)
	get_tree().quit(1)
