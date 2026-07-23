extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")


func _ready() -> void:
	var errors := REGISTRY.validate()
	assert(errors.is_empty(), "HM-02 manifest validation failed with %d error(s)." % errors.size())
	var streamer: Node = STREAMER_SCRIPT.new()
	add_child(streamer)
	streamer.call(&"activate_room", &"HM-02")
	var room: Node2D = streamer.call(&"active_root") as Node2D
	assert(room and room.name == "AuthoredRoom_HM-02")
	assert(room.position == Vector2(14400, 0))
	assert(room.has_node("GroundLayer") and room.has_node("ForegroundLayer"))
	var navigation_layer := room.get_node("NavigationAndCollision") as Node2D
	assert(StringName(navigation_layer.get_meta(&"navigation_id", &"")) == &"authored:hm02-west-foyer-navigation")
	assert(StringName(navigation_layer.get_meta(&"collision_mask_id", &"")) == &"authored:hm02-west-foyer-collision")
	var closed_navigation := NAVIGATION_BUILDER.navigation_record(&"HM-02", [&"Nw", &"Ne", &"E2"])
	var closed_walkable: Dictionary = closed_navigation.get("walkable", {})
	if closed_walkable.size() != 215:
		printerr("HM-02 closed useful-cell count was %d, expected 215." % closed_walkable.size())
		get_tree().quit(1)
		return
	var opened_navigation := NAVIGATION_BUILDER.navigation_record(&"HM-02", [&"Nw", &"Ne", &"E1", &"E2"])
	var opened_walkable: Dictionary = opened_navigation.get("walkable", {})
	if opened_walkable.size() != 216:
		printerr("HM-02 opened useful-cell count was %d, expected 216." % opened_walkable.size())
		get_tree().quit(1)
		return
	assert(closed_walkable.has(Vector2i(8, 3)) and closed_walkable.has(Vector2i(17, 3)), "HM-02 north arrivals must remain open in the entry gallery.")
	assert(closed_walkable.has(Vector2i(22, 6)) and closed_walkable.has(Vector2i(22, 12)), "HM-02 east arrivals must remain open around both side routes.")
	assert(not closed_walkable.has(Vector2i(2, 8)), "HM-02 west wall must own collision rather than using a full open rectangle.")
	assert(closed_walkable.has(Vector2i(13, 7)) and closed_walkable.has(Vector2i(13, 12)), "HM-02 clock hall and south lounge must remain traversable.")
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_root") == null)
	print("CAMPAIGN_HM02_AUTHORED_ROOM_SMOKE_OK scene=true profiles=clock+tableau origin=300,0 navigation=authored cells=215/216 foyer_collision=true unload=true")
	get_tree().quit()
