class_name CampaignAnnexRoomRegistry
extends RefCounted

## Runtime registry for Phase 3 hub/facility rooms and admitted address rooms.
## It remains separate from the locked 102-room core-universe count while
## exposing the same room/route contract to the shared streamer.

const NP_CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const NP_RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
const NP_POPULATION := preload("res://ben_rpg/world/campaign_new_philadelphia_population_catalog.gd")
const FACILITIES := preload("res://ben_rpg/world/campaign_facility_catalog.gd")
const ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ADDRESS_RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const FIELD_SCALE := preload("res://ben_rpg/world/campaign_field_scale.gd")
const STAGING_ORIGIN := Vector2i(650, 0)
const INWARD_DIRECTIONS := {&"Nw": Vector2i.DOWN, &"Ne": Vector2i.DOWN, &"E1": Vector2i.LEFT, &"E2": Vector2i.LEFT, &"Se": Vector2i.UP, &"Sw": Vector2i.UP, &"W2": Vector2i.RIGHT, &"W1": Vector2i.RIGHT}

static var DEFINITIONS := _build_definitions()


static func room(room_id: StringName) -> Dictionary:
	return (DEFINITIONS.get(room_id, {}) as Dictionary).duplicate(true)


static func room_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for room_id in NP_CATALOG.ROOM_ORDER: result.append(room_id)
	for room_id in FACILITIES.ROOM_ORDER: result.append(room_id)
	for room_id in ADDRESS_CATALOG.room_ids(): result.append(room_id)
	return result


static func has_room(room_id: StringName) -> bool: return DEFINITIONS.has(room_id)
static func is_runtime_admitted(room_id: StringName) -> bool: return bool((DEFINITIONS.get(room_id, {}) as Dictionary).get("runtimeEnabled", false))


static func room_at_world_cell(cell: Vector2i, active_room_id: StringName = &"") -> StringName:
	if active_room_id != &"":
		var active := room(active_room_id)
		if Rect2i(active.get("worldOrigin", Vector2i.ZERO), active.get("dimensions", Vector2i.ZERO)).has_point(cell):
			return active_room_id
	return &""


static func route(room_id: StringName, port_id: StringName) -> Dictionary:
	var source := room(room_id)
	var destination_id: StringName = (source.get("ports", {}) as Dictionary).get(port_id, &"")
	if destination_id == &"LOT":
		return _dynamic_lot_route(room_id)
	var destination := room(destination_id)
	if destination.is_empty() and ROOM_REGISTRY.is_authored_room(destination_id):
		destination = ROOM_REGISTRY.room(destination_id)
	if destination.is_empty(): return {}
	var arrival_port := reciprocal_port(destination_id, room_id)
	if arrival_port == &"": return {}
	return {"destinationRoom": destination_id, "arrivalPort": arrival_port, "arrivalCell": safe_arrival_cell(destination_id, arrival_port), "facing": -INWARD_DIRECTIONS[arrival_port]}


static func reciprocal_port(room_id: StringName, source_id: StringName) -> StringName:
	if has_room(room_id):
		for port_id in (room(room_id).get("ports", {}) as Dictionary):
			if StringName(room(room_id)["ports"][port_id]) == source_id: return StringName(port_id)
		return &""
	if ROOM_REGISTRY.has_room(room_id):
		for binding in ROOM_REGISTRY.ports(room_id):
			if StringName(binding.get("destination", &"")) == source_id: return StringName(binding.get("id", &""))
	return &""


static func safe_arrival_cell(room_id: StringName, port_id: StringName) -> Vector2i:
	var definition := room(room_id) if has_room(room_id) else ROOM_REGISTRY.room(room_id)
	var port_cell: Vector2i = (definition.get("portCells", {}) as Dictionary).get(port_id, Vector2i.ZERO)
	return port_cell + (INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO) as Vector2i) * 2


static func enabled_port_ids(room_id: StringName, story_flags: Dictionary = CampaignState.story_flags) -> Array[StringName]:
	var definition := room(room_id)
	var result: Array[StringName] = []
	for port_id in (definition.get("ports", {}) as Dictionary):
		var required_flag := StringName((definition.get("portGates", {}) as Dictionary).get(port_id, &""))
		if required_flag == &"" or bool(story_flags.get(required_flag, false)):
			result.append(StringName(port_id))
	return result


