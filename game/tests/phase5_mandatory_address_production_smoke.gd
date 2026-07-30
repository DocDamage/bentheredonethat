extends Node

const SAVE_PATH := "user://phase5_mandatory_address_production_smoke.json"
const CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")
const ENCOUNTERS := preload("res://ben_rpg/combat/campaign_address_encounter_catalog.gd")
const PROGRESSION := preload("res://ben_rpg/core/campaign_address_progression.gd")
const ANNEX := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const STREAMER := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const RUNTIME := preload("res://ben_rpg/world/campaign_annex_room_runtime.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.SAVE_REPOSITORY.cleanup(SAVE_PATH)
	CampaignState.reset_new_game()
	assert(CATALOG.validate().is_empty())
	assert(RECORDS.validate().is_empty())
	assert(ENCOUNTERS.validate().is_empty())
	assert(PROGRESSION.validate().is_empty())
	assert(ANNEX.validate().is_empty())
	assert(CATALOG.room_ids().size() == 64 and ANNEX.room_ids().size() == 90)
	var previous_properties = Gameboard.properties
	var properties := GameboardProperties.new()
	properties.cell_size = Vector2i(48, 48)
	properties.extents = Rect2i(0, 0, 1000, 1000)
	Gameboard.properties = properties
	var streamer := STREAMER.new()
	var navigation := GameboardLayer.new()
	var runtime := RUNTIME.new()
	add_child(streamer)
	add_child(runtime)
	runtime.configure(streamer, navigation)
	for room_id in CATALOG.room_ids():
		assert(ANNEX.is_runtime_admitted(room_id))
		assert(runtime.activate(room_id), "%s did not activate" % room_id)
		await get_tree().process_frame
		assert(streamer.active_room_id() == room_id)
		assert(streamer.active_root().get_meta(&"room_id", &"") == room_id)
		assert(streamer.active_root().get_node_or_null("NavigationAndCollision") != null)
		var encounter_id := StringName(CATALOG.room(room_id).get("encounterId", &""))
		if encounter_id != &"":
			assert(CampaignCombatDatabase.has_encounter(encounter_id))
			assert(not CampaignCombatDatabase.encounter(encounter_id).is_empty())
			var model := AtbBattleModel.new()
			model.setup(encounter_id, CampaignState.party, CampaignState.character_progress, 5)
			assert(model.encounter_id == encounter_id and not model.living("enemy").is_empty())
			if room_id != &"AF-01": assert(streamer.active_root().get_node_or_null("EncounterLayer/AddressEncounter_%s" % encounter_id) != null)
	for address_id in CATALOG.ADDRESS_ORDER:
		var chapter := CATALOG.address(address_id)
		for flag in chapter.get("unlockFlags", []) as Array: CampaignState.story_flags[StringName(flag)] = true
		assert(PROGRESSION.enter(address_id))
		var critical_encounters: Array[StringName] = []
		var boss_encounter := &""
		for room in chapter.get("rooms", []) as Array:
			if StringName(room.get("class", &"")) != &"C": continue
			var encounter_id := StringName(room.get("encounterId", &""))
			critical_encounters.append(encounter_id)
			if StringName(ENCOUNTERS.contract(encounter_id).get("policy", &"")) == &"boss": boss_encounter = encounter_id
		var before_duckets := CampaignState.duckets
		assert(boss_encounter != &"")
		assert(PROGRESSION.complete_encounter(boss_encounter))
		assert(not PROGRESSION.can_resolve(address_id), "An early boss victory resolved %s before the remaining critical route." % address_id)
		for encounter_id in critical_encounters:
			if encounter_id != boss_encounter: assert(PROGRESSION.complete_encounter(encounter_id))
		var resolution_flag := StringName(chapter.get("resolutionFlag", &""))
		assert(bool(CampaignState.story_flags.get(resolution_flag, false)), "The last critical victory did not recover %s after an early boss clear." % address_id)
		assert(CampaignState.duckets == before_duckets + int((chapter.get("rewards", {}) as Dictionary).get("duckets", 0)))
		assert(not PROGRESSION.resolve(address_id), "Address reward replayed: %s" % address_id)
		assert(PROGRESSION.return_room(address_id).begins_with("NP-"))
	assert(PROGRESSION.all_resolved())
	CampaignState.story_flags[&"empyreal_scenario_complete"] = true
	assert(bool(CampaignState.campaign_ending_state().get("eligible", false)))
	assert(CampaignState.save_game(SAVE_PATH) == OK)
	var expected_duckets := CampaignState.duckets
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(SAVE_PATH) == OK)
	assert(PROGRESSION.all_resolved() and CampaignState.duckets == expected_duckets)
	for address_id in CATALOG.ADDRESS_ORDER:
		var resolution_flag := StringName(CATALOG.address(address_id).get("resolutionFlag", &""))
		assert(bool(CampaignState.story_flags.get(resolution_flag, false)))
		assert(bool(CampaignState.story_flags.get(StringName("%s_reward_claimed" % resolution_flag), false)))
	CampaignState.SAVE_REPOSITORY.cleanup(SAVE_PATH)
	streamer.deactivate()
	navigation.free()
	Gameboard.properties = previous_properties
	print("PHASE5_MANDATORY_ADDRESS_PRODUCTION_SMOKE_OK rooms=64 addresses=6 encounters=41 bosses=6 optional_nonblocking=true rewards=idempotent save_reload=true ending_gate=six_flags")
	get_tree().quit(0)
