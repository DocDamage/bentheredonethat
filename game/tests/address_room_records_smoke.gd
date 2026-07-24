extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")


func _ready() -> void:
	var errors := RECORDS.validate()
	assert(errors.is_empty(), "Address room records validation failed: %s" % errors)
	var af01 := RECORDS.record(&"AF-01")
	assert(af01.get("implementationState", &"") == &"scene_collision_authored_runtime_gated")
	assert(af01.get("populationContractId", &"") == &"af01-survivor-watch-v1")
	assert((af01.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO) == Vector2i(26, 18))
	assert((af01.get("navigation", {}) as Dictionary).get("walkableRects", []).size() == 4)
	assert(ResourceLoader.exists(String(af01.get("scenePath", ""))))
	assert((af01.get("layout", {}) as Dictionary).get("terrainRuns", []).size() == 1)
	assert((af01.get("navigation", {}) as Dictionary).get("blockedCells", []).size() == 102)
	assert((af01.get("navigation", {}) as Dictionary).get("collisionState", &"") == &"native_perimeter_and_landmark_shapes_authored")
	var navigation: Dictionary = af01.get("navigation", {})
	assert(navigation.get("arrivalSafeCells", {}) == {&"Nw": Vector2i(8, 3), &"E1": Vector2i(22, 6), &"Sw": Vector2i(8, 14)})
	assert(RECORDS.expected_arrival_follower_cells(Vector2i(8, 3), &"Nw") == [Vector2i(7, 3), Vector2i(9, 3), Vector2i(8, 4)])
	assert(RECORDS.expected_arrival_follower_cells(Vector2i(22, 6), &"E1") == [Vector2i(22, 5), Vector2i(22, 7), Vector2i(21, 6)])
	assert(RECORDS.expected_arrival_follower_cells(Vector2i(8, 14), &"Sw") == [Vector2i(9, 14), Vector2i(7, 14), Vector2i(8, 13)])
	assert(FileAccess.file_exists(String((af01.get("layout", {}) as Dictionary).get("firstVisitCapture", ""))))
	print("ADDRESS_ROOM_RECORDS_SMOKE_OK records=1 room=AF-01 state=scene_collision_authored_runtime_gated landmark_barricade=true")
	get_tree().quit(0)
