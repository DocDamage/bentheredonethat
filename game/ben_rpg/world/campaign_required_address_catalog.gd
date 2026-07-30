class_name CampaignRequiredAddressCatalog
extends RefCounted

## Locked Section 23.5-23.10 room contracts. Phase 5 admits these chapters
## through CampaignAnnexRoomRegistry after their complete production gate.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ADDRESS_ORDER := [&"ashfall", &"pelagic", &"steamforge", &"frontier", &"warfront", &"liminal"]
const EXTERNAL_TARGETS := [&"NP-03", &"NP-09", &"NP-12", &"NP-15"]
const ENCOUNTER_IDS_BY_ROOM := {
	&"AF-01": &"ashfall_cinder_gate_arrival_raid", &"AF-03": &"ashfall_green_ruins_patrol",
	&"AF-04": &"ashfall_polluted_causeway_hazards", &"AF-05": &"ashfall_bunker_defense_line",
	&"AF-06": &"ashfall_continuity_defenses", &"AF-07": &"ashfall_furnace_pact",
	&"AF-08": &"ashfall_supermarket_scavengers", &"AF-10": &"ashfall_school_memory_echo",
	&"AF-12": &"ashfall_bone_service_patrol",
}

static var ADDRESS_DEFINITIONS := {
	&"ashfall": _address(&"AF", "Ashfall Address", 12, [&"horror_arc_mansion_briefed"], &"ashfall_address_resolved", {&"duckets": 220, &"items": {&"reclamation_core": 1}}, [7, 3, 2], [
		["Cinder Gate", &"C", &"L2", [&"E1:AF-02", &"Sw:AF-11", &"Nw:NP-15"], &"ashfall_cinder_gate_arrival_raid"], ["Scavenger Exchange", &"C", &"H1", [&"W1:AF-01", &"E1:AF-03", &"Se:AF-09"]], ["Green Ruins Avenue", &"C", &"L3", [&"W1:AF-02", &"E1:AF-04", &"Se:AF-08"]], ["Polluted Causeway", &"C", &"M3", [&"W1:AF-03", &"E1:AF-05", &"Se:AF-10"]], ["Abandoned Bunker Exterior", &"C", &"L1", [&"W1:AF-04", &"E1:AF-06", &"Sw:AF-11"]], ["Continuity Bunker", &"C", &"L3", [&"W1:AF-05", &"E1:AF-07", &"Se:AF-12"]], ["Furnace of False Salvation", &"C", &"L4", [&"W1:AF-06"]], ["Abandoned Supermarket", &"O", &"L3", [&"Nw:AF-03", &"E1:AF-09"]], ["Recovery Farm", &"O", &"L2", [&"Nw:AF-02", &"W1:AF-08"]], ["Wasteland School", &"O", &"M3", [&"Nw:AF-04", &"E1:AF-12"]], ["Parking/Subway Bypass", &"X", &"S3", [&"Ne:AF-01", &"E1:AF-05"]], ["Bone-Service Tunnel", &"X", &"M1", [&"Nw:AF-06", &"W1:AF-10"]],
	]),
	&"pelagic": _address(&"PL", "Pelagic Address", 12, [&"pelagic_chart_recovered"], &"pelagic_address_resolved", {&"duckets": 220, &"items": {&"tide_crown": 1}}, [7, 3, 2], [
		["Sunward Beach", &"C", &"L2", [&"E1:PL-02", &"Sw:PL-11", &"Nw:NP-09"]], ["Pirate Harbor", &"C", &"H1", [&"W1:PL-01", &"E1:PL-03", &"Se:PL-08", &"Sw:PL-11"]], ["Stormglass Island", &"C", &"L3", [&"W1:PL-02", &"E1:PL-04", &"Se:PL-09"]], ["Continental Shelf Lift", &"C", &"M4", [&"W1:PL-03", &"E1:PL-05", &"Se:PL-12"]], ["Living Reef Road", &"C", &"L3", [&"W1:PL-04", &"E1:PL-06", &"Se:PL-10"]], ["Sunken City Gate", &"C", &"L3", [&"W1:PL-05", &"E1:PL-07", &"Sw:PL-10", &"Se:PL-12"]], ["Abyssal Crown Chamber", &"C", &"L4", [&"W1:PL-06"]], ["Moonwake Resort", &"O", &"L2", [&"Nw:PL-02", &"E1:PL-11"]], ["Pirate Wreck Labyrinth", &"O", &"M3", [&"Nw:PL-03", &"E1:PL-12"]], ["Coral Reliquary", &"O", &"L2", [&"Nw:PL-05", &"E1:PL-06"]], ["Public Ferry Loop", &"X", &"S3", [&"Ne:PL-01", &"E1:PL-02", &"W1:PL-08"]], ["Pressure Current", &"X", &"M1", [&"Nw:PL-04", &"E1:PL-06", &"W1:PL-09"]],
	]),
	&"steamforge": _address(&"SF", "Steamforge Address", 12, [&"steamforge_salvage_telemetry"], &"steamforge_address_resolved", {&"duckets": 220, &"items": {&"pressure_regulator": 1}}, [7, 3, 2], [
		["Airship Freight Dock", &"C", &"L2", [&"E1:SF-02", &"Sw:SF-11", &"Nw:NP-12"]], ["Ferrum Slums", &"C", &"H1", [&"W1:SF-01", &"E1:SF-03", &"Se:SF-09"]], ["Junkyard Parliament", &"C", &"L3", [&"W1:SF-02", &"E1:SF-04", &"Se:SF-08"]], ["Boiler Bridgeworks", &"C", &"M4", [&"W1:SF-03", &"E1:SF-05", &"Sw:SF-11", &"Se:SF-12"]], ["Civic Foundry", &"C", &"L3", [&"W1:SF-04", &"E1:SF-06", &"Se:SF-10"]], ["Arc Reactor Laboratory", &"C", &"L2", [&"W1:SF-05", &"E1:SF-07", &"Sw:SF-12"]], ["Baron's Pressure Court", &"C", &"L4", [&"W1:SF-06"]], ["Factory Ruins", &"O", &"L3", [&"Nw:SF-03", &"E1:SF-11"]], ["Gear Market", &"O", &"L2", [&"Nw:SF-02", &"E1:SF-10"]], ["Duchess's Design House", &"O", &"M3", [&"Nw:SF-05", &"W1:SF-09"]], ["Condensate Tram", &"X", &"S3", [&"Ne:SF-01", &"E1:SF-04", &"W1:SF-08"]], ["Service Pipeway", &"X", &"M1", [&"Nw:SF-04", &"E1:SF-06"]],
	]),
	&"frontier": _address(&"FT", "Frontier Address", 10, [&"frontier_rail_deed"], &"frontier_address_resolved", {&"duckets": 180, &"items": {&"public_rail_deed": 1}}, [6, 2, 2], [
		["Fault-Line Railhead", &"C", &"L1", [&"E1:FT-02", &"Sw:FT-09", &"Nw:NP-12"]], ["Blackwood Main Street", &"C", &"H1", [&"W1:FT-01", &"E1:FT-03", &"Se:FT-07"]], ["Open-Sky Ranch", &"C", &"L3", [&"W1:FT-02", &"E1:FT-04", &"Se:FT-08"]], ["Red Mesa Canyon", &"C", &"M4", [&"W1:FT-03", &"E1:FT-05", &"Sw:FT-09", &"Se:FT-10"]], ["Royal Vein Mine", &"C", &"L3", [&"W1:FT-04", &"E1:FT-06", &"Sw:FT-10"]], ["King's Claim Office", &"C", &"L4", [&"W1:FT-05"]], ["Rose's Saloon", &"O", &"M3", [&"Nw:FT-02", &"E1:FT-09"]], ["Prospector's Side Cavern", &"O", &"L2", [&"Nw:FT-03", &"E1:FT-10"]], ["Rail Loop", &"X", &"S3", [&"Ne:FT-01", &"E1:FT-04", &"W1:FT-07"]], ["Smuggler Switchback", &"X", &"M1", [&"Nw:FT-04", &"E1:FT-05", &"W1:FT-08"]],
	]),
	&"warfront": _address(&"WF", "Warfront Address", 10, [&"warfront_ledger_recovered"], &"warfront_address_resolved", {&"duckets": 180, &"items": {&"ceasefire_transmitter": 1}}, [6, 2, 2], [
		["Memorial Staging Ground", &"C", &"L1", [&"E1:WF-02", &"Sw:WF-09", &"Nw:NP-15"]], ["First-Line Trenches", &"C", &"L3", [&"W1:WF-01", &"E1:WF-03", &"Se:WF-07"]], ["Command Bunker", &"C", &"M4", [&"W1:WF-02", &"E1:WF-04", &"Sw:WF-09"]], ["Forest No-Man's-Land", &"C", &"L3", [&"W1:WF-03", &"E1:WF-05", &"Se:WF-08"]], ["Collapsed City Corridor", &"C", &"L3", [&"W1:WF-04", &"E1:WF-06", &"Sw:WF-10"]], ["Ceasefire Operations Hall", &"C", &"L4", [&"W1:WF-05"]], ["Normandy Echo", &"O", &"L2", [&"Nw:WF-02", &"E1:WF-09"]], ["Silent Submarine", &"O", &"L2", [&"Nw:WF-04", &"E1:WF-10"]], ["Supply Rail Cut", &"X", &"S3", [&"Ne:WF-01", &"E1:WF-03", &"W1:WF-07"]], ["Temporal Rubble Tunnel", &"X", &"M1", [&"Nw:WF-05", &"W1:WF-08"]],
	]),
	&"liminal": _address(&"LM", "Liminal Address", 8, [&"liminal_main_quest_unlocked"], &"liminal_address_resolved", {&"duckets": 160, &"items": {&"null_index": 1}}, [5, 2, 1], [
		["Fluorescent Reception", &"C", &"M2", [&"E1:LM-02", &"Sw:LM-08", &"Nw:NP-03"]], ["Yellow Office Loop", &"C", &"L2", [&"W1:LM-01", &"E1:LM-03", &"Se:LM-06"]], ["Concrete Maintenance Level", &"C", &"M4", [&"W1:LM-02", &"E1:LM-04", &"Sw:LM-08"]], ["Poolcore Threshold", &"C", &"L3", [&"W1:LM-03", &"E1:LM-05", &"Se:LM-07"]], ["Exit Archive", &"C", &"L4", [&"W1:LM-04"]], ["Level Ten Records", &"O", &"M3", [&"Nw:LM-02", &"E1:LM-08"]], ["Silent Pool", &"O", &"L2", [&"Nw:LM-04", &"E1:LM-08"]], ["Service Elevator", &"X", &"S3", [&"Ne:LM-01", &"E1:LM-03", &"W1:LM-06", &"W2:LM-07"]],
	]),
}


