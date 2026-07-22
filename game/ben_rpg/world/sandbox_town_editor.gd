class_name SandboxTownEditor
extends CanvasLayer

const UI_ROOT := "res://game_assets/Tilesets/Dark RPG GUI Kit - Pixel Art Asset Pack"
const UI_PARTY_HUD := UI_ROOT + "/dfgui_partyhud.png"
const CATALOG := preload("res://ben_rpg/world/sandbox_object_catalog.gd")
const TERRAIN_CATALOG := preload("res://ben_rpg/world/sandbox_terrain_catalog.gd")
const SANDBOX_VISUAL_RESOLVER := preload("res://ben_rpg/world/sandbox_visual_resolver.gd")
const HISTORY_LIMIT := 100

var campaign: Node
var renderer
var suppress_persistence := false
var active := false
var editor_mode: StringName = &"objects"
var cursor_cell := Vector2i(50, 10)
var selected_instance_id := ""
var selected_instance_ids: Array[String] = []
var selected_resident_id: StringName = &""
var pack_index := 0
var item_index := 0
var _panel: PanelContainer
var _pack_label: Label
var _item_label: Label
var _mode_label: Label
var _preview: TextureRect
var _help_label: Label
var _last_painted_cell := Gameboard.INVALID_CELL
var _undo_stack: Array[Dictionary] = []
var _redo_stack: Array[Dictionary] = []
var _clipboard: Dictionary = {}
var _box_selection_start := Gameboard.INVALID_CELL
var _multi_move_origin := Gameboard.INVALID_CELL
var _search_query := ""
var _search_input: LineEdit
var _sandbox_visuals = SANDBOX_VISUAL_RESOLVER.new()


func _ready() -> void:
	layer = 35
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_hud()
	_panel.hide()


