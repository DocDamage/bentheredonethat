extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")


func _ready() -> void:
	var errors := REGISTRY.validate()
	assert(errors.is_empty(), "HM-03/HM-04 manifest validation failed with %d error(s)." % errors.size())
	var streamer: Node = STREAMER_SCRIPT.new()
	add_child(streamer)
	_assert_room(streamer, &"HM-03", &"authored:hm03-ledger-study-navigation", &"authored:hm03-ledger-study-collision")
	var study_walkable: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-03", [&"Nw"]).get("walkable", {})
	if study_walkable.size() != 134:
		_fail("HM-03 useful-cell count was %d, expected 134." % study_walkable.size())
		return
	assert(study_walkable.has(Vector2i(7, 3)) and study_walkable.has(Vector2i(5, 9)))
	assert(not study_walkable.has(Vector2i(1, 8)), "HM-03 shelving wall must own collision.")
	_assert_room(streamer, &"HM-04", &"authored:hm04-clock-passage-navigation", &"authored:hm04-clock-passage-collision")
	var closed_walkable: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-04", [&"Nw", &"Ne"]).get("walkable", {})
	var opened_walkable: Dictionary = NAVIGATION_BUILDER.navigation_record(&"HM-04", [&"Nw", &"Ne", &"E1"]).get("walkable", {})
	if closed_walkable.size() != 62 or opened_walkable.size() != 63:
		_fail("HM-04 useful-cell counts were %d/%d, expected 62/63." % [closed_walkable.size(), opened_walkable.size()])
		return
	assert(closed_walkable.has(Vector2i(4, 3)) and closed_walkable.has(Vector2i(9, 3)) and closed_walkable.has(Vector2i(10, 3)))
	assert(closed_walkable.has(Vector2i(7, 7)) and not closed_walkable.has(Vector2i(1, 5)), "HM-04 alcoves and passage walls must own collision.")
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_root") == null)
	print("CAMPAIGN_HM03_HM04_AUTHORED_ROOMS_SMOKE_OK rooms=study+clock_passage navigation=authored cells=134+62/63 collision=true unload=true")
	get_tree().quit()


func _assert_room(streamer: Node, room_id: StringName, navigation_id: StringName, collision_id: StringName) -> void:
	streamer.call(&"activate_room", room_id)
	var room: Node2D = streamer.call(&"active_root") as Node2D
	assert(room and room.name == "AuthoredRoom_%s" % room_id)
	var navigation_layer := room.get_node("NavigationAndCollision") as Node2D
	assert(StringName(navigation_layer.get_meta(&"navigation_id", &"")) == navigation_id)
	assert(StringName(navigation_layer.get_meta(&"collision_mask_id", &"")) == collision_id)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_HM03_HM04_AUTHORED_ROOMS_SMOKE_FAILED: " + message)
	get_tree().quit(1)
