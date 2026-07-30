extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
const SCENE := preload("res://ben_rpg/world/rooms/new_philadelphia_invention_annex.tscn")


func _ready() -> void:
	var errors := RECORDS.validate()
	assert(errors.is_empty(), "New Philadelphia room record validation failed: %s" % errors)
	var room := SCENE.instantiate()
	add_child(room)
	assert(room.get_meta(&"room_id") == &"NP-02" and bool(room.get_meta(&"runtime_gated")))
	var collision := room.get_node("NavigationAndCollision")
	assert(collision.call(&"blocked_cell_count") == 81)
	assert(collision.call(&"blocks_cell", Vector2i(12, 8)))
	assert(room.get_node("InteractionLayer").has_node("NewPhiladelphiaFeature_InventionBench"))
	print("NEW_PHILADELPHIA_INVENTION_ANNEX_SMOKE_OK room=NP-02 scene_collision=authored gateway=still_gated")
	get_tree().quit()