static func address(address_id: StringName) -> Dictionary:
	return (ADDRESS_DEFINITIONS.get(address_id, {}) as Dictionary).duplicate(true)


static func room(room_id: StringName) -> Dictionary:
	for definition in ADDRESS_DEFINITIONS.values():
		for record in (definition.get("rooms", []) as Array):
			if StringName(record.get("id", &"")) == room_id:
				return record.duplicate(true)
	return {}


static func address_for_room(room_id: StringName) -> StringName:
	for address_id in ADDRESS_ORDER:
		for record in (ADDRESS_DEFINITIONS[address_id].get("rooms", []) as Array):
			if StringName(record.get("id", &"")) == room_id:
				return address_id
	return &""


static func room_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for address_id in ADDRESS_ORDER:
		for record in (ADDRESS_DEFINITIONS[address_id].get("rooms", []) as Array):
			result.append(StringName(record.get("id", &"")))
	return result


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if ADDRESS_DEFINITIONS.size() != 6:
		errors.append("Required address catalog must contain six addresses.")
	for address_id in ADDRESS_ORDER:
		var definition: Dictionary = ADDRESS_DEFINITIONS.get(address_id, {})
		var rooms: Array = definition.get("rooms", [])
		var expected: Array = definition.get("classBudget", [])
		if rooms.size() != int(definition.get("roomCount", 0)) or expected.size() != 3:
			errors.append("%s has an invalid room or class budget." % address_id)
			continue
		var counts := {&"C": 0, &"O": 0, &"X": 0}
		var known_ids := {}
		for record in rooms:
			var room_id := StringName(record.get("id", &""))
			var room_class := StringName(record.get("class", &""))
			var blueprint := StringName(record.get("blueprint", &""))
			if room_id == &"" or known_ids.has(room_id) or room_class not in counts or not ROOM_REGISTRY.BLUEPRINTS.has(blueprint):
				errors.append("%s has an invalid room record %s." % [address_id, room_id])
				continue
			known_ids[room_id] = true
			counts[room_class] += 1
			for port_id in (record.get("ports", {}) as Dictionary).keys():
				var target := StringName(record["ports"][port_id])
				if not (ROOM_REGISTRY.BLUEPRINTS[blueprint].get("ports", {}) as Dictionary).has(port_id):
					errors.append("%s uses unavailable %s port %s." % [room_id, blueprint, port_id])
				elif not target in EXTERNAL_TARGETS and not String(target).begins_with(String(definition.get("prefix", ""))):
					errors.append("%s links outside its address: %s." % [room_id, target])
		if counts[&"C"] != int(expected[0]) or counts[&"O"] != int(expected[1]) or counts[&"X"] != int(expected[2]):
			errors.append("%s class budget differs from the locked matrix." % address_id)
		if StringName(definition.get("resolutionFlag", &"")) == &"" or not bool(definition.get("runtimeEnabled", false)):
			errors.append("%s must be production-admitted with a resolution flag." % address_id)
	return PackedStringArray(errors)


