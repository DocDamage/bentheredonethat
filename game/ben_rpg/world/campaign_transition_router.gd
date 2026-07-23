class_name CampaignTransitionRouter
extends RefCounted

## Resolves manifest ports into destination room ids and two-cell-inward safe
## arrivals. It is data-only so room scenes never hard-code global coordinates.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

const INWARD_DIRECTIONS := {
	&"Nw": Vector2i.DOWN, &"Ne": Vector2i.DOWN, &"E1": Vector2i.LEFT, &"E2": Vector2i.LEFT,
	&"Se": Vector2i.UP, &"Sw": Vector2i.UP, &"W2": Vector2i.RIGHT, &"W1": Vector2i.RIGHT,
}


static func resolve(room_id: StringName, port_id: StringName) -> Dictionary:
	var binding := ROOM_REGISTRY.port(room_id, port_id)
	if binding.is_empty():
		return {}
	var destination_room := StringName(binding.get("destination", &""))
	var arrival_port := StringName(binding.get("arrivalPort", &""))
	if arrival_port == &"":
		arrival_port = reciprocal_port(destination_room, room_id)
	if not ROOM_REGISTRY.has_room(destination_room) or not INWARD_DIRECTIONS.has(arrival_port):
		return {}
	return {
		"destinationRoom": destination_room,
		"arrivalPort": arrival_port,
		"arrivalCell": safe_arrival_cell(destination_room, arrival_port),
		"facing": -INWARD_DIRECTIONS[arrival_port],
	}


static func reciprocal_port(room_id: StringName, source_room_id: StringName) -> StringName:
	if not ROOM_REGISTRY.has_room(room_id):
		return &""
	for binding in ROOM_REGISTRY.ports(room_id):
		if StringName(binding.get("destination", &"")) == source_room_id:
			return StringName(binding.get("id", &""))
	return &""


static func safe_arrival_cell(room_id: StringName, port_id: StringName) -> Vector2i:
	var room_definition := ROOM_REGISTRY.room(room_id)
	var port_cells: Dictionary = room_definition.get("portCells", {})
	var port_cell: Vector2i = port_cells.get(port_id, Vector2i.ZERO)
	return port_cell + (INWARD_DIRECTIONS.get(port_id, Vector2i.ZERO) as Vector2i) * 2


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for room_id in ROOM_REGISTRY.room_ids():
		for binding in ROOM_REGISTRY.ports(room_id):
			var port_id := StringName(binding.get("id", &""))
			var destination_room := StringName(binding.get("destination", &""))
			if destination_room in [&"FI-05", &"FI-06"]:
				continue
			var mansion_route := resolve(room_id, port_id)
			if mansion_route.is_empty():
				errors.append("Mansion route %s.%s cannot resolve a reciprocal arrival." % [room_id, port_id])
	for source_port in [&"Nw", &"Ne"]:
		var route := resolve(&"TEST-01", source_port)
		if route.is_empty() or StringName(route.get("destinationRoom", &"")) != &"TEST-01":
			errors.append("Manifest test room port %s does not resolve." % source_port)
			continue
		var arrival_port := StringName(route.get("arrivalPort", &""))
		var reciprocal := ROOM_REGISTRY.port(&"TEST-01", arrival_port)
		if StringName(reciprocal.get("arrivalPort", &"")) != source_port:
			errors.append("Manifest test room ports are not reciprocal.")
	var hm02_arrival := safe_arrival_cell(&"HM-02", &"Nw")
	if hm02_arrival != Vector2i(8, 3):
		errors.append("Transition router must derive Mansion arrivals from the L2 manifest port cells.")
	var hm04_route := resolve(&"HM-02", &"E1")
	if StringName(hm04_route.get("destinationRoom", &"")) != &"HM-04" or StringName(hm04_route.get("arrivalPort", &"")) != &"Nw":
		errors.append("Transition router must infer HM-02 to HM-04 reciprocal ports.")
	return PackedStringArray(errors)
