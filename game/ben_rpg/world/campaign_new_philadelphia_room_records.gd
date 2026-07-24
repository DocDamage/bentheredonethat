class_name CampaignNewPhiladelphiaRoomRecords
extends RefCounted

## First scene/collision admission slice for the New Philadelphia hub. It
## intentionally keeps NP-15 runtime-gated until its cultural pavilion/table
## art, population schedules, and stream gateway have their own review.

const CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ADDRESS_RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")

static var RECORDS := {&"NP-01": _franklin_laboratory_record(), &"NP-02": _invention_annex_record(), &"NP-03": _power_records_basement_record(), &"NP-15": _embassy_green_record()}


static func record(room_id: StringName) -> Dictionary:
	return (RECORDS.get(room_id, {}) as Dictionary).duplicate(true)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for room_id in [&"NP-01", &"NP-02", &"NP-03", &"NP-15"]:
		var definition := record(room_id)
		var catalog_room := CATALOG.room(room_id)
		var layout: Dictionary = definition.get("layout", {})
		var navigation: Dictionary = definition.get("navigation", {})
		if definition.is_empty() or catalog_room.is_empty() or StringName(definition.get("implementationState", &"")) != &"scene_collision_authored_runtime_gated":
			errors.append("%s must retain a separately gated scene/collision record." % room_id)
			continue
		if not ResourceLoader.exists(String(definition.get("scenePath", ""))):
			errors.append("%s scene path is missing." % room_id)
		var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
		var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
		if layout.get("dimensions", Vector2i.ZERO) != dimensions or navigation.get("dimensions", Vector2i.ZERO) != dimensions:
			errors.append("%s dimensions must resolve from its blueprint." % room_id)
		var walkable: Dictionary = {}
		for cell in navigation.get("walkableCells", []):
			walkable[cell] = true
		var blocked: Dictionary = {}
		for cell in navigation.get("blockedCells", []):
			blocked[cell] = true
		if walkable.size() + blocked.size() != dimensions.x * dimensions.y:
			errors.append("%s must retain a complete navigation partition." % room_id)
		for port_id in (catalog_room.get("ports", {}) as Dictionary):
			var port_cell: Vector2i = (blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO)
			var safe_cell := ADDRESS_RECORDS.expected_arrival_cell(port_cell, StringName(port_id))
			if not walkable.has(safe_cell) or (navigation.get("arrivalSafeCells", {}) as Dictionary).get(port_id, Vector2i.ZERO) != safe_cell:
				errors.append("%s.%s must keep its two-cell-inward safe arrival." % [room_id, port_id])
	var np01 := record(&"NP-01")
	if (np01.get("layout", {}) as Dictionary).get("terrainProfileIds", []) != [&"laboratory_floor_tile", &"laboratory_wall_tile"]:
		errors.append("NP-01 must use only its approved laboratory floor and wall profiles.")
	if (np01.get("layout", {}) as Dictionary).get("featureContracts", []) != [{"id": &"franklin_workbench", "anchor": &"Icenter", "cell": Vector2i(15, 10), "runtimeState": &"visual_and_interaction_gated"}]:
		errors.append("NP-01 must retain its gated Franklin workbench marker.")
	if (np01.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 499:
		errors.append("NP-01 must reserve its five laboratory-equipment collision cells.")
	var np02 := record(&"NP-02")
	if (np02.get("layout", {}) as Dictionary).get("terrainProfileIds", []) != [&"laboratory_floor_tile", &"laboratory_wall_tile"]:
		errors.append("NP-02 must use only its approved laboratory floor and wall profiles.")
	if (np02.get("layout", {}) as Dictionary).get("featureContracts", []) != [{"id": &"invention_bench", "anchor": &"Icenter", "cell": Vector2i(12, 8), "runtimeState": &"visual_and_interaction_gated"}]:
		errors.append("NP-02 must retain its gated invention-bench marker.")
	if (np02.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 303:
		errors.append("NP-02 must reserve its five annex-equipment collision cells.")
	var np03 := record(&"NP-03")
	if (np03.get("layout", {}) as Dictionary).get("terrainProfileIds", []) != [&"laboratory_floor_tile", &"laboratory_wall_tile"]:
		errors.append("NP-03 must use only its approved laboratory floor and wall profiles.")
	if (np03.get("layout", {}) as Dictionary).get("featureContracts", []) != [{"id": &"fault_line_regulator", "anchor": &"Icenter", "cell": Vector2i(9, 8), "runtimeState": &"visual_and_interaction_gated"}]:
		errors.append("NP-03 must retain its gated fault-line regulator marker.")
	if (np03.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 219:
		errors.append("NP-03 must reserve its five basement-equipment collision cells.")
	var np15 := record(&"NP-15")
	if (np15.get("layout", {}) as Dictionary).get("terrainProfileIds", []) != [&"sandbox_modern_grass", &"sandbox_modern_cobble"]:
		errors.append("NP-15 must use only its approved initial town terrain profiles.")
	if (np15.get("layout", {}) as Dictionary).get("featureContracts", []) != [{"id": &"charter_table", "anchor": &"Icenter", "cell": Vector2i(15, 10), "runtimeState": &"visual_and_interaction_gated"}]:
		errors.append("NP-15 must retain its gated Charter table marker.")
	if (np15.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 504:
		errors.append("NP-15 must retain its complete H1 navigation partition.")
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
		"layout": {"dimensions": dimensions, "terrainProfileIds": [&"sandbox_modern_grass", &"sandbox_modern_cobble"], "boundaryProfileIds": [&"town_ranch_tree_small", &"town_ranch_tree_tall"], "featureContracts": [{"id": &"charter_table", "anchor": &"Icenter", "cell": Vector2i(15, 10), "runtimeState": &"visual_and_interaction_gated"}]},
		"navigation": {"id": &"np15-embassy-green-navigation-v1", "collisionMaskId": &"np15-embassy-green-perimeter-v1", "dimensions": dimensions, "walkableCells": walkable, "blockedCells": blocked, "arrivalSafeCells": safe_cells},
	}


static func _franklin_laboratory_record() -> Dictionary:
	var catalog_room := CATALOG.room(&"NP-01")
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
	var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
	var equipment_cells := [Vector2i(6, 5), Vector2i(24, 5), Vector2i(6, 14), Vector2i(24, 14), Vector2i(15, 10)]
	var walkable := _walkable_cells(dimensions, blueprint.get("ports", {}), catalog_room.get("ports", {}))
	for cell in equipment_cells:
		walkable.erase(cell)
	var blocked := _blocked_cells(dimensions, walkable)
	var safe_cells := {}
	for port_id in catalog_room.get("ports", {}):
		safe_cells[port_id] = ADDRESS_RECORDS.expected_arrival_cell((blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO), StringName(port_id))
	return {
		"id": &"NP-01", "implementationState": &"scene_collision_authored_runtime_gated", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_franklin_laboratory.tscn",
		"layout": {"dimensions": dimensions, "terrainProfileIds": [&"laboratory_floor_tile", &"laboratory_wall_tile"], "propProfileIds": [&"laboratory_analysis_station", &"laboratory_east_calibrator", &"laboratory_west_storage", &"laboratory_center_storage", &"laboratory_east_fabricator"], "featureContracts": [{"id": &"franklin_workbench", "anchor": &"Icenter", "cell": Vector2i(15, 10), "runtimeState": &"visual_and_interaction_gated"}]},
		"navigation": {"id": &"np01-franklin-laboratory-navigation-v1", "collisionMaskId": &"np01-franklin-laboratory-perimeter-and-equipment-v1", "dimensions": dimensions, "walkableCells": walkable, "blockedCells": blocked, "arrivalSafeCells": safe_cells},
	}


static func _invention_annex_record() -> Dictionary:
	var catalog_room := CATALOG.room(&"NP-02")
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
	var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
	var equipment_cells := [Vector2i(4, 6), Vector2i(20, 6), Vector2i(4, 11), Vector2i(20, 11), Vector2i(12, 8)]
	var walkable := _walkable_cells(dimensions, blueprint.get("ports", {}), catalog_room.get("ports", {}))
	for cell in equipment_cells:
		walkable.erase(cell)
	var blocked := _blocked_cells(dimensions, walkable)
	var safe_cells := {}
	for port_id in catalog_room.get("ports", {}):
		safe_cells[port_id] = ADDRESS_RECORDS.expected_arrival_cell((blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO), StringName(port_id))
	return {
		"id": &"NP-02", "implementationState": &"scene_collision_authored_runtime_gated", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_invention_annex.tscn",
		"layout": {"dimensions": dimensions, "terrainProfileIds": [&"laboratory_floor_tile", &"laboratory_wall_tile"], "propProfileIds": [&"laboratory_west_terminal", &"laboratory_east_reactor", &"laboratory_east_generator", &"laboratory_center_storage", &"laboratory_east_fabricator"], "featureContracts": [{"id": &"invention_bench", "anchor": &"Icenter", "cell": Vector2i(12, 8), "runtimeState": &"visual_and_interaction_gated"}]},
		"navigation": {"id": &"np02-invention-annex-navigation-v1", "collisionMaskId": &"np02-invention-annex-perimeter-and-equipment-v1", "dimensions": dimensions, "walkableCells": walkable, "blockedCells": blocked, "arrivalSafeCells": safe_cells},
	}


static func _power_records_basement_record() -> Dictionary:
	var catalog_room := CATALOG.room(&"NP-03")
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
	var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
	var equipment_cells := [Vector2i(4, 5), Vector2i(13, 5), Vector2i(4, 11), Vector2i(14, 11), Vector2i(9, 8)]
	var walkable := _walkable_cells(dimensions, blueprint.get("ports", {}), catalog_room.get("ports", {}))
	for cell in equipment_cells:
		walkable.erase(cell)
	var blocked := _blocked_cells(dimensions, walkable)
	var safe_cells := {}
	for port_id in catalog_room.get("ports", {}):
		safe_cells[port_id] = ADDRESS_RECORDS.expected_arrival_cell((blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO), StringName(port_id))
	return {
		"id": &"NP-03", "implementationState": &"scene_collision_authored_runtime_gated", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_power_records_basement.tscn",
		"layout": {"dimensions": dimensions, "terrainProfileIds": [&"laboratory_floor_tile", &"laboratory_wall_tile"], "propProfileIds": [&"laboratory_west_storage", &"laboratory_east_generator", &"laboratory_analysis_station", &"laboratory_center_storage", &"laboratory_east_reactor"], "featureContracts": [{"id": &"fault_line_regulator", "anchor": &"Icenter", "cell": Vector2i(9, 8), "runtimeState": &"visual_and_interaction_gated"}]},
		"navigation": {"id": &"np03-power-records-navigation-v1", "collisionMaskId": &"np03-power-records-perimeter-and-equipment-v1", "dimensions": dimensions, "walkableCells": walkable, "blockedCells": blocked, "arrivalSafeCells": safe_cells},
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
