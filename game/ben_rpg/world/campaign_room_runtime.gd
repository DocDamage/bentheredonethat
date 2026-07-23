class_name CampaignRoomRuntime
extends Node2D

## Owns the active manifest room's navigation and reciprocal port triggers.
## Staging coordinates are shared by streamed rooms, so only this node changes
## collision and ports when the active scene changes. It is a Node2D so its
## dynamically-instanced port triggers inherit the field canvas transform.

signal active_room_changed(room_id: StringName)

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const PORT_TRANSITION := preload("res://ben_rpg/world/campaign_manifest_port_transition.tscn")

var _streamer: Node
var _navigation: GameboardLayer
var _active_room_id: StringName = &""


func configure(streamer: Node, navigation: GameboardLayer) -> void:
	_streamer = streamer
	_navigation = navigation
	if not CampaignState.state_changed.is_connected(_on_campaign_state_changed):
		CampaignState.state_changed.connect(_on_campaign_state_changed)


func active_room_id() -> StringName:
	return _active_room_id


func room_at_cell(cell: Vector2i) -> StringName:
	if _active_room_id == &"":
		return &""
	var definition := ROOM_REGISTRY.room(_active_room_id)
	var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
	return _active_room_id if Rect2i(origin, dimensions).has_point(cell) else &""


func activate(room_id: StringName) -> void:
	if not ROOM_REGISTRY.is_authored_room(room_id) or not _navigation:
		return
	if room_id == _active_room_id:
		return
	var previous := _active_room_id
	_unregister_room_save_points(previous)
	_active_room_id = room_id
	_apply_navigation(previous, room_id)
	if _streamer:
		_streamer.call(&"activate_room", room_id)
	_install_port_transitions(room_id)
	active_room_changed.emit(room_id)


func refresh_active_room() -> void:
	if _active_room_id == &"":
		return
	_apply_navigation(_active_room_id, _active_room_id)
	_install_port_transitions(_active_room_id)


func _on_campaign_state_changed() -> void:
	refresh_active_room()


func _apply_navigation(previous_room_id: StringName, room_id: StringName) -> void:
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	if previous_room_id != &"":
		_set_room_cells(previous_room_id, {}, cleared, blocked)
	var enabled_ports := _streamable_port_ids(room_id)
	var record := NAVIGATION_BUILDER.navigation_record(room_id, enabled_ports)
	var walkable: Dictionary = record.get("walkable", {})
	_set_room_cells(room_id, walkable, cleared, blocked)
	_navigation.cells_changed.emit(cleared, blocked)


func _set_room_cells(room_id: StringName, walkable: Dictionary, cleared: Array[Vector2i], blocked: Array[Vector2i]) -> void:
	var definition := ROOM_REGISTRY.room(room_id)
	var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var local_cell := Vector2i(x, y)
			var world_cell := origin + local_cell
			var is_open := walkable.has(local_cell)
			_navigation.set_cell(world_cell, 0, Vector2i(2, 2) if is_open else Vector2i(1, 4), 0)
			(cleared if is_open else blocked).append(world_cell)


func _unregister_room_save_points(room_id: StringName) -> void:
	if room_id == &"":
		return
	var definition := ROOM_REGISTRY.room(room_id)
	var save_point: Dictionary = definition.get("savePoint", {})
	var save_point_id := StringName(save_point.get("id", &""))
	if save_point_id != &"":
		CampaignState.unregister_runtime_save_point(save_point_id)
	for property_name in [&"asterionInteractions", &"primevalInteractions", &"heliosInteractions", &"frostholdInteractions", &"moonpetalInteractions", &"empyrealInteractions"]:
		for interaction_definition in definition.get(property_name, []):
			var interaction_save_point_id := StringName(interaction_definition.get("savePointId", &""))
			if interaction_save_point_id != &"":
				CampaignState.unregister_runtime_save_point(interaction_save_point_id)


func _install_port_transitions(room_id: StringName) -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	var definition := ROOM_REGISTRY.room(room_id)
	var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	var enabled_ports := _streamable_port_ids(room_id)
	var port_cells: Dictionary = definition.get("portCells", {})
	for port in ROOM_REGISTRY.ports(room_id):
		var port_id := StringName(port.get("id", &""))
		var destination_room_id := StringName(port.get("destination", &""))
		if not port_id in enabled_ports or not ROOM_REGISTRY.is_authored_room(destination_room_id):
			continue
		var route := TRANSITION_ROUTER.resolve(room_id, port_id)
		if route.is_empty():
			continue
		var transition := PORT_TRANSITION.instantiate() as AreaTransition
		if not transition:
			continue
		transition.name = "ManifestPort_%s_%s" % [room_id, port_id]
		transition.position = Gameboard.cell_to_pixel(origin + (port_cells.get(port_id, Vector2i.ZERO) as Vector2i))
		var destination_definition := ROOM_REGISTRY.room(destination_room_id)
		var destination_origin: Vector2i = destination_definition.get("worldOrigin", Vector2i.ZERO)
		transition.arrival_coordinates = Gameboard.cell_to_pixel(destination_origin + (route.get("arrivalCell", Vector2i.ZERO) as Vector2i))
		transition.set("room_runtime", self)
		transition.set("destination_room_id", destination_room_id)
		add_child(transition)


func _streamable_port_ids(room_id: StringName) -> Array[StringName]:
	var result: Array[StringName] = []
	for port_id in ROOM_REGISTRY.enabled_port_ids(room_id):
		var destination_room_id := StringName(ROOM_REGISTRY.port(room_id, port_id).get("destination", &""))
		if destination_room_id in [&"FI-05", &"FI-06", &"FI-07", &"FI-08"] or ROOM_REGISTRY.is_authored_room(destination_room_id):
			result.append(port_id)
	return result
