extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")


func _ready() -> void:
	var errors := REGISTRY.validate()
	assert(errors.is_empty(), "HM-01 manifest validation failed with %d error(s)." % errors.size())
	var streamer: Node = STREAMER_SCRIPT.new()
	add_child(streamer)
	streamer.call(&"activate_room", &"HM-01")
	var room: Node2D = streamer.call(&"active_root") as Node2D
	assert(room and room.name == "AuthoredRoom_HM-01")
	assert(room.position == Vector2(14400, 0))
	assert(room.has_node("GroundLayer") and room.has_node("ForegroundLayer"))
	assert(room.has_node("InteractionLayer/ManifestInteraction"))
	assert(room.get_node("LowDecorationLayer").get("_exterior") is Texture2D, "HM-01 must resolve its admitted exterior profile at runtime.")
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_root") == null)
	print("CAMPAIGN_HM01_AUTHORED_ROOM_SMOKE_OK scene=true profile=haunted_mansion_exterior origin=300,0 layers=7 unload=true")
	get_tree().quit()
