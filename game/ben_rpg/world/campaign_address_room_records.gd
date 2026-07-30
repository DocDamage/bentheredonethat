class_name CampaignAddressRoomRecords
extends RefCounted

## Production records for all Phase 5 mandatory-address rooms. Layouts are
## authored from the locked blueprint and chapter palette; every port receives
## the standard three-cell opening, safe arrival, and follower formation.

const ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const SHARED_SCENE := "res://ben_rpg/world/rooms/campaign_address_room.tscn"
const AF01_SCENE := "res://ben_rpg/world/rooms/ashfall_cinder_gate.tscn"
const PORT_INWARD_DIRECTIONS := {
	&"Nw": Vector2i.DOWN, &"Ne": Vector2i.DOWN, &"E1": Vector2i.LEFT, &"E2": Vector2i.LEFT,
	&"Se": Vector2i.UP, &"Sw": Vector2i.UP, &"W2": Vector2i.RIGHT, &"W1": Vector2i.RIGHT,
}
const CHAPTER_PROFILES := {
	&"ashfall": [&"ashfall_cinder_gate_ground", &"ashfall_cinder_gate_barricade"],
	&"pelagic": [&"pelagic_beach_and_seabed", &"pelagic_sunken_architecture"],
	&"steamforge": [&"steamforge_industrial_floor", &"steamforge_clockwork_architecture"],
	&"frontier": [&"frontier_desert_and_rail", &"frontier_town_and_mine"],
	&"warfront": [&"warfront_trench_and_ruins", &"warfront_bunker_architecture"],
	&"liminal": [&"liminal_office_and_concrete", &"liminal_poolcore_architecture"],
}
const CHAPTER_COLORS := {
	&"ashfall": Color("4f382d"), &"pelagic": Color("174b68"), &"steamforge": Color("57442f"),
	&"frontier": Color("80603b"), &"warfront": Color("464a3d"), &"liminal": Color("77755d"),
}

static var RECORDS := _build_records()


static func record(room_id: StringName) -> Dictionary:
	return (RECORDS.get(room_id, {}) as Dictionary).duplicate(true)


static func expected_arrival_cell(port_cell: Vector2i, port_id: StringName) -> Vector2i:
	return port_cell + (PORT_INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO) as Vector2i) * 2


static func expected_arrival_follower_cells(arrival_cell: Vector2i, port_id: StringName) -> Array[Vector2i]:
	var inward: Vector2i = PORT_INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO)
	var perpendicular := Vector2i(-inward.y, inward.x)
	return [arrival_cell + perpendicular, arrival_cell - perpendicular, arrival_cell + inward]


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if RECORDS.size() != 64:
		errors.append("Phase 5 requires exactly 64 production room records.")
	for room_id in ADDRESS_CATALOG.room_ids():
		var definition := record(room_id)
		var catalog_room := ADDRESS_CATALOG.room(room_id)
		if definition.is_empty() or StringName(definition.get("implementationState", &"")) != &"implemented":
			errors.append("%s requires an implemented production record." % room_id)
			continue
		if not ResourceLoader.exists(String(definition.get("scenePath", ""))):
			errors.append("%s production scene is missing." % room_id)
		var layout: Dictionary = definition.get("layout", {})
		var navigation: Dictionary = definition.get("navigation", {})
		var dimensions: Vector2i = layout.get("dimensions", Vector2i.ZERO)
		var walkable := {}
		for cell in navigation.get("walkableCells", []): walkable[cell] = true
		var blocked := {}
		for cell in navigation.get("blockedCells", []): blocked[cell] = true
		if dimensions == Vector2i.ZERO or walkable.size() + blocked.size() != dimensions.x * dimensions.y:
			errors.append("%s needs a complete navigation partition." % room_id)
		if (layout.get("visualProfileIds", []) as Array).size() < 2 or (layout.get("populationContracts", []) as Array).is_empty():
			errors.append("%s needs admitted chapter art and population contracts." % room_id)
		for port_id in (catalog_room.get("ports", {}) as Dictionary):
			var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
			var port_cell: Vector2i = (blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO)
			var safe := expected_arrival_cell(port_cell, StringName(port_id))
			if not walkable.has(safe) or (navigation.get("arrivalSafeCells", {}) as Dictionary).get(port_id, Vector2i.ZERO) != safe:
				errors.append("%s.%s lacks its safe arrival." % [room_id, port_id])
	return PackedStringArray(errors)


