extends Node

## Captures the locked 192-room campaign at first-visit and stabilized states.
## Output is release-review evidence, not automatic visual or input approval.

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const CORE := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ANNEX := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const CORE_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const GRAPH_REPORT := preload("res://ben_rpg/world/campaign_room_graph_report.gd")
const CAPTURE_ROOT := "user://phase7-campaign-release-captures"
const STATES := [&"fresh", &"stabilized"]

var records: Array[Dictionary] = []


func _ready() -> void:
	_capture_all.call_deferred()


func _capture_all() -> void:
	assert(CORE.validate().is_empty() and ANNEX.validate().is_empty())
	assert(CORE.room_ids().size() + ANNEX.room_ids().size() == 192)
	var tag := OS.get_environment("FFVI_CAPTURE_TAG").strip_edges()
	if tag.is_empty(): tag = "unlabeled"
	var commit := _capture_commit()
	assert(not commit.is_empty(), "Capture evidence requires an exact commit.")
	assert(DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CAPTURE_ROOT)) == OK)
	var requested_rooms := _requested_rooms()
	var requested_states := _requested_states()
	for state_id in requested_states:
		if not await _capture_state(state_id, tag, commit, requested_rooms):
			return
	assert(records.size() == requested_rooms.size() * requested_states.size())
	var manifest_path := "%s/capture-manifest-%s.json" % [CAPTURE_ROOT, tag]
	var manifest := FileAccess.open(manifest_path, FileAccess.WRITE)
	assert(manifest != null)
	manifest.store_string(JSON.stringify({
		"captureTag": tag,
		"commit": commit,
		"reviewStatus": "visual_review_only",
		"states": requested_states,
		"locations": requested_rooms.size(),
		"captures": records,
	}, "\t"))
	manifest.close()
	print("CAMPAIGN_RELEASE_CAPTURE_OK locations=%d captures=%d states=%d root=%s visual_review_only=true" % [requested_rooms.size(), records.size(), requested_states.size(), ProjectSettings.globalize_path(CAPTURE_ROOT)])
	get_tree().quit(0)


func _capture_state(state_id: StringName, tag: String, commit: String, room_ids: Array[StringName]) -> bool:
	CampaignState.reset_new_game()
	CampaignState.party = [&"ben"]
	for flag in GRAPH_REPORT.story_state(state_id):
		CampaignState.story_flags[flag] = GRAPH_REPORT.story_state(state_id)[flag]
	CampaignState.state_changed.emit()
	var main: Node = null
	var core_runtime: Node = null
	var annex_runtime: Node = null
	var active_prefix := ""
	for room_id in room_ids:
		var room_prefix := String(room_id).get_slice("-", 0)
		# Runtime navigation and actor registries are intentionally shared by the
		# rooms in one universe. Rebuild at universe boundaries so a capture batch
		# cannot inherit an occupant or pathfinder cell from the prior universe.
		if main == null or room_prefix != active_prefix:
			if main != null:
				main.queue_free()
				await _settle()
			main = load("res://src/main.tscn").instantiate()
			main.get_node("Field").opening_cutscene = null
			get_tree().root.add_child(main)
			await _settle()
			core_runtime = main.get_node("Field/Map/CampaignWorld/ManifestRoomRuntime")
			annex_runtime = main.get_node("Field/Map/CampaignWorld/Phase3RoomRuntime")
			active_prefix = room_prefix
		var definition := CORE.room(room_id) if CORE.has_room(room_id) else ANNEX.room(room_id)
		if CORE.has_room(room_id): core_runtime.call(&"activate", room_id)
		elif not bool(annex_runtime.call(&"activate", room_id)):
			_fail("Could not activate %s." % room_id)
			return false
		await _settle()
		var local_cell := _capture_cell(room_id, definition)
		if local_cell == Vector2i(-1, -1):
			_fail("No unoccupied live capture cell exists in %s." % room_id)
			return false
		var target: Vector2i = definition.get("worldOrigin", Vector2i.ZERO) + local_cell
		main._place_player(target)
		await _settle()
		if Player.gamepiece == null or GamepieceRegistry.get_cell(Player.gamepiece) != target:
			_fail("Player placement failed in %s at %s." % [room_id, target])
			return false
		var path := "%s/%s-%s-native-%s.png" % [CAPTURE_ROOT, String(room_id).to_lower(), state_id, tag]
		assert(CAPTURE_GUARD.save_viewport_png(get_viewport(), path, "Phase 7 %s %s" % [room_id, state_id]))
		var viewport_size := get_viewport().get_visible_rect().size
		records.append({
			"roomId": room_id,
			"state": state_id,
			"path": path,
			"resolution": [int(viewport_size.x), int(viewport_size.y)],
			"inputMode": "visual_review_only",
			"captureTag": tag,
			"commit": commit,
		})
	if main != null:
		main.queue_free()
		await _settle()
	return true