static func lot_route_for_facility(facility_room_id: StringName) -> Dictionary:
	return _dynamic_lot_route(facility_room_id)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if DEFINITIONS.size() != 90:
		errors.append("Annex registry must contain 15 hub rooms, 11 facilities, and all 64 address rooms.")
	errors.append_array(NP_POPULATION.validate())
	for room_id in NP_CATALOG.ROOM_ORDER + FACILITIES.ROOM_ORDER:
		var definition := room(room_id)
		if definition.is_empty() or String(definition.get("scenePath", "")).is_empty() or not bool(definition.get("runtimeEnabled", false)):
			errors.append("%s must be admitted to the production annex runtime." % room_id)
		if definition.get("cameraBounds", Rect2i()) != FIELD_SCALE.camera_bounds_for_cells(definition.get("dimensions", Vector2i.ZERO)):
			errors.append("%s has invalid runtime camera bounds." % room_id)
	for room_id in NP_CATALOG.ROOM_ORDER:
		for port_id in (room(room_id).get("ports", {}) as Dictionary):
			var target := StringName(room(room_id)["ports"][port_id])
			if target.begins_with("NP-") and route(room_id, StringName(port_id)).is_empty():
				errors.append("Annex route %s.%s lacks a reciprocal safe arrival." % [room_id, port_id])
	for facility_id in FACILITIES.ROOM_ORDER:
		var definition := room(facility_id)
		var portal_target := StringName(definition.get("portalTarget", &""))
		if portal_target != &"" and route(facility_id, &"Ne").is_empty():
			errors.append("%s cannot reach its core-universe entry room." % facility_id)
	for room_id in ADDRESS_CATALOG.room_ids():
		var definition := room(room_id)
		if definition.is_empty() or not bool(definition.get("runtimeEnabled", false)) or String(definition.get("scenePath", "")).is_empty():
			errors.append("%s must be admitted to the Phase 5 runtime." % room_id)
		for port_id in (definition.get("ports", {}) as Dictionary):
			if route(room_id, StringName(port_id)).is_empty(): errors.append("Address route %s.%s lacks a reciprocal safe arrival." % [room_id, port_id])
	var af_route := route(&"NP-15", &"E2")
	if StringName(af_route.get("destinationRoom", &"")) != &"AF-01":
		errors.append("NP-15 must retain its gated reciprocal AF-01 route.")
	var np15 := room(&"NP-15")
	if StringName((np15.get("ports", {}) as Dictionary).get(&"Se", &"")) != &"WF-01" or StringName((np15.get("portGates", {}) as Dictionary).get(&"Se", &"")) != &"warfront_ledger_received":
		errors.append("NP-15 must retain its gated WF-01 production route contract.")
	return PackedStringArray(errors)


static func _build_definitions() -> Dictionary:
	var result := {}
	for room_id in NP_CATALOG.ROOM_ORDER:
		var catalog := NP_CATALOG.room(room_id)
		var record := NP_RECORDS.record(room_id)
		var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog.get("blueprint", &""), {})
		var definition := {
			"id": room_id, "worldOrigin": STAGING_ORIGIN,
			"dimensions": (record.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO),
			"cameraBounds": FIELD_SCALE.camera_bounds_for_cells((record.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO)),
			"ports": catalog.get("ports", {}), "portCells": blueprint.get("ports", {}),
			"portGates": _np_port_gates(room_id), "scenePath": record.get("scenePath", ""),
			"record": record, "navigation": record.get("navigation", {}), "runtimeEnabled": true,
			"implementationState": &"implemented",
		}
		definition.merge(_population_contract(definition["dimensions"]), false)
		result[room_id] = definition
	for room_id in FACILITIES.ROOM_ORDER:
		var facility := FACILITIES.room(room_id)
		var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(facility.get("blueprint", &""), {})
		facility["id"] = room_id
		facility["worldOrigin"] = STAGING_ORIGIN
		facility["cameraBounds"] = FIELD_SCALE.camera_bounds_for_cells(facility.get("dimensions", Vector2i.ZERO))
		facility["portCells"] = blueprint.get("ports", {})
		facility["navigation"] = _facility_navigation(facility)
		facility.merge(_population_contract(facility["dimensions"]), false)
		facility["record"] = facility.duplicate(true)
		result[room_id] = facility
	for room_id in ADDRESS_CATALOG.room_ids():
		var address_catalog := ADDRESS_CATALOG.room(room_id)
		var address_record := ADDRESS_RECORDS.record(room_id)
		var dimensions: Vector2i = (address_record.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO)
		var address_blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(address_catalog.get("blueprint", &""), {})
		var address_definition := {"id": room_id, "worldOrigin": STAGING_ORIGIN, "dimensions": dimensions, "cameraBounds": FIELD_SCALE.camera_bounds_for_cells(dimensions), "ports": address_catalog.get("ports", {}), "portCells": address_blueprint.get("ports", {}), "scenePath": address_record.get("scenePath", ""), "record": address_record, "navigation": address_record.get("navigation", {}), "runtimeEnabled": true, "implementationState": &"implemented"}
		address_definition.merge(_population_contract(dimensions), false)
		result[room_id] = address_definition
	return result


