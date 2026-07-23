extends Node

## Characterizes the compatibility surface callers may retain while CampaignState
## definitions and services are extracted.  It deliberately names public calls
## by caller domain, then exercises a small cross-domain save/load flow.

const TEST_SAVE := "user://campaign_state_contract_smoke.json"
const REQUIRED_CALLS := {
	&"bootstrap": [&"reset_new_game", &"begin_play_session", &"pause_play_session", &"build_facility", &"anchor_universe", &"available_universe_anchors", &"universe_definition", &"mark_story_flag", &"save_game", &"load_game"],
	&"menu": [&"visible_quests", &"set_tracked_quest", &"visible_facility_jobs", &"service_stock", &"actor_build", &"format_play_time"],
	&"battle": [&"set_character_vitals", &"apply_battle_victory", &"restore_party", &"active_party_members_with_skill"],
	&"facilities": [&"assign_to_facility", &"facility_job_status", &"start_facility_job", &"collect_facility_job"],
	&"residents": [&"set_resident_state", &"resident_state"],
	&"tests": [&"read_save_summary", &"has_save", &"town_state_overlay"],
}
const REQUIRED_SIGNALS := [&"state_changed", &"facility_built", &"recruit_status_changed", &"party_changed", &"encounter_pressure_changed"]

var _signals := {}


func _ready() -> void:
	for domain: StringName in REQUIRED_CALLS:
		for method: StringName in REQUIRED_CALLS[domain]:
			assert(CampaignState.has_method(method), "%s callers require CampaignState.%s" % [domain, method])
	for signal_name: StringName in REQUIRED_SIGNALS:
		assert(CampaignState.has_signal(signal_name), "CampaignState.%s must remain available during extraction" % signal_name)
	CampaignState.state_changed.connect(_on_state_changed)
	CampaignState.facility_built.connect(_on_facility_built)
	CampaignState.recruit_status_changed.connect(_on_recruit_status_changed)
	CampaignState.party_changed.connect(_on_party_changed)
	CampaignState.encounter_pressure_changed.connect(_on_encounter_pressure_changed)

	CampaignState.reset_new_game()
	_signals.clear()
	CampaignState.begin_play_session()
	CampaignState.pause_play_session()
	assert(CampaignState.universe_definition(&"haunted_mansion").get("destination") == &"haunted_mansion")
	assert(CampaignState.available_universe_anchors() is Array)
	assert(CampaignState.visible_quests() is Array and CampaignState.town_state_overlay().has("name"))
	assert(CampaignState.build_facility(0, "Cafe"))
	assert(CampaignState.build_facility(1, "Library"))
	assert(CampaignState.build_facility(2, "Clinic"))
	assert(CampaignState.hire_recruit(&"fighter"))
	assert(CampaignState.add_to_party(&"fighter"))
	assert(CampaignState.assign_to_facility(&"fighter", "Cafe"))
	CampaignState.set_resident_state(&"contract_caretaker", Vector2i(8, 9), &"reading", Vector2i(9, 9))
	assert(CampaignState.resident_state(&"contract_caretaker").get("activity") == &"reading")
	CampaignState.report_encounter_pressure(&"haunted_mansion", 3, 5)
	CampaignState.set_character_vitals(&"ben", 8, 3, 25, 10)
	assert(CampaignState.actor_build(&"ben").has("bonuses") and CampaignState.character_progress[&"ben"].get("hp") == 8)
	assert(CampaignState.mark_story_flag(&"campaign_state_contract_fixture"))
	assert(CampaignState.save_game(TEST_SAVE) == OK)
	assert(CampaignState.has_save(TEST_SAVE))
	var summary := CampaignState.read_save_summary(TEST_SAVE)
	assert(summary.get("facilities") == 3 and summary.get("duckets") == CampaignState.duckets)
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(TEST_SAVE) == OK)
	var restored_resident := CampaignState.resident_state(&"contract_caretaker")
	assert(restored_resident.get("x") == 8 and restored_resident.get("y") == 9)
	assert(CampaignState.facility_assignments.get("Cafe") == "fighter")
	assert(int(_signals.get(&"facility_built", 0)) == 3)
	assert(int(_signals.get(&"recruit_status_changed", 0)) >= 1)
	assert(int(_signals.get(&"party_changed", 0)) >= 2)
	assert(int(_signals.get(&"encounter_pressure_changed", 0)) >= 1)
	assert(int(_signals.get(&"state_changed", 0)) >= 1)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("CAMPAIGN_STATE_CONTRACT_SMOKE_OK domains=%d signals=%s save_load=true" % [REQUIRED_CALLS.size(), _signals])
	get_tree().quit()


func _record(signal_name: StringName) -> void:
	_signals[signal_name] = int(_signals.get(signal_name, 0)) + 1


func _on_state_changed() -> void:
	_record(&"state_changed")


func _on_facility_built(_plot_index: int, _facility_name: String) -> void:
	_record(&"facility_built")


func _on_recruit_status_changed(_recruit_id: StringName, _status: StringName) -> void:
	_record(&"recruit_status_changed")


func _on_party_changed() -> void:
	_record(&"party_changed")


func _on_encounter_pressure_changed(_data: Dictionary) -> void:
	_record(&"encounter_pressure_changed")
