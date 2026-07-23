extends Node

const BOOTSTRAP := preload("res://ben_rpg/world/campaign_bootstrap.gd")
const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")


func _ready() -> void:
	var previous_properties := Gameboard.properties
	var properties := GameboardProperties.new()
	properties.cell_size = Vector2i(48, 48)
	Gameboard.properties = properties
	var campaign := BOOTSTRAP.new()
	var world := Node2D.new()
	world.name = "CampaignWorld"
	campaign.add_child(world)
	var universes := [
		{"facility": &"Haunted Mansion", "prefix": "HauntedMansion", "entry": &"HM-01", "rooms": REGISTRY.MANSION_ROOM_IDS, "restricted": &"haunted_mansion"},
		{"facility": &"Observatory", "prefix": "AsterionStation", "entry": &"AS-01", "rooms": REGISTRY.ASTERION_ROOM_IDS},
		{"facility": &"Trailhead Lodge", "prefix": "PrimevalExpanse", "entry": &"PV-01", "rooms": REGISTRY.PRIMEVAL_ROOM_IDS},
		{"facility": &"Afterlight Club", "prefix": "HeliosArcology", "entry": &"HE-01", "rooms": REGISTRY.HELIOS_ROOM_IDS},
		{"facility": &"Cold Storage", "prefix": "FrostholdKingdom", "entry": &"FR-01", "rooms": REGISTRY.FROSTHOLD_ROOM_IDS},
		{"facility": &"Tea House", "prefix": "MoonpetalCourt", "entry": &"MP-01", "rooms": REGISTRY.MOONPETAL_ROOM_IDS},
		{"facility": &"Belfry", "prefix": "EmpyrealCourt", "entry": &"EM-01", "rooms": REGISTRY.EMPYREAL_ROOM_IDS},
	]
	var total_routes := 0
	for universe in universes:
		var facility_name := StringName(universe["facility"])
		var prefix := String(universe["prefix"])
		var entry_room_id := StringName(universe["entry"])
		var room_ids: Array = universe["rooms"]
		var portal := REGISTRY.facility_portal(facility_name)
		assert(portal.get("prefix", "") == prefix)
		assert(StringName(portal.get("entryRoomId", &"")) == entry_room_id)
		assert(portal.get("roomIds", []) == room_ids)
		var arguments := [world, prefix, Vector2i(4, 4), Vector2i(2, 2), entry_room_id, room_ids]
		if universe.has("restricted"):
			arguments.append(StringName(universe["restricted"]))
		campaign.callv(&"_create_manifest_facility_transitions", arguments)
		var entry := world.get_node_or_null("%sEntrance" % prefix) as AreaTransition
		var exit := world.get_node_or_null("%sExit" % prefix) as AreaTransition
		var container := world.get_node_or_null("%sManifestTransitions" % prefix) as Node2D
		assert(entry and exit and container)
		var entry_definition := REGISTRY.room(entry_room_id)
		assert(Gameboard.pixel_to_cell(entry.arrival_coordinates) == entry_definition["worldOrigin"] + ROUTER.safe_arrival_cell(entry_room_id, &"Nw"))
		assert(Gameboard.pixel_to_cell(exit.position) == entry_definition["worldOrigin"] + entry_definition["portCells"][&"Nw"])
		var expected_count := _enabled_internal_route_count(room_ids)
		assert(container.get_child_count() == expected_count)
		for transition in container.get_children():
			assert(transition is AreaTransition)
		assert(container.get_node_or_null("%s_Ne" % entry_room_id))
		total_routes += expected_count
	campaign.free()
	Gameboard.properties = previous_properties
	print("CAMPAIGN_MANIFEST_TRANSITION_INSTALLER_SMOKE_OK universes=%d routes=%d gated=current_state" % [universes.size(), total_routes])
	get_tree().quit()


func _enabled_internal_route_count(room_ids: Array) -> int:
	var lookup := {}
	for room_id in room_ids:
		lookup[room_id] = true
	var count := 0
	for room_id in room_ids:
		for port_id in REGISTRY.enabled_port_ids(room_id):
			var route := ROUTER.resolve(room_id, port_id)
			if not route.is_empty() and lookup.has(StringName(route.get("destinationRoom", &""))):
				count += 1
	return count
