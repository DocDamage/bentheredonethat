extends Node

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var runtime: Node = main.get_node("Field/Map/CampaignWorld/ManifestRoomRuntime")
	var streamer: Node = main.get_node("Field/Map/CampaignWorld/RoomStreamer")
	var profiles := CampaignVisualProfileRegistry.new()
	var authored_rooms := 0
	for room_id in ROOM_REGISTRY.MANSION_ROOM_IDS:
		var definition := ROOM_REGISTRY.room(room_id)
		if not ROOM_REGISTRY.is_authored_room(room_id):
			_fail("Mansion room is not scene-backed: %s" % room_id)
			return
		for profile_id in definition.get("visualProfileIds", []):
			if not profiles.has(profile_id):
				_fail("Missing Mansion visual profile %s for %s" % [profile_id, room_id])
				return
		runtime.call(&"activate", room_id)
		await get_tree().process_frame
		var root := streamer.call(&"active_root") as Node2D
		if not root or root.get_meta(&"room_id") != room_id:
			_fail("Room streamer did not activate %s" % room_id)
			return
		for layer_name in ["GroundLayer", "LowDecorationLayer", "NavigationAndCollision", "YSortedActorsAndProps", "ForegroundLayer", "InteractionLayer", "EncounterLayer"]:
			if not root.has_node(layer_name):
				_fail("%s is missing %s" % [room_id, layer_name])
				return
		var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
		var walkable := false
		for cell in (definition.get("populationAnchorCells", {}) as Dictionary).values():
			walkable = Gameboard.pathfinder.has_cell(origin + cell)
			if walkable:
				break
		if not walkable:
			_fail("%s exposes no navigable population anchor" % room_id)
			return
		authored_rooms += 1

	print("MANSION_LAYOUT_SMOKE_OK rooms=%d renderer=authored scenes=16 layers=7 profiles=validated navigation=active_room" % authored_rooms)
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("MANSION_LAYOUT_SMOKE_FAILED: " + message)
	get_tree().quit(1)
