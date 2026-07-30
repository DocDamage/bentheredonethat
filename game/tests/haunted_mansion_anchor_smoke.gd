extends Node


const MANIFEST_ENTRY_CELL := Vector2i(306, 3)
const MANIFEST_EXIT_CELL := Vector2i(306, 1)
const FACILITY_EXIT_CELL := Vector2i(656, 12)

func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame

	FieldEvents.cell_selected.emit(Vector2i(10, 10))
	await get_tree().create_timer(1.5).timeout
	var controller := main.get_node("Field/Map/CampaignWorld/TownBuildController")
	await _send_joy_button(JOY_BUTTON_Y)
	for _facility in range(4):
		await _send_joy_button(JOY_BUTTON_A)
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	await get_tree().process_frame

	await _send_joy_button(JOY_BUTTON_Y)
	await _send_joy_button(JOY_BUTTON_A)
	if CampaignState.built_facilities.get(4) != "Haunted Mansion":
		_fail("Mandatory Haunted Mansion blueprint was not placed in the remaining plot")
		return
	if not main.has_node("Field/Map/CampaignWorld/HauntedMansionEntrance") or not main.has_node("Field/Map/CampaignWorld/HauntedMansionExit"):
		_fail("Haunted Mansion did not create physical two-way door transitions")
		return
	var entrance = main.get_node("Field/Map/CampaignWorld/HauntedMansionEntrance")
	if not entrance or not entrance.requirements_met() or entrance.destination_id != &"haunted_mansion":
		_fail("Haunted Mansion doorway did not enforce its authored party requirement")
		return

	FieldEvents.cell_selected.emit(Vector2i(64, 16))
	await get_tree().create_timer(6.0).timeout
	if GamepieceRegistry.get_cell(Player.gamepiece) != MANIFEST_ENTRY_CELL:
		_fail("Town mansion door did not enter the manifest Mansion rain gate")
		return
	if main._camera_area != "manifest:HM-01":
		_fail("Camera did not switch to the manifest Mansion room bounds")
		return

	FieldEvents.cell_selected.emit(MANIFEST_EXIT_CELL)
	await get_tree().create_timer(1.5).timeout
	if main.get_node("Field/Map/CampaignWorld/RoomStreamer").active_room_id() != &"FI-05":
		_fail("Haunted Mansion exit did not enter the stable FI-05 Anchor Hall")
		return
	var facility_path: Array = Gameboard.pathfinder.get_path_to_cell(GamepieceRegistry.get_cell(Player.gamepiece), FACILITY_EXIT_CELL)
	if facility_path.is_empty():
		var navigation := main.get_node("Field/Map/CampaignWorld/NavigationAndCollision/CampaignNavigation")
		_fail("FI-05 did not install a walkable route from its portal to its lot exit (start=%s start_atlas=%s exit_atlas=%s)" % [GamepieceRegistry.get_cell(Player.gamepiece), navigation.get_cell_atlas_coords(GamepieceRegistry.get_cell(Player.gamepiece)), navigation.get_cell_atlas_coords(FACILITY_EXIT_CELL)])
		return
	FieldEvents.cell_selected.emit(FACILITY_EXIT_CELL)
	await get_tree().create_timer(8.0).timeout
	var np07 := preload("res://ben_rpg/world/campaign_annex_room_registry.gd").room(&"NP-07")
	var expected_return: Vector2i = (np07.get("worldOrigin", Vector2i.ZERO) as Vector2i) + Vector2i(7, 10)
	if GamepieceRegistry.get_cell(Player.gamepiece) != expected_return:
		_fail("FI-05 did not return through its saved LOT-05 exterior (actual=%s expected=%s active=%s)" % [GamepieceRegistry.get_cell(Player.gamepiece), expected_return, main.get_node("Field/Map/CampaignWorld/RoomStreamer").active_room_id()])
		return

	print("HAUNTED_MANSION_ANCHOR_SMOKE_OK build=plot5 enter=(306,3) return=FI05>LOT05 runtime=manifest+phase3")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _send_joy_button(button: JoyButton) -> void:
	var press_event := InputEventJoypadButton.new()
	press_event.button_index = button
	press_event.pressed = true
	Input.parse_input_event(press_event)
	await get_tree().process_frame
	var release_event := InputEventJoypadButton.new()
	release_event.button_index = button
	release_event.pressed = false
	Input.parse_input_event(release_event)
	await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("HAUNTED_MANSION_ANCHOR_SMOKE_FAILED: " + message)
	get_tree().quit(1)
