class_name CampaignRoomGraphReport
extends RefCounted

## Produces a data-only audit of the complete room graph for a supplied story
## state. It intentionally does not instantiate rooms; release tooling and
## smoke tests can therefore inspect 102-room reachability without waking every
## renderer, encounter runtime, or population cohort.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

const STORY_STATES := {
	&"fresh": {},
	&"mid_puzzle": {
		&"mansion_first_room_complete": true,
		&"primeval_terminal_decoded": true,
		&"helios_curfew_lifted": true,
		&"frosthold_rune_clue_found": true,
		&"moonpetal_vow_clue_found": true,
		&"empyreal_gravity_clue_found": true,
	},
	&"stabilized": {
		&"mansion_first_room_complete": true,
		&"mansion_temporal_secret_found": true,
		&"mansion_crypt_key_found": true,
		&"mansion_attic_latch_open": true,
		&"mansion_ballroom_open": true,
		&"asterion_station_restored": true,
		&"asterion_station_complete": true,
		&"asterion_medical_ambush_cleared": true,
		&"primeval_terminal_decoded": true,
		&"primeval_caldera_open": true,
		&"primeval_scenario_complete": true,
		&"helios_curfew_lifted": true,
		&"helios_core_restored": true,
		&"frosthold_rune_clue_found": true,
		&"frosthold_causeway_open": true,
		&"frosthold_scenario_complete": true,
		&"moonpetal_vow_clue_found": true,
		&"moonpetal_mirror_open": true,
		&"moonpetal_scenario_complete": true,
		&"empyreal_gravity_clue_found": true,
		&"empyreal_aerie_open": true,
		&"empyreal_scenario_complete": true,
	},
	&"postgame": {
		&"mansion_first_room_complete": true,
		&"mansion_temporal_secret_found": true,
		&"mansion_crypt_key_found": true,
		&"mansion_attic_latch_open": true,
		&"mansion_ballroom_open": true,
		&"asterion_station_restored": true,
		&"asterion_station_complete": true,
		&"asterion_medical_ambush_cleared": true,
		&"primeval_terminal_decoded": true,
		&"primeval_caldera_open": true,
		&"primeval_scenario_complete": true,
		&"helios_curfew_lifted": true,
		&"helios_core_restored": true,
		&"frosthold_rune_clue_found": true,
		&"frosthold_causeway_open": true,
		&"frosthold_scenario_complete": true,
		&"moonpetal_vow_clue_found": true,
		&"moonpetal_mirror_open": true,
		&"moonpetal_scenario_complete": true,
		&"empyreal_gravity_clue_found": true,
		&"empyreal_aerie_open": true,
		&"empyreal_scenario_complete": true,
		&"postgame_unlocked": true,
	},
}


