extends Node

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	_run.call_deferred()


func _world_name() -> String:
	return "Unknown"


func _room_ids() -> Array:
	return []


func _gate_label() -> String:
	return "opened"


func _run() -> void:
	CampaignState.reset_new_game()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	if not await _validate_world(main):
		return
	print("%s_LAYOUT_SMOKE_OK rooms=%d renderer=authored scenes layers=7 profiles=validated navigation=active_room gated_port=%s" % [_world_name().to_upper(), _room_ids().size(), _gate_label()])
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _validate_world(main: Node) -> bool:
	var runtime: Node = main.get_node("Field/Map/CampaignWorld/ManifestRoomRuntime")
	var streamer: Node = main.get_node("Field/Map/CampaignWorld/RoomStreamer")
	var profiles := CampaignVisualProfileRegistry.new()
	var gated: Dictionary = {}
	for room_id_variant in _room_ids():
		var room_id := StringName(room_id_variant)
		var definition := ROOM_REGISTRY.room(room_id)
		if not ROOM_REGISTRY.is_authored_room(room_id):
			return _fail("room is not scene-backed: %s" % room_id)
		for profile_id in definition.get("visualProfileIds", []):
			if not profiles.has(profile_id):
				return _fail("missing visual profile %s for %s" % [profile_id, room_id])
		if gated.is_empty():
			for port_id in (definition.get("portGates", {}) as Dictionary):
				var destination := StringName(ROOM_REGISTRY.port(room_id, StringName(port_id)).get("destination", &""))
				if ROOM_REGISTRY.is_authored_room(destination):
					gated = {"room_id": room_id, "port_id": StringName(port_id), "flag": StringName(definition.get("portGates", {})[port_id])}
					break
		runtime.call(&"activate", room_id)
		await get_tree().process_frame
		var root := streamer.call(&"active_root") as Node2D
		if not root or root.get_meta(&"room_id") != room_id:
			return _fail("room streamer did not activate %s" % room_id)
		for layer_name in ["GroundLayer", "LowDecorationLayer", "NavigationAndCollision", "YSortedActorsAndProps", "ForegroundLayer", "InteractionLayer", "EncounterLayer"]:
			if not root.has_node(layer_name):
				return _fail("%s is missing %s" % [room_id, layer_name])
		var navigation := CampaignNavigationBuilder.navigation_record(room_id, ROOM_REGISTRY.enabled_port_ids(room_id))
		var walkable_cells: Dictionary = navigation.get("walkable", {})
		var walkable := false
		for cell in (definition.get("populationAnchorCells", {}) as Dictionary).values():
			walkable = walkable_cells.has(cell) and runtime.call(&"room_at_cell", definition.get("worldOrigin", Vector2i.ZERO) + cell) == room_id
			if walkable:
				break
		if not walkable:
			return _fail("%s exposes no navigable population anchor" % room_id)
	if gated.is_empty():
		return true
	var gate_name := "ManifestPort_%s_%s" % [gated["room_id"], gated["port_id"]]
	runtime.call(&"activate", gated["room_id"])
	if runtime.has_node(gate_name):
		return _fail("gated port is available before %s" % gated["flag"])
	CampaignState.story_flags[gated["flag"]] = true
	runtime.call(&"refresh_active_room")
	await get_tree().process_frame
	if not runtime.has_node(gate_name):
		return _fail("gated port did not open after %s" % gated["flag"])
	return true


func _fail(message: String) -> bool:
	printerr("%s_LAYOUT_SMOKE_FAILED: %s" % [_world_name().to_upper(), message])
	get_tree().quit(1)
	return false