func _process(_delta: float) -> void:
	if active and (not CampaignState.sandbox_mode or not _player_is_in_town()):
		_set_active(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("town_build_mode"):
		if CampaignState.sandbox_mode and _player_is_in_town():
			_set_active(not active)
			get_viewport().set_input_as_handled()
		return
	if not active:
		return
	if _search_input and _search_input.has_focus() and event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_ESCAPE:
			_search_input.release_focus()
			get_viewport().set_input_as_handled()
			return
		elif not event.ctrl_pressed:
			return
	if event is InputEventMouseMotion and editor_mode == &"terrain":
		var drag_cell := _screen_to_cell(event.position)
		if drag_cell != _last_painted_cell and (event.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			cursor_cell = drag_cell
			_paint_terrain()
			get_viewport().set_input_as_handled()
			return
		if drag_cell != _last_painted_cell and (event.button_mask & MOUSE_BUTTON_MASK_RIGHT) != 0:
			cursor_cell = drag_cell
			_clear_terrain()
			get_viewport().set_input_as_handled()
			return
	if event is InputEventMouseMotion and _box_selection_start != Gameboard.INVALID_CELL:
		cursor_cell = _screen_to_cell(event.position)
		_sync_renderer()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("back") or event.is_action_pressed("ui_cancel"):
		if selected_instance_id.is_empty() and selected_instance_ids.is_empty() and selected_resident_id == &"":
			_set_active(false)
		else:
			_clear_object_selection()
			_sync_renderer()
			_refresh_hud()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_BACK:
				_toggle_editor_mode()
			JOY_BUTTON_LEFT_SHOULDER:
				_cycle_item(-1)
			JOY_BUTTON_RIGHT_SHOULDER:
				_cycle_item(1)
			JOY_BUTTON_LEFT_STICK:
				_cycle_pack(1)
			JOY_BUTTON_RIGHT_STICK:
				_flip_selected()
			JOY_BUTTON_X:
				_remove_selected_or_cursor()
			_:
				pass
		if event.button_index in [JOY_BUTTON_BACK, JOY_BUTTON_LEFT_SHOULDER, JOY_BUTTON_RIGHT_SHOULDER, JOY_BUTTON_LEFT_STICK, JOY_BUTTON_RIGHT_STICK, JOY_BUTTON_X]:
			get_viewport().set_input_as_handled()
			return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.ctrl_pressed and event.physical_keycode == KEY_F:
			_focus_search()
			get_viewport().set_input_as_handled()
			return
		if event.shift_pressed and not event.ctrl_pressed and event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_3:
			_load_layout_slot(event.physical_keycode - KEY_1 + 1)
			get_viewport().set_input_as_handled()
			return
		if event.ctrl_pressed and event.physical_keycode >= KEY_1 and event.physical_keycode <= KEY_3:
			_save_layout_slot(event.physical_keycode - KEY_1 + 1)
			get_viewport().set_input_as_handled()
			return
		if event.ctrl_pressed and event.physical_keycode == KEY_Z:
			_undo_sandbox_edit()
			get_viewport().set_input_as_handled()
			return
		if event.ctrl_pressed and event.physical_keycode == KEY_Y:
			_redo_sandbox_edit()
			get_viewport().set_input_as_handled()
			return
		if event.ctrl_pressed and event.physical_keycode == KEY_C:
			_copy_selected_object()
			get_viewport().set_input_as_handled()
			return
		if event.ctrl_pressed and event.physical_keycode == KEY_V:
			_paste_copied_object()
			get_viewport().set_input_as_handled()
			return
		match event.physical_keycode:
			KEY_T:
				_toggle_editor_mode()
			KEY_Q:
				_cycle_pack(-1)
			KEY_E:
				_cycle_pack(1)
			KEY_Z:
				_cycle_item(-1)
			KEY_C:
				_cycle_item(1)
			KEY_F:
				_flip_selected()
			KEY_G:
				_begin_multi_move()
			KEY_DELETE:
				_remove_selected_or_cursor()
			_:
				pass
		if event.physical_keycode in [KEY_T, KEY_Q, KEY_E, KEY_Z, KEY_C, KEY_F, KEY_G, KEY_DELETE]:
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("ui_left"):
		_move_cursor(Vector2i.LEFT)
	elif event.is_action_pressed("ui_right"):
		_move_cursor(Vector2i.RIGHT)
	elif event.is_action_pressed("ui_up"):
		_move_cursor(Vector2i.UP)
	elif event.is_action_pressed("ui_down"):
		_move_cursor(Vector2i.DOWN)
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_confirm_cursor()
	elif event is InputEventMouseButton:
		cursor_cell = _screen_to_cell(event.position)
		_last_painted_cell = Gameboard.INVALID_CELL
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_box_selection_start = cursor_cell
			else:
				_commit_box_selection(cursor_cell)
		elif not event.pressed:
			return
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.ctrl_pressed:
				_toggle_multi_selection_at(cursor_cell)
			else:
				_confirm_cursor()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_remove_selected_or_cursor()
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_cycle_item(-1)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_cycle_item(1)
	else:
		return
	get_viewport().set_input_as_handled()


func _set_active(value: bool) -> void:
	active = value
	_clear_object_selection()
	_last_painted_cell = Gameboard.INVALID_CELL
	if value:
		var player_cell := GamepieceRegistry.get_cell(Player.gamepiece)
		cursor_cell = player_cell + Vector2i(2, 0)
		cursor_cell.x = clampi(cursor_cell.x, campaign.TOWN_ORIGIN.x + 1, campaign.TOWN_ORIGIN.x + campaign.TOWN_SIZE.x - 2)
		cursor_cell.y = clampi(cursor_cell.y, campaign.TOWN_ORIGIN.y + 1, campaign.TOWN_ORIGIN.y + campaign.TOWN_SIZE.y - 2)
		_panel.show()
		FieldEvents.input_paused.emit(true)
	else:
		_panel.hide()
		FieldEvents.input_paused.emit(false)
	_sync_renderer()
	_refresh_hud()


func _move_cursor(direction: Vector2i) -> void:
	cursor_cell += direction
	cursor_cell.x = clampi(cursor_cell.x, campaign.TOWN_ORIGIN.x + 1, campaign.TOWN_ORIGIN.x + campaign.TOWN_SIZE.x - 2)
	cursor_cell.y = clampi(cursor_cell.y, campaign.TOWN_ORIGIN.y + 1, campaign.TOWN_ORIGIN.y + campaign.TOWN_SIZE.y - 2)
	_sync_renderer()


func _confirm_cursor() -> void:
	if editor_mode == &"terrain":
		_paint_terrain()
		return
	if _multi_move_origin != Gameboard.INVALID_CELL:
		_commit_multi_move()
		return
	if not selected_instance_ids.is_empty():
		_mode_label.text = "MULTISELECT READY — PRESS G TO MOVE %d OBJECTS, F TO FLIP, OR DELETE TO REMOVE" % selected_instance_ids.size()
		return
	if selected_resident_id != &"":
		var before := _layout_snapshot()
		if _resident_placement_valid(cursor_cell, selected_resident_id) and campaign.relocate_sandbox_resident(selected_resident_id, cursor_cell):
			_after_mutation(before)
			cursor_cell.x = mini(cursor_cell.x + 2, campaign.TOWN_ORIGIN.x + campaign.TOWN_SIZE.x - 2)
		selected_resident_id = &""
		_sync_renderer()
		_refresh_hud()
		return
	if not selected_instance_id.is_empty():
		var moved_catalog_id := _selected_catalog_id()
		if _placement_valid(moved_catalog_id, cursor_cell, selected_instance_id):
			var before := _layout_snapshot()
			CampaignState.move_town_object(selected_instance_id, cursor_cell)
			_after_mutation(before)
			var moved_footprint: Vector2i = CATALOG.definition(moved_catalog_id).get("footprint", Vector2i.ONE)
			cursor_cell.x = mini(cursor_cell.x + moved_footprint.x + 1, campaign.TOWN_ORIGIN.x + campaign.TOWN_SIZE.x - 2)
		selected_instance_id = ""
		_sync_renderer()
		_refresh_hud()
		return
	var existing: Dictionary = renderer.object_at_cell(cursor_cell)
	if not existing.is_empty():
		_clear_object_selection()
		selected_instance_id = String(existing.get("instance_id", ""))
		cursor_cell = Vector2i(int(existing.get("x", cursor_cell.x)), int(existing.get("y", cursor_cell.y)))
		_sync_renderer()
		_refresh_hud()
		return
	var resident: Dictionary = campaign.sandbox_resident_at_cell(cursor_cell)
	if not resident.is_empty():
		selected_resident_id = StringName(resident.get("resident_id", ""))
		_sync_renderer()
		_refresh_hud()
		return
	var catalog_id := _current_catalog_id()
	if _placement_valid(catalog_id, cursor_cell):
		var before := _layout_snapshot()
		CampaignState.place_town_object(catalog_id, cursor_cell)
		_after_mutation(before)
		var footprint: Vector2i = CATALOG.definition(catalog_id).get("footprint", Vector2i.ONE)
		cursor_cell.x = mini(cursor_cell.x + footprint.x + 1, campaign.TOWN_ORIGIN.x + campaign.TOWN_SIZE.x - 2)
	_sync_renderer()


func _remove_selected_or_cursor() -> void:
	if editor_mode == &"terrain":
		_clear_terrain()
		return
	if not selected_instance_ids.is_empty():
		var before_batch := _layout_snapshot()
		for selected_id in selected_instance_ids:
			CampaignState.remove_town_object(selected_id)
		_clear_object_selection()
		_after_mutation(before_batch)
		_sync_renderer()
		_refresh_hud()
		return
	if selected_resident_id != &"":
		_mode_label.text = "PROTECTED RESIDENT — RELOCATE THEM; RESIDENTS CANNOT BE DELETED"
		return
	var instance_id := selected_instance_id
	if instance_id.is_empty():
		var resident: Dictionary = campaign.sandbox_resident_at_cell(cursor_cell)
		if not resident.is_empty():
			selected_resident_id = StringName(resident.get("resident_id", ""))
			_mode_label.text = "PROTECTED RESIDENT — RELOCATE THEM; RESIDENTS CANNOT BE DELETED"
			_sync_renderer()
			return
		instance_id = String(renderer.object_at_cell(cursor_cell).get("instance_id", ""))
	if instance_id.is_empty():
		return
	var placed := CampaignState.town_object(instance_id)
	if bool(placed.get("protected", false)):
		_mode_label.text = "PROTECTED TOWN FACILITY — RELOCATE OR FLIP; IT CANNOT BE DESTROYED"
		return
	var before := _layout_snapshot()
	CampaignState.remove_town_object(instance_id)
	selected_instance_id = ""
	_after_mutation(before)
	_sync_renderer()
	_refresh_hud()


func _flip_selected() -> void:
	if editor_mode == &"terrain" or selected_resident_id != &"":
		return
	if not selected_instance_ids.is_empty():
		var before_batch := _layout_snapshot()
		for selected_id in selected_instance_ids:
			CampaignState.flip_town_object(selected_id)
		_after_mutation(before_batch)
		_sync_renderer()
		_refresh_hud()
		return
	if selected_instance_id.is_empty():
		return
	var before := _layout_snapshot()
	if CampaignState.flip_town_object(selected_instance_id):
		_after_mutation(before)
		_sync_renderer()


func _clear_object_selection() -> void:
	selected_instance_id = ""
	selected_instance_ids.clear()
	selected_resident_id = &""
	_multi_move_origin = Gameboard.INVALID_CELL
	_box_selection_start = Gameboard.INVALID_CELL


func _toggle_multi_selection_at(cell: Vector2i) -> void:
	if editor_mode != &"objects":
		return
	var placed: Dictionary = renderer.object_at_cell(cell)
	if placed.is_empty():
		return
	var instance_id := String(placed.get("instance_id", ""))
	if bool(placed.get("protected", false)):
		_mode_label.text = "PROTECTED TOWN FACILITY — MOVE IT INDIVIDUALLY TO PRESERVE ITS SERVICE DOOR"
		return
	selected_instance_id = ""
	selected_resident_id = &""
	_multi_move_origin = Gameboard.INVALID_CELL
	var selected_index := selected_instance_ids.find(instance_id)
	if selected_index >= 0:
		selected_instance_ids.remove_at(selected_index)
	else:
		selected_instance_ids.append(instance_id)
	_sync_renderer()
	_refresh_hud()


func _commit_box_selection(end_cell: Vector2i) -> void:
	if editor_mode != &"objects" or _box_selection_start == Gameboard.INVALID_CELL:
		_box_selection_start = Gameboard.INVALID_CELL
		return
	var start := _box_selection_start
	_box_selection_start = Gameboard.INVALID_CELL
	var selection := Rect2i(
		Vector2i(mini(start.x, end_cell.x), mini(start.y, end_cell.y)),
		Vector2i(absi(end_cell.x - start.x) + 1, absi(end_cell.y - start.y) + 1)
	)
	selected_instance_id = ""
	selected_resident_id = &""
	selected_instance_ids.clear()
	for placed in CampaignState.town_objects:
		if selection.intersects(renderer.placed_cell_rect(placed)) and not bool(placed.get("protected", false)):
			selected_instance_ids.append(String(placed.get("instance_id", "")))
	if selected_instance_ids.is_empty():
		_mode_label.text = "BOX SELECT FOUND NO EDITABLE OBJECTS — PROTECTED FACILITIES STAY INDIVIDUAL"
	_sync_renderer()
	_refresh_hud()


func _begin_multi_move() -> void:
	if editor_mode != &"objects" or selected_instance_ids.size() < 2:
		_mode_label.text = "SELECT TWO OR MORE UNPROTECTED OBJECTS WITH CTRL+CLICK OR MIDDLE-DRAG"
		return
	var anchor := Vector2i(9999, 9999)
	for instance_id in selected_instance_ids:
		var placed := CampaignState.town_object(instance_id)
		anchor.x = mini(anchor.x, int(placed.get("x", anchor.x)))
		anchor.y = mini(anchor.y, int(placed.get("y", anchor.y)))
	_multi_move_origin = anchor
	cursor_cell = anchor
	_mode_label.text = "MOVING %d OBJECTS — MOVE CURSOR, THEN PRESS ENTER OR CLICK TO COMMIT" % selected_instance_ids.size()
	_sync_renderer()


func _multi_move_valid(delta: Vector2i) -> bool:
	if _multi_move_origin == Gameboard.INVALID_CELL or selected_instance_ids.is_empty():
		return false
	var town_inside := Rect2i(campaign.TOWN_ORIGIN + Vector2i.ONE, campaign.TOWN_SIZE - Vector2i(2, 2))
	var selected_set := {}
	var proposed_rects: Array[Rect2i] = []
	for instance_id in selected_instance_ids:
		selected_set[instance_id] = true
		var placed := CampaignState.town_object(instance_id)
		if placed.is_empty() or bool(placed.get("protected", false)):
			return false
		var proposed := Rect2i(renderer.placed_cell_rect(placed).position + delta, renderer.placed_cell_rect(placed).size)
		if not town_inside.encloses(proposed):
			return false
		for earlier in proposed_rects:
			if proposed.intersects(earlier):
				return false
		proposed_rects.append(proposed)
	for plot_index in CampaignState.built_facilities.keys():
		var facility_rect: Rect2i = campaign.FACILITY_PLOTS[int(plot_index)]
		facility_rect.position += campaign.TOWN_ORIGIN
		for proposed in proposed_rects:
			if proposed.intersects(facility_rect):
				return false
	for placed in CampaignState.town_objects:
		if selected_set.has(String(placed.get("instance_id", ""))):
			continue
		for proposed in proposed_rects:
			if proposed.intersects(renderer.placed_cell_rect(placed)):
				return false
	for proposed in proposed_rects:
		for y in range(proposed.position.y, proposed.end.y):
			for x in range(proposed.position.x, proposed.end.x):
				if GamepieceRegistry.get_gamepiece(Vector2i(x, y)):
					return false
	return true


func _commit_multi_move() -> void:
	var delta := cursor_cell - _multi_move_origin
	if delta == Vector2i.ZERO:
		_multi_move_origin = Gameboard.INVALID_CELL
		_sync_renderer()
		_refresh_hud()
		return
	if not _multi_move_valid(delta):
		_mode_label.text = "GROUP MOVE BLOCKED — KEEP EVERY FOOTPRINT CLEAR, IN BOUNDS, AND OFF TOWN SERVICES"
		return
	var before := _layout_snapshot()
	for instance_id in selected_instance_ids:
		var placed := CampaignState.town_object(instance_id)
		CampaignState.move_town_object(instance_id, Vector2i(int(placed.get("x", 0)), int(placed.get("y", 0))) + delta)
	_clear_object_selection()
	_after_mutation(before)
	_sync_renderer()
	_refresh_hud()


func _after_mutation(before: Dictionary = {}) -> bool:
	if campaign:
		campaign.refresh_sandbox_object_collision()
		if not campaign.sandbox_required_routes_reachable():
			CampaignState.restore_sandbox_layout(before)
			campaign.restore_sandbox_layout()
			_mode_label.text = "EDIT BLOCKED — IT WOULD STRAND A REQUIRED TOWN ROUTE"
			return false
	_record_history(before)
	if not suppress_persistence:
		CampaignState.save_game()
	return true


func _layout_snapshot() -> Dictionary:
	return CampaignState.sandbox_layout_snapshot()


func _record_history(before: Dictionary) -> void:
	if before.is_empty():
		return
	var after := _layout_snapshot()
	if after == before:
		return
	_undo_stack.append({"before": before, "after": after})
	if _undo_stack.size() > HISTORY_LIMIT:
		_undo_stack.pop_front()
	_redo_stack.clear()


func _undo_sandbox_edit() -> void:
	if _undo_stack.is_empty():
		_mode_label.text = "NOTHING TO UNDO — THE SANDBOX HISTORY IS CLEAR"
		return
	var command: Dictionary = _undo_stack.pop_back()
	var before: Dictionary = command.get("before", {})
	if not CampaignState.restore_sandbox_layout(before):
		return
	_redo_stack.append(command)
	_after_history_restore("UNDID EDIT")


func _redo_sandbox_edit() -> void:
	if _redo_stack.is_empty():
		_mode_label.text = "NOTHING TO REDO — MAKE A NEW EDIT TO START A NEW BRANCH"
		return
	var command: Dictionary = _redo_stack.pop_back()
	var after: Dictionary = command.get("after", {})
	if not CampaignState.restore_sandbox_layout(after):
		return
	_undo_stack.append(command)
	_after_history_restore("REDID EDIT")


func _after_history_restore(message: String) -> void:
	if campaign:
		campaign.restore_sandbox_layout()
	if not suppress_persistence:
		CampaignState.save_game()
	_clear_object_selection()
	_sync_renderer()
	_refresh_hud()
	_mode_label.text = "%s   •   UNDO %d   •   REDO %d" % [message, _undo_stack.size(), _redo_stack.size()]


func _copy_selected_object() -> void:
	if selected_instance_id.is_empty():
		_mode_label.text = "SELECT AN UNPROTECTED OBJECT BEFORE COPYING"
		return
	var placed := CampaignState.town_object(selected_instance_id)
	if placed.is_empty() or bool(placed.get("protected", false)):
		_mode_label.text = "PROTECTED ANCHORS CANNOT BE COPIED"
		return
	_clipboard = {
		"catalog_id": StringName(placed.get("catalog_id", "")),
		"flipped": bool(placed.get("flipped", false)),
	}
	_mode_label.text = "COPIED %s — MOVE THE CURSOR AND PRESS CTRL+V" % String(CATALOG.definition(_clipboard["catalog_id"]).get("name", "OBJECT")).to_upper()


func _paste_copied_object() -> void:
	if editor_mode != &"objects" or _clipboard.is_empty():
		_mode_label.text = "COPY AN OBJECT BEFORE PASTING"
		return
	var catalog_id := StringName(_clipboard.get("catalog_id", ""))
	if not _placement_valid(catalog_id, cursor_cell):
		_mode_label.text = "PASTE BLOCKED — CHOOSE A CLEAR, REACHABLE TOWN CELL"
		return
	var before := _layout_snapshot()
	if CampaignState.place_town_object(catalog_id, cursor_cell, bool(_clipboard.get("flipped", false))).is_empty():
		return
	_after_mutation(before)
	_sync_renderer()
	_refresh_hud()


func _toggle_editor_mode() -> void:
	editor_mode = &"terrain" if editor_mode == &"objects" else &"objects"
	_clear_object_selection()
	pack_index = 0
	item_index = 0
	_last_painted_cell = Gameboard.INVALID_CELL
	_refresh_hud()
	_sync_renderer()


func _paint_terrain() -> void:
	var brush_id := _current_catalog_id()
	if not _terrain_placement_valid(brush_id, cursor_cell):
		_sync_renderer()
		return
	var before := _layout_snapshot()
	if CampaignState.paint_town_terrain(cursor_cell, brush_id):
		_last_painted_cell = cursor_cell
		_after_mutation(before)
		_sync_renderer()


func _clear_terrain() -> void:
	var before := _layout_snapshot()
	if CampaignState.clear_town_terrain(cursor_cell):
		_last_painted_cell = cursor_cell
		_after_mutation(before)
		_sync_renderer()


func _placement_valid(catalog_id: StringName, cell: Vector2i, ignore_instance := "") -> bool:
	var definition := CATALOG.definition(catalog_id)
	if definition.is_empty():
		return false
	var footprint: Vector2i = definition.get("footprint", Vector2i.ONE)
	var proposed := Rect2i(cell, footprint)
	var town_inside := Rect2i(campaign.TOWN_ORIGIN + Vector2i.ONE, campaign.TOWN_SIZE - Vector2i(2, 2))
	if not town_inside.encloses(proposed):
		return false
	for plot_index in CampaignState.built_facilities.keys():
		var facility_rect: Rect2i = campaign.FACILITY_PLOTS[int(plot_index)]
		facility_rect.position += campaign.TOWN_ORIGIN
		if proposed.intersects(facility_rect):
			return false
	for placed in CampaignState.town_objects:
		if String(placed.get("instance_id", "")) == ignore_instance:
			continue
		if proposed.intersects(renderer.placed_cell_rect(placed)):
			return false
	for y in range(proposed.position.y, proposed.end.y):
		for x in range(proposed.position.x, proposed.end.x):
			var occupant := GamepieceRegistry.get_gamepiece(Vector2i(x, y))
			if occupant and occupant != Player.gamepiece:
				return false
			if occupant == Player.gamepiece:
				return false
	return true


func _resident_placement_valid(cell: Vector2i, resident_id: StringName) -> bool:
	var town_inside := Rect2i(campaign.TOWN_ORIGIN + Vector2i.ONE, campaign.TOWN_SIZE - Vector2i(2, 2))
	if not town_inside.has_point(cell) or not Gameboard.pathfinder.has_cell(cell):
		return false
	if not renderer.object_at_cell(cell).is_empty():
		return false
	var occupant := GamepieceRegistry.get_gamepiece(cell)
	if not occupant:
		return true
	var summary: Dictionary = campaign.sandbox_resident_summary(resident_id)
	return occupant == summary.get("gamepiece")


func _terrain_placement_valid(brush_id: StringName, cell: Vector2i) -> bool:
	var definition: Dictionary = TERRAIN_CATALOG.definition(brush_id)
	var town_inside := Rect2i(campaign.TOWN_ORIGIN + Vector2i.ONE, campaign.TOWN_SIZE - Vector2i(2, 2))
	if definition.is_empty() or not town_inside.has_point(cell):
		return false
	if not bool(definition.get("blocks", false)):
		return true
	if GamepieceRegistry.get_gamepiece(cell) or not renderer.object_at_cell(cell).is_empty():
		return false
	for plot_index in CampaignState.built_facilities.keys():
		var facility_rect: Rect2i = campaign.FACILITY_PLOTS[int(plot_index)]
		facility_rect.position += campaign.TOWN_ORIGIN
		if facility_rect.has_point(cell):
			return false
	for transition_name in ["TownLaboratoryDoor", "HauntedMansionEntrance"]:
		var transition := campaign.get_node_or_null("Field/Map/CampaignWorld/%s" % transition_name) as Node2D
		if transition and Gameboard.pixel_to_cell(transition.position) == cell:
			return false
	return true


func _cycle_pack(direction: int) -> void:
	if not selected_instance_id.is_empty() or not selected_instance_ids.is_empty() or selected_resident_id != &"":
		return
	pack_index = wrapi(pack_index + direction, 0, _pack_order().size())
	item_index = 0
	_refresh_hud()
	_sync_renderer()


func _cycle_item(direction: int) -> void:
	if not selected_instance_id.is_empty() or not selected_instance_ids.is_empty() or selected_resident_id != &"":
		return
	var items := _pack_items()
	if items.is_empty():
		return
	item_index = wrapi(item_index + direction, 0, items.size())
	_refresh_hud()
	_sync_renderer()


func _current_catalog_id() -> StringName:
	var items := _pack_items()
	if items.is_empty():
		return &""
	item_index = clampi(item_index, 0, items.size() - 1)
	return items[item_index]


func _selected_catalog_id() -> StringName:
	var placed := CampaignState.town_object(selected_instance_id)
	return StringName(placed.get("catalog_id", ""))


func _pack_items() -> Array[StringName]:
	var packs: Array = _pack_order()
	if packs.is_empty():
		return []
	pack_index = clampi(pack_index, 0, packs.size() - 1)
	var items: Array[StringName] = TERRAIN_CATALOG.brushes_for_pack(packs[pack_index]) if editor_mode == &"terrain" else CATALOG.items_for_pack(packs[pack_index])
	if _search_query.is_empty():
		return items
	var filtered: Array[StringName] = []
	for catalog_id in items:
		var definition: Dictionary = TERRAIN_CATALOG.definition(catalog_id) if editor_mode == &"terrain" else CATALOG.definition(catalog_id)
		var searchable := "%s %s" % [String(catalog_id), String(definition.get("name", ""))]
		if searchable.to_lower().contains(_search_query):
			filtered.append(catalog_id)
	return filtered


func _pack_order() -> Array:
	return TERRAIN_CATALOG.PACK_ORDER if editor_mode == &"terrain" else CATALOG.PACK_ORDER


func _set_search_query(next_text: String) -> void:
	_search_query = next_text.strip_edges().to_lower()
	item_index = 0
	_refresh_hud()
	_sync_renderer()


func _focus_search() -> void:
	if _search_input:
		_search_input.grab_focus()
		_search_input.select_all()


func _save_layout_slot(slot_id: int) -> void:
	var error := CampaignState.save_sandbox_layout_slot(slot_id)
	if error != OK:
		_mode_label.text = "LAYOUT %d WAS NOT SAVED — CHECK SANDBOX MODE AND THE SAVE FOLDER" % slot_id
		return
	_mode_label.text = "SAVED LAYOUT %d — LOAD WITH SHIFT+%d" % [slot_id, slot_id]


func _load_layout_slot(slot_id: int) -> void:
	var before := _layout_snapshot()
	var result := CampaignState.load_sandbox_layout_slot(slot_id)
	if not bool(result.get("loaded", false)):
		_mode_label.text = "LAYOUT %d IS MISSING OR INVALID — YOUR CURRENT TOWN WAS LEFT UNCHANGED" % slot_id
		return
	if campaign:
		campaign.restore_sandbox_layout()
		if not campaign.sandbox_required_routes_reachable():
			CampaignState.restore_sandbox_layout(before)
			campaign.restore_sandbox_layout()
			_mode_label.text = "LAYOUT %d WOULD STRAND A REQUIRED TOWN ROUTE — IT WAS REJECTED" % slot_id
			return
	_record_history(before)
	if not suppress_persistence:
		CampaignState.save_game()
	_clear_object_selection()
	_sync_renderer()
	_refresh_hud()
	_mode_label.text = "LOADED LAYOUT %d%s" % [slot_id, " FROM RECOVERY COPY" if bool(result.get("recovered", false)) else ""]


func _sync_renderer() -> void:
	if not renderer:
		return
	var catalog_id := _selected_catalog_id() if not selected_instance_id.is_empty() else _current_catalog_id()
	var valid := _terrain_placement_valid(catalog_id, cursor_cell) if editor_mode == &"terrain" else _placement_valid(catalog_id, cursor_cell, selected_instance_id)
	if _multi_move_origin != Gameboard.INVALID_CELL:
		catalog_id = &""
		valid = _multi_move_valid(cursor_cell - _multi_move_origin)
	if selected_resident_id != &"":
		catalog_id = &""
		valid = _resident_placement_valid(cursor_cell, selected_resident_id)
	renderer.set_editor_state(active, cursor_cell, catalog_id, valid, selected_instance_id, editor_mode, selected_instance_ids, _active_box_selection_rect())


func _active_box_selection_rect() -> Rect2i:
	if _box_selection_start == Gameboard.INVALID_CELL:
		return Rect2i()
	return Rect2i(
		Vector2i(mini(_box_selection_start.x, cursor_cell.x), mini(_box_selection_start.y, cursor_cell.y)),
		Vector2i(absi(cursor_cell.x - _box_selection_start.x) + 1, absi(cursor_cell.y - _box_selection_start.y) + 1)
	)


func _screen_to_cell(screen_position: Vector2) -> Vector2i:
	var local_position: Vector2 = renderer.get_global_transform_with_canvas().affine_inverse() * screen_position
	return Gameboard.pixel_to_cell(local_position)


func _player_is_in_town() -> bool:
	if not Player.gamepiece:
		return false
	var cell := GamepieceRegistry.get_cell(Player.gamepiece)
	return cell.x >= campaign.TOWN_ORIGIN.x and cell.y < campaign.MANSION_ORIGIN.y


func _build_hud() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(210, 752)
	_panel.size = Vector2(1500, 276)
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(_panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 24)
	_panel.add_child(row)
	_preview = TextureRect.new()
	_preview.custom_minimum_size = Vector2(150, 150)
	_preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(_preview)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation", 6)
	row.add_child(details)
	_pack_label = Label.new()
	_pack_label.add_theme_font_size_override("font_size", 25)
	_pack_label.add_theme_color_override("font_color", Color(0.5, 0.9, 1.0))
	details.add_child(_pack_label)
	_search_input = LineEdit.new()
	_search_input.placeholder_text = "SEARCH CURRENT PACK  (CTRL+F)"
	_search_input.clear_button_enabled = true
	_search_input.max_length = 48
	_search_input.add_theme_font_size_override("font_size", 21)
	_search_input.text_changed.connect(_set_search_query)
	details.add_child(_search_input)
	_item_label = Label.new()
	_item_label.add_theme_font_size_override("font_size", 34)
	_item_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.48))
	details.add_child(_item_label)
	_mode_label = Label.new()
	_mode_label.add_theme_font_size_override("font_size", 25)
	details.add_child(_mode_label)
	_help_label = Label.new()
	_help_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_help_label.add_theme_font_size_override("font_size", 22)
	_help_label.add_theme_color_override("font_color", Color(0.67, 0.75, 0.87))
	details.add_child(_help_label)


