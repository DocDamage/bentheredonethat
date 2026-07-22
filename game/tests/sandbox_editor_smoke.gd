extends Node

const TEST_SAVE := "user://sandbox_editor_smoke.json"
const CATALOG := preload("res://ben_rpg/world/sandbox_object_catalog.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.setup_sandbox(Vector2i(50, 8))
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(7):
		await get_tree().process_frame
	var player := Player.gamepiece
	GamepieceRegistry.move_gamepiece(player, main.TOWN_ARRIVAL)
	player.position = Gameboard.cell_to_pixel(main.TOWN_ARRIVAL)
	player.rest_position = player.position
	var editor := main.get_node("SandboxTownEditor")
	var renderer := main.get_node("Field/Map/CampaignWorld/SandboxTownObjects")
	editor.suppress_persistence = true
	if CATALOG.PACK_ORDER.size() != 5 or CATALOG.ITEMS.size() < 34:
		_fail("Catalog did not preserve the five source packs and individual entries")
		return
	editor._set_active(true)
	if not editor.active or not editor._panel.visible:
		_fail("Sandbox editor did not open as an in-map rail")
		return
	editor._cycle_pack(1)
	if CATALOG.PACK_ORDER[editor.pack_index] != &"Ranch Stuff":
		_fail("Controller pack filtering did not advance by source pack")
		return
	var laboratory := CampaignState.town_object_with_role(&"town_lab")
	if laboratory.is_empty() or not bool(laboratory.get("protected", false)):
		_fail("Authored town laboratory was not promoted to a protected editor object")
		return
	if editor._placement_valid(&"modern_warehouse", main.TOWN_ORIGIN + Vector2i(12, 4)):
		_fail("Editor allowed placement through the relocatable laboratory")
		return
	editor.cursor_cell = Vector2i(int(laboratory.get("x", 0)), int(laboratory.get("y", 0)))
	editor._confirm_cursor()
	if editor.selected_instance_id != "sandbox_town_lab":
		_fail("Authored laboratory could not be selected from the map")
		return
	editor.cursor_cell = Vector2i(55, 2)
	editor._confirm_cursor()
	var moved_lab := CampaignState.town_object_with_role(&"town_lab")
	if int(moved_lab.get("x", 0)) != 55 or CampaignState.remove_town_object("sandbox_town_lab"):
		_fail("Laboratory relocation or protected deletion rule failed")
		return
	var town_door := main.get_node("Field/Map/CampaignWorld/TownLaboratoryDoor") as AreaTransition
	var lab_exit := main.get_node("Field/Map/CampaignWorld/LaboratoryExit") as AreaTransition
	if town_door.position != Gameboard.cell_to_pixel(Vector2i(57, 4)) or lab_exit.arrival_coordinates != Gameboard.cell_to_pixel(Vector2i(57, 5)):
		_fail("Relocating the laboratory did not move its functional doorway and return point")
		return
	editor._set_active(false)
	GamepieceRegistry.move_gamepiece(player, main.LAB_SPAWN)
	player.position = Gameboard.cell_to_pixel(main.LAB_SPAWN)
	player.rest_position = player.position
	FieldEvents.cell_selected.emit(main.LAB_EXIT)
	await get_tree().create_timer(1.5).timeout
	if GamepieceRegistry.get_cell(player) != Vector2i(57, 5):
		_fail("Using the laboratory exit did not arrive beside the relocated building")
		return
	editor._set_active(true)

	var cow_id := CampaignState.place_town_object(&"ranch_cow", Vector2i(42, 10))
	var pumpkin_id := CampaignState.place_town_object(&"ranch_pumpkin", Vector2i(46, 10))
	var scifi_id := CampaignState.place_town_object(&"scifi_bio_pod", Vector2i(51, 12))
	main.refresh_sandbox_object_collision()
	if cow_id.is_empty() or renderer.object_at_cell(Vector2i(42, 10)).get("instance_id") != cow_id:
		_fail("Placed individual sprite was not selectable on the map")
		return
	if Gameboard.pathfinder.has_cell(Vector2i(42, 10)):
		_fail("Blocking object did not update navigation collision")
		return
	if not Gameboard.pathfinder.has_cell(Vector2i(46, 10)):
		_fail("Decorative nonblocking object incorrectly blocked navigation")
		return
	if scifi_id.is_empty() or renderer.object_at_cell(Vector2i(51, 12)).get("catalog_id") != &"scifi_bio_pod":
		_fail("Sci-Fi pack sprite was not individually rendered and selectable")
		return
	if Gameboard.pathfinder.has_cell(Vector2i(51, 12)):
		_fail("Sci-Fi object footprint did not update navigation collision")
		return
	if not CampaignState.move_town_object(cow_id, Vector2i(44, 12)):
		_fail("Selected object could not be moved")
		return
	main.refresh_sandbox_object_collision()
	if not Gameboard.pathfinder.has_cell(Vector2i(42, 10)) or Gameboard.pathfinder.has_cell(Vector2i(44, 12)):
		_fail("Moving an object did not clear its old footprint and block its new footprint")
		return
	if not CampaignState.flip_town_object(cow_id) or not CampaignState.town_object(cow_id).get("flipped", false):
		_fail("Placed object could not be flipped")
		return
	if not CampaignState.remove_town_object(pumpkin_id):
		_fail("Placed object could not be removed")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Sandbox object save failed")
		return

	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.town_objects.size() != 7:
		_fail("Sandbox object layer did not survive save/load")
		return
	var restored := CampaignState.town_object(cow_id)
	if restored.get("catalog_id") != &"ranch_cow" or not restored.get("flipped", false) or int(restored.get("x")) != 44:
		_fail("Saved catalog identity or transform was corrupted")
		return
	if CampaignState.town_object(scifi_id).get("catalog_id") != &"scifi_bio_pod":
		_fail("Saved Sci-Fi catalog identity was corrupted")
		return
	var restored_lab := CampaignState.town_object_with_role(&"town_lab")
	if int(restored_lab.get("x", 0)) != 55 or not bool(restored_lab.get("protected", false)):
		_fail("Authored laboratory role, protection, or transform did not survive save/load")
		return

	editor._set_active(false)
	main.queue_free()
	await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	print("SANDBOX_EDITOR_SMOKE_OK packs=5 items=%d complete_building_slices=true scifi=individual+selectable authored=select+relocate+protected doorway=relocates place+move+flip+remove=true collision=true save_load=true" % CATALOG.ITEMS.size())
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("SANDBOX_EDITOR_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
