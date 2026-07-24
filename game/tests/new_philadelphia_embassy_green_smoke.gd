extends Node
const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
const SCENE := preload("res://ben_rpg/world/rooms/new_philadelphia_embassy_green.tscn")
func _ready() -> void:
	var errors := RECORDS.validate()
	assert(errors.is_empty(), "NP-15 record validation failed: %s" % errors)
	var room := SCENE.instantiate()
	add_child(room)
	assert(room.get_meta(&"room_id") == &"NP-15" and bool(room.get_meta(&"runtime_gated")))
	var collision := room.get_node("NavigationAndCollision")
	assert(collision.call(&"blocked_cell_count") == 96)
	assert(room.get_node("InteractionLayer").has_node("NewPhiladelphiaFeature_CharterTable"))
	print("NEW_PHILADELPHIA_EMBASSY_GREEN_SMOKE_OK room=NP-15 scene_collision=authored gateway=still_gated")
	get_tree().quit()
