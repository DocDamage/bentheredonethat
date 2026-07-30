extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")


func _ready() -> void:
	var errors := RECORDS.validate()
	assert(errors.is_empty(), "Address room records validation failed: %s" % errors)
	var af01 := RECORDS.record(&"AF-01")
	assert(RECORDS.RECORDS.size() == 64)
	assert(af01.get("implementationState", &"") == &"implemented")
	assert(af01.get("populationContractId", &"") == &"af01-survivor-watch-v1")
	assert((af01.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO) == Vector2i(26, 18))
	assert(ResourceLoader.exists(String(af01.get("scenePath", ""))))
	assert((af01.get("layout", {}) as Dictionary).get("visualProfileIds", []).size() >= 2)
	assert((af01.get("navigation", {}) as Dictionary).get("blockedCells", []).size() > 0)
	var navigation: Dictionary = af01.get("navigation", {})
	assert(navigation.get("arrivalSafeCells", {}) == {&"Nw": Vector2i(8, 3), &"E1": Vector2i(22, 6), &"Sw": Vector2i(8, 14)})
	assert(RECORDS.expected_arrival_follower_cells(Vector2i(8, 3), &"Nw") == [Vector2i(7, 3), Vector2i(9, 3), Vector2i(8, 4)])
	assert(RECORDS.expected_arrival_follower_cells(Vector2i(22, 6), &"E1") == [Vector2i(22, 5), Vector2i(22, 7), Vector2i(21, 6)])
	assert(RECORDS.expected_arrival_follower_cells(Vector2i(8, 14), &"Sw") == [Vector2i(9, 14), Vector2i(7, 14), Vector2i(8, 13)])
	print("ADDRESS_ROOM_RECORDS_SMOKE_OK records=64 state=implemented navigation=authored populations=phased")
	get_tree().quit(0)
