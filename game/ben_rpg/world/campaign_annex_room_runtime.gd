class_name CampaignAnnexRoomRuntime
extends Node2D

signal active_room_changed(room_id: StringName)

const REGISTRY := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const NP_CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const NP_POPULATION := preload("res://ben_rpg/world/campaign_new_philadelphia_population_catalog.gd")
const FACILITIES := preload("res://ben_rpg/world/campaign_facility_catalog.gd")
const CORE_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const PORT_TRANSITION := preload("res://ben_rpg/world/campaign_manifest_port_transition.tscn")

var _streamer: Node
var _navigation: GameboardLayer
var _core_runtime: Node
var _active_room_id: StringName = &""


func configure(streamer: Node, navigation: GameboardLayer, core_runtime: Node = null) -> void:
	_streamer = streamer
	_navigation = navigation
	_core_runtime = core_runtime
	if not CampaignState.state_changed.is_connected(_on_campaign_state_changed):
		CampaignState.state_changed.connect(_on_campaign_state_changed)


func set_core_runtime(core_runtime: Node) -> void: _core_runtime = core_runtime
func active_room_id() -> StringName: return _active_room_id
func room_at_cell(cell: Vector2i) -> StringName: return REGISTRY.room_at_world_cell(cell, _active_room_id)


func activate(room_id: StringName) -> bool:
	if CORE_REGISTRY.is_authored_room(room_id):
		if _core_runtime: _core_runtime.call_deferred(&"activate", room_id)
		return _core_runtime != null
	if not _navigation or not REGISTRY.is_runtime_admitted(room_id): return false
	if room_id == _active_room_id:
		return true
	if _core_runtime and StringName(_core_runtime.call(&"active_room_id")) != &"":
		_core_runtime.call(&"deactivate")
	var previous := REGISTRY.room(_active_room_id)
	_apply_cells(previous, {})
	_active_room_id = room_id
	var definition := REGISTRY.room(room_id)
	if room_id.begins_with("NP-"):
		definition["populationContract"] = NP_POPULATION.contract(room_id)
		var record: Dictionary = definition.get("record", {}).duplicate(true)
		record["populationContract"] = definition["populationContract"]
		definition["record"] = record
	var walkable := {}
	for cell in (definition.get("navigation", {}) as Dictionary).get("walkableCells", []): walkable[cell] = true
	_apply_cells(definition, walkable)
	if _streamer: _streamer.call(&"activate_annex_room", room_id, definition)
	_install_port_transitions(room_id)
	CampaignState.set_last_manifest_room(room_id)
	active_room_changed.emit(room_id)
	return true


func deactivate() -> void:
	if _active_room_id == &"": return
	_apply_cells(REGISTRY.room(_active_room_id), {})
	_active_room_id = &""
	for child in get_children(): child.queue_free()


func _on_campaign_state_changed() -> void:
	if _active_room_id != &"":
		_install_port_transitions(_active_room_id)


func _apply_cells(definition: Dictionary, walkable: Dictionary) -> void:
	if definition.is_empty(): return
	var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
	var cleared: Array[Vector2i] = []
	var blocked: Array[Vector2i] = []
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var local := Vector2i(x, y)
			var world_cell := origin + local
			var is_open := walkable.has(local)
			_navigation.set_cell(world_cell, 0, Vector2i(2, 2) if is_open else Vector2i(1, 4), 0)
			(cleared if is_open else blocked).append(world_cell)
	_navigation.cells_changed.emit(cleared, blocked)


func _install_port_transitions(room_id: StringName) -> void:
	for child in get_children():
		child.queue_free()
	var definition := REGISTRY.room(room_id)
	var origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	var port_cells: Dictionary = definition.get("portCells", {})
	for port_id in REGISTRY.enabled_port_ids(room_id):
		var route := REGISTRY.route(room_id, port_id)
		if route.is_empty(): continue
		_add_transition("AnnexPort_%s_%s" % [room_id, port_id], origin + (port_cells.get(port_id, Vector2i.ZERO) as Vector2i), route)
	if room_id.begins_with("NP-"):
		_install_lot_transitions(room_id, origin)


func _install_lot_transitions(room_id: StringName, origin: Vector2i) -> void:
	for lot_id in (NP_CATALOG.room(room_id).get("lotIds", []) as Array):
		var facility_room_id := StringName(CampaignState.new_philadelphia_lot_placements.get(lot_id, &""))
		if facility_room_id == &"" or not REGISTRY.is_runtime_admitted(facility_room_id): continue
		var lot := NP_CATALOG.lot(StringName(lot_id))
		var arrival := REGISTRY.safe_arrival_cell(facility_room_id, &"Sw")
		_add_transition("FacilityLot_%s_%s" % [lot_id, facility_room_id], origin + (lot.get("doorCell", Vector2i.ZERO) as Vector2i), {"destinationRoom": facility_room_id, "arrivalCell": arrival})


func _add_transition(node_name: String, source_cell: Vector2i, route: Dictionary) -> void:
	var destination_room_id := StringName(route.get("destinationRoom", &""))
	var destination := REGISTRY.room(destination_room_id) if REGISTRY.has_room(destination_room_id) else CORE_REGISTRY.room(destination_room_id)
	if destination.is_empty(): return
	var transition := PORT_TRANSITION.instantiate() as AreaTransition
	if not transition: return
	transition.name = node_name
	transition.position = Gameboard.cell_to_pixel(source_cell)
	transition.arrival_coordinates = Gameboard.cell_to_pixel((destination.get("worldOrigin", Vector2i.ZERO) as Vector2i) + (route.get("arrivalCell", Vector2i.ZERO) as Vector2i))
	transition.set("room_runtime", self)
	transition.set("destination_room_id", destination_room_id)
	add_child(transition)
