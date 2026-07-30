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
	if not CampaignState.anchor_universe(7, &"frosthold_kingdom"):
		_fail("Frosthold Kingdom could not be anchored after Helios")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	var runtime: Node = world.get_node("ManifestRoomRuntime")
	var streamer: Node = world.get_node("RoomStreamer")
	runtime.call(&"activate", &"FR-01")
	if not runtime.has_node("ManifestPort_FR-01_Ne"):
		_fail("The Frosthold entry room did not install its authored reciprocal port")
		return
	if not world.has_node("RecruitableFrostLich"):
		_fail("The supplied Frost Lich Emperor did not appear in the Frozen Market")
		return

	var controller: FrostholdEncounterController = world.get_node("EncounterLayer/FrostholdEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	controller.suppress_persistence = true
	battle.suppress_persistence = true
	await _trigger_and_win(controller, battle, main.FROSTHOLD_ORIGIN + Vector2i(3, 5), &"frosthold_gate_intro")
	if not CampaignState.story_flags.get(&"frosthold_gate_cleared", false):
		return
	var lich = world.get_node("RecruitableFrostLich/RecruitInteraction")
	lich.apply_interaction(false)
	if CampaignState.recruit_status.get(&"frost_lich_emperor") != &"available":
		_fail("Meeting the Frost Lich did not discover the supplied recruit")
		return
	runtime.call(&"activate", &"FR-03")
	await get_tree().process_frame
	var market_root := streamer.call(&"active_root") as Node2D
	market_root.get_node("InteractionLayer/FrostholdHeatTaxRune").apply_interaction(false)
	CampaignState.duckets = 600
	CampaignState.add_item(&"research_notes", 2, false)
	CampaignState.add_item(&"anchor_dust", 1, false)
	if not CampaignState.craft_invention(&"thermal_arbitration_coil"):
		_fail("The heat-tax rune did not unlock Ben's Thermal Arbitration Coil")
		return
	runtime.call(&"activate", &"FR-05")
	await get_tree().process_frame
	var seal_root := streamer.call(&"active_root") as Node2D
	seal_root.get_node("InteractionLayer/FrostholdCausewaySeal").apply_interaction(false)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"frosthold_causeway_seal_open", false):
		_fail("The Coil did not open the Rune Hall route")
		return
	await _trigger_and_win(controller, battle, main.FROSTHOLD_ORIGIN + Vector2i(13, 15), &"frosthold_rune_ambush")
	runtime.call(&"activate", &"FR-07")
	await get_tree().process_frame
	var throne_root := streamer.call(&"active_root") as Node2D
	throne_root.get_node("InteractionLayer/FrostholdThroneSeal").apply_interaction(false)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"frosthold_throne_open", false):
		_fail("The second seal did not open the Ice Throne")
		return
	await _trigger_and_win(controller, battle, main.FROSTHOLD_ORIGIN + Vector2i(23, 15), &"frosthold_whiteout_auditor")
	if not CampaignState.story_flags.get(&"frosthold_scenario_complete", false):
		_fail("The Whiteout Auditor did not stabilize Frosthold")
		return
	lich.apply_interaction(false)
	if CampaignState.recruit_status.get(&"frost_lich_emperor") not in [&"party", &"reserve"]:
		_fail("The Frost Lich Emperor did not become a permanent recruit")
		return
	var found_crown := false
	for item in CampaignState.loot_inventory:
		found_crown = found_crown or item.get("id") == &"repealed_winter_crown"
	if not found_crown:
		_fail("The Whiteout Auditor did not drop the epic Crown of Repealed Winter")
		return
	if CampaignState._location_name_for_cell(main.FROSTHOLD_ORIGIN + Vector2i(23, 15)) != "Frosthold Kingdom — Ice Throne":
		_fail("Frosthold save metadata was mislabeled")
		return

	print("FROSTHOLD_SCENARIO_SMOKE_OK rooms=5 movement=true art=exact_frozen_islands puzzle=thermal_coil battles=ATB recruit=frost_lich loot=epic_crown")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _trigger_and_win(controller: FrostholdEncounterController, battle: CampaignBattle, cell: Vector2i, expected: StringName) -> void:
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
	printerr("FROSTHOLD_SCENARIO_SMOKE_FAILED: " + message)
	get_tree().quit(1)
