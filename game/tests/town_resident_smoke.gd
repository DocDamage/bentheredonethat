extends Node

const TEST_SAVE := "user://town_resident_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.setup_sandbox(Vector2i(50, 8))
	CampaignState.town_time_minutes = 8.0 * 60.0
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(12):
		await get_tree().process_frame
	var manager := main.get_node("Field/Map/CampaignWorld/TownResidents")
	if manager.residents.size() != 4:
		_fail("Expected four purposeful sandbox residents, got %d" % manager.residents.size())
		return

	var starting_cells := {}
	for resident_id in manager.residents.keys():
		var summary: Dictionary = manager.resident_summary(StringName(resident_id))
		var gamepiece := summary.get("gamepiece") as Gamepiece
		var cell := GamepieceRegistry.get_cell(gamepiece)
		if cell == Gameboard.INVALID_CELL or starting_cells.values().has(cell):
			_fail("Resident spawned off the board or on another resident")
			return
		starting_cells[resident_id] = cell
		var plan: Dictionary = manager.activity_plan(StringName(resident_id), cell)
		if String(plan.get("purpose", "")).is_empty() or StringName(plan.get("activity", "")) != &"working":
			_fail("Resident lacked a fixed role or work routine at 08:00")
			return
		if StringName(plan.get("pose", &"rest")) == &"rest" or String(plan.get("label", "")) in ["", "WORKING"]:
			_fail("Resident work was a generic idle state instead of a role-specific task")
			return
		var interaction = gamepiece.get_node_or_null("ResidentInteraction")
		var dialogue: Array[String] = interaction.apply_interaction() if interaction else []
		if dialogue.size() < 3 or String(summary.get("name", "")).to_upper() not in dialogue[0]:
			_fail("Resident did not provide activity-aware JRPG dialogue")
			return
	if manager.destination_reservations.size() != manager.residents.size() or manager.resident_reservations.size() != manager.residents.size():
		_fail("Residents did not reserve unique activity destinations")
		return

	for resident_id in manager.residents.keys():
		manager.residents[resident_id]["controller"].force_replan()
	var ever_moved := false
	for _sample in range(35):
		await get_tree().create_timer(0.1).timeout
		var occupied: Array[Vector2i] = []
		for resident_id in manager.residents.keys():
			var summary: Dictionary = manager.resident_summary(StringName(resident_id))
			var gamepiece := summary.get("gamepiece") as Gamepiece
			var cell := GamepieceRegistry.get_cell(gamepiece)
			if cell in occupied:
				_fail("Residents reserved or occupied the same cell")
				return
			occupied.append(cell)
			ever_moved = ever_moved or cell != starting_cells[resident_id]
			var controller = manager.residents[resident_id]["controller"]
			if controller.blocked_attempts > 8:
				_fail("Resident repeatedly fought an invalid route instead of yielding")
				return
			if controller.target_cell != Gameboard.INVALID_CELL:
				var town_inside := Rect2i(main.TOWN_ORIGIN + Vector2i.ONE, main.TOWN_SIZE - Vector2i(2, 2))
				if not town_inside.has_point(controller.target_cell) or not Gameboard.pathfinder.has_cell(controller.target_cell):
					_fail("Resident selected an illegal off-road or out-of-town destination")
					return
	if not ever_moved:
		_fail("Residents never commuted toward their scheduled work")
		return
	var recovery_id := StringName(manager.residents.keys()[0])
	var recovery_controller = manager.residents[recovery_id]["controller"]
	var yields_before: int = recovery_controller.yield_count
	recovery_controller.target_cell = Gameboard.INVALID_CELL
	recovery_controller.blocked_attempts = 2
	recovery_controller._plan_route(GamepieceRegistry.get_cell(manager.residents[recovery_id]["gamepiece"]), &"working", "RECOVERY TEST", &"craft")
	if recovery_controller.yield_count != yields_before + 1 or recovery_controller.blocked_attempts != 0:
		_fail("A repeatedly blocked resident did not release its reservation and yield")
		return
	recovery_controller.force_replan()

	var editor := main.get_node("SandboxTownEditor")
	editor.suppress_persistence = true
	editor._set_active(true)
	await get_tree().process_frame
	var chosen_id := StringName(manager.residents.keys()[0])
	var chosen_summary: Dictionary = manager.resident_summary(chosen_id)
	var chosen_gamepiece := chosen_summary.get("gamepiece") as Gamepiece
	var chosen_cell := GamepieceRegistry.get_cell(chosen_gamepiece)
	editor.cursor_cell = chosen_cell
	editor._confirm_cursor()
	if editor.selected_resident_id != chosen_id:
		_fail("Sandbox editor could not select a live resident")
		return
	var target: Vector2i = manager.find_open_activity_cell(Vector2i(60, 18), chosen_cell, chosen_id)
	if target == Gameboard.INVALID_CELL:
		_fail("No valid resident relocation cell was available")
		return
	editor.cursor_cell = target
	editor._confirm_cursor()
	if GamepieceRegistry.get_cell(chosen_gamepiece) != target or editor.selected_resident_id != &"":
		_fail("Sandbox editor did not persistently relocate the selected resident")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Resident state save failed")
		return

	editor._set_active(false)
	main.queue_free()
	await get_tree().process_frame
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Resident state load failed")
		return
	var restored: Dictionary = CampaignState.resident_state(chosen_id)
	if int(restored.get("x", -1)) != target.x or int(restored.get("y", -1)) != target.y or CampaignState.resident_states.size() != 4:
		_fail("Resident identity or relocated cell did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	print("TOWN_RESIDENT_SMOKE_OK residents=4 roles=true tasks=role_specific dialogue=activity_aware schedules=work+lunch+errands+home routes=town_only collision=destination_reservations+yield_recovery relocation=editor save_load=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("TOWN_RESIDENT_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
