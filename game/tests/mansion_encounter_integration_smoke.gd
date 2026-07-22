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
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var player: Gamepiece = Player.gamepiece
	var encounter_controller: MansionEncounterController = main.get_node("Field/Map/CampaignWorld/MansionEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	encounter_controller.suppress_persistence = true
	battle.suppress_persistence = true
	var encounter_cell := Vector2i(4, 37)
	player.position = Gameboard.cell_to_pixel(encounter_cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, encounter_cell)
	encounter_controller._on_player_arrived()
	await get_tree().process_frame
	if not battle.active or battle.model.encounter_id != &"mansion_foyer_intro":
		_fail("Crossing the first Mansion arch did not start the scripted ATB formation")
		return
	if main.get_node("Field").visible:
		_fail("Field remained visible under the battle presentation")
		return
	battle.debug_force_victory()
	await get_tree().process_frame
	if not CampaignState.story_flags.get(&"mansion_foyer_cleared", false):
		_fail("Victory did not advance the Haunted Mansion story")
		return
	battle._leave_battle(true)
	await get_tree().process_frame
	if not main.get_node("Field").visible:
		_fail("Field did not resume after battle")
		return
	print("MANSION_ENCOUNTER_INTEGRATION_SMOKE_OK encounter=scripted field_pause=true victory_progress=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("MANSION_ENCOUNTER_INTEGRATION_SMOKE_FAILED: " + message)
	get_tree().quit(1)
