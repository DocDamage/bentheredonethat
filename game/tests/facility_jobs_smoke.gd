extends Node

const TEST_SAVE := "user://facility_jobs_smoke.json"


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	if not CampaignState.hire_recruit(&"fighter") or not CampaignState.add_to_party(&"fighter"):
		_fail("Fighter could not join the company party")
		return
	if not CampaignState.assign_to_facility(&"fighter", "Cafe"):
		_fail("Fighter could not leave the party to staff the Cafe")
		return
	if &"fighter" in CampaignState.party or CampaignState.recruit_status[&"fighter"] != &"staffed":
		_fail("Staffed recruit remained in the adventuring party")
		return

	var estimate := CampaignState.job_estimate("Cafe", &"cafe_founders_supper", true)
	if not bool(estimate.get("allowed", false)) or int(estimate.get("fit", 0)) != 2:
		_fail("Fighter's Security specialty was not recognized")
		return
	if int(estimate.get("duration_seconds", 900)) >= 900 or int(estimate.get("quality", 0)) < 3:
		_fail("Specialty and Ben assistance did not improve time and reward quality")
		return

	var start_time := int(Time.get_unix_time_from_system())
	if not CampaignState.start_facility_job("Cafe", &"cafe_founders_supper", true, start_time):
		_fail("Staffed Cafe assignment could not start")
		return
	if CampaignState.add_to_party(&"fighter"):
		_fail("Working recruit could be pulled into the party mid-assignment")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Running assignment could not be saved")
		return

	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Running assignment could not be loaded")
		return
	var active := CampaignState.facility_job_status("Cafe")
	if active.is_empty() or StringName(active.get("status", "")) != &"running" or StringName(active.get("worker_id", "")) != &"fighter":
		_fail("Assignment timing and worker did not survive save/load")
		return
	var finishes_at := int(active["finishes_at"])
	if CampaignState.refresh_facility_jobs(finishes_at - 1):
		_fail("Assignment completed before its recorded finish time")
		return
	if not CampaignState.refresh_facility_jobs(finishes_at + 1):
		_fail("Offline timestamp did not complete the assignment")
		return
	var before_duckets := CampaignState.duckets
	var result := CampaignState.collect_facility_job("Cafe", finishes_at + 1)
	if result.is_empty() or int(result.get("duckets", 0)) <= 48 or CampaignState.duckets <= before_duckets:
		_fail("Quality-scaled facility rewards were not collected")
		return
	if int(CampaignState.character_progress[&"fighter"].get("exp", 0)) <= 0:
		_fail("Staffed recruit did not gain assignment experience")
		return
	if not CampaignState.release_facility_worker("Cafe") or not CampaignState.add_to_party(&"fighter"):
		_fail("Finished worker could not return to the adventuring party")
		return

	CampaignState.duckets = 100
	if not CampaignState.craft_invention(&"serving_automaton"):
		_fail("Ben could not build an affordable Cafe invention")
		return
	if &"serving_automaton" not in CampaignState.owned_inventions:
		_fail("Crafted invention was not recorded")
		return
	var ben_estimate := CampaignState.job_estimate("Cafe", &"cafe_morning_service", true)
	if not bool(ben_estimate.get("allowed", false)) or StringName(ben_estimate.get("worker_id", "")) != &"ben":
		_fail("Ben could not lead an eligible menial assignment")
		return
	if not bool(ben_estimate.get("invention_active", false)) or int(ben_estimate.get("duration_seconds", 300)) >= 300:
		_fail("Facility invention did not improve Ben-led work")
		return
	if not CampaignState.start_facility_job("Cafe", &"cafe_morning_service", true, start_time):
		_fail("Ben-led assignment could not start")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Invention and Ben-led work could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Invention and Ben-led work could not be loaded")
		return
	if &"serving_automaton" not in CampaignState.owned_inventions or StringName(CampaignState.facility_job_status("Cafe").get("worker_id", "")) != &"ben":
		_fail("Owned invention or Ben-led assignment did not survive save/load")
		return
	if int(CampaignState.completed_facility_jobs.get(&"cafe_founders_supper", 0)) != 1:
		_fail("Completed-job history did not survive save/load")
		return
	if not CampaignState.cancel_facility_job("Cafe"):
		_fail("Assignment could not be abandoned safely")
		return

	if CampaignState.visible_facility_jobs("Library").size() != 1:
		_fail("Information-gated Library job became visible too early")
		return
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	if CampaignState.visible_facility_jobs("Library").size() != 2:
		_fail("Discovered information did not reveal the hidden Library job")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("FACILITY_JOBS_SMOKE_OK offline=true staffing=party_or_job specialty=time+quality ben=lead+assist inventions=true rewards=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("FACILITY_JOBS_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
