class_name CampaignNewPhiladelphiaCatalog
extends RefCounted

## Locked Section 23.3 hub and facility-lot contracts. This catalog deliberately
## supplies the production Phase 3 district streamer and movable lot runtime.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROOM_ORDER := [&"NP-01", &"NP-02", &"NP-03", &"NP-04", &"NP-05", &"NP-06", &"NP-07", &"NP-08", &"NP-09", &"NP-10", &"NP-11", &"NP-12", &"NP-13", &"NP-14", &"NP-15"]
const EXTERNAL_TARGETS := [&"AF-01", &"FT-01", &"LM-01", &"PL-01", &"SF-01", &"WF-01"]

static var ROOM_DEFINITIONS := {
	&"NP-01": _room(&"Franklin Laboratory Main Floor", &"H1", {&"Ne": &"NP-02", &"Se": &"NP-04"}, &"none", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"]),
	&"NP-02": _room(&"Invention Annex", &"I3", {&"Nw": &"NP-01", &"Ne": &"NP-03"}, &"Tne", &"Icenter", [&"P1", &"P2", &"P3", &"P4"]),
	&"NP-03": _room(&"Power and Records Basement", &"M4", {&"Nw": &"NP-02", &"E1": &"NP-05", &"E2": &"LM-01"}, &"Tsw", &"Icenter", [&"P1", &"P2"]),
	&"NP-04": _room(&"Founders Square", &"H2", {&"Nw": &"NP-01", &"E1": &"NP-06", &"E2": &"NP-07", &"W2": &"NP-05"}, &"none", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"]),
	&"NP-05": _room(&"Old-Town Market", &"L2", {&"E1": &"NP-04", &"E2": &"NP-13", &"Se": &"NP-08", &"W1": &"NP-03"}, &"Tsw", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"], [&"LOT-01", &"LOT-02"]),
	&"NP-06": _room(&"Civic Workshop Row", &"L3", {&"W1": &"NP-04", &"E1": &"NP-10", &"Se": &"NP-09"}, &"Tse", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5"], [&"LOT-03", &"LOT-04"]),
	&"NP-07": _room(&"Anchor Promenade", &"H1", {&"W1": &"NP-04", &"E1": &"NP-12", &"Se": &"NP-11", &"Sw": &"NP-15"}, &"none", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"], [&"LOT-05", &"LOT-06"]),
	&"NP-08": _room(&"Farm and Spring Terraces", &"L3", {&"Nw": &"NP-05", &"E1": &"NP-09", &"Se": &"NP-14"}, &"Tne", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"], [&"LOT-07"]),
	&"NP-09": _room(&"Riverside and Harbor Walk", &"L2", {&"Nw": &"NP-06", &"W1": &"NP-08", &"Se": &"NP-14", &"E2": &"PL-01"}, &"Tne", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5"]),
	&"NP-10": _room(&"Clinic Gardens", &"L1", {&"W1": &"NP-06", &"E2": &"NP-11", &"Sw": &"NP-13"}, &"Tnw", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5"], [&"LOT-08"]),
	&"NP-11": _room(&"South Commons", &"L3", {&"Nw": &"NP-07", &"W1": &"NP-10", &"E1": &"NP-12"}, &"none", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"], [&"LOT-09", &"LOT-10"]),
	&"NP-12": _room(&"Transit and Service Yard", &"L3", {&"W1": &"NP-07", &"W2": &"NP-11", &"Se": &"NP-14", &"Sw": &"NP-15", &"Nw": &"SF-01", &"Ne": &"FT-01"}, &"Tse", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5"], [&"LOT-11"]),
	&"NP-13": _room(&"Residential and Baker Lane", &"M3", {&"Ne": &"NP-05", &"E1": &"NP-10"}, &"Tsw", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"]),
	&"NP-14": _room(&"Recreation Park", &"L1", {&"Nw": &"NP-08", &"Ne": &"NP-09", &"W1": &"NP-12"}, &"Tne", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"]),
	&"NP-15": _room(&"Embassy Green", &"H1", {&"Ne": &"NP-07", &"E1": &"NP-12", &"E2": &"AF-01", &"Se": &"WF-01"}, &"none", &"Icenter", [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"]),
}

static var LOT_DEFINITIONS := {
	&"LOT-01": _lot(&"NP-05", Rect2i(3, 3, 9, 6), Vector2i(7, 9)),
	&"LOT-02": _lot(&"NP-05", Rect2i(14, 3, 9, 6), Vector2i(18, 9)),
	&"LOT-03": _lot(&"NP-06", Rect2i(3, 3, 9, 6), Vector2i(7, 9)),
	&"LOT-04": _lot(&"NP-06", Rect2i(16, 3, 9, 6), Vector2i(20, 9)),
	&"LOT-05": _lot(&"NP-07", Rect2i(3, 3, 9, 6), Vector2i(7, 9)),
	&"LOT-06": _lot(&"NP-07", Rect2i(18, 3, 9, 6), Vector2i(22, 9)),
	&"LOT-07": _lot(&"NP-08", Rect2i(9, 3, 9, 6), Vector2i(13, 9)),
	&"LOT-08": _lot(&"NP-10", Rect2i(7, 3, 9, 6), Vector2i(11, 9)),
	&"LOT-09": _lot(&"NP-11", Rect2i(3, 3, 9, 6), Vector2i(7, 9)),
	&"LOT-10": _lot(&"NP-11", Rect2i(16, 3, 9, 6), Vector2i(20, 9)),
	&"LOT-11": _lot(&"NP-12", Rect2i(9, 3, 9, 6), Vector2i(13, 9)),
}


static func room(room_id: StringName) -> Dictionary:
	return (ROOM_DEFINITIONS.get(room_id, {}) as Dictionary).duplicate(true)


static func lot(lot_id: StringName) -> Dictionary:
	return (LOT_DEFINITIONS.get(lot_id, {}) as Dictionary).duplicate(true)


static func resolved_layout(room_id: StringName) -> Dictionary:
	var definition: Dictionary = ROOM_DEFINITIONS.get(room_id, {})
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(definition.get("blueprint", &""), {})
	var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
	return {
		"dimensions": dimensions,
		"cameraBounds": Rect2i(Vector2i.ZERO, dimensions * 48),
		"populationAnchors": _population_anchors(dimensions),
		"treasureCell": _treasure_anchor(dimensions, StringName(definition.get("treasureAnchor", &"none"))),
		"interactionCell": _interaction_anchor(dimensions, StringName(definition.get("interactionAnchor", &""))),
	}


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if ROOM_DEFINITIONS.size() != 15 or ROOM_ORDER.size() != 15:
		errors.append("New Philadelphia must retain its locked 15-room budget.")
	if LOT_DEFINITIONS.size() != 11:
		errors.append("New Philadelphia must retain its locked 11-lot budget.")
	var known_rooms := {}
	for room_id in ROOM_ORDER:
		var definition: Dictionary = ROOM_DEFINITIONS.get(room_id, {})
		if definition.is_empty() or known_rooms.has(room_id):
			errors.append("New Philadelphia room order contains an invalid duplicate or missing %s." % room_id)
			continue
		known_rooms[room_id] = true
		var blueprint_id: StringName = definition.get("blueprint", &"")
		var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(blueprint_id, {})
		if blueprint.is_empty() or not bool(definition.get("runtimeEnabled", false)):
			errors.append("%s must use a known blueprint and be runtime-enabled." % room_id)
			continue
		var dimensions: Vector2i = blueprint.get("dimensions", Vector2i.ZERO)
		var layout := resolved_layout(room_id)
		if layout.get("cameraBounds", Rect2i()) != Rect2i(Vector2i.ZERO, dimensions * 48) or (layout.get("populationAnchors", {}) as Dictionary).size() != 6:
			errors.append("%s must resolve its Section 23.2 camera and population anchors." % room_id)
		if StringName(definition.get("interactionAnchor", &"")) == &"" or layout.get("interactionCell", Vector2i(-1, -1)) == Vector2i(-1, -1):
			errors.append("%s must declare a valid interaction anchor." % room_id)
		for port_id in (definition.get("ports", {}) as Dictionary):
			var target: StringName = definition["ports"][port_id]
			if not (blueprint.get("ports", {}) as Dictionary).has(port_id):
				errors.append("%s uses unavailable %s port %s." % [room_id, blueprint_id, port_id])
			elif not ROOM_DEFINITIONS.has(target) and target not in EXTERNAL_TARGETS:
				errors.append("%s has an unknown port target %s." % [room_id, target])
		for lot_id in definition.get("lotIds", []):
			if not LOT_DEFINITIONS.has(lot_id) or StringName(LOT_DEFINITIONS[lot_id].get("district", &"")) != room_id:
				errors.append("%s does not own declared lot %s." % [room_id, lot_id])
	for room_id in ROOM_ORDER:
		for target in (ROOM_DEFINITIONS[room_id].get("ports", {}) as Dictionary).values():
			if StringName(target) in ROOM_DEFINITIONS and not _has_reciprocal_port(StringName(target), room_id):
				errors.append("%s lacks a reciprocal New Philadelphia port from %s." % [room_id, target])
	for lot_id in LOT_DEFINITIONS:
		var definition: Dictionary = LOT_DEFINITIONS[lot_id]
		var district: StringName = definition.get("district", &"")
		var footprint: Rect2i = definition.get("footprint", Rect2i())
		var door: Vector2i = definition.get("doorCell", Vector2i(-1, -1))
		var dimensions: Vector2i = resolved_layout(district).get("dimensions", Vector2i.ZERO)
		if district not in ROOM_DEFINITIONS or footprint.size != Vector2i(9, 6) or not Rect2i(Vector2i.ONE, dimensions - Vector2i(2, 2)).encloses(footprint) or door.y != footprint.end.y or door.x < footprint.position.x or door.x >= footprint.end.x:
			errors.append("%s must retain an in-bounds 9x6 facade and exterior door." % lot_id)
	return PackedStringArray(errors)


static func _room(title: String, blueprint: StringName, ports: Dictionary, treasure_anchor: StringName, interaction_anchor: StringName, population_anchor_ids: Array, lot_ids: Array = []) -> Dictionary:
	return {"title": title, "blueprint": blueprint, "ports": ports, "treasureAnchor": treasure_anchor, "interactionAnchor": interaction_anchor, "populationAnchorIds": population_anchor_ids, "lotIds": lot_ids, "runtimeEnabled": true, "implementationState": &"implemented"}


static func _lot(district: StringName, footprint: Rect2i, door_cell: Vector2i) -> Dictionary:
	return {"district": district, "footprint": footprint, "doorCell": door_cell, "runtimeEnabled": true}


static func _has_reciprocal_port(room_id: StringName, target_room_id: StringName) -> bool:
	return target_room_id in (ROOM_DEFINITIONS.get(room_id, {}) as Dictionary).get("ports", {}).values()


static func _population_anchors(dimensions: Vector2i) -> Dictionary:
	return {&"P1": Vector2i(dimensions.x / 4, dimensions.y / 3), &"P2": Vector2i(dimensions.x / 2, dimensions.y / 3), &"P3": Vector2i(dimensions.x * 3 / 4, dimensions.y / 3), &"P4": Vector2i(dimensions.x / 4, dimensions.y * 2 / 3), &"P5": Vector2i(dimensions.x / 2, dimensions.y * 2 / 3), &"P6": Vector2i(dimensions.x * 3 / 4, dimensions.y * 2 / 3)}


static func _treasure_anchor(dimensions: Vector2i, anchor: StringName) -> Vector2i:
	match anchor:
		&"Tnw": return Vector2i(3, 3)
		&"Tne": return Vector2i(dimensions.x - 4, 3)
		&"Tsw": return Vector2i(3, dimensions.y - 4)
		&"Tse": return Vector2i(dimensions.x - 4, dimensions.y - 4)
		_: return Vector2i(-1, -1)


static func _interaction_anchor(dimensions: Vector2i, anchor: StringName) -> Vector2i:
	match anchor:
		&"Icenter": return Vector2i(dimensions.x / 2, dimensions.y / 2)
		&"Inorth": return Vector2i(dimensions.x / 2, 3)
		&"Ieast": return Vector2i(dimensions.x - 4, dimensions.y / 2)
		&"Isouth": return Vector2i(dimensions.x / 2, dimensions.y - 4)
		&"Iwest": return Vector2i(3, dimensions.y / 2)
		_: return Vector2i(-1, -1)
