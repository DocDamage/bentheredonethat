extends Node

const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")


func _ready() -> void:
	var streamer: Node = STREAMER_SCRIPT.new()
	add_child(streamer)
	streamer.call(&"activate_legacy_mansion_area", &"mansion_foyer")
	assert(streamer.call(&"active_room_id") == &"HM-01")
	var foyer_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(foyer_root and foyer_root.has_node("GroundLayer") and foyer_root.has_node("YSortedActorsAndProps"))
	streamer.call(&"activate_legacy_mansion_area", &"mansion_ballroom")
	assert(streamer.call(&"active_room_id") == &"HM-09")
	assert(streamer.call(&"active_root") != foyer_root and not is_instance_valid(foyer_root))
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_room_id") == &"" and streamer.call(&"active_root") == null)
	print("CAMPAIGN_ROOM_STREAMER_SMOKE_OK legacy_rooms=5 active=one layers=7 unload=true")
	get_tree().quit()
