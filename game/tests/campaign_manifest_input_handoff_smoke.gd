extends Node

## Exercises the real field-input and AreaTransition pipeline while a streamed
## room owns navigation, ports, camera bounds, and encounter policy.

const STAGING_ORIGIN := Vector2i(300, 0)
const ENTRY_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const FOYER_SAFE_CELL := STAGING_ORIGIN + Vector2i(8, 3)


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
	main._create_manifest_facility_portal(0, &"Haunted Mansion")
	main._place_player(ENTRY_SAFE_CELL)
	for _frame in range(2):
		await get_tree().process_frame
	var runtime: Node = main.get_node("Field/Map/CampaignWorld/ManifestRoomRuntime")
	if runtime.call(&"active_room_id") != &"HM-01" or main._camera_area != "manifest:HM-01":
		_fail("Manifest entry did not activate HM-01 (runtime=%s area=%s)." % [runtime.call(&"active_room_id"), main._camera_area], main)
		return

	var gamepiece: Gamepiece = Player.gamepiece
	var registry: Node = get_tree().root.get_node("GamepieceRegistry")
	var gameboard: Node = get_tree().root.get_node("Gameboard")
	var start: Vector2i = registry.get_cell(gamepiece)
	var controller_target := _adjacent_walkable_cell(start, gameboard)
	if controller_target == gameboard.INVALID_CELL:
		_fail("Manifest safe arrival has no controller-reachable neighbor.", main)
		return
	await _send_directional_input(controller_target - start)
	await get_tree().create_timer(0.5).timeout
	if registry.get_cell(gamepiece) != controller_target:
		_fail("Controller input stopped at %s instead of %s." % [registry.get_cell(gamepiece), controller_target], main)
		return

	# Use the normal click/pathfinder flow to reach the trigger. The transition
	# itself remains entirely production-owned: it pauses input, moves the party,
	# changes the streamer runtime at blackout, and restores the field.
	var foyer_port: Node = runtime.get_node_or_null("ManifestPort_HM-01_Ne")
	if not foyer_port:
		_fail("HM-01 did not expose its streamed Foyer transition.", main)
		return
	var port_cell := Gameboard.pixel_to_cell(foyer_port.position)
	var declared_arrival := Gameboard.pixel_to_cell(foyer_port.arrival_coordinates)
	if declared_arrival != FOYER_SAFE_CELL:
		_fail("HM-01 Foyer port declares %s instead of %s." % [declared_arrival, FOYER_SAFE_CELL], main)
		return
	FieldEvents.cell_selected.emit(port_cell)
	await get_tree().create_timer(4.0).timeout
	if registry.get_cell(gamepiece) != declared_arrival:
		var trigger_area: Area2D = foyer_port.get_node_or_null("Area2D") as Area2D if is_instance_valid(foyer_port) else null
		var player_area := gamepiece.get_node_or_null("PlayerController/PlayerCollision") as Area2D
		print("MANIFEST_PORT_CONTACT port_global=%s player_global=%s overlapping=%s player_overlaps=%s" % [trigger_area.global_position if trigger_area else Vector2.ZERO, player_area.global_position if player_area else Vector2.ZERO, trigger_area.has_overlapping_areas() if trigger_area else false, player_area.get_overlapping_areas() if player_area else []])
		_fail("Manifest port stopped at %s instead of safe arrival %s (port=%s)." % [registry.get_cell(gamepiece), declared_arrival, port_cell], main)
		return
	if runtime.call(&"active_room_id") != &"HM-02" or main._camera_area != "manifest:HM-02":
		_fail("Blackout did not activate HM-02 (runtime=%s area=%s)." % [runtime.call(&"active_room_id"), main._camera_area], main)
		return
	if Cutscene.is_cutscene_in_progress():
		_fail("Input remained paused after the manifest transition.", main)
		return

	print("CAMPAIGN_MANIFEST_INPUT_HANDOFF_SMOKE_OK controller=manifest click=port runtime=HM01_to_HM02 camera=streamed input=restored")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit()


func _adjacent_walkable_cell(start: Vector2i, gameboard: Node) -> Vector2i:
	# Prefer an interior direction so this probe does not deliberately step onto
	# HM-01's separate Nw facility-return trigger before exercising its Ne port.
	for direction in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		var candidate: Vector2i = start + direction
		var path: Array = gameboard.pathfinder.get_path_to_cell(start, candidate)
		if not path.is_empty():
			return candidate
	return gameboard.INVALID_CELL


func _send_directional_input(direction: Vector2i) -> void:
	var buttons := {
		Vector2i.UP: JOY_BUTTON_DPAD_UP,
		Vector2i.RIGHT: JOY_BUTTON_DPAD_RIGHT,
		Vector2i.DOWN: JOY_BUTTON_DPAD_DOWN,
		Vector2i.LEFT: JOY_BUTTON_DPAD_LEFT,
	}
	if not buttons.has(direction):
		_fail("Controller movement direction must be cardinal: %s" % direction)
		return
	var event := InputEventJoypadButton.new()
	event.button_index = buttons[direction]
	event.pressed = true
	Input.parse_input_event(event)
	await get_tree().process_frame
	event.pressed = false
	Input.parse_input_event(event)


func _fail(message: String, main: Node = null) -> void:
	printerr("CAMPAIGN_MANIFEST_INPUT_HANDOFF_SMOKE_FAILED: " + message)
	if main:
		main.queue_free()
	get_tree().quit(1)
