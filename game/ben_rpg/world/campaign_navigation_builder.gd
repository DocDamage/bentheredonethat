class_name CampaignNavigationBuilder
extends RefCounted

## Builds the audited, manifest-level navigation contract. Live TileMap setup
## will consume this record as rooms migrate; this builder intentionally owns no
## universe geometry or legacy map state.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")


static func navigation_record(room_id: StringName, enabled_port_ids: Array[StringName] = ROOM_REGISTRY.enabled_port_ids(room_id)) -> Dictionary:
	var definition := ROOM_REGISTRY.room(room_id)
	var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
	if dimensions == Vector2i.ZERO:
		return {}
	var walkable: Dictionary = {}
	for y in range(1, dimensions.y - 1):
		for x in range(1, dimensions.x - 1):
			walkable[Vector2i(x, y)] = true
	var enabled_ports: Dictionary = {}
	for port_id in enabled_port_ids:
		enabled_ports[StringName(port_id)] = true
	var port_cells: Dictionary = definition.get("portCells", {})
	for port_id in port_cells:
		if not enabled_ports.has(port_id):
			walkable.erase(port_cells[port_id])
	for port_id in enabled_ports:
		var port_cell: Vector2i = port_cells.get(port_id, Vector2i.ZERO)
		if port_cell != Vector2i.ZERO:
			walkable[port_cell] = true
	var safe_arrivals: Array[Vector2i] = []
	for port in ROOM_REGISTRY.ports(room_id):
		var port_id := StringName(port.get("id", &""))
		var arrival := TRANSITION_ROUTER.safe_arrival_cell(room_id, port_id)
		if walkable.has(arrival):
			safe_arrivals.append(arrival)
	return {
		"navigationId": definition.get("navigationId", &""),
		"collisionMaskId": definition.get("collisionMaskId", &""),
		"dimensions": dimensions,
		"walkable": walkable,
		"safeArrivals": safe_arrivals,
	}


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for room_id in ROOM_REGISTRY.room_ids():
		_validate_room(room_id, errors)
	return PackedStringArray(errors)


static func _validate_room(room_id: StringName, errors: Array[String]) -> void:
	var definition := ROOM_REGISTRY.room(room_id)
	var record := navigation_record(room_id)
	if record.is_empty() or StringName(record.get("navigationId", &"")) == &"" or StringName(record.get("collisionMaskId", &"")) == &"":
		errors.append("%s needs navigation and collision records." % room_id)
		return
	var walkable: Dictionary = record.get("walkable", {})
	if walkable.is_empty():
		errors.append("%s has no walkable navigation cells." % room_id)
		return
	var required_cells: Array[Vector2i] = []
	for anchor_cell in (definition.get("populationAnchorCells", {}) as Dictionary).values():
		var cell := anchor_cell as Vector2i
		if not walkable.has(cell):
			errors.append("%s population anchor %s is not walkable." % [room_id, cell])
		else:
			required_cells.append(cell)
	for port in ROOM_REGISTRY.ports(room_id):
		var port_id := StringName(port.get("id", &""))
		var arrival := TRANSITION_ROUTER.safe_arrival_cell(room_id, port_id)
		if not walkable.has(arrival):
			errors.append("%s.%s safe arrival is not walkable." % [room_id, port_id])
			continue
		if _legal_follower_cells(arrival, walkable) < 3:
			errors.append("%s.%s safe arrival has fewer than three legal follower cells." % [room_id, port_id])
		required_cells.append(arrival)
	if required_cells.is_empty():
		errors.append("%s has no required navigation anchors." % room_id)
		return
	var connected := _connected_component(required_cells[0], walkable)
	for cell in required_cells:
		if not connected.has(cell):
			errors.append("%s required navigation anchors are not connected." % room_id)
			break


static func _legal_follower_cells(cell: Vector2i, walkable: Dictionary) -> int:
	var legal := 0
	for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
		if walkable.has(cell + direction):
			legal += 1
	return legal


static func _connected_component(start: Vector2i, walkable: Dictionary) -> Dictionary:
	var connected: Dictionary = {}
	var pending: Array[Vector2i] = [start]
	while not pending.is_empty():
		var cell: Vector2i = pending.pop_back()
		if connected.has(cell) or not walkable.has(cell):
			continue
		connected[cell] = true
		for direction in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var neighbor: Vector2i = cell + direction
			if walkable.has(neighbor) and not connected.has(neighbor):
				pending.append(neighbor)
	return connected