static func _address(prefix: StringName, title: String, room_count: int, unlock_flags: Array, resolution_flag: StringName, rewards: Dictionary, class_budget: Array, rows: Array) -> Dictionary:
	var rooms: Array[Dictionary] = []
	for index in rows.size():
		var row: Array = rows[index]
		var port_map := {}
		for binding in row[3]:
			var parts := String(binding).split(":", false, 1)
			port_map[StringName(parts[0])] = StringName(parts[1])
		var room_id := StringName("%s-%02d" % [prefix, index + 1])
		var encounter_id := StringName(row[4]) if row.size() > 4 else StringName(ENCOUNTER_IDS_BY_ROOM.get(room_id, &""))
		if encounter_id == &"" and StringName(row[1]) == &"C":
			encounter_id = StringName("%s_%02d_%s" % [String(prefix).to_lower(), index + 1, "boss" if index == int(class_budget[0]) - 1 else "encounter"])
		rooms.append({"id": room_id, "title": row[0], "class": row[1], "blueprint": row[2], "ports": port_map, "encounterId": encounter_id})
	return {"prefix": prefix, "title": title, "roomCount": room_count, "unlockFlags": unlock_flags, "resolutionFlag": resolution_flag, "rewards": rewards, "classBudget": class_budget, "runtimeEnabled": true, "rooms": rooms}
