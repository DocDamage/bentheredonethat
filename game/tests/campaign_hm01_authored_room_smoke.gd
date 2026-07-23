extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const STREAMER_SCRIPT := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")


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
	var navigation_layer := room.get_node("NavigationAndCollision") as Node2D
	assert(StringName(navigation_layer.get_meta(&"navigation_id", &"")) == &"authored:hm01-rain-gate-navigation")
	assert(StringName(navigation_layer.get_meta(&"collision_mask_id", &"")) == &"authored:hm01-rain-gate-collision")
	var navigation := NAVIGATION_BUILDER.navigation_record(&"HM-01")
	var walkable: Dictionary = navigation.get("walkable", {})
	if walkable.size() != 100:
		printerr("HM-01 authored useful-cell count was %d, expected 100." % walkable.size())
		get_tree().quit(1)
		return
	assert(walkable.has(Vector2i(6, 3)) and walkable.has(Vector2i(12, 3)), "HM-01 safe arrivals must remain open around the facade.")
	assert(not walkable.has(Vector2i(9, 3)), "HM-01 mansion facade must own collision rather than using a full open rectangle.")
	assert(walkable.has(Vector2i(4, 10)) and walkable.has(Vector2i(10, 12)), "HM-01 forecourt and return lip must remain traversable.")
	streamer.call(&"deactivate")
	assert(streamer.call(&"active_root") == null)
	print("CAMPAIGN_HM01_AUTHORED_ROOM_SMOKE_OK scene=true profile=haunted_mansion_exterior origin=300,0 layers=7 navigation=authored cells=100 facade_collision=true unload=true")
	get_tree().quit()
