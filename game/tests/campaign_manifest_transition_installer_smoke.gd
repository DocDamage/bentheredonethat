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
	for universe in universes:
		var facility_name := StringName(universe["facility"])
		var prefix := String(universe["prefix"])
		var entry_room_id := StringName(universe["entry"])
		var room_ids: Array = universe["rooms"]
		var portal := REGISTRY.facility_portal(facility_name)
		assert(portal.get("prefix", "") == prefix)
		assert(StringName(portal.get("entryRoomId", &"")) == entry_room_id)
		assert(portal.get("roomIds", []) == room_ids)
		var arguments := [world, prefix, Vector2i(4, 4), Vector2i(2, 2), entry_room_id]
		if universe.has("restricted"):
			arguments.append(StringName(universe["restricted"]))
		campaign.callv(&"_create_manifest_facility_portal_transitions", arguments)
		var entry := world.get_node_or_null("%sEntrance" % prefix) as AreaTransition
		var exit := world.get_node_or_null("%sExit" % prefix) as AreaTransition
		assert(entry and exit)
		var entry_definition := REGISTRY.room(entry_room_id)
		assert(Gameboard.pixel_to_cell(entry.arrival_coordinates) == entry_definition["worldOrigin"] + ROUTER.safe_arrival_cell(entry_room_id, &"Nw"))
		assert(Gameboard.pixel_to_cell(exit.position) == entry_definition["worldOrigin"] + entry_definition["portCells"][&"Nw"])
		assert(not world.has_node("%sManifestTransitions" % prefix))
	campaign.free()
	Gameboard.properties = previous_properties
	print("CAMPAIGN_MANIFEST_TRANSITION_INSTALLER_SMOKE_OK universes=%d external_only=true internal=room_runtime" % universes.size())
	get_tree().quit()
