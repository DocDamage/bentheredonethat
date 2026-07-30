extends Node

## Automated Phase 4 gate. Human keyboard/controller, visual, balance, and
## product acceptance remain intentionally outside this fixture.

const SAVE_PATH := "user://phase4_core_universe_acceptance_smoke.json"
const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")

const UNIVERSES := {
	&"asterion": {"rooms": REGISTRY.ASTERION_ROOM_IDS, "entry": &"AS-01", "boss": &"AS-08", "complete": &"asterion_station_complete", "facility": &"Observatory"},
	&"primeval": {"rooms": REGISTRY.PRIMEVAL_ROOM_IDS, "entry": &"PV-01", "boss": &"PV-08", "complete": &"primeval_scenario_complete", "facility": &"Trailhead Lodge"},
	&"helios": {"rooms": REGISTRY.HELIOS_ROOM_IDS, "entry": &"HE-01", "boss": &"HE-08", "complete": &"helios_scenario_complete", "facility": &"Afterlight Club"},
	&"frosthold": {"rooms": REGISTRY.FROSTHOLD_ROOM_IDS, "entry": &"FR-01", "boss": &"FR-08", "complete": &"frosthold_scenario_complete", "facility": &"Cold Storage"},
	&"moonpetal": {"rooms": REGISTRY.MOONPETAL_ROOM_IDS, "entry": &"MP-01", "boss": &"MP-08", "complete": &"moonpetal_scenario_complete", "facility": &"Tea House"},
	&"empyreal": {"rooms": REGISTRY.EMPYREAL_ROOM_IDS, "entry": &"EM-01", "boss": &"EM-09", "complete": &"empyreal_scenario_complete", "facility": &"Belfry"},
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.SAVE_REPOSITORY.cleanup(SAVE_PATH)
	CampaignState.reset_new_game()
	_assert_static_contracts()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	await _assert_live_streaming(main)
	_assert_save_and_ending_boundaries()
	CampaignState.SAVE_REPOSITORY.cleanup(SAVE_PATH)
	main.queue_free()
	await get_tree().process_frame
	print("PHASE4_CORE_UNIVERSE_ACCEPTANCE_SMOKE_OK core_rooms=102 phase4_rooms=86 universes=6 streaming=live ports=reciprocal saves=6 trio=true ending=provisional")
	get_tree().quit(0)


func _assert_static_contracts() -> void:
	assert(REGISTRY.validate().is_empty())
	assert(ROUTER.validate().is_empty())
	assert(REGISTRY.room_ids().size() == 102)
	var phase4_room_count := 0
	var seen: Dictionary = {}
	for universe_id in UNIVERSES:
		var universe: Dictionary = UNIVERSES[universe_id]
		var room_ids: Array = universe["rooms"]
		phase4_room_count += room_ids.size()
		assert(room_ids.front() == universe["entry"])
		assert(universe["boss"] in room_ids)
		var portal := REGISTRY.facility_portal(universe["facility"] as StringName)
		assert(portal.get("entryRoomId", &"") == universe["entry"])
		assert(portal.get("roomIds", []) == room_ids)
		for room_id in room_ids:
			assert(not seen.has(room_id), "Phase 4 room is duplicated: %s" % room_id)
			seen[room_id] = true
			var definition := REGISTRY.room(room_id)
			var scene_path := String(definition.get("scenePath", ""))
			assert(scene_path.begins_with("res://ben_rpg/world/rooms/"), "%s is not scene-owned" % room_id)
			assert(ResourceLoader.exists(scene_path), "%s scene is missing" % room_id)
			assert(StringName(definition.get("navigationId", &"")).begins_with("authored:"), "%s navigation is not authored" % room_id)
			assert(StringName(definition.get("collisionMaskId", &"")).begins_with("authored:"), "%s collision is not authored" % room_id)
			assert(not (definition.get("visualProfileIds", []) as Array).is_empty(), "%s has no admitted visual profile" % room_id)
			assert(int(definition.get("populationAnchorCount", 0)) in range(1, 7), "%s population is outside the room budget" % room_id)
			assert(not (definition.get("encounterContract", {}) as Dictionary).is_empty(), "%s has no encounter contract" % room_id)
			for port in REGISTRY.ports(room_id):
				var destination := StringName(port.get("destination", &""))
				if not REGISTRY.has_room(destination):
					continue
				var route := ROUTER.resolve(room_id, StringName(port.get("id", &"")))
				assert(not route.is_empty(), "%s has an unresolved internal port" % room_id)
				assert(route.get("arrivalCell", Vector2i.ZERO) != Vector2i.ZERO, "%s has an unsafe zero arrival" % room_id)
	assert(phase4_room_count == 86)


func _assert_live_streaming(main: Node) -> void:
	var runtime: Node = main.get_node("Field/Map/CampaignWorld/ManifestRoomRuntime")
	var streamer: Node = main.get_node("Field/Map/CampaignWorld/RoomStreamer")
	_unlock_all_gates()
	for universe in UNIVERSES.values():
		for room_id in universe["rooms"] as Array:
			runtime.call(&"activate", room_id)
			await get_tree().process_frame
			assert(StringName(runtime.call(&"active_room_id")) == room_id, "%s did not activate in the production runtime" % room_id)
			var root := streamer.call(&"active_root") as Node2D
			assert(root != null and root.get_meta(&"room_id", &"") == room_id)
			assert(root.position == Vector2((REGISTRY.room(room_id).get("worldOrigin", Vector2i.ZERO) as Vector2i) * 48))
			for layer_name in [&"GroundLayer", &"NavigationAndCollision", &"YSortedActorsAndProps", &"InteractionLayer", &"EncounterLayer"]:
				assert(root.get_node_or_null(NodePath(layer_name)) != null, "%s is missing %s" % [room_id, layer_name])


func _assert_save_and_ending_boundaries() -> void:
	for character_id in CampaignState.CORE_PROTAGONIST_IDS:
		assert(character_id in CampaignState.party, "Core protagonist left the party: %s" % character_id)
	for universe in UNIVERSES.values():
		var boss_room := universe["boss"] as StringName
		CampaignState.story_flags[universe["complete"] as StringName] = true
		CampaignState.last_manifest_room_id = boss_room
		CampaignState.last_save_cell = REGISTRY.room(boss_room).get("worldOrigin", Vector2i.ZERO) + Vector2i(3, 3)
		assert(CampaignState.save_game(SAVE_PATH) == OK)
		var expected_party := CampaignState.party.duplicate()
		CampaignState.reset_new_game()
		assert(CampaignState.load_game(SAVE_PATH) == OK)
		assert(CampaignState.last_manifest_room_id == boss_room, "%s save boundary was lost" % boss_room)
		assert(CampaignState.party == expected_party, "%s save changed the active party" % boss_room)
		assert(bool(CampaignState.story_flags.get(universe["complete"] as StringName, false)))
	assert(CampaignState.stabilized_universe_count() == 6)
	assert(CampaignState.commit_campaign_ending_result(), "Empyreal completion did not reach the provisional ending handoff")
	assert(not CampaignState.commit_campaign_ending_result(), "The provisional ending transaction is not idempotent")
	assert(bool(CampaignState.campaign_ending_state().get("needs_presentation", false)))
	for character_id in CampaignState.CORE_PROTAGONIST_IDS:
		assert(character_id in CampaignState.party, "Ending handoff lost %s" % character_id)


func _unlock_all_gates() -> void:
	for universe in UNIVERSES.values():
		for room_id in universe["rooms"] as Array:
			for raw_flag in (REGISTRY.room(room_id).get("portGates", {}) as Dictionary).values():
				CampaignState.story_flags[StringName(raw_flag)] = true
	CampaignState.state_changed.emit()
