extends Node


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_foyer_cleared"] = true
	CampaignState.discover_recruit(&"fighter")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.add_item(&"rift_ward", 2, false)
	CampaignState.set_character_vitals(&"ben", 48, 7, 140, 36)

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	var menu := main.get_node("CampaignMenu") as CampaignMenu
	menu.suppress_persistence = true
	menu.open_menu(&"inventory")
	for _frame in range(3):
		await get_tree().process_frame
	_capture("field-inventory.png")
	menu.close_menu()

	var danger_cell: Vector2i = main.MANSION_ORIGIN + Vector2i(12, 5)
	var player: Gamepiece = Player.gamepiece
	player.position = Gameboard.cell_to_pixel(danger_cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, danger_cell)
	Camera.reset_position()
	CampaignState.report_encounter_pressure(&"haunted_mansion", 8, 10, true)
	for _frame in range(5):
		await get_tree().process_frame
	_capture("encounter-pressure.png")
	print("FIELD_INVENTORY_ENCOUNTER_CAPTURE_OK inventory=supplied_ui pressure=imminent")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png("res://validation/%s" % file_name)
	if result != OK:
		printerr("FIELD_INVENTORY_ENCOUNTER_CAPTURE_FAILED file=%s error=%d" % [file_name, result])
		get_tree().quit(1)
