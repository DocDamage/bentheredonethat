class_name CampaignAddressRoomRecords
extends RefCounted

## Section 23.14 room records begin with AF-01. Its scene is deliberately
## non-runtime until the address gateway, encounter, population, and visual
## acceptance gates are all complete. Native perimeter collision is now owned
## by the scene from this same navigation record.

const ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

## Address ports share the locked Section 23.2 convention: an arrival is two
## cells inward, with two perpendicular follower cells and one trailing cell.
## This stays here until the address graph can enter CampaignRoomRegistry.
const PORT_INWARD_DIRECTIONS := {
	&"Nw": Vector2i.DOWN, &"Ne": Vector2i.DOWN, &"E1": Vector2i.LEFT, &"E2": Vector2i.LEFT,
	&"Se": Vector2i.UP, &"Sw": Vector2i.UP, &"W2": Vector2i.RIGHT, &"W1": Vector2i.RIGHT,
}

static var RECORDS := {
	&"AF-01": {
		"id": &"AF-01",
		"implementationState": &"scene_collision_authored_runtime_gated",
		"scenePath": "res://ben_rpg/world/rooms/ashfall_cinder_gate.tscn",
		"populationContractId": &"af01-survivor-watch-v1",
		"layout": {
			"id": &"af01-cinder-gate-layout-v1",
			"dimensions": Vector2i(26, 18),
			"terrainRuns": [{"profileId": &"ashfall_cinder_gate_ground", "tileId": &"burnt_ash_ground", "origin": Vector2i.ZERO, "size": Vector2i(26, 18)}],
			"propPlacements": [
				{"profileId": &"ashfall_cinder_gate_dead_tree", "drawPosition": Vector2i(0, 58), "collisionFootprint": &"boundary_only"},
				{"profileId": &"ashfall_cinder_gate_dead_tree", "drawPosition": Vector2i(1056, 58), "collisionFootprint": &"boundary_only"},
				{"profileId": &"ashfall_cinder_gate_barricade", "drawPosition": Vector2i(480, 72), "collisionFootprint": &"cinder_gate_barricade_6x3"},
				{"profileId": &"ashfall_cinder_gate_air_beacon", "drawPosition": Vector2i(620, 409), "collisionFootprint": &"air_quality_beacon"},
				{"profileId": &"ashfall_cinder_gate_filter_cache", "drawPosition": Vector2i(176, 169), "collisionFootprint": &"filter_cache"},
			],
			"interactionCell": Vector2i(13, 9),
			"treasureCell": Vector2i(4, 4),
			"featureContracts": [
				{"id": &"air_quality_beacon", "anchor": &"Icenter", "cell": Vector2i(13, 9), "runtimeState": &"scene_marker_runtime_gated"},
				{"id": &"air_filter_cache", "anchor": &"Tnw", "cell": Vector2i(4, 4), "runtimeState": &"scene_marker_runtime_gated"},
			],
			"populationAnchors": {&"P1": Vector2i(6, 6), &"P2": Vector2i(13, 6), &"P3": Vector2i(20, 6)},
			"foregroundCells": [Vector2i(5, 3), Vector2i(21, 3)],
			"captureState": &"first_visit_captured_stabilized_blocked",
			"firstVisitCapture": "res://validation/af01-cinder-gate-scene-first-visit.png",
			"stabilizedCaptureBlocker": "The non-runtime arrival encounter actors/backdrop/balance, population field-profile/actor admission, and address gateway remain incomplete.",
		},
		"navigation": {
			"id": &"af01-cinder-gate-navigation-v1",
			"kind": &"authored",
			"collisionMaskId": &"af01-cinder-gate-boundary-collision-v1",
			"collisionState": &"native_perimeter_and_landmark_shapes_authored",
			"usefulCellRange": Vector2i(366, 366),
			"walkableRects": [{&"origin": Vector2i(1, 1), &"size": Vector2i(24, 1)}, {&"origin": Vector2i(1, 2), &"size": Vector2i(9, 3)}, {&"origin": Vector2i(16, 2), &"size": Vector2i(9, 3)}, {&"origin": Vector2i(1, 5), &"size": Vector2i(24, 12)}],
			"blockedCells": _cinder_gate_blocked_cells(Vector2i(26, 18)),
			"arrivalSafeCells": {&"Nw": Vector2i(8, 3), &"E1": Vector2i(22, 6), &"Sw": Vector2i(8, 14)},
			"arrivalFollowerCells": {&"Nw": [Vector2i(7, 3), Vector2i(9, 3), Vector2i(8, 4)], &"E1": [Vector2i(22, 5), Vector2i(22, 7), Vector2i(21, 6)], &"Sw": [Vector2i(9, 14), Vector2i(7, 14), Vector2i(8, 13)]},
			"npcRouteCells": {&"P1": [Vector2i(6, 6), Vector2i(7, 6)], &"P2": [Vector2i(13, 6), Vector2i(14, 6)], &"P3": [Vector2i(20, 6), Vector2i(19, 6)]},
			"blockedDescription": "The perimeter, ash barriers, and foreground dead trees are collision-solid outside the authored interior route.",
		},
	},
}


