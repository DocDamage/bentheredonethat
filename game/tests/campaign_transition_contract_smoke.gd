extends Node

## Characterizes every manifest transition before ownership moves farther away
## from the legacy bootstrap.  The fixture stays data-only: a full graph audit
## must not wake all room scenes merely to prove a destination and its return.

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const NAVIGATION := preload("res://ben_rpg/world/campaign_navigation_builder.gd")
const REPORT := preload("res://ben_rpg/world/campaign_room_graph_report.gd")


func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	assert(ROUTER.validate().is_empty())
	var total_internal_routes := 0
	var fresh_enabled_routes := 0
	var stabilized_enabled_routes := 0
	for state_id in [&"fresh", &"stabilized"]:
		var result := _assert_state(state_id)
		total_internal_routes = int(result.get("internal", total_internal_routes))
		if state_id == &"fresh":
			fresh_enabled_routes = int(result.get("enabled", 0))
		else:
			stabilized_enabled_routes = int(result.get("enabled", 0))
	assert(total_internal_routes > 0)
	assert(stabilized_enabled_routes > fresh_enabled_routes, "Stabilized story state must open additional gated links.")
	print("CAMPAIGN_TRANSITION_CONTRACT_SMOKE_OK states=fresh+stabilized internal_routes=%d fresh_enabled=%d stabilized_enabled=%d reciprocal_safe_arrivals=true" % [total_internal_routes, fresh_enabled_routes, stabilized_enabled_routes])
	get_tree().quit()


func _assert_state(state_id: StringName) -> Dictionary:
	var flags := REPORT.story_state(state_id)
	var enabled_routes := 0
	var internal_routes := 0
	for room_id in REGISTRY.room_ids():
		var source_definition := REGISTRY.room(room_id)
		var enabled_port_ids := REGISTRY.enabled_port_ids(room_id, flags)
		var configured_port_ids: Array = source_definition.get("enabledPortIds", [])
		var source_navigation := NAVIGATION.navigation_record(room_id, enabled_port_ids)
		var source_walkable: Dictionary = source_navigation.get("walkable", {})
		for binding in REGISTRY.ports(room_id):
			var port_id := StringName(binding.get("id", &""))
			var destination_room_id := StringName(binding.get("destination", &""))
			if not REGISTRY.has_room(destination_room_id):
				continue
			internal_routes += 1
			var route := ROUTER.resolve(room_id, port_id)
			assert(not route.is_empty(), "%s.%s must resolve in %s." % [room_id, port_id, state_id])
			assert(StringName(route.get("destinationRoom", &"")) == destination_room_id)
			var arrival_port_id := StringName(route.get("arrivalPort", &""))
			var expected_arrival := ROUTER.safe_arrival_cell(destination_room_id, arrival_port_id)
			assert(route.get("arrivalCell", Vector2i.ZERO) == expected_arrival, "%s.%s must use %s's declared safe arrival." % [room_id, port_id, destination_room_id])
			var destination_navigation := NAVIGATION.navigation_record(destination_room_id, REGISTRY.enabled_port_ids(destination_room_id, flags))
			var destination_walkable: Dictionary = destination_navigation.get("walkable", {})
			assert(destination_walkable.has(expected_arrival), "%s.%s arrival must stay walkable in %s." % [room_id, port_id, state_id])
			assert(NAVIGATION._legal_follower_cells(expected_arrival, destination_walkable) >= 3, "%s.%s arrival needs follower-safe space in %s." % [room_id, port_id, state_id])
			var return_binding := REGISTRY.port(destination_room_id, arrival_port_id)
			assert(StringName(return_binding.get("destination", &"")) == room_id, "%s.%s must return to its source room." % [room_id, port_id])
			var return_route := ROUTER.resolve(destination_room_id, arrival_port_id)
			assert(StringName(return_route.get("destinationRoom", &"")) == room_id)
			var required_flag := StringName((source_definition.get("portGates", {}) as Dictionary).get(port_id, &""))
			var enabled := port_id in enabled_port_ids
			var configured := port_id in configured_port_ids
			assert(enabled == (configured and (required_flag == &"" or bool(flags.get(required_flag, false)))), "%s.%s availability contract diverged in %s." % [room_id, port_id, state_id])
			if enabled:
				enabled_routes += 1
				assert(source_walkable.has((source_definition.get("portCells", {}) as Dictionary).get(port_id, Vector2i.ZERO)), "%s.%s must expose its source port when unlocked." % [room_id, port_id])
			else:
				assert(not source_walkable.has((source_definition.get("portCells", {}) as Dictionary).get(port_id, Vector2i.ZERO)), "%s.%s must block its source port while locked." % [room_id, port_id])
	return {"internal": internal_routes, "enabled": enabled_routes}
