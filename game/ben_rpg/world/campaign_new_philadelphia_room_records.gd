class_name CampaignNewPhiladelphiaRoomRecords
extends RefCounted

## Production scene/collision records for the Phase 3 New Philadelphia hub.

const CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ADDRESS_RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")

static var RECORDS := {&"NP-01": _franklin_laboratory_record(), &"NP-02": _invention_annex_record(), &"NP-03": _power_records_basement_record(), &"NP-04": _founders_square_record(), &"NP-05": _old_town_market_record(), &"NP-06": _civic_workshop_row_record(), &"NP-07": _anchor_promenade_record(), &"NP-08": _farm_spring_terraces_record(), &"NP-09": _riverside_harbor_walk_record(), &"NP-10": _clinic_gardens_record(), &"NP-11": _south_commons_record(), &"NP-12": _transit_service_yard_record(), &"NP-13": _residential_baker_lane_record(), &"NP-14": _recreation_park_record(), &"NP-15": _embassy_green_record()}


static func record(room_id: StringName) -> Dictionary:
	return (RECORDS.get(room_id, {}) as Dictionary).duplicate(true)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for room_id in [&"NP-01", &"NP-02", &"NP-03", &"NP-04", &"NP-05", &"NP-06", &"NP-07", &"NP-08", &"NP-09", &"NP-10", &"NP-11", &"NP-12", &"NP-13", &"NP-14", &"NP-15"]:
		var definition := record(room_id)
		var catalog_room := CATALOG.room(room_id)
		var layout: Dictionary = definition.get("layout", {})
		var navigation: Dictionary = definition.get("navigation", {})
		if definition.is_empty() or catalog_room.is_empty() or StringName(definition.get("implementationState", &"")) != &"implemented":
			errors.append("%s must retain an implemented scene/collision record." % room_id)
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
	var np04 := record(&"NP-04")
	if (np04.get("layout", {}) as Dictionary).get("terrainProfileIds", []) != [&"sandbox_modern_grass", &"sandbox_modern_cobble"] or (np04.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 599:
		errors.append("NP-04 must retain its approved hub terrain and one-cell monument reservation.")
	var np05 := record(&"NP-05")
	if (np05.get("layout", {}) as Dictionary).get("lotIds", []) != [&"LOT-01", &"LOT-02"] or (np05.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 351:
		errors.append("NP-05 must retain both market lots and its two facade reservations.")
	var np06 := record(&"NP-06")
	if (np06.get("layout", {}) as Dictionary).get("lotIds", []) != [&"LOT-03", &"LOT-04"] or (np06.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 383:
		errors.append("NP-06 must retain both workshop lots and its repair-board circulation.")
	var np07 := record(&"NP-07")
	if (np07.get("layout", {}) as Dictionary).get("lotIds", []) != [&"LOT-05", &"LOT-06"] or (np07.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 499:
		errors.append("NP-07 must retain both promenade lots and its anchor-map reservation.")
	var np08 := record(&"NP-08")
	if (np08.get("layout", {}) as Dictionary).get("lotIds", []) != [&"LOT-07"] or (np08.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 415:
		errors.append("NP-08 must retain its farm lot and irrigation-pump reservation.")
	var np09 := record(&"NP-09")
	if not (np09.get("layout", {}) as Dictionary).get("lotIds", []).is_empty() or (np09.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 383:
		errors.append("NP-09 must retain its no-lot harbor loop and ferry-board reservation.")
	var np10 := record(&"NP-10")
	if (np10.get("layout", {}) as Dictionary).get("lotIds", []) != [&"LOT-08"] or (np10.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != 335:
		errors.append("NP-10 must retain its clinic lot, facade, and recovery-fountain circulation.")
	for expectation in [[&"NP-11", [&"LOT-09", &"LOT-10"], 415], [&"NP-12", [&"LOT-11"], 415], [&"NP-13", [], 223], [&"NP-14", [], 351]]:
		var definition := record(expectation[0])
		if (definition.get("layout", {}) as Dictionary).get("lotIds", []) != expectation[1] or (definition.get("navigation", {}) as Dictionary).get("walkableCells", []).size() != expectation[2]:
			errors.append("%s must retain its final exterior lot and circulation contract." % expectation[0])
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
		"id": &"NP-15", "implementationState": &"implemented", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_embassy_green.tscn",
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
		"id": &"NP-01", "implementationState": &"implemented", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_franklin_laboratory.tscn",
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
		"id": &"NP-02", "implementationState": &"implemented", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_invention_annex.tscn",
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
		"id": &"NP-03", "implementationState": &"implemented", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_power_records_basement.tscn",
		"layout": {"dimensions": dimensions, "terrainProfileIds": [&"laboratory_floor_tile", &"laboratory_wall_tile"], "propProfileIds": [&"laboratory_west_storage", &"laboratory_east_generator", &"laboratory_analysis_station", &"laboratory_center_storage", &"laboratory_east_reactor"], "featureContracts": [{"id": &"fault_line_regulator", "anchor": &"Icenter", "cell": Vector2i(9, 8), "runtimeState": &"visual_and_interaction_gated"}]},
		"navigation": {"id": &"np03-power-records-navigation-v1", "collisionMaskId": &"np03-power-records-perimeter-and-equipment-v1", "dimensions": dimensions, "walkableCells": walkable, "blockedCells": blocked, "arrivalSafeCells": safe_cells},
	}


static func _founders_square_record() -> Dictionary:
	var catalog_room := CATALOG.room(&"NP-04")
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
	var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
	var walkable := _walkable_cells(dimensions, blueprint.get("ports", {}), catalog_room.get("ports", {}))
	walkable.erase(Vector2i(16, 11))
	var safe_cells := {}
	for port_id in catalog_room.get("ports", {}): safe_cells[port_id] = ADDRESS_RECORDS.expected_arrival_cell((blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO), StringName(port_id))
	return {"id": &"NP-04", "implementationState": &"implemented", "scenePath": "res://ben_rpg/world/rooms/new_philadelphia_founders_square.tscn", "layout": {"dimensions": dimensions, "terrainProfileIds": [&"sandbox_modern_grass", &"sandbox_modern_cobble"], "featureContracts": [{"id": &"founding_monument", "anchor": &"Icenter", "cell": Vector2i(16, 11), "runtimeState": &"visual_and_interaction_gated"}]}, "navigation": {"id": &"np04-founders-square-navigation-v1", "collisionMaskId": &"np04-founders-square-perimeter-and-monument-v1", "dimensions": dimensions, "walkableCells": walkable, "blockedCells": _blocked_cells(dimensions, walkable), "arrivalSafeCells": safe_cells}}


static func _old_town_market_record() -> Dictionary:
	return _district_record(&"NP-05", "res://ben_rpg/world/rooms/new_philadelphia_old_town_market.tscn", [&"sandbox_modern_grass", &"sandbox_modern_cobble", &"sandbox_modern_dirt"], [&"town_cafe_facade", &"town_ranch_tree_small"], [&"LOT-01", &"LOT-02"], [], [Vector2i(5, 6), Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 6), Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7), Vector2i(8, 7), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8), Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9), Vector2i(8, 9), Vector2i(18, 6), Vector2i(19, 6), Vector2i(20, 6), Vector2i(21, 6), Vector2i(18, 7), Vector2i(19, 7), Vector2i(20, 7), Vector2i(21, 7), Vector2i(18, 8), Vector2i(19, 8), Vector2i(20, 8), Vector2i(21, 8), Vector2i(18, 9), Vector2i(19, 9), Vector2i(20, 9), Vector2i(21, 9), Vector2i(13, 9)])


static func _civic_workshop_row_record() -> Dictionary:
	return _district_record(&"NP-06", "res://ben_rpg/world/rooms/new_philadelphia_civic_workshop_row.tscn", [&"sandbox_modern_grass", &"sandbox_modern_cobble", &"sandbox_modern_dirt"], [&"town_armory_facade", &"town_ranch_tree_small"], [&"LOT-03", &"LOT-04"], [{"id": &"public_repair_board", "anchor": &"Icenter", "cell": Vector2i(14, 9), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(5, 6), Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 6), Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7), Vector2i(8, 7), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8), Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9), Vector2i(8, 9), Vector2i(20, 6), Vector2i(21, 6), Vector2i(22, 6), Vector2i(23, 6), Vector2i(20, 7), Vector2i(21, 7), Vector2i(22, 7), Vector2i(23, 7), Vector2i(20, 8), Vector2i(21, 8), Vector2i(22, 8), Vector2i(23, 8), Vector2i(20, 9), Vector2i(21, 9), Vector2i(22, 9), Vector2i(23, 9), Vector2i(14, 9)])


