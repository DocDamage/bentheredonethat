extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")


func _ready() -> void:
	var record := RECORDS.record(&"AF-01")
	var scene := load(String(record.get("scenePath", ""))) as PackedScene
	assert(scene, "AF-01 authored scene must load from its room record.")
	var room := scene.instantiate() as Node2D
	assert(room, "AF-01 authored scene must instantiate.")
	add_child(room)
	await get_tree().process_frame
	assert(room.get_meta(&"room_id", &"") == &"AF-01")
	assert(bool(room.get_meta(&"runtime_gated", false)))
	assert(room.has_node("GroundLayer") and room.has_node("NavigationAndCollision") and room.has_node("ForegroundLayer"))
	assert(room.get_node("GroundLayer").has_method(&"configure"))
	assert(room.get_node("YSortedActorsAndProps").has_method(&"configure"))
	var navigation := room.get_node("NavigationAndCollision") as Node2D
	assert(navigation.get_meta(&"navigation_id", &"") == &"af01-cinder-gate-navigation-v1")
	assert(navigation.get_meta(&"collision_mask_id", &"") == &"af01-cinder-gate-boundary-collision-v1")
	print("ASHFALL_CINDER_GATE_SCENE_SMOKE_OK room=AF-01 runtime_gated=true")
	get_tree().quit(0)
