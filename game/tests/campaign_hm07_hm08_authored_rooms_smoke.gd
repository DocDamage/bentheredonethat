extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")


func _ready() -> void:
	assert(REGISTRY.validate().is_empty(), "HM-07/HM-08 manifest validation failed.")
	var streamer: Node = STREAMER_SCRIPT.new()
	add_child(streamer)
	_assert_room(streamer, &"HM-07", &"authored:hm07-borrowed-years-navigation", &"authored:hm07-borrowed-years-collision")
	var nursery: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-07", [&"Nw", &"Ne"]).get("walkable", {})
	if nursery.size() != 136:
		_fail("HM-07 useful-cell count was %d, expected 136." % nursery.size())
		return
	assert(nursery.has(Vector2i(7, 3)) and nursery.has(Vector2i(14, 3)) and nursery.has(Vector2i(18, 4)))
	assert(nursery.has(Vector2i(12, 6)) and nursery.has(Vector2i(16, 8)) and not nursery.has(Vector2i(1, 7)))
	_assert_room(streamer, &"HM-08", &"authored:hm08-ballroom-antechamber-navigation", &"authored:hm08-ballroom-antechamber-collision")
	var closed: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-08", [&"Nw"]).get("walkable", {})
	var opened: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-08", [&"Nw", &"Ne", &"E1", &"E2"]).get("walkable", {})
	if closed.size() != 121 or opened.size() != 124:
		_fail("HM-08 useful-cell counts were %d/%d, expected 121/124." % [closed.size(), opened.size()])
		return
	assert(closed.has(Vector2i(6, 3)) and closed.has(Vector2i(12, 3)) and closed.has(Vector2i(14, 5)) and closed.has(Vector2i(14, 10)))
	assert(closed.has(Vector2i(9, 8)) and not closed.has(Vector2i(1, 8)))
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_root") == null)
	print("CAMPAIGN_HM07_HM08_AUTHORED_ROOMS_SMOKE_OK rooms=nursery+antechamber navigation=authored cells=136+121/124 collision=true unload=true")
	get_tree().quit()


func _assert_room(streamer: Node, room_id: StringName, navigation_id: StringName, collision_id: StringName) -> void:
	streamer.call(&"activate_room", room_id)
	var room: Node2D = streamer.call(&"active_root") as Node2D
	assert(room and room.name == "AuthoredRoom_%s" % room_id)
	var navigation_layer := room.get_node("NavigationAndCollision") as Node2D
	assert(StringName(navigation_layer.get_meta(&"navigation_id", &"")) == navigation_id)
	assert(StringName(navigation_layer.get_meta(&"collision_mask_id", &"")) == collision_id)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_HM07_HM08_AUTHORED_ROOMS_SMOKE_FAILED: " + message)
	get_tree().quit(1)