func _requested_rooms() -> Array[StringName]:
	var all_rooms: Array[StringName] = []
	all_rooms.append_array(CORE.room_ids())
	all_rooms.append_array(ANNEX.room_ids())
	var filter := OS.get_environment("FFVI_CAPTURE_ROOM_IDS").strip_edges()
	if filter.is_empty(): return all_rooms
	var requested: Array[StringName] = []
	for raw_id in filter.split(",", false):
		var room_id := StringName(raw_id.strip_edges().to_upper())
		assert(room_id in all_rooms, "Unknown requested capture room %s" % room_id)
		requested.append(room_id)
	return requested


func _requested_states() -> Array[StringName]:
	var filter := OS.get_environment("FFVI_CAPTURE_STATES").strip_edges()
	var requested: Array[StringName] = []
	if filter.is_empty():
		requested.append_array(STATES)
		return requested
	for raw_state in filter.split(",", false):
		var state_id := StringName(raw_state.strip_edges().to_lower())
		assert(state_id in STATES, "Unknown requested capture state %s" % state_id)
		requested.append(state_id)
	return requested


func _capture_commit() -> String:
	var configured := OS.get_environment("FFVI_CAPTURE_COMMIT").strip_edges()
	if not configured.is_empty():
		return configured
	var output: Array = []
	var exit_code := OS.execute("git", PackedStringArray(["-C", ProjectSettings.globalize_path("res://"), "rev-parse", "HEAD"]), output, true)
	if exit_code != 0 or output.is_empty():
		return ""
	return String(output[0]).strip_edges()


func _capture_cell(room_id: StringName, definition: Dictionary) -> Vector2i:
	var candidates: Array[Vector2i] = []
	if CORE.has_room(room_id):
		for port in CORE.ports(room_id):
			var cell := CORE_ROUTER.safe_arrival_cell(room_id, StringName(port.get("id", &"")))
			if cell != Vector2i.ZERO: candidates.append(cell)
	else:
		for port_id in (definition.get("portCells", {}) as Dictionary):
			var cell := ANNEX.safe_arrival_cell(room_id, StringName(port_id))
			if cell != Vector2i.ZERO: candidates.append(cell)
	var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
	candidates.append(Vector2i(maxi(1, dimensions.x / 2), maxi(1, dimensions.y / 2)))
	var layout: Dictionary = definition.get("navigationLayout", definition.get("navigation", {}))
	for walkable_rect in layout.get("walkableRects", []):
		var origin: Vector2i = walkable_rect.get("origin", Vector2i.ZERO)
		var size: Vector2i = walkable_rect.get("size", Vector2i.ZERO)
		candidates.append(origin + Vector2i(size.x / 2, size.y / 2))
	for local_cell in candidates:
		var target: Vector2i = definition.get("worldOrigin", Vector2i.ZERO) + local_cell
		var occupant := GamepieceRegistry.get_gamepiece(target)
		if Gameboard.pathfinder.has_cell(target) and (occupant == null or occupant == Player.gamepiece):
			return local_cell
	for y in range(1, maxi(1, dimensions.y - 1)):
		for x in range(1, maxi(1, dimensions.x - 1)):
			var local_cell := Vector2i(x, y)
			var target: Vector2i = definition.get("worldOrigin", Vector2i.ZERO) + local_cell
			var occupant: Node = GamepieceRegistry.get_gamepiece(target)
			if Gameboard.pathfinder.has_cell(target) and (occupant == null or occupant == Player.gamepiece):
				return local_cell
	return Vector2i(-1, -1)


func _settle() -> void:
	for _frame in range(4): await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("CAMPAIGN_RELEASE_CAPTURE_FAILED: " + message)
	get_tree().quit(1)
