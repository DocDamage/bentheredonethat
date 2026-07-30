extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	var field: Node = main.get_node("Field")
	field.opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame

	var player_state: Node = get_tree().root.get_node("Player")
	var registry: Node = get_tree().root.get_node("GamepieceRegistry")
	var gameboard: Node = get_tree().root.get_node("Gameboard")
	var field_events: Node = get_tree().root.get_node("FieldEvents")
	var gamepiece: Gamepiece = player_state.gamepiece
	if gamepiece == null:
		_fail("No player gamepiece was assigned")
		return
	var start: Vector2i = registry.get_cell(gamepiece)
	var target: Vector2i = gameboard.INVALID_CELL
	var direction := Vector2i.ZERO
	for candidate in [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]:
		var path: Array = gameboard.pathfinder.get_path_to_cell(start, start + candidate)
		if not path.is_empty():
			target = start + candidate
			direction = candidate
			break
	if target == gameboard.INVALID_CELL:
		_fail("No adjacent walkable cell was found")
		return

	# The click selection route must traverse the template pathfinder/controller.
	field_events.cell_selected.emit(target)
	await get_tree().create_timer(0.5).timeout
	var after_click: Vector2i = registry.get_cell(gamepiece)
	if after_click != target:
		_fail("Click movement did not reach %s (at %s)" % [target, after_click])
		return

	# Send a real joypad event, rather than calling the controller directly.
	var reverse := -direction
	var button_by_direction := {
		Vector2i.UP: JOY_BUTTON_DPAD_UP,
		Vector2i.DOWN: JOY_BUTTON_DPAD_DOWN,
		Vector2i.LEFT: JOY_BUTTON_DPAD_LEFT,
		Vector2i.RIGHT: JOY_BUTTON_DPAD_RIGHT,
	}
	var joy_event := InputEventJoypadButton.new()
	joy_event.button_index = button_by_direction[reverse]
	joy_event.pressed = true
	Input.parse_input_event(joy_event)
	await get_tree().process_frame
	joy_event.pressed = false
	Input.parse_input_event(joy_event)
	await get_tree().create_timer(0.5).timeout
	var after_controller: Vector2i = registry.get_cell(gamepiece)
	if after_controller != start:
		_fail("Controller movement did not return to %s (at %s)" % [start, after_controller])
		return

	# Crossing the laboratory door must use the real Trigger/AreaTransition
	# pipeline and update both registry state and camera bounds.
	var lab_exit := Vector2i(10, 10)
	var town_arrival := Vector2i(50, 8)
	field_events.cell_selected.emit(lab_exit)
	await get_tree().create_timer(1.5).timeout
	var after_lab_exit: Vector2i = registry.get_cell(gamepiece)
	if after_lab_exit != town_arrival:
		_fail("Lab exit did not arrive in town at %s (at %s)" % [town_arrival, after_lab_exit])
		return

	var town_lab_door := Vector2i(50, 7)
	field_events.cell_selected.emit(town_lab_door)
	await get_tree().create_timer(1.5).timeout
	var after_town_door: Vector2i = registry.get_cell(gamepiece)
	if after_town_door != start:
		_fail("Town lab door did not return to %s (at %s)" % [start, after_town_door])
		return

	print("FIELD_INPUT_SMOKE_OK click=%s controller=%s lab_to_town=%s town_to_lab=%s" % [after_click, after_controller, after_lab_exit, after_town_door])
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("FIELD_INPUT_SMOKE_FAILED: " + message)
	get_tree().quit(1)
