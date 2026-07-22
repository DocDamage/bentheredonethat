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
	var encounter_controller: MansionEncounterController = main.get_node("Field/Map/CampaignWorld/EncounterLayer/MansionEncounters")
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	var autosave_results: Array[int] = []
	battle.victory_autosave_committed.connect(func(_encounter_id: StringName, result: int) -> void:
		autosave_results.append(result)
	)
	var encounter_cell := Vector2i(4, 37)
	player.position = Gameboard.cell_to_pixel(encounter_cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, encounter_cell)
	encounter_controller._on_player_arrived()
	await get_tree().process_frame
	if not battle.active:
		_fail("The scripted Mansion encounter did not start")
		return
	battle.debug_force_victory()
	battle._leave_battle(true)
	await get_tree().process_frame
	if autosave_results.size() != 1 or autosave_results[0] != OK:
		_fail("A completed battle must commit exactly one successful victory autosave; observed %s" % autosave_results)
		return
	if CampaignState.load_game(CampaignState.DEFAULT_SAVE_PATH) != OK:
		_fail("The victory autosave could not be loaded")
		return
	if not CampaignState.story_flags.get(&"mansion_foyer_cleared", false):
		_fail("The autosave ran before the encounter controller updated world state")
		return
	print("ENCOUNTER_AUTOSAVE_SMOKE_OK saves=1 ordering=controller_before_autosave")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("ENCOUNTER_AUTOSAVE_SMOKE_FAILED: " + message)
	get_tree().quit(1)
