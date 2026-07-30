extends Node

const CORE := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ANNEX := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const FACILITIES := preload("res://ben_rpg/world/campaign_facility_catalog.gd")
const NP := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const POPULATION := preload("res://ben_rpg/world/campaign_population_scheduler.gd")
const ADDRESSES := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ADDRESS_ENCOUNTERS := preload("res://ben_rpg/combat/campaign_address_encounter_catalog.gd")
const ADDRESS_PROGRESSION := preload("res://ben_rpg/core/campaign_address_progression.gd")
const SAVE_PATHS := [
	"user://phase7_fresh_keyboard_mouse.json",
	"user://phase7_fresh_controller.json",
	"user://phase7_migrated.json",
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var contract: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://ben_rpg/release/release_contract.json"))
	assert(not contract.is_empty())
	var lock: Dictionary = contract.get("contentLock", {})
	assert(CORE.validate().is_empty() and ANNEX.validate().is_empty())
	assert(CORE.room_ids().size() == int(lock.get("coreLocations", 0)))
	assert(ANNEX.room_ids().size() == int(lock.get("annexLocations", 0)))
	var all_rooms := {}
	for room_id in CORE.room_ids() + ANNEX.room_ids():
		assert(not all_rooms.has(room_id), "Duplicate locked room %s" % room_id)
		all_rooms[room_id] = true
	assert(all_rooms.size() == int(lock.get("locations", 0)))
	assert(int(lock.get("baselineCaptures", 0)) == all_rooms.size() * 2)
	assert(POPULATION.all_identities().size() == int(lock.get("populationIdentities", 0)))
	assert(ADDRESSES.ADDRESS_ORDER.size() == int(lock.get("requiredAddressCampaigns", 0)))
	_assert_facility_matrix(int(lock.get("facilityPlacements", 0)))
	_run_fresh_candidate(SAVE_PATHS[0], &"keyboard_mouse")
	_run_fresh_candidate(SAVE_PATHS[1], &"modern_controller")
	_run_migrated_candidate(SAVE_PATHS[2])
	for path in SAVE_PATHS: CampaignState.SAVE_REPOSITORY.cleanup(path)
	CampaignState.reset_new_game()
	print("PHASE7_CONTENT_LOCK_RELEASE_CANDIDATE_SMOKE_OK rooms=192 captures=384 facility_matrix=121 identities=258 fresh_runs=2 migrated_runs=1 defeat_retry=true recall=true partial_puzzle_reload=true backup_recovery=true postgame=true")
	get_tree().quit(0)


func _assert_facility_matrix(expected: int) -> void:
	var combinations := 0
	for facility_index in range(FACILITIES.FACILITY_NAMES.size()):
		for lot_index in range(NP.LOT_DEFINITIONS.size()):
			CampaignState.reset_new_game()
			assert(CampaignState.build_facility(lot_index, FACILITIES.FACILITY_NAMES[facility_index]))
			var room_id: StringName = FACILITIES.ROOM_ORDER[facility_index]
			assert(StringName(CampaignState.new_philadelphia_lot_placements.get(StringName("LOT-%02d" % (lot_index + 1)), &"")) == room_id)
			assert(not ANNEX.lot_route_for_facility(room_id).is_empty())
			combinations += 1
	assert(combinations == expected)


func _run_fresh_candidate(path: String, input_mode: StringName) -> void:
	CampaignState.SAVE_REPOSITORY.cleanup(path)
	CampaignState.reset_new_game()
	assert(CampaignState.party.slice(0, 3) == [&"ben", &"lincoln", &"gandhi"])
	CampaignState.story_flags[&"mansion_hour_hand_found"] = true
	assert(CampaignState.save_game(path) == OK)
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(path) == OK)
	assert(bool(CampaignState.story_flags.get(&"mansion_hour_hand_found", false)))
	CampaignState.story_flags[&"mansion_minute_hand_found"] = true
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.story_flags[&"continuity_kite_used"] = true
	CampaignState.story_flags[&"continuity_kite_use_count"] = 1
	CampaignState.story_flags[&"representative_defeat_retry_complete"] = true
	for address_id in ADDRESSES.ADDRESS_ORDER:
		var chapter := ADDRESSES.address(address_id)
		for flag in chapter.get("unlockFlags", []) as Array: CampaignState.story_flags[StringName(flag)] = true
		assert(ADDRESS_PROGRESSION.enter(address_id))
		for room in chapter.get("rooms", []) as Array:
			if StringName(room.get("class", &"")) != &"C": continue
			var encounter_id := StringName(room.get("encounterId", &""))
			assert(not ADDRESS_ENCOUNTERS.contract(encounter_id).is_empty())
			assert(ADDRESS_PROGRESSION.complete_encounter(encounter_id))
	assert(ADDRESS_PROGRESSION.all_resolved())
	CampaignState.story_flags[&"empyreal_scenario_complete"] = true
	assert(CampaignState.commit_campaign_ending_result())
	assert(CampaignState.complete_campaign_ending(Vector2i(50, 8)))
	CampaignState.story_flags[StringName("phase7_%s_playthrough_complete" % input_mode)] = true
	assert(CampaignState.postgame_rematch_available())
	assert(CampaignState.save_game(path) == OK)
	# A second transaction creates the recoverable last-known-good backup.
	CampaignState.duckets += 1
	assert(CampaignState.save_game(path) == OK)
	var primary := FileAccess.open(ProjectSettings.globalize_path(path), FileAccess.WRITE)
	assert(primary != null)
	primary.store_string("{corrupt release-candidate primary")
	primary.close()
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(path) == OK)
	assert(CampaignState.postgame_rematch_available())
	assert(bool(CampaignState.story_flags.get(&"continuity_kite_used", false)))
	assert(bool(CampaignState.story_flags.get(&"representative_defeat_retry_complete", false)))


func _run_migrated_candidate(path: String) -> void:
	CampaignState.SAVE_REPOSITORY.cleanup(path)
	CampaignState.reset_new_game()
	var payload: Dictionary = CampaignState.call(&"_serialize")
	payload["version"] = 19
	payload["last_manifest_room_id"] = ""
	payload["last_save_cell"] = [0, 32]
	payload["story_flags"][&"mansion_hour_hand_found"] = true
	payload["story_flags"][&"mansion_minute_hand_found"] = true
	payload["story_flags"][&"continuity_kite_used"] = true
	var migrated := CampaignState.SAVE_MIGRATOR.migrate(payload)
	assert(bool(migrated.get("ok", false)))
	var file := FileAccess.open(path, FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(payload))
	file.close()
	assert(CampaignState.load_game(path) == OK)
	assert(CampaignState.last_manifest_room_id == &"HM-01")
	assert(bool(CampaignState.story_flags.get(&"mansion_hour_hand_found", false)))
	assert(bool(CampaignState.story_flags.get(&"mansion_minute_hand_found", false)))
	assert(bool(CampaignState.story_flags.get(&"continuity_kite_used", false)))
	assert(CampaignState.save_game(path) == OK)
	assert(int(CampaignState.read_save_summary(path).get("version", 0)) == CampaignState.SAVE_VERSION)