static func _population_contract(dimensions: Vector2i) -> Dictionary:
	var anchors: Array[StringName] = [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"]
	var candidates := [
		Vector2i(floori(dimensions.x / 4.0), floori(dimensions.y / 3.0)),
		Vector2i(floori(dimensions.x / 2.0), floori(dimensions.y / 3.0)),
		Vector2i(floori(3.0 * dimensions.x / 4.0), floori(dimensions.y / 3.0)),
		Vector2i(floori(dimensions.x / 4.0), floori(2.0 * dimensions.y / 3.0)),
		Vector2i(floori(dimensions.x / 2.0), floori(2.0 * dimensions.y / 3.0)),
		Vector2i(floori(3.0 * dimensions.x / 4.0), floori(2.0 * dimensions.y / 3.0)),
	]
	var cells := {}
	for index in range(anchors.size()):
		cells[anchors[index]] = candidates[index]
	return {"populationAnchors": anchors, "populationAnchorCells": cells}


static func _facility_navigation(definition: Dictionary) -> Dictionary:
	var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
	var walkable: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var cell := Vector2i(x, y)
			if x > 0 and y > 0 and x < dimensions.x - 1 and y < dimensions.y - 1: walkable.append(cell)
			else: blocked.append(cell)
	var safe := {}
	for port_id in (definition.get("ports", {}) as Dictionary):
		safe[port_id] = safe_arrival_cell_for_definition(definition, StringName(port_id))
	return {"id": StringName("%s-navigation-v1" % String(definition.get("facilityName", "facility")).to_snake_case()), "dimensions": dimensions, "walkableCells": walkable, "blockedCells": blocked, "arrivalSafeCells": safe}


static func safe_arrival_cell_for_definition(definition: Dictionary, port_id: StringName) -> Vector2i:
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(definition.get("blueprint", &""), {})
	return (blueprint.get("ports", {}) as Dictionary).get(port_id, Vector2i.ZERO) + (INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO) as Vector2i) * 2


static func _dynamic_lot_route(facility_room_id: StringName) -> Dictionary:
	for raw_lot_id in CampaignState.new_philadelphia_lot_placements:
		if StringName(CampaignState.new_philadelphia_lot_placements[raw_lot_id]) != facility_room_id:
			continue
		var lot_id := StringName(raw_lot_id)
		var lot := NP_CATALOG.lot(lot_id)
		var district_id := StringName(lot.get("district", &""))
		return {"destinationRoom": district_id, "arrivalPort": lot_id, "arrivalCell": (lot.get("doorCell", Vector2i.ZERO) as Vector2i) + Vector2i.DOWN, "facing": Vector2i.DOWN, "lotId": lot_id}
	return {}


static func _np_port_gates(room_id: StringName) -> Dictionary:
	match room_id:
		&"NP-03": return {&"E1": &"town_foundations_complete", &"E2": &"liminal_main_quest_unlocked"}
		&"NP-09": return {&"E2": &"pelagic_chart_received"}
		&"NP-12": return {&"Nw": &"steamforge_salvage_telemetry", &"Ne": &"frontier_rail_deed"}
		&"NP-15": return {&"E2": &"ashfall_reclamation_lead", &"Se": &"warfront_ledger_received"}
		_: return {}
