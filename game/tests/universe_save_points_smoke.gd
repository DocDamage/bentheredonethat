extends Node


const POINTS := {
	&"mansion_archive": {"node": "ArchiveAnchorClock", "cell": Vector2i(12, 35), "flag": &"mansion_archive_save_found"},
	&"mansion_ballroom_antechamber": {"node": "NurseryRespiteClock", "cell": Vector2i(13, 49), "flag": &"mansion_ballroom_respite_found"},
	&"asterion_medical": {"node": "AsterionSaveBeacon", "cell": Vector2i(52, 45), "flag": &"asterion_save_found"},
	&"primeval_nest": {"node": "PrimevalAnchorTotem", "cell": Vector2i(84, 45), "flag": &"primeval_save_found"},
	&"helios_clinic": {"node": "HeliosSaveBeacon", "cell": Vector2i(122, 45), "flag": &"helios_save_found"},
	&"frosthold_rune_hall": {"node": "FrostholdSaveBrazier", "cell": Vector2i(156, 47), "flag": &"frosthold_save_found"},
	&"moonpetal_bell_walk": {"node": "MoonpetalSaveLantern", "cell": Vector2i(191, 47), "flag": &"moonpetal_save_found"},
	&"empyreal_aerie": {"node": "EmpyrealSaveFountain", "cell": Vector2i(230, 47), "flag": &"empyreal_save_found"},
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame

	var world: Node = main.get_node("Field/Map/CampaignWorld")
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	var player: Gamepiece = Player.gamepiece
	if not player or CampaignState.UNIVERSE_SAVE_POINTS.size() != POINTS.size():
		_fail("The shared eight-point registry or field player is missing")
		return
	if CampaignState.activate_save_point(&"not_a_real_anchor"):
		_fail("An unknown save-point id was accepted")
		return

	for point_id in POINTS:
		var expected: Dictionary = POINTS[point_id]
		var definition: Dictionary = CampaignState.UNIVERSE_SAVE_POINTS.get(point_id, {})
		if definition.get("cell") != expected["cell"] or definition.get("flag") != expected["flag"]:
			_fail("The registry disagrees with the authored placement for %s" % point_id)
			return
		var interaction := world.get_node_or_null(expected["node"])
		if not interaction:
			_fail("Missing save-point interaction: %s" % expected["node"])
			return
		if Gameboard.pixel_to_cell(interaction.position) != expected["cell"]:
			_fail("The interaction is not grounded on its visible prop: %s" % expected["node"])
			return
		if not interaction.has_node("InteractionArea2D") or not interaction.has_node("Button"):
			_fail("Save point lacks controller proximity or mouse input: %s" % expected["node"])
			return

		_move_player(player, expected["cell"])
		if menu._at_roster_edit_location():
			_fail("An unactivated save point unlocked roster editing: %s" % point_id)
			return
		CampaignState.set_character_vitals(&"ben", 1, 0, 140, 36)
		if String(point_id).begins_with("mansion_"):
			interaction.activate_anchor(false)
		else:
			interaction.apply_interaction(false)
		var progress: Dictionary = CampaignState.character_progress[&"ben"]
		if int(progress.get("hp", 0)) <= 1 or int(progress.get("mp", 0)) <= 0:
			_fail("Save point did not restore HP and MP: %s" % point_id)
			return
		if not bool(CampaignState.story_flags.get(expected["flag"], false)):
			_fail("Save point did not set its persistent activation flag: %s" % point_id)
			return
		var nearby: Dictionary = CampaignState.activated_save_point_near(expected["cell"])
		if nearby.get("id") != point_id or not menu._at_roster_edit_location():
			_fail("Activated save point did not unlock local party management: %s" % point_id)
			return

	_move_player(player, Vector2i(100, 20))
	if menu._at_roster_edit_location() or not CampaignState.activated_save_point_near(Vector2i(100, 20)).is_empty():
		_fail("Save-point roster access leaked into an unrelated field cell")
		return

	var save_path := "user://universe_save_points_smoke.json"
	var final_cell: Vector2i = POINTS[&"empyreal_aerie"]["cell"]
	_move_player(player, final_cell)
	if CampaignState.save_game(save_path) != OK:
		_fail("Activated save points could not be persisted")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(save_path) != OK:
		_fail("Activated save points could not be loaded")
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	for point_id in POINTS:
		if not bool(CampaignState.story_flags.get(POINTS[point_id]["flag"], false)):
			_fail("Save-point activation was lost after reload: %s" % point_id)
			return
	if CampaignState.last_save_cell != final_cell:
		_fail("The final save point was not recorded as the retry location")
		return

	print("UNIVERSE_SAVE_POINTS_SMOKE_OK points=8 mansion_respite=true restore=true retry=true roster=true controller+mouse=true pack_props=true persistence=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _move_player(player: Gamepiece, cell: Vector2i) -> void:
	player.position = Gameboard.cell_to_pixel(cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, cell)


func _fail(message: String) -> void:
	printerr("UNIVERSE_SAVE_POINTS_SMOKE_FAILED: " + message)
	get_tree().quit(1)