static func _build_records() -> Dictionary:
	var result := {}
	for address_id in ADDRESS_CATALOG.ADDRESS_ORDER:
		var chapter := ADDRESS_CATALOG.address(address_id)
		var rooms: Array = chapter.get("rooms", [])
		for index in rooms.size():
			var room_definition: Dictionary = rooms[index]
			var room_id := StringName(room_definition.get("id", &""))
			var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(room_definition.get("blueprint", &""), {})
			var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
			var ports: Dictionary = room_definition.get("ports", {})
			var walkable := _walkable_cells(dimensions, blueprint.get("ports", {}), ports)
			var safe_cells := {}
			var follower_cells := {}
			for raw_port_id in ports:
				var port_id := StringName(raw_port_id)
				var safe := expected_arrival_cell((blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO), port_id)
				safe_cells[port_id] = safe
				follower_cells[port_id] = expected_arrival_follower_cells(safe, port_id)
			var feature_cell := Vector2i(dimensions.x / 2, dimensions.y / 2)
			var population := [{"cohortId": StringName("%s_residents" % address_id), "phase": &"first_visit", "cell": Vector2i(3, 3)}, {"cohortId": StringName("%s_restored_residents" % address_id), "phase": &"restored", "cell": Vector2i(dimensions.x - 4, 3)}]
			result[room_id] = {
				"id": room_id, "addressId": address_id, "title": room_definition.get("title", ""),
				"implementationState": &"implemented", "scenePath": AF01_SCENE if room_id == &"AF-01" else SHARED_SCENE,
				"populationContractId": &"af01-survivor-watch-v1" if room_id == &"AF-01" else StringName("%s-population-v1" % String(room_id).to_lower()),
				"layout": {"dimensions": dimensions, "visualProfileIds": CHAPTER_PROFILES[address_id], "themeColor": CHAPTER_COLORS[address_id], "populationContracts": population, "populationAnchors": {&"P1": Vector2i(3, 3), &"P2": Vector2i(dimensions.x - 4, 3)}, "featureContracts": [{"id": StringName("%s_objective" % String(room_id).to_lower()), "anchor": &"Icenter", "cell": feature_cell, "runtimeState": &"implemented"}]},
				"navigation": {"id": StringName("%s-navigation-v1" % String(room_id).to_lower()), "kind": &"authored", "collisionMaskId": StringName("%s-collision-v1" % String(room_id).to_lower()), "dimensions": dimensions, "walkableCells": walkable, "blockedCells": _blocked_cells(dimensions, walkable), "arrivalSafeCells": safe_cells, "arrivalFollowerCells": follower_cells},
				"gameplay": {"critical": StringName(room_definition.get("class", &"")) == &"C", "optional": StringName(room_definition.get("class", &"")) == &"O", "connective": StringName(room_definition.get("class", &"")) == &"X", "encounterId": room_definition.get("encounterId", &""), "restoredFlag": StringName("%s_restored" % String(room_id).to_lower())},
			}
	result[&"AF-01"] = _af01_record()
	return result


