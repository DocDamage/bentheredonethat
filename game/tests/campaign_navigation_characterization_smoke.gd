extends Node

## Characterizes the field-navigation relationship that must survive the
## room-platform migration: visible floor stays traversable, visible scenery
## stays solid, state-gated ports change their navigation overlay, facility
## footprints preserve their doors/returns, and every manifest arrival leaves
## room for the follower train.

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const NAVIGATION := preload("res://ben_rpg/world/campaign_navigation_builder.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const FACILITY_NAVIGATION := preload("res://ben_rpg/world/campaign_facility_navigation.gd")

const TOWN_ORIGIN := Vector2i(36, 0)
const FACILITIES: Array[String] = [
	"Cafe", "Library", "Clinic", "Armory", "Haunted Mansion", "Observatory",
	"Trailhead Lodge", "Afterlight Club", "Cold Storage", "Tea House", "Belfry",
]
const FACILITY_PLOTS: Array[Rect2i] = [
	Rect2i(7, 5, 5, 4), Rect2i(18, 5, 5, 4), Rect2i(7, 13, 5, 4),
	Rect2i(16, 12, 9, 5), Rect2i(25, 13, 7, 4), Rect2i(25, 5, 5, 4),
	Rect2i(1, 13, 5, 4), Rect2i(1, 4, 5, 5), Rect2i(16, 20, 5, 5),
	Rect2i(25, 20, 5, 5), Rect2i(7, 20, 5, 5),
]

# These are deliberately named for the visible field art they characterize;
# each must remain a walkable floor or approach cell in the live Gameboard.
const VISIBLE_FLOOR_CELLS := [
	Vector2i(10, 9), Vector2i(50, 7), Vector2i(158, 37), Vector2i(203, 47),
	Vector2i(229, 47), Vector2i(230, 48),
]
const BLOCKED_SCENERY_CELLS := [
	Vector2i(3, 3), Vector2i(16, 9), Vector2i(48, 3), Vector2i(37, 1),
	Vector2i(64, 2), Vector2i(38, 19), Vector2i(156, 47), Vector2i(158, 36),
	Vector2i(201, 46), Vector2i(205, 46), Vector2i(204, 46), Vector2i(228, 36),
	Vector2i(231, 36), Vector2i(230, 47), Vector2i(237, 46),
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	assert(REGISTRY.validate().is_empty())
	assert(NAVIGATION.validate().is_empty())
	if not _seed_all_facilities():
		return
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	if not _assert_visible_floor_and_scenery():
		return
	var facility_cells := _assert_facility_footprints()
	if facility_cells < 1:
		return
	var gated_ports := _assert_dynamic_gate_overlays()
	if gated_ports < 1:
		return
	var follower_arrivals := _assert_follower_safe_arrivals()
	if follower_arrivals < 1:
		return
	main.queue_free()
	await get_tree().process_frame
	CampaignState.reset_new_game()
	print("CAMPAIGN_NAVIGATION_CHARACTERIZATION_SMOKE_OK floor=%d scenery=%d facility_footprints=11 gate_overlays=%d follower_safe_arrivals=%d" % [VISIBLE_FLOOR_CELLS.size(), BLOCKED_SCENERY_CELLS.size(), gated_ports, follower_arrivals])
	get_tree().quit(0)


func _seed_all_facilities() -> bool:
	CampaignState.reset_new_game()
	for plot_index in range(FACILITIES.size()):
		if not CampaignState.build_facility(plot_index, FACILITIES[plot_index]):
			_fail("Could not construct %s at lot %d" % [FACILITIES[plot_index], plot_index + 1])
			return false
	return true


func _assert_visible_floor_and_scenery() -> bool:
	for cell in VISIBLE_FLOOR_CELLS:
		if not Gameboard.pathfinder.has_cell(cell):
			_fail("Visible floor or approach became blocked at %s" % cell)
			return false
	for cell in BLOCKED_SCENERY_CELLS:
		if Gameboard.pathfinder.has_cell(cell):
			_fail("Visible solid scenery remained walkable at %s" % cell)
			return false
	return true


func _assert_facility_footprints() -> int:
	for plot_index in range(FACILITY_PLOTS.size()):
		var plot := FACILITY_PLOTS[plot_index]
		var door := FACILITY_NAVIGATION.door_cell(TOWN_ORIGIN, plot)
		var returned := FACILITY_NAVIGATION.return_cell(TOWN_ORIGIN, plot)
		var blocked := FACILITY_NAVIGATION.blocked_cells(TOWN_ORIGIN, plot)
		for cell in blocked:
			if Gameboard.pathfinder.has_cell(cell):
				_fail("Facility %d left solid footprint cell open at %s" % [plot_index + 1, cell])
				return 0
		if not Gameboard.pathfinder.has_cell(door) or not Gameboard.pathfinder.has_cell(returned):
			_fail("Facility %d blocked its door or town-side return" % (plot_index + 1))
			return 0
	return FACILITY_PLOTS.size()


func _assert_dynamic_gate_overlays() -> int:
	var fresh_flags := {}
	var unlocked_flags := _all_gate_flags()
	var gated_ports := 0
	for room_id in REGISTRY.room_ids():
		var definition := REGISTRY.room(room_id)
		var gates: Dictionary = definition.get("portGates", {})
		if gates.is_empty():
			continue
		var port_cells: Dictionary = definition.get("portCells", {})
		var fresh_navigation := NAVIGATION.navigation_record(room_id, REGISTRY.enabled_port_ids(room_id, fresh_flags))
		var unlocked_navigation := NAVIGATION.navigation_record(room_id, REGISTRY.enabled_port_ids(room_id, unlocked_flags))
		var fresh_walkable: Dictionary = fresh_navigation.get("walkable", {})
		var unlocked_walkable: Dictionary = unlocked_navigation.get("walkable", {})
		for raw_port_id in gates:
			var port_id := StringName(raw_port_id)
			var gate_cell: Vector2i = port_cells.get(port_id, Vector2i.ZERO)
			if gate_cell == Vector2i.ZERO:
				_fail("%s.%s gate has no navigation cell" % [room_id, port_id])
				return 0
			if fresh_walkable.has(gate_cell) or not unlocked_walkable.has(gate_cell):
				_fail("%s.%s did not change its blocked gate overlay with story state" % [room_id, port_id])
				return 0
			gated_ports += 1
	return gated_ports


func _all_gate_flags() -> Dictionary:
	var flags := {}
	for room_id in REGISTRY.room_ids():
		for flag in (REGISTRY.room(room_id).get("portGates", {}) as Dictionary).values():
			flags[StringName(flag)] = true
	return flags


func _assert_follower_safe_arrivals() -> int:
	var flags := _all_gate_flags()
	var arrivals := 0
	for room_id in REGISTRY.room_ids():
		for port in REGISTRY.ports(room_id):
			var port_id := StringName(port.get("id", &""))
			var route := ROUTER.resolve(room_id, port_id)
			if route.is_empty():
				continue
			var destination_room_id := StringName(route.get("destinationRoom", &""))
			if not REGISTRY.has_room(destination_room_id):
				continue
			var arrival := route.get("arrivalCell", Vector2i.ZERO) as Vector2i
			var navigation := NAVIGATION.navigation_record(destination_room_id, REGISTRY.enabled_port_ids(destination_room_id, flags))
			var walkable: Dictionary = navigation.get("walkable", {})
			if not walkable.has(arrival) or NAVIGATION._legal_follower_cells(arrival, walkable) < 3:
				_fail("%s.%s has no follower-safe arrival in %s" % [room_id, port_id, destination_room_id])
				return 0
			arrivals += 1
	return arrivals


func _fail(message: String) -> void:
	printerr("CAMPAIGN_NAVIGATION_CHARACTERIZATION_SMOKE_FAILED: " + message)
	CampaignState.reset_new_game()
	get_tree().quit(1)
