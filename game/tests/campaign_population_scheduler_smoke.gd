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
	print("CAMPAIGN_POPULATION_SCHEDULER_SMOKE_OK identities=267 quarantined=9 anchors=reserved cohort=filtered")
	get_tree().quit()
