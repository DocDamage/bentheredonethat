extends Node

const TEST_SAVE := "user://progression_catchup_smoke.json"


func _ready() -> void:
	CampaignState.reset_new_game()
	_use_ben_only_fixture()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	if not CampaignState.hire_recruit(&"fighter") or not CampaignState.add_to_party(&"fighter"):
		_fail("The Fighter could not establish the active-party reference level")
		return
	CampaignState.character_progress[&"ben"]["level"] = 8
	CampaignState.character_progress[&"fighter"]["level"] = 6
	CampaignState.discover_recruit(&"astronaut")
	if not CampaignState.hire_recruit(&"astronaut"):
		_fail("The Astronaut could not be hired for catch-up validation")
		return
	if int(CampaignState.character_progress[&"astronaut"].get("level", 0)) != 6:
		_fail("New hires must enter at the party median minus one")
		return
	CampaignState.character_progress[&"fighter"]["level"] = 2
	if not CampaignState.move_to_reserve(&"fighter"):
		_fail("The Fighter could not move to reserve")
		return
	CampaignState.apply_battle_victory(100, 0, [])
	if int(CampaignState.character_progress[&"fighter"].get("level", 0)) < 6 or int(CampaignState.character_progress[&"fighter"].get("exp", 0)) < 78:
		_fail("Reserve recruits did not receive 78 percent experience and a two-level floor")
		return
	CampaignState.character_progress[&"astronaut"]["level"] = 2
	if not CampaignState.assign_to_facility(&"astronaut", "Cafe"):
		_fail("The Astronaut could not staff the Cafe")
		return
	if not CampaignState.start_facility_job("Cafe", &"cafe_morning_service", false, 1000):
		_fail("The staffed catch-up fixture could not start a job")
		return
	var finish := int(CampaignState.facility_job_status("Cafe").get("finishes_at", 0))
	CampaignState.refresh_facility_jobs(finish)
	var job_result := CampaignState.collect_facility_job("Cafe", finish)
	if int(job_result.get("experience", 0)) <= 0 or int(CampaignState.character_progress[&"astronaut"].get("level", 0)) < 6:
		_fail("Staffed recruits did not receive job experience plus rested catch-up")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Catch-up progression could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or int(CampaignState.character_progress[&"fighter"].get("level", 0)) < 6 or int(CampaignState.character_progress[&"astronaut"].get("level", 0)) < 6:
		_fail("Catch-up levels did not survive save/load")
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("PROGRESSION_CATCHUP_SMOKE_OK hire=median_minus_one reserve=78pct staff=job_plus_rested floor=two_levels save_load=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("PROGRESSION_CATCHUP_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)


func _use_ben_only_fixture() -> void:
	# The median-level calculation below intentionally models the historical
	# two-person party, independent of the authored opening trio.
	CampaignState.party.assign([&"ben"])
	CampaignState.party_formation = {&"ben": &"back"}
	CampaignState.recruit_status[&"ben"] = &"party"
	CampaignState.recruit_status[&"lincoln"] = &"reserve"
	CampaignState.recruit_status[&"gandhi"] = &"reserve"
