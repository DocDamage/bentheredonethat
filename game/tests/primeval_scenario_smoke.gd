extends Node

const PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")


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
	CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
	CampaignState.anchor_universe(4, &"asterion_station")
	CampaignState.story_flags[&"asterion_station_complete"] = true
	if not CampaignState.anchor_universe(5, &"primeval_expanse"):
		_fail("Primeval Expanse could not be anchored after Asterion")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	for transition_name in ["PrimevalExpanseEntrance", "PrimevalExpanseExit"]:
		if not world.has_node(transition_name):
			_fail("Missing Primeval transition: " + transition_name)
			return
	var room_runtime := world.get_node("ManifestRoomRuntime")
	room_runtime.activate(&"PV-03")
	if not room_runtime.has_node("ManifestPort_PV-03_Ne") or room_runtime.has_node("ManifestPort_PV-03_E1"):
		_fail("Primeval internal ports were not installed by the active room runtime")
		return
	if not Gameboard.pathfinder.has_cell(main.PRIMEVAL_ORIGIN + Vector2i(4, 5)):
		_fail("The expanded gameboard did not register Primeval movement cells")
		return
	if room_runtime.has_node("ManifestPort_PV-03_E1"):
		_fail("The Relay Nest route was not puzzle-gated")
		return
	if not world.has_node("RecruitableCaveman"):
		_fail("The supplied Caveman did not appear in Primeval Borough")
		return

	var registry = PROFILE_REGISTRY.new()
	for case_data in [
		[&"primeval_raptor", &"primeval_raptor_battle_actor"],
		[&"stone_triceratops", &"stone_triceratops_battle_actor"],
		[&"municipal_spinosaur", &"municipal_spinosaur_battle_actor"],
		[&"commute_tyrant", &"commute_tyrant_battle_actor"],
	]:
		var enemy_id: StringName = case_data[0]
		var profile_id: StringName = case_data[1]
		var actor := CampaignCombatDatabase.enemy_actor(enemy_id, 0)
		if StringName(actor.get("sprite_profile", &"")) != profile_id or String(actor.get("sprite_path", "")) != registry.texture_path(profile_id) or actor.get("sprite_region", Rect2()) != registry.region(profile_id):
			_fail("Dinosaur battle actor did not resolve profile %s" % enemy_id)
			return

	var controller: PrimevalEncounterController = world.get_node("EncounterLayer/PrimevalEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	controller.suppress_persistence = true
	battle.suppress_persistence = true
	await _trigger_and_win(main, controller, battle, main.PRIMEVAL_ORIGIN + Vector2i(4, 5), &"primeval_grove_intro")
	if not CampaignState.story_flags.get(&"primeval_grove_cleared", false):
		return
	var caveman = world.get_node("RecruitableCaveman/RecruitInteraction")
	caveman.apply_interaction(false)
	if CampaignState.recruit_status.get(&"caveman") != &"available":
		_fail("Meeting the Caveman did not discover the supplied recruit")
		return
	world.get_node("PrimevalTrafficTotem").apply_interaction(false)
	CampaignState.duckets = 500
	CampaignState.add_item(&"research_notes", 1, false)
	CampaignState.add_item(&"anchor_dust", 1, false)
	if not CampaignState.craft_invention(&"paleo_translator"):
		_fail("The traffic clue did not unlock Ben's Paleo-Linguistic Telegraph")
		return
	world.get_node("PrimevalCaveTerminal").apply_interaction(false)
	await get_tree().process_frame
	room_runtime.activate(&"PV-03")
	if not room_runtime.has_node("ManifestPort_PV-03_E1"):
		_fail("Decoding the cave computer did not open the Relay Nest route")
		return

	await _trigger_and_win(main, controller, battle, main.PRIMEVAL_ORIGIN + Vector2i(12, 15), &"primeval_nest_ambush")
	world.get_node("PrimevalRelayNest").apply_interaction(false)
	await get_tree().process_frame
	room_runtime.activate(&"PV-07")
	if not room_runtime.has_node("ManifestPort_PV-07_Ne"):
		_fail("Resetting the relay did not open the Caldera route")
		return

	await _trigger_and_win(main, controller, battle, main.PRIMEVAL_ORIGIN + Vector2i(23, 15), &"primeval_commute_tyrant")
	if not CampaignState.story_flags.get(&"primeval_scenario_complete", false):
		_fail("The Primeval boss did not stabilize the scenario")
		return
	caveman.apply_interaction(false)
	if CampaignState.recruit_status.get(&"caveman") not in [&"party", &"reserve"]:
		_fail("The Caveman did not become a permanent recruit")
		return
	var found_club := false
	for item in CampaignState.loot_inventory:
		found_club = found_club or item.get("id") == &"meteor_mammoth_club"
	if not found_club:
		_fail("The commute tyrant did not drop its epic randomized-modifier weapon")
		return
	if CampaignState._location_name_for_cell(main.PRIMEVAL_ORIGIN + Vector2i(23, 15)) != "Primeval Expanse — Caldera":
		_fail("Primeval save metadata was mislabeled as another universe")
		return

	print("PRIMEVAL_SCENARIO_SMOKE_OK rooms=5 movement=true crops=atlas_regions puzzle=translator+relay battles=ATB recruit=caveman loot=epic_club")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _trigger_and_win(main: Node, controller: PrimevalEncounterController, battle: CampaignBattle, cell: Vector2i, expected: StringName) -> void:
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
	printerr("PRIMEVAL_SCENARIO_SMOKE_FAILED: " + message)
	get_tree().quit(1)