static func _perimeter_cells(dimensions: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for x in range(dimensions.x):
		cells.append(Vector2i(x, 0))
		cells.append(Vector2i(x, dimensions.y - 1))
	for y in range(1, dimensions.y - 1):
		cells.append(Vector2i(0, y))
		cells.append(Vector2i(dimensions.x - 1, y))
	return cells


static func _cinder_gate_blocked_cells(dimensions: Vector2i) -> Array[Vector2i]:
	var cells := _perimeter_cells(dimensions)
	for y in range(2, 5):
		for x in range(10, 16):
			cells.append(Vector2i(x, y))
	return cells


static func expected_arrival_cell(port_cell: Vector2i, port_id: StringName) -> Vector2i:
	return port_cell + (PORT_INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO) as Vector2i) * 2


static func expected_arrival_follower_cells(arrival_cell: Vector2i, port_id: StringName) -> Array[Vector2i]:
	var inward: Vector2i = PORT_INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO)
	var perpendicular := Vector2i(-inward.y, inward.x)
	return [arrival_cell + perpendicular, arrival_cell - perpendicular, arrival_cell + inward]


static func _port_opening_cells(port_cell: Vector2i, port_id: StringName) -> Array[Vector2i]:
	var inward: Vector2i = PORT_INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO)
	var perpendicular := Vector2i(-inward.y, inward.x)
	return [port_cell - perpendicular, port_cell, port_cell + perpendicular]


