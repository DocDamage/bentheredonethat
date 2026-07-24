class_name CampaignAddressRoomRecords
extends RefCounted

## Section 23.14 room records begin with AF-01. These data are deliberately
## non-runtime until the address gateway, final visual profile, battle record,
## and scene audit are all complete.

const ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

static var RECORDS := {
	&"AF-01": {
		"id": &"AF-01",
		"implementationState": &"records_authored_runtime_gated",
		"scenePath": &"",
		"layout": {
			"id": &"af01-cinder-gate-layout-v1",
			"dimensions": Vector2i(26, 18),
			"ground": &"ashfall_cinder_ground_pending_profile",
			"propDerivatives": [&"ashfall_cinder_gate_dead_tree"],
			"interactionCell": Vector2i(13, 9),
			"treasureCell": Vector2i(4, 4),
			"populationAnchors": {&"P1": Vector2i(6, 6), &"P2": Vector2i(13, 6), &"P3": Vector2i(20, 6)},
			"foregroundCells": [Vector2i(5, 3), Vector2i(21, 3)],
		},
		"navigation": {
			"id": &"af01-cinder-gate-navigation-v1",
			"kind": &"authored",
			"usefulCellRange": Vector2i(384, 384),
			"walkableRects": [{&"origin": Vector2i(1, 1), &"size": Vector2i(24, 16)}],
			"arrivalSafeCells": {&"Nw": Vector2i(8, 2), &"E1": Vector2i(23, 6), &"Sw": Vector2i(8, 15)},
			"blockedDescription": "The perimeter, ash barriers, and foreground dead trees are collision-solid outside the authored interior route.",
		},
	},
}


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
		if StringName(record_definition.get("implementationState", &"")) != &"records_authored_runtime_gated" or String(record_definition.get("scenePath", "")) != "":
			errors.append("%s must not claim a runtime scene before its admission gates close." % room_id)
		if StringName(navigation.get("kind", &"")) != &"authored" or (navigation.get("walkableRects", []) as Array).is_empty():
			errors.append("%s requires an authored navigation record." % room_id)
		var walkable: Dictionary = {}
		for rectangle in navigation.get("walkableRects", []):
			var origin: Vector2i = rectangle.get("origin", Vector2i.ZERO)
			var size: Vector2i = rectangle.get("size", Vector2i.ZERO)
			for y in range(origin.y, origin.y + size.y):
				for x in range(origin.x, origin.x + size.x):
					walkable[Vector2i(x, y)] = true
		if walkable.size() != int((navigation.get("usefulCellRange", Vector2i.ZERO) as Vector2i).x):
			errors.append("%s useful-cell count must match its audited navigation record." % room_id)
		for port_id in (catalog_room.get("ports", {}) as Dictionary).keys():
			var safe_cell: Vector2i = (navigation.get("arrivalSafeCells", {}) as Dictionary).get(port_id, Vector2i.ZERO)
			if not walkable.has(safe_cell):
				errors.append("%s.%s arrival-safe cell must be walkable." % [room_id, port_id])
		for anchor_cell in (layout.get("populationAnchors", {}) as Dictionary).values():
			if not walkable.has(anchor_cell):
				errors.append("%s population anchor must be walkable." % room_id)
		if not walkable.has(layout.get("interactionCell", Vector2i.ZERO)) or not walkable.has(layout.get("treasureCell", Vector2i.ZERO)):
			errors.append("%s interaction and treasure cells must be walkable." % room_id)
	return PackedStringArray(errors)
