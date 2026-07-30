extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")


func _ready() -> void:
	assert(REGISTRY.validate().is_empty(), "HM-09/HM-10 manifest validation failed.")
	var streamer: Node = STREAMER_SCRIPT.new()
	add_child(streamer)
	_assert_room(streamer, &"HM-09", &"authored:hm09-grand-ballroom-navigation", &"authored:hm09-grand-ballroom-collision")
	var ballroom: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-09", [&"Nw"]).get("walkable", {})
	if ballroom.size() != 197:
		_fail("HM-09 useful-cell count was %d, expected 197." % ballroom.size())
		return
	assert(ballroom.has(Vector2i(8, 3)) and ballroom.has(Vector2i(12, 9)) and ballroom.has(Vector2i(18, 12)))
	assert(not ballroom.has(Vector2i(1, 9)), "HM-09 ballroom walls must own collision.")
	_assert_room(streamer, &"HM-10", &"authored:hm10-dead-conservatory-navigation", &"authored:hm10-dead-conservatory-collision")
	var conservatory: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-10", [&"Nw", &"Ne"]).get("walkable", {})
	if conservatory.size() != 114:
		_fail("HM-10 useful-cell count was %d, expected 114." % conservatory.size())
		return
	assert(conservatory.has(Vector2i(6, 3)) and conservatory.has(Vector2i(13, 3)) and conservatory.has(Vector2i(15, 9)))
	assert(not conservatory.has(Vector2i(1, 7)), "HM-10 conservatory walls must own collision.")
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_root") == null)
	print("CAMPAIGN_HM09_HM10_AUTHORED_ROOMS_SMOKE_OK rooms=ballroom+conservatory navigation=authored cells=197+114 collision=true unload=true")
	get_tree().quit()


func _assert_room(streamer: Node, room_id: StringName, navigation_id: StringName, collision_id: StringName) -> void:
	streamer.call(&"activate_room", room_id)
	var room: Node2D = streamer.call(&"active_root") as Node2D
	assert(room and room.name == "AuthoredRoom_%s" % room_id)
	var navigation_layer := room.get_node("NavigationAndCollision") as Node2D
	assert(StringName(navigation_layer.get_meta(&"navigation_id", &"")) == navigation_id)
	assert(StringName(navigation_layer.get_meta(&"collision_mask_id", &"")) == collision_id)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_HM09_HM10_AUTHORED_ROOMS_SMOKE_FAILED: " + message)
	get_tree().quit(1)
