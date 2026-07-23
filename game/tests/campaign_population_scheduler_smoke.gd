extends Node

const SCHEDULER := preload("res://ben_rpg/world/campaign_population_scheduler.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	var errors := SCHEDULER.validate()
	assert(errors.is_empty(), "Population registry validation failed with %d error(s)." % errors.size())
	var hm02 := ROOM_REGISTRY.room(&"HM-02")
	var anchors: Dictionary = hm02.get("populationAnchorCells", {})
	assert(anchors.get(&"P1") == Vector2i(6, 6))
	assert(anchors.get(&"P6") == Vector2i(19, 12))
	var result := SCHEDULER.schedule_profiles(&"TEST-POP", [
		{&"id": &"approved", &"runtimeProfileId": &"runtime:approved", &"anchor": &"P1"},
		{&"id": &"quarantined", &"runtimeProfileId": &"runtime:blocked", &"anchor": &"P2", &"quarantined": true},
	], anchors, {anchors[&"P3"]: &"reserved"})
	var assignments: Array = result.get("assignments", [])
	assert(assignments.size() == 1 and assignments[0].get("cell") == anchors[&"P1"])
	assert(result.get("unavailable", []) == [&"quarantined"])
	var hm05 := ROOM_REGISTRY.room(&"HM-05")
	var hm05_reserved := SCHEDULER.reserved_cells_for_room(&"HM-05", hm05)
	assert(hm05_reserved.has(Vector2i(9, 7)), "Manifest save anchors must reserve their population cell.")
	assert(hm05_reserved.has((hm05.get("portCells", {}) as Dictionary).get(&"Nw")), "Manifest port cells must reserve their population cell.")
	var conflicting := SCHEDULER.schedule_profiles(&"TEST-POP", [
		{&"id": &"save_anchor_conflict", &"runtimeProfileId": &"runtime:approved", &"anchor": &"P1"},
	], {&"P1": Vector2i(9, 7)}, hm05_reserved)
	assert((conflicting.get("assignments", []) as Array).is_empty())
	assert(conflicting.get("unavailable", []) == [&"save_anchor_conflict"])
	print("CAMPAIGN_POPULATION_SCHEDULER_SMOKE_OK identities=267 quarantined=9 anchors=reserved ports+saves+features cohort=filtered")
	get_tree().quit()
