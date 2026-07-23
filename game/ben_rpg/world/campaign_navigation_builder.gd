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
	var record := navigation_record(&"TEST-01")
	if record.is_empty() or StringName(record.get("navigationId", &"")) == &"" or StringName(record.get("collisionMaskId", &"")) == &"":
		errors.append("Manifest test room needs navigation and collision records.")
	var walkable: Dictionary = record.get("walkable", {})
	for arrival in record.get("safeArrivals", []):
		if not walkable.has(arrival):
			errors.append("Manifest test room safe arrival is not walkable.")
	return PackedStringArray(errors)