static func _anchor_promenade_record() -> Dictionary:
	return _district_record(&"NP-07", "res://ben_rpg/world/rooms/new_philadelphia_anchor_promenade.tscn", [&"sandbox_modern_grass", &"sandbox_modern_cobble"], [&"town_ranch_tree_small", &"town_ranch_tree_tall"], [&"LOT-05", &"LOT-06"], [{"id": &"anchor_status_map", "anchor": &"Icenter", "cell": Vector2i(15, 10), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(5, 5), Vector2i(24, 5), Vector2i(5, 15), Vector2i(24, 15), Vector2i(15, 10)])


static func _farm_spring_terraces_record() -> Dictionary:
	return _district_record(&"NP-08", "res://ben_rpg/world/rooms/new_philadelphia_farm_spring_terraces.tscn", [&"sandbox_ranch_meadow", &"sandbox_ranch_dirt", &"sandbox_ranch_farmland"], [&"sandbox_ranch_corn", &"sandbox_ranch_pumpkin", &"town_ranch_tree_small"], [&"LOT-07"], [{"id": &"irrigation_pump", "anchor": &"Icenter", "cell": Vector2i(14, 9), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(14, 9)])


static func _riverside_harbor_walk_record() -> Dictionary:
	return _district_record(&"NP-09", "res://ben_rpg/world/rooms/new_philadelphia_riverside_harbor_walk.tscn", [&"sandbox_modern_grass", &"sandbox_modern_cobble", &"sandbox_ranch_water"], [&"town_ranch_tree_small", &"town_ranch_tree_tall"], [], [{"id": &"ferry_board", "anchor": &"Icenter", "cell": Vector2i(13, 9), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(13, 9)])


static func _clinic_gardens_record() -> Dictionary:
	return _district_record(&"NP-10", "res://ben_rpg/world/rooms/new_philadelphia_clinic_gardens.tscn", [&"sandbox_modern_grass", &"sandbox_modern_cobble", &"sandbox_modern_dirt"], [&"town_clinic_facade", &"town_ranch_tree_small"], [&"LOT-08"], [{"id": &"public_recovery_fountain", "anchor": &"Icenter", "cell": Vector2i(12, 9), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(5, 6), Vector2i(6, 6), Vector2i(7, 6), Vector2i(8, 6), Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7), Vector2i(8, 7), Vector2i(5, 8), Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8), Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9), Vector2i(8, 9), Vector2i(12, 9)])


static func _south_commons_record() -> Dictionary:
	return _district_record(&"NP-11", "res://ben_rpg/world/rooms/new_philadelphia_south_commons.tscn", [&"sandbox_modern_grass", &"sandbox_modern_cobble", &"sandbox_modern_dirt"], [&"town_ranch_tree_small", &"town_ranch_tree_tall"], [&"LOT-09", &"LOT-10"], [{"id": &"events_stage", "anchor": &"Icenter", "cell": Vector2i(14, 9), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(14, 9)])


static func _transit_service_yard_record() -> Dictionary:
	return _district_record(&"NP-12", "res://ben_rpg/world/rooms/new_philadelphia_transit_service_yard.tscn", [&"sandbox_modern_dirt", &"sandbox_modern_cobble"], [&"town_armory_facade", &"town_ranch_tree_small"], [&"LOT-11"], [{"id": &"dispatch_board", "anchor": &"Icenter", "cell": Vector2i(14, 9), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(14, 9)])


static func _residential_baker_lane_record() -> Dictionary:
	return _district_record(&"NP-13", "res://ben_rpg/world/rooms/new_philadelphia_residential_baker_lane.tscn", [&"sandbox_modern_grass", &"sandbox_modern_cobble", &"sandbox_modern_dirt"], [&"town_cafe_facade", &"town_ranch_tree_small"], [], [{"id": &"neighborhood_notice", "anchor": &"Icenter", "cell": Vector2i(10, 7), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(4, 4), Vector2i(5, 4), Vector2i(6, 4), Vector2i(7, 4), Vector2i(4, 5), Vector2i(5, 5), Vector2i(6, 5), Vector2i(7, 5), Vector2i(4, 6), Vector2i(5, 6), Vector2i(6, 6), Vector2i(7, 6), Vector2i(4, 7), Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7), Vector2i(10, 7)])


static func _recreation_park_record() -> Dictionary:
	return _district_record(&"NP-14", "res://ben_rpg/world/rooms/new_philadelphia_recreation_park.tscn", [&"sandbox_ranch_meadow", &"sandbox_modern_cobble"], [&"town_ranch_tree_small", &"town_ranch_tree_tall"], [], [{"id": &"recreation_booking", "anchor": &"Icenter", "cell": Vector2i(12, 9), "runtimeState": &"visual_and_interaction_gated"}], [Vector2i(12, 9)])


static func _district_record(room_id: StringName, scene_path: String, terrain_profile_ids: Array, prop_profile_ids: Array, lot_ids: Array, feature_contracts: Array, reservations: Array[Vector2i]) -> Dictionary:
	var catalog_room := CATALOG.room(room_id)
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog_room.get("blueprint", &""), {})
	var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
	var walkable := _walkable_cells(dimensions, blueprint.get("ports", {}), catalog_room.get("ports", {}))
	for cell in reservations: walkable.erase(cell)
	var safe_cells := {}
	for port_id in catalog_room.get("ports", {}): safe_cells[port_id] = ADDRESS_RECORDS.expected_arrival_cell((blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO), StringName(port_id))
	return {"id": room_id, "implementationState": &"implemented", "scenePath": scene_path, "layout": {"dimensions": dimensions, "terrainProfileIds": terrain_profile_ids, "propProfileIds": prop_profile_ids, "lotIds": lot_ids, "featureContracts": feature_contracts}, "navigation": {"id": StringName("%s-navigation-v1" % String(room_id).to_lower()), "collisionMaskId": StringName("%s-perimeter-and-reservations-v1" % String(room_id).to_lower()), "dimensions": dimensions, "walkableCells": walkable, "blockedCells": _blocked_cells(dimensions, walkable), "arrivalSafeCells": safe_cells}}


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
