class_name CampaignAnnexRoomRegistry
extends RefCounted

## Shared staging registry for non-core authored rooms. It prevents the
## required-address and New Philadelphia slices from polluting the locked
## 102-room CampaignRoomRegistry while giving their future streamer one
## reciprocal source of truth.

const NP_CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const NP_RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
const ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ADDRESS_RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const INWARD_DIRECTIONS := {&"Nw": Vector2i.DOWN, &"Ne": Vector2i.DOWN, &"E1": Vector2i.LEFT, &"E2": Vector2i.LEFT, &"Se": Vector2i.UP, &"Sw": Vector2i.UP, &"W2": Vector2i.RIGHT, &"W1": Vector2i.RIGHT}

static var DEFINITIONS := {&"NP-15": _new_philadelphia_definition(), &"AF-01": _ashfall_definition()}

static func room(room_id: StringName) -> Dictionary: return (DEFINITIONS.get(room_id, {}) as Dictionary).duplicate(true)
static func has_room(room_id: StringName) -> bool: return DEFINITIONS.has(room_id)
static func is_runtime_admitted(room_id: StringName) -> bool: return bool((DEFINITIONS.get(room_id, {}) as Dictionary).get("runtimeEnabled", false))

static func route(room_id: StringName, port_id: StringName) -> Dictionary:
	var source := room(room_id)
	var destination_id: StringName = (source.get("ports", {}) as Dictionary).get(port_id, &"")
	var destination := room(destination_id)
	if destination.is_empty(): return {}
	var arrival_port := _reciprocal_port(destination_id, room_id)
	if arrival_port == &"": return {}
	var safe_cells: Dictionary = (destination.get("navigation", {}) as Dictionary).get("arrivalSafeCells", {})
	return {"destinationRoom": destination_id, "arrivalPort": arrival_port, "arrivalCell": safe_cells.get(arrival_port, Vector2i.ZERO), "facing": -INWARD_DIRECTIONS[arrival_port]}

static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if DEFINITIONS.size() != 2: errors.append("Annex gateway must contain exactly NP-15 and AF-01.")
	for room_id in [&"NP-15", &"AF-01"]:
		var definition := room(room_id)
		if definition.is_empty() or String(definition.get("scenePath", "")).is_empty() or bool(definition.get("runtimeEnabled", true)):
			errors.append("%s must retain its gated authored annex definition." % room_id)
	for binding in [[&"NP-15", &"E2", &"AF-01"], [&"AF-01", &"Nw", &"NP-15"]]:
		var resolved := route(binding[0], binding[1])
		if StringName(resolved.get("destinationRoom", &"")) != binding[2] or resolved.get("arrivalCell", Vector2i.ZERO) == Vector2i.ZERO:
			errors.append("Annex route %s.%s must resolve its reciprocal safe arrival." % [binding[0], binding[1]])
	return PackedStringArray(errors)

static func _new_philadelphia_definition() -> Dictionary:
	var catalog := NP_CATALOG.room(&"NP-15")
	var record := NP_RECORDS.record(&"NP-15")
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog.get("blueprint", &""), {})
	return {"id": &"NP-15", "worldOrigin": Vector2i(360, 0), "dimensions": (record.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO), "ports": catalog.get("ports", {}), "portCells": blueprint.get("ports", {}), "scenePath": record.get("scenePath", ""), "record": record, "navigation": record.get("navigation", {}), "runtimeEnabled": false}

static func _ashfall_definition() -> Dictionary:
	var catalog := ADDRESS_CATALOG.room(&"AF-01")
	var record := ADDRESS_RECORDS.record(&"AF-01")
	var navigation: Dictionary = record.get("navigation", {}).duplicate(true)
	var walkable_cells: Array[Vector2i] = []
	for rectangle in navigation.get("walkableRects", []):
		var origin: Vector2i = rectangle.get("origin", Vector2i.ZERO)
		var size: Vector2i = rectangle.get("size", Vector2i.ZERO)
		for y in range(origin.y, origin.y + size.y):
			for x in range(origin.x, origin.x + size.x):
				walkable_cells.append(Vector2i(x, y))
	navigation["walkableCells"] = walkable_cells
	var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(catalog.get("blueprint", &""), {})
	return {"id": &"AF-01", "worldOrigin": Vector2i(400, 0), "dimensions": (record.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO), "ports": catalog.get("ports", {}), "portCells": blueprint.get("ports", {}), "scenePath": record.get("scenePath", ""), "record": record, "navigation": navigation, "runtimeEnabled": false}

static func _reciprocal_port(room_id: StringName, source_id: StringName) -> StringName:
	for port_id in (room(room_id).get("ports", {}) as Dictionary):
		if StringName(room(room_id)["ports"][port_id]) == source_id: return StringName(port_id)
	return &""
