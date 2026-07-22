extends Node

const TEST_SAVE := "user://town_resident_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	for slot_id in range(1, CampaignState.SANDBOX_LAYOUT_SLOT_COUNT + 1):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CampaignState.sandbox_layout_slot_path(slot_id)))
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
	var before_history := CampaignState.sandbox_layout_snapshot()
	var undo_before: int = editor._undo_stack.size()
	editor.editor_mode = &"terrain"
	editor.pack_index = 0
	editor.item_index = 0
	for edit_index in range(100):
		editor.cursor_cell = Vector2i(37 + edit_index % 25, 20 + int(edit_index / 25))
		editor._paint_terrain()
	if editor._undo_stack.size() != mini(100, undo_before + 100):
		_fail("Sandbox history did not retain every committed paint action")
		return
	var after_history := CampaignState.sandbox_layout_snapshot()
	for _undo in range(100):
		editor._undo_sandbox_edit()
	if CampaignState.sandbox_layout_snapshot() != before_history:
		_fail("A 100-action sandbox undo sequence did not restore the exact prior layout")
		return
	for _redo in range(100):
		editor._redo_sandbox_edit()
	if CampaignState.sandbox_layout_snapshot() != after_history:
		_fail("A 100-action sandbox redo sequence did not restore the exact painted layout")
		return
	editor.editor_mode = &"objects"
	var copy_source := Gameboard.INVALID_CELL
	for y in range(main.TOWN_ORIGIN.y + 1, main.TOWN_ORIGIN.y + main.TOWN_SIZE.y - 3):
		for x in range(main.TOWN_ORIGIN.x + 1, main.TOWN_ORIGIN.x + main.TOWN_SIZE.x - 3):
			var candidate := Vector2i(x, y)
			if editor._placement_valid(editor._current_catalog_id(), candidate):
				copy_source = candidate
				break
		if copy_source != Gameboard.INVALID_CELL:
			break
	if copy_source == Gameboard.INVALID_CELL:
		_fail("Sandbox object placement unexpectedly blocked the clipboard test")
		return
	var objects_before_copy := CampaignState.town_objects.size()
	editor.cursor_cell = copy_source
	editor._confirm_cursor()
	editor.cursor_cell = copy_source
	editor._confirm_cursor()
	editor._copy_selected_object()
	var copy_target := Gameboard.INVALID_CELL
	for y in range(main.TOWN_ORIGIN.y + 1, main.TOWN_ORIGIN.y + main.TOWN_SIZE.y - 3):
		for x in range(main.TOWN_ORIGIN.x + 1, main.TOWN_ORIGIN.x + main.TOWN_SIZE.x - 3):
			var candidate := Vector2i(x, y)
			if editor._placement_valid(editor._current_catalog_id(), candidate):
				copy_target = candidate
				break
		if copy_target != Gameboard.INVALID_CELL:
			break
	if copy_target == Gameboard.INVALID_CELL:
		_fail("Sandbox copy target unexpectedly had no legal cell")
		return
	editor.cursor_cell = copy_target
	editor._paste_copied_object()
	if CampaignState.town_objects.size() != objects_before_copy + 2:
		_fail("Sandbox copy/paste did not create an independent duplicate object")
		return
	var editable_objects: Array[Dictionary] = []
	for placed in CampaignState.town_objects:
		if not bool(placed.get("protected", false)):
			editable_objects.append(placed)
	if editable_objects.size() < 2:
		_fail("Sandbox did not retain two editable objects for multiselect")
		return
	editor._box_selection_start = Vector2i(int(editable_objects[0].get("x", 0)), int(editable_objects[0].get("y", 0)))
	editor._commit_box_selection(Vector2i(int(editable_objects[1].get("x", 0)) + 3, int(editable_objects[1].get("y", 0)) + 1))
	if not editor.selected_instance_ids.has(String(editable_objects[0].get("instance_id", ""))) or not editor.selected_instance_ids.has(String(editable_objects[1].get("instance_id", ""))):
		_fail("Sandbox middle-drag box selection did not retain both editable objects")
		return
	editor._clear_object_selection()
	editor._toggle_multi_selection_at(Vector2i(int(editable_objects[0].get("x", 0)), int(editable_objects[0].get("y", 0))))
	editor._toggle_multi_selection_at(Vector2i(int(editable_objects[1].get("x", 0)), int(editable_objects[1].get("y", 0))))
	if editor.selected_instance_ids.size() != 2:
		_fail("Sandbox ctrl-click multiselect did not retain both editable objects")
		return
	editor._begin_multi_move()
	var group_delta := Gameboard.INVALID_CELL
	for candidate_delta in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), Vector2i(2, 0), Vector2i(0, 2)]:
		if editor._multi_move_valid(candidate_delta):
			group_delta = candidate_delta
			break
	if group_delta == Gameboard.INVALID_CELL:
		_fail("Sandbox multiselect did not find a legal group move")
		return
	var group_before := CampaignState.sandbox_layout_snapshot()
	editor.cursor_cell = editor._multi_move_origin + group_delta
	editor._commit_multi_move()
	if CampaignState.sandbox_layout_snapshot() == group_before:
		_fail("Sandbox group move did not commit a batch layout command")
		return
	editor._undo_sandbox_edit()
	if CampaignState.sandbox_layout_snapshot() != group_before:
		_fail("Sandbox batch move undo did not restore the exact prior layout")
		return
	editor._redo_sandbox_edit()
	if CampaignState.sandbox_layout_snapshot() == group_before:
		_fail("Sandbox batch move redo did not restore the moved layout")
		return
	editor.pack_index = 1
	editor._set_search_query("town cat")
	var search_results: Array[StringName] = editor._pack_items()
	if search_results.size() != 1 or search_results[0] != &"ranch_cat":
		_fail("Sandbox pack search did not filter catalog IDs and names")
		return
	editor._set_search_query("")
	var slot_layout := CampaignState.sandbox_layout_snapshot()
	if CampaignState.save_sandbox_layout_slot(1) != OK:
		_fail("Sandbox layout slot save failed")
		return
	var terrain_cell := Gameboard.INVALID_CELL
	editor.editor_mode = &"terrain"
	for y in range(main.TOWN_ORIGIN.y + 1, main.TOWN_ORIGIN.y + main.TOWN_SIZE.y - 1):
		for x in range(main.TOWN_ORIGIN.x + 1, main.TOWN_ORIGIN.x + main.TOWN_SIZE.x - 1):
			var candidate := Vector2i(x, y)
			if editor._terrain_placement_valid(editor._current_catalog_id(), candidate) and CampaignState.town_terrain_at(candidate) != editor._current_catalog_id():
				terrain_cell = candidate
				break
		if terrain_cell != Gameboard.INVALID_CELL:
			break
	if terrain_cell == Gameboard.INVALID_CELL:
		_fail("Sandbox layout slot test could not find a terrain mutation cell")
		return
	editor.cursor_cell = terrain_cell
	editor._paint_terrain()
	if CampaignState.sandbox_layout_snapshot() == slot_layout:
		_fail("Sandbox layout slot mutation did not change the current layout")
		return
	var loaded_slot := CampaignState.load_sandbox_layout_slot(1)
	if not bool(loaded_slot.get("loaded", false)):
		_fail("Sandbox layout slot load failed")
		return
	main.restore_sandbox_layout()
	var slot_layout_matches := CampaignState.sandbox_layout_snapshot() == slot_layout
	var slot_routes_valid: bool = main.sandbox_required_routes_reachable()
	if not slot_layout_matches or not slot_routes_valid:
		_fail("Sandbox layout slot did not preserve the exact valid layout and routes (layout=%s routes=%s)" % [slot_layout_matches, slot_routes_valid])
		return
	var invalid_before := CampaignState.sandbox_layout_snapshot()
	var invalid_slot_file := FileAccess.open(CampaignState.sandbox_layout_slot_path(3), FileAccess.WRITE)
	invalid_slot_file.store_string('{"version":1,"layout":{"town_objects":[]}}')
	invalid_slot_file.close()
	if bool(CampaignState.load_sandbox_layout_slot(3).get("loaded", false)) or CampaignState.sandbox_layout_snapshot() != invalid_before:
		_fail("Malformed sandbox layout overwrote a valid current layout")
		return
	editor.editor_mode = &"objects"
	editor._sync_renderer()
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
	for slot_id in range(1, CampaignState.SANDBOX_LAYOUT_SLOT_COUNT + 1):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CampaignState.sandbox_layout_slot_path(slot_id)))
	CampaignState.reset_new_game()
	print("TOWN_RESIDENT_SMOKE_OK residents=4 roles=true tasks=role_specific dialogue=activity_aware schedules=work+lunch+errands+home routes=town_only collision=destination_reservations+yield_recovery relocation=editor history=100_action_undo_redo clipboard=true multiselect=batch_move search=pack_filter slots=validated save_load=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("TOWN_RESIDENT_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	for slot_id in range(1, CampaignState.SANDBOX_LAYOUT_SLOT_COUNT + 1):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(CampaignState.sandbox_layout_slot_path(slot_id)))
	get_tree().quit(1)
