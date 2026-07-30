extends Node

const TEST_SAVE := "user://field_specialist_assist_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()

	var cargo := AsterionInteraction.new()
	cargo.interaction_kind = &"cargo_cache"
	var locked_events := cargo.apply_interaction(false)
	if CampaignState.story_flags.get(&"asterion_cargo_opened", false) or int(CampaignState.inventory.get(&"research_notes", 0)) != 0:
		_fail("The orbital cargo cache opened without an active navigation specialist")
		return
	if not _contains_text(locked_events, "return with Astronaut active"):
		_fail("The locked cache did not clearly explain the active-party requirement")
		return

	_add_recruit(&"astronaut")
	var cargo_events := cargo.apply_interaction(false)
	if not CampaignState.story_flags.get(&"asterion_cargo_opened", false) or not _contains_text(cargo_events, "Specialist assist"):
		_fail("The Astronaut did not unlock and visibly assist with the cargo cache")
		return
	if CampaignState.duckets != 60 or int(CampaignState.inventory.get(&"ether", 0)) != 3 or int(CampaignState.inventory.get(&"research_notes", 0)) != 1:
		_fail("The Asterion base and specialist rewards were incorrect")
		return
	var cargo_snapshot := [CampaignState.duckets, CampaignState.inventory.duplicate(true)]
	cargo.apply_interaction(false)
	if CampaignState.duckets != cargo_snapshot[0] or CampaignState.inventory != cargo_snapshot[1]:
		_fail("Revisiting the Asterion cache duplicated its one-time rewards")
		return

	CampaignState.owned_inventions.append(&"paleo_translator")
	var primeval := PrimevalInteraction.new()
	primeval.interaction_kind = &"cave_terminal"
	if not _assert_assisted(primeval.apply_interaction(false), &"primeval_terminal_decoded", &"field_assist_primeval_relay_survey_claimed"):
		return

	CampaignState.owned_inventions.append(&"night_phase_inverter")
	var helios := HeliosInteraction.new()
	helios.interaction_kind = &"transit_node"
	if not _assert_assisted(helios.apply_interaction(false), &"helios_transit_node_disabled", &"field_assist_helios_transit_override_claimed"):
		return

	_add_recruit(&"neon_viper")
	CampaignState.owned_inventions.append(&"thermal_arbitration_coil")
	var frosthold := FrostholdInteraction.new()
	frosthold.interaction_kind = &"causeway_seal"
	if not _assert_assisted(frosthold.apply_interaction(false), &"frosthold_causeway_seal_open", &"field_assist_frosthold_thermal_counsel_claimed"):
		return

	_add_recruit(&"frost_lich_emperor")
	CampaignState.owned_inventions.append(&"veracity_lantern")
	var moonpetal := MoonpetalInteraction.new()
	moonpetal.interaction_kind = &"garden_seal"
	if not _assert_assisted(moonpetal.apply_interaction(false), &"moonpetal_bell_walk_open", &"field_assist_moonpetal_memory_audit_claimed"):
		return

	_add_recruit(&"kitsune_empress")
	CampaignState.owned_inventions.append(&"galvanic_counterweight")
	var empyreal := EmpyrealInteraction.new()
	empyreal.interaction_kind = &"aerie_seal"
	if not _assert_assisted(empyreal.apply_interaction(false), &"empyreal_aerie_open", &"field_assist_empyreal_weight_appeal_claimed"):
		return
	if int(CampaignState.story_flags.get(&"field_specialist_assist_count", 0)) != 6:
		_fail("The persistent assist ledger did not record all six universe assists")
		return

	var saved_duckets := CampaignState.duckets
	var saved_inventory := CampaignState.inventory.duplicate(true)
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("The specialist state could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("The specialist state could not be loaded")
		return
	if CampaignState.duckets != saved_duckets or not _same_inventory(CampaignState.inventory, saved_inventory) or int(CampaignState.story_flags.get(&"field_specialist_assist_count", 0)) != 6:
		_fail("Specialist rewards or one-time claim flags did not survive save/load (duckets=%d/%d inventory=%s/%s count=%d)" % [CampaignState.duckets, saved_duckets, CampaignState.inventory, saved_inventory, int(CampaignState.story_flags.get(&"field_specialist_assist_count", 0))])
		return

	CampaignState.reset_new_game()
	_use_ben_only_fixture()
	CampaignState.discover_recruit(&"mossback_surveyor")
	CampaignState.hire_recruit(&"mossback_surveyor")
	if bool(CampaignState.field_specialist_result(&"primeval_relay_survey").get("available", false)):
		_fail("A reserve specialist incorrectly counted as an active field assistant")
		return
	CampaignState.add_to_party(&"mossback_surveyor")
	var mossback_result := CampaignState.field_specialist_result(&"primeval_relay_survey")
	if StringName(mossback_result.get("recruit_id", &"")) != &"mossback_surveyor" or StringName(mossback_result.get("match_kind", &"")) != &"signature":
		_fail("Mossback's cultivation/logistics role did not cross-solve the Primeval survey")
		return

	CampaignState.reset_new_game()
	_use_ben_only_fixture()
	_add_recruit(&"fighter")
	var skill_result := CampaignState.field_specialist_result(&"helios_transit_override")
	if StringName(skill_result.get("recruit_id", &"")) != &"fighter" or StringName(skill_result.get("match_kind", &"")) != &"specialty":
		_fail("The reusable skill fallback did not recognize Fighter's Security specialty")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("FIELD_SPECIALIST_ASSIST_SMOKE_OK tasks=6 active_party_only=true signature+specialty+cross_role=true rewards=one_time persistence=true")
	get_tree().quit(0)


func _add_recruit(recruit_id: StringName) -> void:
	CampaignState.discover_recruit(recruit_id)
	CampaignState.hire_recruit(recruit_id)
	CampaignState.add_to_party(recruit_id)


func _use_ben_only_fixture() -> void:
	# These assertions isolate active-party specialist eligibility. The authored
	# opening roster is a trio, so make the historical Ben-only fixture explicit.
	CampaignState.party.assign([&"ben"])
	CampaignState.party_formation = {&"ben": &"back"}
	CampaignState.recruit_status[&"ben"] = &"party"
	CampaignState.recruit_status[&"lincoln"] = &"reserve"
	CampaignState.recruit_status[&"gandhi"] = &"reserve"


func _assert_assisted(events: Array[String], progress_flag: StringName, assist_flag: StringName) -> bool:
	if not bool(CampaignState.story_flags.get(progress_flag, false)):
		_fail("Scenario progress flag was not set: %s" % String(progress_flag))
		return false
	if not bool(CampaignState.story_flags.get(assist_flag, false)) or not _contains_text(events, "Specialist assist"):
		_fail("The active specialist did not create a visible, persistent assist: %s" % String(assist_flag))
		return false
	return true


func _contains_text(events: Array[String], fragment: String) -> bool:
	for event in events:
		if fragment in event:
			return true
	return false


func _same_inventory(left: Dictionary, right: Dictionary) -> bool:
	if left.size() != right.size():
		return false
	for raw_item_id in right.keys():
		if int(left.get(String(raw_item_id), left.get(StringName(raw_item_id), -999))) != int(right[raw_item_id]):
			return false
	return true


func _fail(message: String) -> void:
	printerr("FIELD_SPECIALIST_ASSIST_SMOKE_FAILED: " + message)
	get_tree().quit(1)
