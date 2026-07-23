extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")


func _ready() -> void:
	var errors := REGISTRY.validate()
	assert(errors.is_empty(), "HM-06/HM-15 manifest validation failed with %d error(s)." % errors.size())
	var streamer: Node = STREAMER_SCRIPT.new()
	add_child(streamer)
	_assert_room(streamer, &"HM-06", &"authored:hm06-portrait-gallery-navigation", &"authored:hm06-portrait-gallery-collision")
	var gallery_walkable: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-06", [&"Nw", &"Ne"]).get("walkable", {})
	if gallery_walkable.size() != 207:
		_fail("HM-06 useful-cell count was %d, expected 207." % gallery_walkable.size())
		return
	assert(gallery_walkable.has(Vector2i(8, 3)) and gallery_walkable.has(Vector2i(17, 3)))
	assert(gallery_walkable.has(Vector2i(13, 6)) and gallery_walkable.has(Vector2i(4, 7)) and gallery_walkable.has(Vector2i(13, 12)))
	assert(not gallery_walkable.has(Vector2i(1, 8)), "HM-06 gallery walls must own collision.")
	_assert_room(streamer, &"HM-15", &"authored:hm15-mirror-link-navigation", &"authored:hm15-mirror-link-collision")
	var mirror_walkable: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-15", [&"Nw", &"Ne"]).get("walkable", {})
	if mirror_walkable.size() != 76:
		_fail("HM-15 useful-cell count was %d, expected 76." % mirror_walkable.size())
		return
	assert(mirror_walkable.has(Vector2i(6, 3)) and mirror_walkable.has(Vector2i(12, 3)) and mirror_walkable.has(Vector2i(14, 3)))
	assert(mirror_walkable.has(Vector2i(9, 5)) and not mirror_walkable.has(Vector2i(1, 5)), "HM-15 mirror walls must own collision.")
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_root") == null)
	print("CAMPAIGN_HM06_HM15_AUTHORED_ROOMS_SMOKE_OK rooms=portrait_gallery+mirror_link navigation=authored cells=207+76 collision=true unload=true")
	get_tree().quit()


func _assert_room(streamer: Node, room_id: StringName, navigation_id: StringName, collision_id: StringName) -> void:
	streamer.call(&"activate_room", room_id)
	var room: Node2D = streamer.call(&"active_root") as Node2D
	assert(room and room.name == "AuthoredRoom_%s" % room_id)
	var navigation_layer := room.get_node("NavigationAndCollision") as Node2D
	assert(StringName(navigation_layer.get_meta(&"navigation_id", &"")) == navigation_id)
	assert(StringName(navigation_layer.get_meta(&"collision_mask_id", &"")) == collision_id)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_HM06_HM15_AUTHORED_ROOMS_SMOKE_FAILED: " + message)
	get_tree().quit(1)
