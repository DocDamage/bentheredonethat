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
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
	if not CampaignState.build_facility(4, "Observatory"):
		_fail("The second universe anchor could not be built in the fifth plot")
		return

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame

	var world := main.get_node("Field/Map/CampaignWorld")
	for transition_name in ["AsterionStationEntrance", "AsterionStationExit", "StationDockToMess", "StationMessToHydro", "StationMessToMedical"]:
		if not world.has_node(transition_name):
			_fail("Missing Asterion transition: " + transition_name)
			return
	var town_entrance := world.get_node("AsterionStationEntrance") as AreaTransition
	var expected_town_door := Vector2i(64, 16)
	if town_entrance.position != Gameboard.cell_to_pixel(expected_town_door) or not Gameboard.pathfinder.has_cell(expected_town_door):
		_fail("Observatory transition was not aligned to its visible centered doorway")
		return
	if not Gameboard.pathfinder.has_cell(Vector2i(64, 17)) or not Gameboard.pathfinder.has_cell(Vector2i(64, 18)):
		_fail("Observatory doorway was not connected to the southern approach road")
		return
	if not world.has_node("RecruitableAstronaut"):
		_fail("The supplied Astronaut did not appear in Asterion Docking")
		return
	var gate_cell: Vector2i = main.STATION_HYDRO_TO_CONTROL
	if main._navigation.get_cell_atlas_coords(gate_cell) != Vector2i(1, 4):
		_fail("Station Control was not oxygen-gated before Hydroponics restoration")
		return

	var controller: AsterionEncounterController = world.get_node("AsterionEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	controller.suppress_persistence = true
	battle.suppress_persistence = true
	await _trigger_and_win(main, controller, battle, main.STATION_ORIGIN + Vector2i(4, 5), &"asterion_dock_intro")
	if not CampaignState.story_flags.get(&"asterion_dock_cleared", false):
		_fail("Docking victory did not advance the station scenario")
		return
	var astronaut = world.get_node("RecruitableAstronaut/RecruitInteraction")
	astronaut.apply_interaction(false)
	if not CampaignState.story_flags.get(&"asterion_astronaut_met", false) or CampaignState.recruit_status.get(&"astronaut") != &"available":
		_fail("Meeting the Astronaut did not discover the supplied recruit")
		return

	await _trigger_and_win(main, controller, battle, main.STATION_ORIGIN + Vector2i(12, 15), &"asterion_medical_ambush")
	world.get_node("AsterionBiocircuit").apply_interaction(false)
	if int(CampaignState.inventory.get(&"asterion_biocircuit", 0)) != 1:
		_fail("Medical did not yield the life-support biocircuit")
		return
	await _trigger_and_win(main, controller, battle, main.STATION_ORIGIN + Vector2i(22, 5), &"asterion_hydro_ambush")
	world.get_node("AsterionHydroConsole").apply_interaction(false)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"asterion_station_restored", false):
		_fail("Hydroponics did not restore the oxygen loop")
		return
	if main._navigation.get_cell_atlas_coords(gate_cell) != Vector2i(2, 2) or not world.has_node("StationHydroToControl"):
		_fail("Oxygen restoration did not unlock the Control route")
		return

	await _trigger_and_win(main, controller, battle, main.STATION_ORIGIN + Vector2i(23, 15), &"asterion_mother_computer")
	if not CampaignState.story_flags.get(&"asterion_station_complete", false):
		_fail("Mother Computer victory did not stabilize Asterion")
		return
	astronaut.apply_interaction(false)
	if CampaignState.recruit_status.get(&"astronaut") != &"party" or &"astronaut" not in CampaignState.party:
		_fail("The Astronaut did not become a permanent active recruit")
		return
	var found_pistol := false
	for item in CampaignState.loot_inventory:
		found_pistol = found_pistol or item.get("id") == &"ion_pistol"
	if not found_pistol:
		_fail("The station boss did not drop its supplied-theme epic weapon")
		return
	if CampaignState._location_name_for_cell(main.STATION_ORIGIN + Vector2i(23, 15)) != "Asterion Station — Control":
		_fail("Asterion save metadata was mislabeled as another universe")
		return

	print("ASTERION_SCENARIO_SMOKE_OK rooms=5 scale=48px gate=oxygen battles=ATB recruit=astronaut boss=mother_computer loot=ion_pistol")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _trigger_and_win(main: Node, controller: AsterionEncounterController, battle: CampaignBattle, cell: Vector2i, expected: StringName) -> void:
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
	printerr("ASTERION_SCENARIO_SMOKE_FAILED: " + message)
	get_tree().quit(1)
