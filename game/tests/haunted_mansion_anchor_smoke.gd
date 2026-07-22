extends Node


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
	if GamepieceRegistry.get_cell(Player.gamepiece) != Vector2i(4, 38):
		_fail("Town mansion door did not enter the Haunted Mansion foyer")
		return
	if main._camera_area != "mansion_foyer":
		_fail("Camera did not switch to isolated Haunted Mansion bounds")
		return

	FieldEvents.cell_selected.emit(Vector2i(4, 39))
	await get_tree().create_timer(1.5).timeout
	if GamepieceRegistry.get_cell(Player.gamepiece) != Vector2i(64, 17):
		_fail("Haunted Mansion exit did not return to the safe town side")
		return

	print("HAUNTED_MANSION_ANCHOR_SMOKE_OK build=plot5 enter=(4,38) return=(64,17)")
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
