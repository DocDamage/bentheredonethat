extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame

	FieldEvents.cell_selected.emit(Vector2i(10, 10))
	await get_tree().create_timer(1.5).timeout
	if GamepieceRegistry.get_cell(Player.gamepiece) != Vector2i(50, 8):
		_fail("Player did not reach town before construction test")
		return
	for _frame in range(2):
		await get_tree().process_frame

	var controller := main.get_node("Field/Map/CampaignWorld/TownBuildController")
	var visual := main.get_node("Field/Map/CampaignWorld/GroundLayer/Visuals")
	await _send_joy_button(JOY_BUTTON_Y)
	if not controller.is_active:
		_fail("Controller Y did not open in-map construction mode")
		return

	for _facility in range(4):
		await _send_joy_button(JOY_BUTTON_A)
	for _frame in range(3):
		await get_tree().process_frame
	if visual.built_facilities.size() != 4:
		_fail("Expected four built facilities, got %d" % visual.built_facilities.size())
		return
	if controller.is_active:
		_fail("Construction mode did not close after the four founding facilities")
		return
	if Gameboard.pathfinder.has_cell(Vector2i(43, 5)):
		_fail("Built facility footprint did not update navigation collision")
		return
	var expected_services := {
		"CafeService": Vector2i(45, 8),
		"LibraryService": Vector2i(56, 8),
		"ClinicService": Vector2i(45, 16),
		"ArmoryService": Vector2i(56, 16),
	}
	for service_name in expected_services:
		var service := main.get_node_or_null("Field/Map/CampaignWorld/%s" % service_name)
		var door_cell: Vector2i = expected_services[service_name]
		if not service or service.position != Gameboard.cell_to_pixel(door_cell):
			_fail("%s was not aligned to its visible facility doorway" % service_name)
			return
		if not Gameboard.pathfinder.has_cell(door_cell):
			_fail("%s doorway was blocked by its own building footprint" % service_name)
			return
	for approach_cell in [Vector2i(45, 9), Vector2i(56, 9), Vector2i(45, 17), Vector2i(56, 17), Vector2i(50, 18)]:
		if not Gameboard.pathfinder.has_cell(approach_cell):
			_fail("Facility approach road was not walkable at %s" % approach_cell)
			return
	if not main.has_node("Field/Map/CampaignWorld/RecruitableFighter"):
		_fail("Fighter did not appear at the Café after the founding facilities completed")
		return
	if CampaignState.recruit_status.get(&"fighter") != &"available":
		_fail("Fighter appeared without becoming available for recruitment")
		return

	print("TOWN_BUILD_SMOKE_OK facilities=%s controller=Y/A collision=blocked doors=aligned approaches=walkable fighter=available" % [visual.built_facilities])
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
	printerr("TOWN_BUILD_SMOKE_FAILED: " + message)
	get_tree().quit(1)