static func build(story_flags: Dictionary = {}) -> Dictionary:
	var worlds: Array[Dictionary] = []
	var total_nodes := 0
	var total_edges := 0
	var total_blocked_edges := 0
	for portal in ROOM_REGISTRY.FACILITY_PORTALS.values():
		var room_ids: Array = portal.get("roomIds", [])
		var entry_room_id := StringName(portal.get("entryRoomId", &""))
		var nodes: Array[Dictionary] = []
		var edges: Array[Dictionary] = []
		var blocked_edges: Array[Dictionary] = []
		var saves: Array[Dictionary] = []
		var returns: Array[Dictionary] = []
		for raw_room_id in room_ids:
			var room_id := StringName(raw_room_id)
			var definition := ROOM_REGISTRY.room(room_id)
			var node := {
				"roomId": room_id,
				"scenePath": String(definition.get("scenePath", "")),
				"encounterPolicy": StringName(definition.get("encounterPolicy", &"none")),
				"visualProfileIds": definition.get("visualProfileIds", []),
			}
			nodes.append(node)
			var save_point: Dictionary = definition.get("savePoint", {})
			if not save_point.is_empty():
				saves.append({"roomId": room_id, "id": StringName(save_point.get("id", &"")), "cell": save_point.get("cell", Vector2i.ZERO)})
			for property_name in [&"asterionInteractions", &"primevalInteractions", &"heliosInteractions", &"frostholdInteractions", &"moonpetalInteractions", &"empyrealInteractions"]:
				for interaction in definition.get(property_name, []):
					var save_id := StringName(interaction.get("savePointId", &""))
					if save_id != &"":
						saves.append({"roomId": room_id, "id": save_id, "cell": interaction.get("cell", Vector2i.ZERO)})
			var gates: Dictionary = definition.get("portGates", {})
			for binding in ROOM_REGISTRY.ports(room_id):
				var port_id := StringName(binding.get("id", &""))
				var target_room_id := StringName(binding.get("destination", &""))
				var gate_flag := StringName(gates.get(port_id, &""))
				var enabled := gate_flag == &"" or bool(story_flags.get(gate_flag, false))
				var target_is_room := target_room_id in room_ids
				var returns_to_source := _has_return_edge(target_room_id, room_id)
				var edge := {
					"sourceRoomId": room_id,
					"portId": port_id,
					"targetRoomId": target_room_id,
					"gateFlag": gate_flag,
					"enabled": enabled,
					"internal": target_is_room,
					"reciprocal": returns_to_source,
				}
				edges.append(edge)
				if not enabled:
					blocked_edges.append(edge)
				if not target_is_room:
					returns.append(edge)
		var reachable := _reachable_room_ids(entry_room_id, edges)
		var unreachable: Array[StringName] = []
		for raw_room_id in room_ids:
			var room_id := StringName(raw_room_id)
			if not reachable.has(room_id):
				unreachable.append(room_id)
		var critical_target := _first_boss_room(room_ids)
		var critical_path := _shortest_path(entry_room_id, critical_target, edges)
		var optional_rooms: Array[StringName] = []
		for reachable_room_id in reachable:
			var room_id := StringName(reachable_room_id)
			if room_id not in critical_path:
				optional_rooms.append(room_id)
		var loop_edges: Array[Dictionary] = []
		for edge in edges:
			if bool(edge.get("internal", false)) and bool(edge.get("reciprocal", false)):
				loop_edges.append(edge)
		var world := {
			"facility": String(portal.get("prefix", "")),
			"entryRoomId": entry_room_id,
			"nodes": nodes,
			"edges": edges,
			"blockedEdges": blocked_edges,
			"reachableRoomIds": reachable.keys(),
			"unreachableRoomIds": unreachable,
			"criticalPathRoomIds": critical_path,
			"optionalRoomIds": optional_rooms,
			"loopEdges": loop_edges,
			"savePoints": saves,
			"returns": returns,
		}
		worlds.append(world)
		total_nodes += nodes.size()
		total_edges += edges.size()
		total_blocked_edges += (world.get("blockedEdges", []) as Array).size()
	return {"worlds": worlds, "totalNodes": total_nodes, "totalEdges": total_edges, "totalBlockedEdges": total_blocked_edges}


static func story_state(state_id: StringName) -> Dictionary:
	return (STORY_STATES.get(state_id, {}) as Dictionary).duplicate(true)


static func _reachable_room_ids(entry_room_id: StringName, edges: Array[Dictionary]) -> Dictionary:
	var reachable := {entry_room_id: true}
	var changed := true
	while changed:
		changed = false
		for edge in edges:
			if not bool(edge.get("enabled", false)) or not bool(edge.get("internal", false)):
				continue
			var source := StringName(edge.get("sourceRoomId", &""))
			var target := StringName(edge.get("targetRoomId", &""))
			if reachable.has(source) and not reachable.has(target):
				reachable[target] = true
				changed = true
	return reachable


static func _has_return_edge(room_id: StringName, source_room_id: StringName) -> bool:
	if not ROOM_REGISTRY.has_room(room_id):
		return false
	for binding in ROOM_REGISTRY.ports(room_id):
		if StringName(binding.get("destination", &"")) == source_room_id:
			return true
	return false


static func _first_boss_room(room_ids: Array) -> StringName:
	for raw_room_id in room_ids:
		var room_id := StringName(raw_room_id)
		if StringName(ROOM_REGISTRY.room(room_id).get("encounterPolicy", &"none")) == &"boss":
			return room_id
	return &""


static func _shortest_path(start_room_id: StringName, target_room_id: StringName, edges: Array[Dictionary]) -> Array[StringName]:
	if start_room_id == &"" or target_room_id == &"":
		return []
	var previous: Dictionary = {start_room_id: &""}
	var queue: Array[StringName] = [start_room_id]
	while not queue.is_empty():
		var current: StringName = queue.pop_front()
		if current == target_room_id:
			break
		for edge in edges:
			if not bool(edge.get("enabled", false)) or not bool(edge.get("internal", false)):
				continue
			if StringName(edge.get("sourceRoomId", &"")) != current:
				continue
			var target := StringName(edge.get("targetRoomId", &""))
			if not previous.has(target):
				previous[target] = current
				queue.append(target)
	if not previous.has(target_room_id):
		return []
	var reverse_path: Array[StringName] = []
	var cursor := target_room_id
	while cursor != &"":
		reverse_path.append(cursor)
		cursor = StringName(previous[cursor])
	reverse_path.reverse()
	return reverse_path


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for state_id in STORY_STATES:
		var report := build(story_state(state_id))
		if int(report.get("totalNodes", 0)) != 102:
			errors.append("Graph report %s must include all 102 rooms." % state_id)
		if (report.get("worlds", []) as Array).size() != 7:
			errors.append("Graph report %s must include all seven core worlds." % state_id)
	return PackedStringArray(errors)
