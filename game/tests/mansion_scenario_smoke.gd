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
	CampaignState.story_flags[&"mansion_foyer_cleared"] = true

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame

	var passage_cell := Vector2i(6, 36)
	if main._navigation.get_cell_atlas_coords(passage_cell) != Vector2i(1, 4):
		_fail("The servants' passage was not gated before the 4:44 puzzle")
		return
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	CampaignState.state_changed.emit()
	await get_tree().process_frame
	if main._navigation.get_cell_atlas_coords(passage_cell) != Vector2i(2, 2):
		_fail("Solving 4:44 did not open the passage navigation cell")
		return
	if not main.has_node("Field/Map/CampaignWorld/MansionServantsPassage") or not main.has_node("Field/Map/CampaignWorld/MansionServantsPassageReturn"):
		_fail("The two-way servants' passage was not created")
		return

	var save_point = main.get_node("Field/Map/CampaignWorld/ArchiveAnchorClock")
	CampaignState.character_progress[&"ben"]["hp"] = 1
	CampaignState.character_progress[&"ben"]["mp"] = 0
	save_point.activate_anchor(false)
	if int(CampaignState.character_progress[&"ben"]["hp"]) != 140 or int(CampaignState.character_progress[&"ben"]["mp"]) != 36:
		_fail("Archive anchor did not fully restore the party")
		return

	# The archive now leads into a real chapter rather than directly to the boss.
	for transition_name in ["MansionArchiveToGallery", "MansionGalleryToArchive", "MansionGalleryToNursery", "MansionNurseryToGallery"]:
		if not main.has_node("Field/Map/CampaignWorld/" + transition_name):
			_fail("Missing chapter transition: " + transition_name)
			return
	CampaignState.story_flags[&"mansion_gallery_ambush_cleared"] = true
	var gallery_portrait = main.get_node("Field/Map/CampaignWorld/GalleryPortrait")
	gallery_portrait.apply_interaction(false)
	if int(CampaignState.inventory.get(&"silver_hour_hand", 0)) != 1:
		_fail("The portrait gallery did not grant the Silver Hour Hand")
		return
	CampaignState.story_flags[&"mansion_nursery_ambush_cleared"] = true
	var music_box = main.get_node("Field/Map/CampaignWorld/NurseryMusicBox")
	music_box.apply_interaction(false)
	if int(CampaignState.inventory.get(&"brass_minute_hand", 0)) != 1:
		_fail("The nursery music box did not grant the Brass Minute Hand")
		return
	var respite: MansionSavePoint = main.get_node("Field/Map/CampaignWorld/NurseryRespiteClock")
	CampaignState.character_progress[&"ben"]["hp"] = 1
	CampaignState.character_progress[&"ben"]["mp"] = 0
	respite.activate_anchor(false)
	if not CampaignState.story_flags.get(&"mansion_ballroom_respite_found", false) or int(CampaignState.character_progress[&"ben"]["hp"]) != 140:
		_fail("The nursery antechamber did not provide a persistent recovery point before the ballroom")
		return
	var ballroom_gate = main.get_node("Field/Map/CampaignWorld/BallroomGate")
	ballroom_gate.apply_interaction(false)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"mansion_ballroom_open", false):
		_fail("Both clock hands did not open the ballroom")
		return
	if not main.has_node("Field/Map/CampaignWorld/MansionNurseryToBallroom") or not main.has_node("Field/Map/CampaignWorld/MansionBallroomToNursery"):
		_fail("The ballroom's two-way transition was not created")
		return

	var controller: MansionEncounterController = main.get_node("Field/Map/CampaignWorld/EncounterLayer/MansionEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	controller.suppress_persistence = true
	battle.suppress_persistence = true
	var boss_cell := Vector2i(23, 41)
	var player: Gamepiece = Player.gamepiece
	player.position = Gameboard.cell_to_pixel(boss_cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, boss_cell)
	controller._on_player_arrived()
	await get_tree().process_frame
	if not battle.active or battle.model.encounter_id != &"mansion_archive_boss":
		_fail("Entering the ballroom did not start the scripted 4:44 boss")
		return
	battle.debug_force_victory()
	await get_tree().process_frame
	if int(CampaignState.inventory.get(&"anchor_core", 0)) != 1:
		_fail("Boss victory did not grant the Multiversal Anchor Core")
		return
	var found_chronometer := false
	for item in CampaignState.loot_inventory:
		found_chronometer = found_chronometer or item.get("id") == &"anchored_chronometer"
	if not found_chronometer:
		_fail("Boss victory did not grant the epic chronometer")
		return
	battle._leave_battle(true)
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"haunted_mansion_scenario_complete", false):
		_fail("Boss victory did not complete and stabilize the first universe")
		return

	print("MANSION_SCENARIO_SMOKE_OK rooms=5 gate=4:44 hands=gallery+nursery respite=pre_boss_save boss=ballroom reward=anchor_core+epic_chronometer")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("MANSION_SCENARIO_SMOKE_FAILED: " + message)
	get_tree().quit(1)
