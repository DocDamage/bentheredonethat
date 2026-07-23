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
	campaign.call(&"_create_manifest_facility_transitions", world, "HeliosArcology", Vector2i(4, 4), Vector2i(2, 2), &"HE-01", REGISTRY.HELIOS_ROOM_IDS)
	var entry := world.get_node_or_null("HeliosArcologyEntrance") as AreaTransition
	var exit := world.get_node_or_null("HeliosArcologyExit") as AreaTransition
	var container := world.get_node_or_null("HeliosArcologyManifestTransitions") as Node2D
	assert(entry and exit and container)
	var entry_definition := REGISTRY.room(&"HE-01")
	assert(Gameboard.pixel_to_cell(entry.arrival_coordinates) == entry_definition["worldOrigin"] + ROUTER.safe_arrival_cell(&"HE-01", &"Nw"))
	assert(Gameboard.pixel_to_cell(exit.position) == entry_definition["worldOrigin"] + entry_definition["portCells"][&"Nw"])
	var expected_count := _enabled_internal_route_count(REGISTRY.HELIOS_ROOM_IDS)
	assert(container.get_child_count() == expected_count)
	for transition in container.get_children():
		assert(transition is AreaTransition)
	assert(container.get_node_or_null("HE-01_Ne"))
	campaign.free()
	Gameboard.properties = previous_properties
	print("CAMPAIGN_MANIFEST_TRANSITION_INSTALLER_SMOKE_OK universe=helios routes=%d gated=current_state" % expected_count)
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
