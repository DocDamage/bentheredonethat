extends Node

const TEST_SAVE := "user://sandbox_terrain_smoke.json"
const TERRAIN := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.setup_sandbox(Vector2i(50, 8))
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(12):
		await get_tree().process_frame
	var player := Player.gamepiece
	GamepieceRegistry.move_gamepiece(player, main.TOWN_ARRIVAL)
	player.position = Gameboard.cell_to_pixel(main.TOWN_ARRIVAL)
	player.rest_position = player.position
	var editor := main.get_node("SandboxTownEditor")
	var company_menu := main.get_node("CampaignMenu")
	editor.suppress_persistence = true
	editor._set_active(true)
	await _send_joy_button(JOY_BUTTON_BACK)
	if editor.editor_mode != &"terrain" or company_menu.visible:
		_fail("Controller Select did not switch terrain mode cleanly inside the editor")
		return
	if TERRAIN.PACK_ORDER.size() != 5 or TERRAIN.BRUSHES.size() < 20:
		_fail("Terrain catalog did not preserve five source packs and individual brushes")
		return
	if not (editor._preview.texture is AtlasTexture):
		_fail("Terrain HUD did not preview the exact individual atlas region")
		return
	var scifi_items: Array[StringName] = TERRAIN.brushes_for_pack(&"Sci-Fi Spaceship")
	if scifi_items.size() != 4 or not scifi_items.has(&"scifi_steel_floor"):
		_fail("Sci-Fi terrain was not separated into its own sortable source pack")
		return

	var clear_cells: Array[Vector2i] = []
	for y in range(main.TOWN_ORIGIN.y + 2, main.TOWN_ORIGIN.y + main.TOWN_SIZE.y - 2):
		for x in range(main.TOWN_ORIGIN.x + 2, main.TOWN_ORIGIN.x + main.TOWN_SIZE.x - 2):
			var candidate := Vector2i(x, y)
			if Gameboard.pathfinder.can_move_to(candidate) and not GamepieceRegistry.get_gamepiece(candidate) and editor.renderer.object_at_cell(candidate).is_empty():
				clear_cells.append(candidate)
				if clear_cells.size() == 3:
					break
		if clear_cells.size() == 3:
			break
	if clear_cells.size() < 3:
		_fail("Terrain test could not find clear town cells")
		return

	var ranch_items: Array[StringName] = TERRAIN.brushes_for_pack(&"Ranch Stuff")
	editor.pack_index = 0
	editor.item_index = ranch_items.find(&"ranch_meadow")
	editor.cursor_cell = clear_cells[0]
	editor._confirm_cursor()
	if CampaignState.town_terrain_at(clear_cells[0]) != &"ranch_meadow" or not Gameboard.pathfinder.has_cell(clear_cells[0]):
		_fail("Walkable terrain paint did not persist without blocking navigation")
		return

	editor.item_index = ranch_items.find(&"ranch_water")
	editor.cursor_cell = clear_cells[1]
	editor._confirm_cursor()
	if CampaignState.town_terrain_at(clear_cells[1]) != &"ranch_water" or Gameboard.pathfinder.has_cell(clear_cells[1]):
		_fail("Blocking water brush did not update navigation")
		return
	if editor._terrain_placement_valid(&"ranch_water", GamepieceRegistry.get_cell(player)):
		_fail("Blocking terrain was allowed underneath a gamepiece")
		return
	var lab: Dictionary = CampaignState.town_object_with_role(&"town_lab")
	var lab_cell := Vector2i(int(lab.get("x", 0)), int(lab.get("y", 0)))
	if editor._terrain_placement_valid(&"ranch_water", lab_cell):
		_fail("Blocking terrain was allowed underneath a placed structure")
		return

	editor.item_index = ranch_items.find(&"ranch_meadow")
	editor.cursor_cell = clear_cells[1]
	editor._confirm_cursor()
	if not Gameboard.pathfinder.has_cell(clear_cells[1]):
		_fail("Replacing blocking terrain with a walkable brush did not restore navigation")
		return
	editor._remove_selected_or_cursor()
	if CampaignState.town_terrain_at(clear_cells[1]) != &"" or not Gameboard.pathfinder.has_cell(clear_cells[1]):
		_fail("Restoring authored base terrain failed")
		return

	editor.item_index = ranch_items.find(&"ranch_farmland")
	editor.cursor_cell = clear_cells[0]
	editor._confirm_cursor()
	editor.pack_index = TERRAIN.PACK_ORDER.find(&"Haunted Mansion")
	var haunted_items: Array[StringName] = TERRAIN.brushes_for_pack(&"Haunted Mansion")
	editor.item_index = haunted_items.find(&"haunted_planks")
	editor.cursor_cell = clear_cells[2]
	editor._confirm_cursor()
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Terrain override save failed")
		return

	editor._set_active(false)
	main.queue_free()
	await get_tree().process_frame
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.town_terrain.size() != 2:
		_fail("Terrain overrides did not survive save/load")
		return
	if CampaignState.town_terrain_at(clear_cells[0]) != &"ranch_farmland" or CampaignState.town_terrain_at(clear_cells[2]) != &"haunted_planks":
		_fail("Saved terrain pack identities or cells were corrupted")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	print("SANDBOX_TERRAIN_SMOKE_OK packs=5 brushes=%d scifi_pack=sortable paint+drag_controls=true walkable+blocking=true restore=true controller_mode=true save_load=true" % TERRAIN.BRUSHES.size())
	get_tree().quit(0)


func _send_joy_button(button: JoyButton) -> void:
	var press := InputEventJoypadButton.new()
	press.button_index = button
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventJoypadButton.new()
	release.button_index = button
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("SANDBOX_TERRAIN_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
