extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
const SCENE := preload("res://ben_rpg/world/rooms/new_philadelphia_franklin_laboratory.tscn")


func _ready() -> void:
	var errors := RECORDS.validate()
	assert(errors.is_empty(), "New Philadelphia room record validation failed: %s" % errors)
	var room := SCENE.instantiate()
	add_child(room)
	assert(room.get_meta(&"room_id") == &"NP-01" and bool(room.get_meta(&"runtime_gated")))
	var collision := room.get_node("NavigationAndCollision")
	assert(collision.call(&"blocked_cell_count") == 101)
	assert(collision.call(&"blocks_cell", Vector2i(15, 10)))
	assert(room.get_node("InteractionLayer").has_node("NewPhiladelphiaFeature_FranklinWorkbench"))
	print("NEW_PHILADELPHIA_FRANKLIN_LABORATORY_SMOKE_OK room=NP-01 scene_collision=authored gateway=still_gated")
	get_tree().quit()
