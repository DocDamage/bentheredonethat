extends Node

## Exercises real D-pad movement after every internal manifest-port arrival.
## This is deliberately narrower than final controller traversal acceptance: it
## proves that every declared arrival can hand control back to the player in the
## live streamer/runtime, while end-to-end input traversal of every port and
## interaction remains a separate release gate.

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	# Apply this fixture's fully-open progression after scene initialization, so
	# the runtime receives a state-change refresh before the first arrival probe.
	CampaignState.party = [&"ben"]
	_unlock_all_manifest_gates()
	var runtime: Node = main.get_node_or_null("Field/Map/CampaignWorld/ManifestRoomRuntime")
	var gameboard: Node = get_tree().root.get_node_or_null("Gameboard")
	var piece_registry: Node = get_tree().root.get_node_or_null("GamepieceRegistry")
	if runtime == null or gameboard == null or piece_registry == null or Player.gamepiece == null:
		_fail("Live campaign runtime did not expose controller movement dependencies.", main)
		return
	var arrivals := 0
	for room_id in REGISTRY.room_ids():
		runtime.call(&"activate", room_id)
		for port in REGISTRY.ports(room_id):
			var port_id := StringName(port.get("id", &""))
			var route := ROUTER.resolve(room_id, port_id)
			if route.is_empty():
				continue
			var destination_room_id := StringName(route.get("destinationRoom", &""))
			if destination_room_id == &"":
				continue
			runtime.call(&"activate", destination_room_id)
			if StringName(runtime.call(&"active_room_id")) != destination_room_id:
				_fail("%s.%s did not synchronously activate destination %s (active=%s)." % [room_id, port_id, destination_room_id, runtime.call(&"active_room_id")], main)
				return
			var destination_definition := REGISTRY.room(destination_room_id)
			var origin: Vector2i = destination_definition.get("worldOrigin", Vector2i.ZERO)
			var local_arrival: Vector2i = route.get("arrivalCell", Vector2i.ZERO)
			var expected_cell := origin + local_arrival
			var player: Gamepiece = Player.gamepiece
			var current_cell: Vector2i = piece_registry.get_cell(player)
			if not gameboard.pathfinder.has_cell(expected_cell) and current_cell != expected_cell:
				_fail("%s.%s destination %s did not install arrival %s." % [room_id, port_id, destination_room_id, expected_cell], main)
				return
			var occupant: Gamepiece = piece_registry.get_gamepiece(expected_cell)
			if occupant != null and occupant != Player.gamepiece:
				_fail("%s.%s arrival %s in %s is occupied by %s before placement." % [room_id, port_id, expected_cell, destination_room_id, occupant.name], main)
				return
			main._place_player(expected_cell)
			await get_tree().process_frame
			var start: Vector2i = piece_registry.get_cell(player)
			if start != expected_cell:
				_fail("%s.%s placed controller probe in %s at %s instead of %s." % [room_id, port_id, destination_room_id, start, expected_cell], main)
				return
			var target := _adjacent_walkable_cell(start, gameboard, destination_definition)
			if target == gameboard.INVALID_CELL:
				_fail("%s.%s safe arrival %s in %s has no controller-reachable neighbor." % [room_id, port_id, start, destination_room_id], main)
				return
			await _send_directional_input(target - start)
			await get_tree().create_timer(0.5).timeout
			if piece_registry.get_cell(player) != target:
				_fail("%s.%s controller move stopped at %s instead of %s." % [room_id, port_id, piece_registry.get_cell(player), target], main)
				return
			if Cutscene.is_cutscene_in_progress():
				_fail("%s.%s left controller input paused after the arrival probe." % [room_id, port_id], main)
				return
			arrivals += 1
	main.queue_free()
	await get_tree().process_frame
	CampaignState.reset_new_game()
	print("CAMPAIGN_MANIFEST_CONTROLLER_ARRIVALS_SMOKE_OK rooms=%d internal_port_arrivals=%d controller=dpad live_runtime=true" % [REGISTRY.room_ids().size(), arrivals])
	get_tree().quit(0)


func _unlock_all_manifest_gates() -> void:
	for room_id in REGISTRY.room_ids():
		for raw_flag in (REGISTRY.room(room_id).get("portGates", {}) as Dictionary).values():
			CampaignState.story_flags[StringName(raw_flag)] = true
	CampaignState.state_changed.emit()


func _adjacent_walkable_cell(start: Vector2i, gameboard: Node, definition: Dictionary) -> Vector2i:
	var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	var port_cells: Dictionary = definition.get("portCells", {})
	for direction in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		var candidate: Vector2i = start + direction
		if candidate - origin in port_cells.values():
			continue
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
	printerr("CAMPAIGN_MANIFEST_CONTROLLER_ARRIVALS_SMOKE_FAILED: " + message)
	if main:
		main.queue_free()
	get_tree().quit(1)