static func record(room_id: StringName) -> Dictionary:
	return (RECORDS.get(room_id, {}) as Dictionary).duplicate(true)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for raw_room_id in RECORDS:
		var room_id := StringName(raw_room_id)
		var record_definition: Dictionary = RECORDS[room_id]
		var catalog_room := ADDRESS_CATALOG.room(room_id)
		var layout: Dictionary = record_definition.get("layout", {})
		var navigation: Dictionary = record_definition.get("navigation", {})
		if catalog_room.is_empty() or room_id != &"AF-01":
			errors.append("%s must bind an existing required-address room." % room_id)
			continue
		var blueprint := StringName(catalog_room.get("blueprint", &""))
		var blueprint_layout: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(blueprint, {}) as Dictionary
		var expected_dimensions: Vector2i = blueprint_layout.get("dimensions", Vector2i.ZERO)
		if layout.get("dimensions", Vector2i.ZERO) != expected_dimensions:
			errors.append("%s layout dimensions must match its locked blueprint." % room_id)
		if StringName(record_definition.get("implementationState", &"")) != &"scene_collision_authored_runtime_gated" or not ResourceLoader.exists(String(record_definition.get("scenePath", ""))):
			errors.append("%s needs its recorded collision-authored scene while remaining runtime-gated." % room_id)
		if StringName(record_definition.get("populationContractId", &"")) != &"af01-survivor-watch-v1":
			errors.append("%s needs its stable address-population contract id." % room_id)
		if StringName(navigation.get("kind", &"")) != &"authored" or (navigation.get("walkableRects", []) as Array).is_empty():
			errors.append("%s requires an authored navigation record." % room_id)
		if StringName(navigation.get("collisionState", &"")) != &"native_perimeter_and_landmark_shapes_authored":
			errors.append("%s requires native perimeter and landmark collision ownership." % room_id)
		var walkable: Dictionary = {}
		for rectangle in navigation.get("walkableRects", []):
			var origin: Vector2i = rectangle.get("origin", Vector2i.ZERO)
			var size: Vector2i = rectangle.get("size", Vector2i.ZERO)
			for y in range(origin.y, origin.y + size.y):
				for x in range(origin.x, origin.x + size.x):
					walkable[Vector2i(x, y)] = true
		if walkable.size() != int((navigation.get("usefulCellRange", Vector2i.ZERO) as Vector2i).x):
			errors.append("%s useful-cell count must match its audited navigation record." % room_id)
		var blocked: Dictionary = {}
		for cell in navigation.get("blockedCells", []):
			blocked[cell] = true
		var dimensions: Vector2i = layout.get("dimensions", Vector2i.ZERO)
		if blocked.size() + walkable.size() != dimensions.x * dimensions.y or not _walkable_component_is_connected(walkable):
			errors.append("%s requires a complete, connected walkable/blocked navigation partition." % room_id)
		for terrain_run in layout.get("terrainRuns", []):
			if StringName(terrain_run.get("profileId", &"")) != &"ashfall_cinder_gate_ground" or terrain_run.get("origin", Vector2i.ZERO) != Vector2i.ZERO or terrain_run.get("size", Vector2i.ZERO) != dimensions:
				errors.append("%s terrain record must cover the locked blueprint with the admitted ground profile." % room_id)
		if (layout.get("terrainRuns", []) as Array).size() != 1 or (layout.get("propPlacements", []) as Array).size() != 5:
			errors.append("%s must record its terrain, boundary trees, Cinder Gate barricade, beacon, and filter cache." % room_id)
		if StringName(layout.get("captureState", &"")) != &"first_visit_captured_stabilized_blocked" or not FileAccess.file_exists(String(layout.get("firstVisitCapture", ""))) or String(layout.get("stabilizedCaptureBlocker", "")).is_empty():
			errors.append("%s must retain its first-visit capture and explicit stabilized-state blocker." % room_id)
		var dead_tree_count := 0
		var barricade_count := 0
		var beacon_count := 0
		var filter_cache_count := 0
		for placement in layout.get("propPlacements", []):
			var profile_id := StringName(placement.get("profileId", &""))
			var collision_footprint := StringName(placement.get("collisionFootprint", &""))
			if profile_id == &"ashfall_cinder_gate_dead_tree" and collision_footprint == &"boundary_only":
				dead_tree_count += 1
			elif profile_id == &"ashfall_cinder_gate_barricade" and collision_footprint == &"cinder_gate_barricade_6x3":
				barricade_count += 1
			elif profile_id == &"ashfall_cinder_gate_air_beacon" and collision_footprint == &"air_quality_beacon":
				beacon_count += 1
			elif profile_id == &"ashfall_cinder_gate_filter_cache" and collision_footprint == &"filter_cache":
				filter_cache_count += 1
			else:
				errors.append("%s contains an unadmitted prop or collision footprint." % room_id)
		if dead_tree_count != 2 or barricade_count != 1 or beacon_count != 1 or filter_cache_count != 1:
			errors.append("%s must bind two boundary trees, a barricade, beacon, and filter cache." % room_id)
		var blueprint_port_cells: Dictionary = blueprint_layout.get("ports", {})
		for raw_port_id in (catalog_room.get("ports", {}) as Dictionary).keys():
			var port_id := StringName(raw_port_id)
			var port_cell: Vector2i = blueprint_port_cells.get(port_id, Vector2i.ZERO)
			if port_cell == Vector2i.ZERO or not PORT_INWARD_DIRECTIONS.has(port_id):
				errors.append("%s.%s must resolve to a locked blueprint port." % [room_id, port_id])
				continue
			for opening_cell in _port_opening_cells(port_cell, port_id):
				if not walkable.has(opening_cell):
					errors.append("%s.%s must retain a three-cell walkable port opening." % [room_id, port_id])
					break
			var safe_cell: Vector2i = (navigation.get("arrivalSafeCells", {}) as Dictionary).get(port_id, Vector2i.ZERO)
			if safe_cell != expected_arrival_cell(port_cell, port_id) or not walkable.has(safe_cell):
				errors.append("%s.%s arrival-safe cell must be the locked two-cell-inward walkable cell." % [room_id, port_id])
			var followers: Array = (navigation.get("arrivalFollowerCells", {}) as Dictionary).get(port_id, [])
			var expected_followers := expected_arrival_follower_cells(safe_cell, port_id)
			if followers != expected_followers or followers.any(func(cell): return not walkable.has(cell)):
				errors.append("%s.%s requires its exact three-cell follower formation." % [room_id, port_id])
		for anchor_cell in (layout.get("populationAnchors", {}) as Dictionary).values():
			if not walkable.has(anchor_cell):
				errors.append("%s population anchor must be walkable." % room_id)
		if not walkable.has(layout.get("interactionCell", Vector2i.ZERO)) or not walkable.has(layout.get("treasureCell", Vector2i.ZERO)):
			errors.append("%s interaction and treasure cells must be walkable." % room_id)
		var features: Array = layout.get("featureContracts", [])
		if features.size() != 2:
			errors.append("%s requires its exact beacon and filter-cache feature contracts." % room_id)
		else:
			var expected_features := {&"air_quality_beacon": {"anchor": &"Icenter", "cell": layout.get("interactionCell", Vector2i.ZERO)}, &"air_filter_cache": {"anchor": &"Tnw", "cell": layout.get("treasureCell", Vector2i.ZERO)}}
			for feature in features:
				var feature_id := StringName(feature.get("id", &""))
				var expected_feature: Dictionary = expected_features.get(feature_id, {})
				if expected_feature.is_empty() or StringName(feature.get("anchor", &"")) != StringName(expected_feature.get("anchor", &"")) or feature.get("cell", Vector2i.ZERO) != expected_feature.get("cell", Vector2i.ZERO) or StringName(feature.get("runtimeState", &"")) != &"scene_marker_runtime_gated":
					errors.append("%s feature contract %s must retain its exact gated anchor and cell." % [room_id, feature_id])
	return PackedStringArray(errors)


static func _walkable_component_is_connected(walkable: Dictionary) -> bool:
	if walkable.is_empty():
		return false
	var frontier: Array[Vector2i] = [walkable.keys().front()]
	var visited: Dictionary = {}
	while not frontier.is_empty():
		var cell: Vector2i = frontier.pop_back()
		if visited.has(cell):
			continue
		visited[cell] = true
		for neighbor in [cell + Vector2i.LEFT, cell + Vector2i.RIGHT, cell + Vector2i.UP, cell + Vector2i.DOWN]:
			if walkable.has(neighbor) and not visited.has(neighbor):
				frontier.append(neighbor)
	return visited.size() == walkable.size()