func _refresh_hud() -> void:
	if not _panel:
		return
	if editor_mode == &"terrain":
		var brush_id := _current_catalog_id()
		var terrain_definition: Dictionary = TERRAIN_CATALOG.definition(brush_id)
		var terrain_packs: Array = _pack_order()
		_pack_label.text = "TERRAIN MODE   •   PACK  %d / %d   •   %s%s" % [pack_index + 1, terrain_packs.size(), String(terrain_definition.get("pack", "Unknown")).to_upper(), "   •   FILTER: " + _search_query.to_upper() if not _search_query.is_empty() else ""]
		_item_label.text = String(terrain_definition.get("name", "No terrain brush")).to_upper()
		_mode_label.text = "INDIVIDUAL TILE  %d / %d   •   %s" % [item_index + 1, _pack_items().size(), "BLOCKING" if bool(terrain_definition.get("blocks", false)) else "WALKABLE"]
		_help_label.text = "D-pad/arrows: move brush  •  A/Enter/click or left-drag: paint  •  X/Delete/right-click or right-drag: restore base  •  Ctrl+Z/Y: undo/redo  •  Ctrl+F: search  •  LB/RB or Z/C: tile  •  L3 or Q/E: pack  •  Select/T: objects  •  Ctrl+1–3: save layouts  •  Shift+1–3: load layouts"
		var terrain_texture_path := _sandbox_visuals.texture_path(terrain_definition)
		if ResourceLoader.exists(terrain_texture_path):
			var terrain_atlas := AtlasTexture.new()
			terrain_atlas.atlas = _sandbox_visuals.texture(terrain_definition)
			terrain_atlas.region = _sandbox_visuals.region(terrain_definition, terrain_atlas.atlas)
			_preview.texture = terrain_atlas
		else:
			_preview.texture = null
		return
	if selected_resident_id != &"":
		var resident: Dictionary = campaign.sandbox_resident_summary(selected_resident_id)
		_pack_label.text = "RESIDENT PACK   •   %s" % String(resident.get("pack", "Cozy Village NPC")).to_upper()
		_item_label.text = String(resident.get("name", "Resident")).to_upper()
		_mode_label.text = "EDITING RESIDENT HOME POSITION — %s" % String(resident.get("role", "Town resident")).to_upper()
		_help_label.text = "D-pad/arrows: choose a clear cell  •  A/Enter or click: confirm relocation  •  Ctrl+Z/Y: undo/redo  •  B/Esc: cancel  •  Residents resume their purposeful routine when editing closes"
		var resident_texture := String(resident.get("texture", ""))
		_preview.texture = load(resident_texture) if ResourceLoader.exists(resident_texture) else null
		return
	var catalog_id := _selected_catalog_id() if not selected_instance_id.is_empty() else _current_catalog_id()
	var definition := CATALOG.definition(catalog_id)
	_pack_label.text = "PACK  %d / %d   •   %s%s" % [pack_index + 1, CATALOG.PACK_ORDER.size(), String(definition.get("pack", "Unknown")).to_upper(), "   •   FILTER: " + _search_query.to_upper() if not _search_query.is_empty() else ""]
	_item_label.text = String(definition.get("name", "No object")).to_upper()
	var selected := CampaignState.town_object(selected_instance_id)
	if not selected_instance_id.is_empty() and bool(selected.get("protected", false)):
		_mode_label.text = "EDITING PROTECTED TOWN FACILITY — MOVABLE, NOT DELETABLE"
	else:
		if not selected_instance_ids.is_empty():
			_mode_label.text = "MULTISELECT  %d OBJECTS%s" % [selected_instance_ids.size(), " — MOVING" if _multi_move_origin != Gameboard.INVALID_CELL else ""]
		else:
			_mode_label.text = "EDITING PLACED OBJECT" if not selected_instance_id.is_empty() else "INDIVIDUAL SPRITE  %d / %d" % [item_index + 1, _pack_items().size()]
		_help_label.text = "Ctrl+click/middle-drag: multiselect  •  G: move group  •  Ctrl+Z/Y: undo/redo  •  Ctrl+C/V: copy/paste  •  Ctrl+F: search  •  Ctrl+1–3: save layouts  •  Shift+1–3: load layouts  •  X/Delete: remove  •  R3/F: flip  •  Select/T: terrain"
	var texture_path := String(definition.get("texture", ""))
	if ResourceLoader.exists(texture_path):
		var atlas := AtlasTexture.new()
		atlas.atlas = load(texture_path)
		atlas.region = definition.get("region", Rect2())
		_preview.texture = atlas


func _panel_style() -> StyleBoxTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = load(UI_PARTY_HUD)
	atlas.region = Rect2(2, 2, 53, 53)
	var style := StyleBoxTexture.new()
	style.texture = atlas
	for side in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
		style.set_texture_margin(side, 7)
	style.content_margin_left = 24
	style.content_margin_right = 24
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	return style
