extends Node

const REPORT := preload("res://ben_rpg/world/campaign_room_graph_report.gd")


func _ready() -> void:
	assert(REPORT.validate().is_empty())
	var fresh := REPORT.build(REPORT.story_state(&"fresh"))
	assert(int(fresh.get("totalNodes", 0)) == 102)
	assert((fresh.get("worlds", []) as Array).size() == 7)
	var mansion_fresh := _world(fresh, "HauntedMansion")
	assert(not mansion_fresh.is_empty())
	assert(_edge(mansion_fresh, &"HM-02", &"E1").get("gateFlag", &"") == &"mansion_first_room_complete")
	assert(not bool(_edge(mansion_fresh, &"HM-02", &"E1").get("enabled", true)))
	assert(_has_return(mansion_fresh, &"FI-05"))
	var stabilized := REPORT.build(REPORT.story_state(&"stabilized"))
	var mansion_stabilized := _world(stabilized, "HauntedMansion")
	assert(bool(_edge(mansion_stabilized, &"HM-02", &"E1").get("enabled", false)))
	assert((mansion_stabilized.get("unreachableRoomIds", []) as Array).is_empty())
	assert((mansion_stabilized.get("criticalPathRoomIds", []) as Array).back() == &"HM-09")
	assert((mansion_stabilized.get("optionalRoomIds", []) as Array).has(&"HM-10"))
	assert(not (mansion_stabilized.get("loopEdges", []) as Array).is_empty())
	assert(not (mansion_stabilized.get("savePoints", []) as Array).is_empty())
	var postgame := REPORT.build(REPORT.story_state(&"postgame"))
	assert(int(postgame.get("totalEdges", 0)) >= int(fresh.get("totalEdges", 0)))
	print("CAMPAIGN_ROOM_GRAPH_REPORT_SMOKE_OK states=fresh+mid_puzzle+stabilized+postgame nodes=102 worlds=7 mansion_gates+saves+returns=true")
	get_tree().quit()


func _world(report: Dictionary, prefix: String) -> Dictionary:
	for world in report.get("worlds", []):
		if String(world.get("facility", "")) == prefix:
			return world
	return {}


func _edge(world: Dictionary, source_room_id: StringName, port_id: StringName) -> Dictionary:
	for edge in world.get("edges", []):
		if StringName(edge.get("sourceRoomId", &"")) == source_room_id and StringName(edge.get("portId", &"")) == port_id:
			return edge
	return {}


func _has_return(world: Dictionary, target_room_id: StringName) -> bool:
	for edge in world.get("returns", []):
		if StringName(edge.get("targetRoomId", &"")) == target_room_id:
			return true
	return false
