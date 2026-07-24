class_name CampaignAddressRoomRecords
extends RefCounted

## Section 23.14 room records begin with AF-01. Its scene is deliberately
## non-runtime until the address gateway, encounter, population, and visual
## acceptance gates are all complete. Native perimeter collision is now owned
## by the scene from this same navigation record.

const ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

static var RECORDS := {
	&"AF-01": {
		"id": &"AF-01",
		"implementationState": &"scene_collision_authored_runtime_gated",
		"scenePath": "res://ben_rpg/world/rooms/ashfall_cinder_gate.tscn",
		"layout": {
			"id": &"af01-cinder-gate-layout-v1",
			"dimensions": Vector2i(26, 18),
			"terrainRuns": [{"profileId": &"ashfall_cinder_gate_ground", "tileId": &"burnt_ash_ground", "origin": Vector2i.ZERO, "size": Vector2i(26, 18)}],
			"propPlacements": [
				{"profileId": &"ashfall_cinder_gate_dead_tree", "drawPosition": Vector2i(0, 58), "collisionFootprint": &"boundary_only"},
				{"profileId": &"ashfall_cinder_gate_dead_tree", "drawPosition": Vector2i(1056, 58), "collisionFootprint": &"boundary_only"},
			],
			"interactionCell": Vector2i(13, 9),
			"treasureCell": Vector2i(4, 4),
			"populationAnchors": {&"P1": Vector2i(6, 6), &"P2": Vector2i(13, 6), &"P3": Vector2i(20, 6)},
			"foregroundCells": [Vector2i(5, 3), Vector2i(21, 3)],
			"captureState": &"first_visit_captured_stabilized_blocked",
			"firstVisitCapture": "res://validation/af01-cinder-gate-scene-first-visit.png",
			"stabilizedCaptureBlocker": "The non-runtime arrival encounter actors/backdrop/balance, population state, and address gateway remain incomplete.",
		},
		"navigation": {
			"id": &"af01-cinder-gate-navigation-v1",
			"kind": &"authored",
			"collisionMaskId": &"af01-cinder-gate-boundary-collision-v1",
			"collisionState": &"native_perimeter_shapes_authored",
			"usefulCellRange": Vector2i(384, 384),
			"walkableRects": [{&"origin": Vector2i(1, 1), &"size": Vector2i(24, 16)}],
			"blockedCells": _perimeter_cells(Vector2i(26, 18)),
			"arrivalSafeCells": {&"Nw": Vector2i(8, 2), &"E1": Vector2i(23, 6), &"Sw": Vector2i(8, 15)},
			"arrivalFollowerCells": {&"Nw": [Vector2i(7, 2), Vector2i(9, 2), Vector2i(8, 3)], &"E1": [Vector2i(22, 6), Vector2i(23, 5), Vector2i(23, 7)], &"Sw": [Vector2i(7, 15), Vector2i(9, 15), Vector2i(8, 14)]},
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
		var expected_dimensions: Vector2i = (ROOM_REGISTRY.BLUEPRINTS.get(blueprint, {}) as Dictionary).get("dimensions", Vector2i.ZERO)
		if layout.get("dimensions", Vector2i.ZERO) != expected_dimensions:
			errors.append("%s layout dimensions must match its locked blueprint." % room_id)
		if StringName(record_definition.get("implementationState", &"")) != &"scene_collision_authored_runtime_gated" or not ResourceLoader.exists(String(record_definition.get("scenePath", ""))):
			errors.append("%s needs its recorded collision-authored scene while remaining runtime-gated." % room_id)
		if StringName(navigation.get("kind", &"")) != &"authored" or (navigation.get("walkableRects", []) as Array).is_empty():
			errors.append("%s requires an authored navigation record." % room_id)
		if StringName(navigation.get("collisionState", &"")) != &"native_perimeter_shapes_authored":
			errors.append("%s requires a native perimeter collision ownership record." % room_id)
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
		if (layout.get("terrainRuns", []) as Array).size() != 1 or (layout.get("propPlacements", []) as Array).size() != 2:
			errors.append("%s must record its exact terrain run and two boundary dead-tree placements." % room_id)
		if StringName(layout.get("captureState", &"")) != &"first_visit_captured_stabilized_blocked" or not FileAccess.file_exists(String(layout.get("firstVisitCapture", ""))) or String(layout.get("stabilizedCaptureBlocker", "")).is_empty():
			errors.append("%s must retain its first-visit capture and explicit stabilized-state blocker." % room_id)
		for placement in layout.get("propPlacements", []):
			if StringName(placement.get("profileId", &"")) != &"ashfall_cinder_gate_dead_tree" or StringName(placement.get("collisionFootprint", &"")) != &"boundary_only":
				errors.append("%s prop placement must use the admitted boundary dead-tree profile." % room_id)
		for port_id in (catalog_room.get("ports", {}) as Dictionary).keys():
			var safe_cell: Vector2i = (navigation.get("arrivalSafeCells", {}) as Dictionary).get(port_id, Vector2i.ZERO)
			if not walkable.has(safe_cell):
				errors.append("%s.%s arrival-safe cell must be walkable." % [room_id, port_id])
			var followers: Array = (navigation.get("arrivalFollowerCells", {}) as Dictionary).get(port_id, [])
			if followers.size() < 3 or followers.any(func(cell): return not walkable.has(cell)):
				errors.append("%s.%s requires three walkable follower cells." % [room_id, port_id])
		for anchor_cell in (layout.get("populationAnchors", {}) as Dictionary).values():
			if not walkable.has(anchor_cell):
				errors.append("%s population anchor must be walkable." % room_id)
		if not walkable.has(layout.get("interactionCell", Vector2i.ZERO)) or not walkable.has(layout.get("treasureCell", Vector2i.ZERO)):
			errors.append("%s interaction and treasure cells must be walkable." % room_id)
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
