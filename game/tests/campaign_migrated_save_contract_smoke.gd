extends Node

## A deliberately dense pre-refactor save.  It proves that a schema migration
## preserves the compatibility facade when several formerly coupled domains
## coexist in one real repository payload.

const TEST_SAVE := "user://campaign_migrated_save_contract_smoke.json"
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

const FACILITIES := {
	0: "Cafe", 1: "Library", 2: "Clinic", 3: "Armory", 4: "Haunted Mansion",
	5: "Observatory", 6: "Trailhead Lodge", 7: "Afterlight Club", 8: "Cold Storage",
	9: "Tea House", 10: "Belfry",
}
const ANCHORS := {
	4: &"haunted_mansion", 5: &"asterion_station", 6: &"primeval_expanse",
	7: &"helios_arcology", 8: &"frosthold_kingdom", 9: &"moonpetal_court",
	10: &"empyreal_court",
}


func _ready() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	var payload := CampaignState.call(&"_serialize") as Dictionary
	payload.merge({
		"version": 19,
		"last_save_cell": [0, 32],
		"last_manifest_room_id": "",
		"built_facilities": FACILITIES,
		"universe_anchors": ANCHORS,
		"resident_states": {&"cafe_owner": {"x": 42, "y": 9, "activity": &"working", "target_x": 43, "target_y": 9}},
		"inventory": {&"tonic": 9, &"anchor_core": 0, &"save_contract_token": 3},
		"loot_inventory": [{"instance_id": "migration-saber", "slot": &"weapon", "modifiers": []}],
		"party": [&"ben", &"fighter"],
		"party_formation": {&"ben": &"back", &"fighter": &"front"},
		"recruit_status": {&"ben": &"party", &"fighter": &"party"},
		"facility_assignments": {"Cafe": &"fighter"},
		"owned_inventions": [&"continuity_kite"],
		"equipment_loadouts": {&"ben": {"Migration": {&"weapon": "migration-saber"}}},
		"quest_states": {&"a_fault_in_reality": {"status": &"active", "step": 1, "discovered": true, "reward_claimed": false, "objective_states": {}}},
		"tracked_quest": &"a_fault_in_reality",
	}, true)
	var progress: Dictionary = (payload.get("character_progress", {}) as Dictionary).get(&"ben", {}).duplicate(true)
	progress["equipment"] = {&"weapon": "migration-saber"}
	payload["character_progress"][&"ben"] = progress
	var all_gate_flags := _all_gate_flags()
	all_gate_flags.merge({
		&"haunted_mansion_scenario_complete": true, &"asterion_station_complete": true,
		&"primeval_scenario_complete": true, &"helios_scenario_complete": true,
		&"frosthold_scenario_complete": true, &"moonpetal_scenario_complete": true,
		&"empyreal_scenario_complete": true,
		&"ending_result_committed": true, &"ending_credits_seen": true, &"postgame_unlocked": true,
		&"ending_final_save_marker": true, &"continuity_kite_used": true, &"continuity_kite_use_count": 2,
	}, true)
	payload["story_flags"] = all_gate_flags
	var migration := CampaignState.SAVE_MIGRATOR.migrate(payload)
	assert(bool(migration.get("ok", false)) and int(migration["data"].get("version", 0)) == CampaignState.SAVE_VERSION)
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(payload))
	file.close()
	assert(CampaignState.load_game(TEST_SAVE) == OK)
	_assert_contract(all_gate_flags)
	assert(CampaignState.save_game(TEST_SAVE) == OK)
	var summary := CampaignState.read_save_summary(TEST_SAVE)
	assert(int(summary.get("version", 0)) == CampaignState.SAVE_VERSION)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	print("CAMPAIGN_MIGRATED_SAVE_CONTRACT_SMOKE_OK migration=v19_to_v21 gates=%d facilities=11 anchors=7 residents+inventory+equipment+party+quest+ending+recall=true" % all_gate_flags.size())
	get_tree().quit()


func _all_gate_flags() -> Dictionary:
	var flags := {}
	for room_id in ROOM_REGISTRY.room_ids():
		for flag in (ROOM_REGISTRY.room(room_id).get("portGates", {}) as Dictionary).values():
			if StringName(flag) != &"":
				flags[StringName(flag)] = true
	for universe_id in ANCHORS.values():
		var anchor_flag := StringName(CampaignState.universe_definition(StringName(universe_id)).get("anchor_flag", &""))
		if anchor_flag != &"":
			flags[anchor_flag] = true
	return flags


func _assert_contract(all_gate_flags: Dictionary) -> void:
	assert(CampaignState.built_facilities == FACILITIES and CampaignState.universe_anchors == ANCHORS)
	for flag in all_gate_flags:
		assert(bool(CampaignState.story_flags.get(flag, false)), "Migrated gate %s was lost." % flag)
	assert(CampaignState.last_manifest_room_id == &"HM-01", "Version-19 location migration must retain a stable room id.")
	assert(CampaignState.last_save_cell == Vector2i(306, 3))
	var resident := CampaignState.resident_state(&"cafe_owner")
	assert(resident.get("x") == 42 and resident.get("activity") == &"working")
	assert(int(CampaignState.inventory.get(&"save_contract_token", 0)) == 3)
	assert(CampaignState.party == [&"ben", &"fighter"] and CampaignState.formation_for(&"fighter") == &"front")
	assert(String(CampaignState.character_progress[&"ben"].get("equipment", {}).get(&"weapon", "")) == "migration-saber")
	assert(CampaignState.equipment_loadouts_for(&"ben").has("Migration"))
	assert(CampaignState.tracked_quest == &"a_fault_in_reality" and StringName(CampaignState.quest_state(&"a_fault_in_reality").get("status", &"")) == &"active")
	assert(&"continuity_kite" in CampaignState.owned_inventions and int(CampaignState.story_flags.get(&"continuity_kite_use_count", 0)) == 2)
	var ending := CampaignState.campaign_ending_state()
	assert(bool(ending.get("postgame_unlocked", false)) and bool(ending.get("credits_seen", false)) and bool(ending.get("final_save_marked", false)))
