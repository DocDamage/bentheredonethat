extends Node
const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
const SCENE := preload("res://ben_rpg/world/rooms/new_philadelphia_founders_square.tscn")
func _ready() -> void:
	assert(RECORDS.validate().is_empty())
	var room := SCENE.instantiate()
	add_child(room)
	assert(room.get_meta(&"room_id") == &"NP-04" and bool(room.get_meta(&"runtime_gated")))
	assert(room.get_node("NavigationAndCollision").call(&"blocked_cell_count") == 105)
	assert(room.get_node("InteractionLayer").has_node("NewPhiladelphiaFeature_FoundingMonument"))
	print("NEW_PHILADELPHIA_FOUNDERS_SQUARE_SMOKE_OK room=NP-04 scene_collision=authored gateway=still_gated")
	get_tree().quit()
