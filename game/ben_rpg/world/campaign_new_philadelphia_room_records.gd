class_name CampaignNewPhiladelphiaRoomRecords
extends RefCounted

## First scene/collision admission slice for the New Philadelphia hub. It
## intentionally keeps NP-15 runtime-gated until its cultural pavilion/table
## art, population schedules, and stream gateway have their own review.

const CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ADDRESS_RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")

static var RECORDS := {&"NP-15": _embassy_green_record()}


static func record(room_id: StringName) -> Dictionary:
	return (RECORDS.get(room_id, {}) as Dictionary).duplicate(true)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	var definition := record(&"NP-15")
	var catalog_room := CATALOG.room(&"NP-15")
	var layout: Dictionary = definition.get("layout", {})
	var navigation: Dictionary = definition.get("navigation", {})
	if definition.is_empty() or catalog_room.is_empty() or StringName(definition.get("implementationState", &"")) != &"scene_collision_authored_runtime_gated":
		errors.append("NP-15 must retain a separately gated scene/collision record.")
		return PackedStringArray(errors)
	if not ResourceLoader.exists(String(definition.get("scenePath", ""))):
		errors.append("NP-15 scene path is missing.")
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
	var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
	if layout.get("dimensions", Vector2i.ZERO) != dimensions or navigation.get("dimensions", Vector2i.ZERO) != dimensions:
		errors.append("NP-15 dimensions must resolve from H1.")
	if layout.get("terrainProfileIds", []) != [&"town_grass_tile", &"town_road_tile"]:
		errors.append("NP-15 must use only its approved initial town terrain profiles.")
	if layout.get("featureContracts", []) != [{"id": &"charter_table", "anchor": &"Icenter", "cell": Vector2i(15, 10), "runtimeState": &"visual_and_interaction_gated"}]:
		errors.append("NP-15 must retain its gated Charter table marker.")
	var walkable: Dictionary = {}
	for cell in navigation.get("walkableCells", []):
		walkable[cell] = true
	var blocked: Dictionary = {}
	for cell in navigation.get("blockedCells", []):
		blocked[cell] = true
	if walkable.size() + blocked.size() != dimensions.x * dimensions.y or walkable.size() != 504:
		errors.append("NP-15 must retain its complete H1 navigation partition.")
	for port_id in (catalog_room.get("ports", {}) as Dictionary):
		var port_cell: Vector2i = (blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO)
		var safe_cell := ADDRESS_RECORDS.expected_arrival_cell(port_cell, StringName(port_id))
		if not walkable.has(safe_cell) or (navigation.get("arrivalSafeCells", {}) as Dictionary).get(port_id, Vector2i.ZERO) != safe_cell:
			errors.append("NP-15.%s must keep its two-cell-inward safe arrival." % port_id)
	return PackedStringArray(errors)


static func _embassy_green_record() -> Dictionary:
	var catalog_room := CATALOG.room(&"NP-15")
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
	var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
	var ports: Dictionary = catalog_room.get("ports", {})
	var walkable := _walkable_cells(dimensions, blueprint.get("ports", {}), ports)
	var blocked := _blocked_cells(dimensions, walkable)
	var safe_cells := {}
	for port_id in ports:
		safe_cells[port_id] = ADDRESS_RECORDS.expected_arrival_cell((blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO), StringName(port_id))
	return {
		"id": &"NP-15", "implementationState": &"scene_collision_authored_runtime_gated", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_embassy_green.tscn",
		"layout": {"dimensions": dimensions, "terrainProfileIds": [&"town_grass_tile", &"town_road_tile"], "boundaryProfileIds": [&"town_ranch_tree_small", &"town_ranch_tree_tall"], "featureContracts": [{"id": &"charter_table", "anchor": &"Icenter", "cell": Vector2i(15, 10), "runtimeState": &"visual_and_interaction_gated"}]},
		"navigation": {"id": &"np15-embassy-green-navigation-v1", "collisionMaskId": &"np15-embassy-green-perimeter-v1", "dimensions": dimensions, "walkableCells": walkable, "blockedCells": blocked, "arrivalSafeCells": safe_cells},
	}


static func _walkable_cells(dimensions: Vector2i, blueprint_ports: Dictionary, bound_ports: Dictionary) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for y in range(1, dimensions.y - 1):
		for x in range(1, dimensions.x - 1): cells.append(Vector2i(x, y))
	# Section 23.2 port cells are deliberately one cell inside the visual
	# perimeter, so every three-cell port opening is already part of this
	# interior. Keep the parameters to make that relationship explicit.
	assert(not blueprint_ports.is_empty() and not bound_ports.is_empty())
	return cells


static func _blocked_cells(dimensions: Vector2i, walkable_cells: Array[Vector2i]) -> Array[Vector2i]:
	var open := {}
	for cell in walkable_cells: open[cell] = true
	var blocked: Array[Vector2i] = []
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var cell := Vector2i(x, y)
			if not open.has(cell): blocked.append(cell)
	return blocked
