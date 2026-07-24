extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")


func _ready() -> void:
	var errors := RECORDS.validate()
	assert(errors.is_empty(), "Address room records validation failed: %s" % errors)
	var af01 := RECORDS.record(&"AF-01")
	assert(af01.get("implementationState", &"") == &"scene_authored_runtime_gated")
	assert((af01.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO) == Vector2i(26, 18))
	assert((af01.get("navigation", {}) as Dictionary).get("walkableRects", []).size() == 1)
	assert(ResourceLoader.exists(String(af01.get("scenePath", ""))))
	assert((af01.get("layout", {}) as Dictionary).get("terrainRuns", []).size() == 1)
	assert((af01.get("navigation", {}) as Dictionary).get("blockedCells", []).size() == 84)
	assert(FileAccess.file_exists(String((af01.get("layout", {}) as Dictionary).get("firstVisitCapture", ""))))
	print("ADDRESS_ROOM_RECORDS_SMOKE_OK records=1 room=AF-01 state=scene_authored_runtime_gated")
	get_tree().quit(0)
