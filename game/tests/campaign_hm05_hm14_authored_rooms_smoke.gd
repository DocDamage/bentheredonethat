extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")


func _ready() -> void:
	var errors := REGISTRY.validate()
	assert(errors.is_empty(), "HM-05/HM-14 manifest validation failed with %d error(s)." % errors.size())
	var streamer: Node = STREAMER_SCRIPT.new()
	add_child(streamer)
	_assert_room(streamer, &"HM-05", &"authored:hm05-servants-archive-navigation", &"authored:hm05-servants-archive-collision")
	var archive_closed: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-05", [&"Nw", &"Ne", &"E1"]).get("walkable", {})
	var archive_opened: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-05", [&"Nw", &"Ne", &"E1", &"E2"]).get("walkable", {})
	if archive_closed.size() != 111 or archive_opened.size() != 112:
		_fail("HM-05 useful-cell counts were %d/%d, expected 111/112." % [archive_closed.size(), archive_opened.size()])
		return
	assert(archive_closed.has(Vector2i(6, 3)) and archive_closed.has(Vector2i(12, 3)) and archive_closed.has(Vector2i(14, 4)) and archive_closed.has(Vector2i(14, 9)))
	assert(archive_closed.has(Vector2i(9, 7)) and not archive_closed.has(Vector2i(1, 7)), "HM-05 save floor and archive walls must own collision.")
	_assert_room(streamer, &"HM-14", &"authored:hm14-west-stair-navigation", &"authored:hm14-west-stair-collision")
	var stair_walkable: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-14", [&"Nw", &"Ne", &"E1"]).get("walkable", {})
	if stair_walkable.size() != 122:
		_fail("HM-14 useful-cell count was %d, expected 122." % stair_walkable.size())
		return
	assert(stair_walkable.has(Vector2i(6, 3)) and stair_walkable.has(Vector2i(13, 3)) and stair_walkable.has(Vector2i(16, 4)))
	assert(stair_walkable.has(Vector2i(10, 8)) and not stair_walkable.has(Vector2i(1, 8)), "HM-14 stair landing and balcony walls must own collision.")
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_root") == null)
	print("CAMPAIGN_HM05_HM14_AUTHORED_ROOMS_SMOKE_OK rooms=archive+west_stair navigation=authored cells=111/112+122 collision=true unload=true")
	get_tree().quit()


func _assert_room(streamer: Node, room_id: StringName, navigation_id: StringName, collision_id: StringName) -> void:
	streamer.call(&"activate_room", room_id)
	var room: Node2D = streamer.call(&"active_root") as Node2D
	assert(room and room.name == "AuthoredRoom_%s" % room_id)
	var navigation_layer := room.get_node("NavigationAndCollision") as Node2D
	assert(StringName(navigation_layer.get_meta(&"navigation_id", &"")) == navigation_id)
	assert(StringName(navigation_layer.get_meta(&"collision_mask_id", &"")) == collision_id)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_HM05_HM14_AUTHORED_ROOMS_SMOKE_FAILED: " + message)
	get_tree().quit(1)
