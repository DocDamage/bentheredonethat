extends Node
const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
func _ready() -> void:
	assert(RECORDS.validate().is_empty())
	for expected in [[&"NP-11", "new_philadelphia_south_commons", 89, &"events_stage"], [&"NP-12", "new_philadelphia_transit_service_yard", 89, &"dispatch_board"], [&"NP-13", "new_philadelphia_residential_baker_lane", 85, &"neighborhood_notice"], [&"NP-14", "new_philadelphia_recreation_park", 81, &"recreation_booking"]]:
		var scene := load("res://ben_rpg/world/rooms/%s.tscn" % expected[1]) as PackedScene
		assert(scene)
		var room := scene.instantiate() as Node2D
		add_child(room)
		assert(room.get_meta(&"room_id", &"") == expected[0] and bool(room.get_meta(&"runtime_gated", false)))
		assert(room.get_node("NavigationAndCollision").call(&"blocked_cell_count") == expected[2])
		assert(room.get_node("InteractionLayer").has_node("NewPhiladelphiaFeature_%s" % expected[3]))
		room.queue_free(); await get_tree().process_frame
	print("NEW_PHILADELPHIA_FINAL_DISTRICTS_SMOKE_OK rooms=4 lots=3 scene_collision=authored")
	get_tree().quit()
