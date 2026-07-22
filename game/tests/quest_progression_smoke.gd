extends Node

const TEST_SAVE := "user://quest_progression_smoke.json"


func _ready() -> void:
	CampaignState.reset_new_game()
	if CampaignState.tracked_quest != &"a_fault_in_reality" or StringName(CampaignState.quest_state(&"a_fault_in_reality").get("status", "")) != &"active":
		_fail("Opening main quest was not active and tracked")
		return
	if int(CampaignState.quest_state(&"a_fault_in_reality").get("step", -1)) != 0:
		_fail("Opening quest did not begin at its first objective")
		return

	CampaignState.mark_story_flag(&"opening_complete")
	CampaignState.mark_story_flag(&"town_entered")
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Armory")
	if StringName(CampaignState.quest_state(&"a_fault_in_reality").get("status", "")) != &"complete":
		_fail("Town founding events did not complete the opening quest")
		return
	if CampaignState.tracked_quest != &"first_hire" or CampaignState.duckets != 40 or int(CampaignState.inventory.get(&"tonic", 0)) != 4:
		_fail("Opening quest rewards or automatic main-quest tracking failed")
		return
	if not _quest_visible(&"company_at_work") or _quest_visible(&"echoes_on_paper"):
		_fail("Side quest discovery or hidden quest concealment failed")
		return

	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	if StringName(CampaignState.quest_state(&"first_hire").get("status", "")) != &"complete" or CampaignState.tracked_quest != &"first_anchor":
		_fail("Recruitment did not complete and advance the main quest")
		return
	if not CampaignState.assign_to_facility(&"fighter", "Cafe"):
		_fail("Fighter could not begin the staffing side quest")
		return
	if int(CampaignState.quest_state(&"company_at_work").get("step", 0)) != 1:
		_fail("Facility assignment did not advance the staffing quest")
		return
	if not CampaignState.start_facility_job("Cafe", &"cafe_founders_supper", false, 1000):
		_fail("Staffing quest job could not start")
		return
	var finish := int(CampaignState.facility_job_status("Cafe")["finishes_at"])
	CampaignState.refresh_facility_jobs(finish)
	CampaignState.collect_facility_job("Cafe", finish)
	if StringName(CampaignState.quest_state(&"company_at_work").get("status", "")) != &"complete":
		_fail("Collecting company work did not complete its side quest")
		return
	CampaignState.release_facility_worker("Cafe")
	CampaignState.add_to_party(&"fighter")

	CampaignState.build_facility(4, "Haunted Mansion")
	CampaignState.mark_story_flag(&"mansion_entered")
	if StringName(CampaignState.quest_state(&"first_anchor").get("status", "")) != &"complete" or CampaignState.tracked_quest != &"the_house_keeps_time":
		_fail("Entering the first universe did not start the Mansion scenario quest")
		return
	for flag in [&"mansion_foyer_cleared", &"mansion_clock_examined", &"mansion_ledger_found", &"mansion_first_room_complete", &"mansion_archive_save_found"]:
		CampaignState.mark_story_flag(flag)
	if int(CampaignState.quest_state(&"the_house_keeps_time").get("step", 0)) != 5:
		_fail("Mansion encounter, clue, puzzle, and save events did not advance in order")
		return
	if not _quest_visible(&"echoes_on_paper"):
		_fail("Household information did not reveal the hidden Library quest")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Quest journal could not be saved")
		return

	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Quest journal could not be loaded")
		return
	if CampaignState.tracked_quest != &"the_house_keeps_time" or int(CampaignState.quest_state(&"the_house_keeps_time").get("step", 0)) != 5:
		_fail("Tracked quest or current step did not survive save/load")
		return
	for flag in [&"mansion_gallery_ambush_cleared", &"mansion_hour_hand_found", &"mansion_nursery_ambush_cleared", &"mansion_minute_hand_found", &"mansion_ballroom_open"]:
		CampaignState.mark_story_flag(flag)
	CampaignState.mark_story_flag(&"mansion_archive_boss_defeated")
	if StringName(CampaignState.quest_state(&"the_house_keeps_time").get("status", "")) != &"complete":
		_fail("Boss victory did not complete the Haunted Mansion quest")
		return
	var rewarded_duckets := CampaignState.duckets
	CampaignState.sync_quests()
	if CampaignState.duckets != rewarded_duckets:
		_fail("Completed quest rewards could be claimed more than once")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("QUEST_PROGRESSION_SMOKE_OK main=opening>hire>anchor>mansion side=staffing hidden=information rewards=once save_load=true")
	get_tree().quit(0)


func _quest_visible(quest_id: StringName) -> bool:
	for quest in CampaignState.visible_quests():
		if StringName(quest.get("id", "")) == quest_id:
			return true
	return false


func _fail(message: String) -> void:
	printerr("QUEST_PROGRESSION_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