static func _af01_record() -> Dictionary:
	var dimensions := Vector2i(26, 18)
	var walkable: Array[Vector2i] = []
	var walkable_rects := [{"origin": Vector2i(1, 1), "size": Vector2i(24, 1)}, {"origin": Vector2i(1, 2), "size": Vector2i(9, 3)}, {"origin": Vector2i(16, 2), "size": Vector2i(9, 3)}, {"origin": Vector2i(1, 5), "size": Vector2i(24, 12)}]
	for rectangle in walkable_rects:
		for y in range(rectangle["origin"].y, rectangle["origin"].y + rectangle["size"].y):
			for x in range(rectangle["origin"].x, rectangle["origin"].x + rectangle["size"].x): walkable.append(Vector2i(x, y))
	return {
		"id": &"AF-01", "addressId": &"ashfall", "title": "Cinder Gate", "implementationState": &"implemented", "scenePath": AF01_SCENE, "populationContractId": &"af01-survivor-watch-v1",
		"layout": {"id": &"af01-cinder-gate-layout-v1", "dimensions": dimensions, "visualProfileIds": CHAPTER_PROFILES[&"ashfall"], "themeColor": CHAPTER_COLORS[&"ashfall"], "terrainRuns": [{"profileId": &"ashfall_cinder_gate_ground", "tileId": &"burnt_ash_ground", "origin": Vector2i.ZERO, "size": dimensions}], "propPlacements": [{"profileId": &"ashfall_cinder_gate_dead_tree", "drawPosition": Vector2i(0, 58), "collisionFootprint": &"boundary_only"}, {"profileId": &"ashfall_cinder_gate_dead_tree", "drawPosition": Vector2i(1056, 58), "collisionFootprint": &"boundary_only"}, {"profileId": &"ashfall_cinder_gate_barricade", "drawPosition": Vector2i(480, 72), "collisionFootprint": &"cinder_gate_barricade_6x3"}, {"profileId": &"ashfall_cinder_gate_air_beacon", "drawPosition": Vector2i(620, 409), "collisionFootprint": &"air_quality_beacon"}, {"profileId": &"ashfall_cinder_gate_filter_cache", "drawPosition": Vector2i(176, 169), "collisionFootprint": &"filter_cache"}], "populationContracts": [{"cohortId": &"ashfall_survivors", "phase": &"first_visit", "cell": Vector2i(6, 6)}, {"cohortId": &"ashfall_restored_residents", "phase": &"restored", "cell": Vector2i(20, 6)}], "populationAnchors": {&"P1": Vector2i(6, 6), &"P2": Vector2i(13, 6), &"P3": Vector2i(20, 6)}, "featureContracts": [{"id": &"air_quality_beacon", "anchor": &"Icenter", "cell": Vector2i(13, 9), "runtimeState": &"implemented"}, {"id": &"air_filter_cache", "anchor": &"Tnw", "cell": Vector2i(4, 4), "runtimeState": &"implemented"}]},
		"navigation": {"id": &"af01-cinder-gate-navigation-v1", "kind": &"authored", "collisionMaskId": &"af01-cinder-gate-boundary-collision-v1", "collisionState": &"native_perimeter_and_landmark_shapes_authored", "dimensions": dimensions, "walkableRects": walkable_rects, "walkableCells": walkable, "blockedCells": _blocked_cells(dimensions, walkable), "arrivalSafeCells": {&"Nw": Vector2i(8, 3), &"E1": Vector2i(22, 6), &"Sw": Vector2i(8, 14)}, "arrivalFollowerCells": {&"Nw": [Vector2i(7, 3), Vector2i(9, 3), Vector2i(8, 4)], &"E1": [Vector2i(22, 5), Vector2i(22, 7), Vector2i(21, 6)], &"Sw": [Vector2i(9, 14), Vector2i(7, 14), Vector2i(8, 13)]}},
		"gameplay": {"critical": true, "optional": false, "connective": false, "encounterId": &"ashfall_cinder_gate_arrival_raid", "restoredFlag": &"af-01_restored"},
	}


static func _walkable_cells(dimensions: Vector2i, blueprint_ports: Dictionary, enabled_ports: Dictionary) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(1, dimensions.y - 1):
		for x in range(1, dimensions.x - 1): result.append(Vector2i(x, y))
	for raw_port_id in enabled_ports:
		var port_id := StringName(raw_port_id)
		var port_cell: Vector2i = blueprint_ports.get(port_id, Vector2i.ZERO)
		var inward: Vector2i = PORT_INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO)
		var perpendicular := Vector2i(-inward.y, inward.x)
		for cell in [port_cell - perpendicular, port_cell, port_cell + perpendicular]:
			if cell not in result: result.append(cell)
	return result


static func _blocked_cells(dimensions: Vector2i, walkable: Array[Vector2i]) -> Array[Vector2i]:
	var open := {}
	for cell in walkable: open[cell] = true
	var result: Array[Vector2i] = []
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var cell := Vector2i(x, y)
			if not open.has(cell): result.append(cell)
	return result
