extends Node

const TEST_SAVE := "user://universe_anchor_choice_smoke.json"
const LEGACY_SAVE := "user://universe_anchor_choice_legacy.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(LEGACY_SAVE))
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	if CampaignState.available_universe_anchors().size() != 0:
		_fail("The mandatory first universe became available before the Fighter was hired")
		return
	CampaignState.hire_recruit(&"fighter")
	var first_choices := CampaignState.available_universe_anchors()
	if first_choices.size() != 1 or StringName(first_choices[0].get("id", &"")) != &"haunted_mansion":
		_fail("The Haunted Mansion was not the sole mandatory first anchor")
		return
	if not CampaignState.anchor_universe(3, &"haunted_mansion"):
		_fail("The selected first universe could not be anchored")
		return
	if CampaignState.anchored_universe_at(3) != &"haunted_mansion" or not CampaignState.story_flags.get(&"haunted_mansion_anchor_built", false):
		_fail("The first building did not retain its explicit universe destination")
		return
	if CampaignState.anchor_universe(4, &"haunted_mansion"):
		_fail("The same universe was anchored twice")
		return
	if not CampaignState.available_universe_anchors().is_empty():
		_fail("Asterion was revealed before its relevant Mansion discovery")
		return
	CampaignState.mark_story_flag(&"mansion_archive_boss_defeated")
	var second_choices := CampaignState.available_universe_anchors()
	if second_choices.size() != 1 or StringName(second_choices[0].get("id", &"")) != &"asterion_station":
		_fail("Asterion did not become a selectable post-Mansion destination")
		return
	if not CampaignState.anchor_universe(4, &"asterion_station") or CampaignState.built_facilities.get(4) != "Observatory":
		_fail("The selected Asterion destination did not construct its Observatory shell")
		return
	if not CampaignState.available_universe_anchors().is_empty():
		_fail("Primeval Expanse was revealed before Asterion was stabilized")
		return
	CampaignState.mark_story_flag(&"asterion_station_complete")
	var third_choices := CampaignState.available_universe_anchors()
	if third_choices.size() != 1 or StringName(third_choices[0].get("id", &"")) != &"primeval_expanse":
		_fail("Primeval Expanse did not become the discovered post-Asterion destination")
		return
	if not CampaignState.anchor_universe(5, &"primeval_expanse") or CampaignState.built_facilities.get(5) != "Trailhead Lodge":
		_fail("The selected Primeval destination did not construct its Trailhead Lodge shell")
		return
	if not CampaignState.available_universe_anchors().is_empty():
		_fail("Helios Arcology was revealed before Primeval was stabilized")
		return
	CampaignState.mark_story_flag(&"primeval_scenario_complete")
	var fourth_choices := CampaignState.available_universe_anchors()
	if fourth_choices.size() != 1 or StringName(fourth_choices[0].get("id", &"")) != &"helios_arcology":
		_fail("Helios Arcology did not become the discovered post-Primeval destination")
		return
	if not CampaignState.anchor_universe(6, &"helios_arcology") or CampaignState.built_facilities.get(6) != "Afterlight Club":
		_fail("The selected Helios destination did not construct its Afterlight Club shell")
		return
	if not CampaignState.available_universe_anchors().is_empty():
		_fail("Frosthold Kingdom was revealed before Helios was stabilized")
		return
	CampaignState.mark_story_flag(&"helios_scenario_complete")
	var fifth_choices := CampaignState.available_universe_anchors()
	if fifth_choices.size() != 1 or StringName(fifth_choices[0].get("id", &"")) != &"frosthold_kingdom":
		_fail("Frosthold Kingdom did not become the discovered post-Helios destination")
		return
	if not CampaignState.anchor_universe(7, &"frosthold_kingdom") or CampaignState.built_facilities.get(7) != "Cold Storage":
		_fail("The selected Frosthold destination did not construct its Cold Storage shell")
		return
	if not CampaignState.available_universe_anchors().is_empty():
		_fail("Moonpetal Court was revealed before Frosthold was stabilized")
		return
	CampaignState.mark_story_flag(&"frosthold_scenario_complete")
	var sixth_choices := CampaignState.available_universe_anchors()
	if sixth_choices.size() != 1 or StringName(sixth_choices[0].get("id", &"")) != &"moonpetal_court":
		_fail("Moonpetal Court did not become the discovered post-Frosthold destination")
		return
	if not CampaignState.anchor_universe(8, &"moonpetal_court") or CampaignState.built_facilities.get(8) != "Tea House":
		_fail("The selected Moonpetal destination did not construct its Tea House shell")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Explicit universe anchors could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.anchored_universe_at(3) != &"haunted_mansion" or CampaignState.anchored_universe_at(4) != &"asterion_station" or CampaignState.anchored_universe_at(5) != &"primeval_expanse" or CampaignState.anchored_universe_at(6) != &"helios_arcology" or CampaignState.anchored_universe_at(7) != &"frosthold_kingdom" or CampaignState.anchored_universe_at(8) != &"moonpetal_court":
		_fail("Explicit universe selections did not survive save/load")
		return

	# Version 11 stored only building names. Loading it must infer the same
	# destinations so established towns remain usable after the migration.
	var legacy_data: Dictionary = CampaignState._serialize()
	legacy_data["version"] = 11
	legacy_data.erase("universe_anchors")
	var legacy_file := FileAccess.open(LEGACY_SAVE, FileAccess.WRITE)
	if legacy_file == null:
		_fail("Could not create the legacy migration fixture")
		return
	legacy_file.store_string(JSON.stringify(legacy_data))
	legacy_file.close()
	CampaignState.reset_new_game()
	if CampaignState.load_game(LEGACY_SAVE) != OK or CampaignState.anchored_universe_at(3) != &"haunted_mansion" or CampaignState.anchored_universe_at(4) != &"asterion_station" or CampaignState.anchored_universe_at(5) != &"primeval_expanse" or CampaignState.anchored_universe_at(6) != &"helios_arcology" or CampaignState.anchored_universe_at(7) != &"frosthold_kingdom" or CampaignState.anchored_universe_at(8) != &"moonpetal_court":
		_fail("Version-11 building saves did not migrate into explicit universe anchors")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(LEGACY_SAVE))
	CampaignState.reset_new_game()
	print("UNIVERSE_ANCHOR_CHOICE_SMOKE_OK mandatory=mansion asterion=discovery_gated primeval=post_asterion helios=post_primeval frosthold=post_helios moonpetal=post_frosthold duplicate=false save_load=true migration=v11")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("UNIVERSE_ANCHOR_CHOICE_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(LEGACY_SAVE))
	get_tree().quit(1)
