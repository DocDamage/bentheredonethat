extends Node

const TEST_SAVE := "user://campaign_state_smoke.json"


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.duckets = 127
	if not CampaignState.build_facility(0, "Cafe") or not CampaignState.build_facility(1, "Library") or not CampaignState.build_facility(2, "Clinic"):
		_fail("Founding facilities could not be recorded")
		return
	if CampaignState.recruit_status[&"fighter"] != &"available":
		_fail("Fighter was not revealed after town foundations completed")
		return
	if not CampaignState.hire_recruit(&"fighter") or not CampaignState.add_to_party(&"fighter"):
		_fail("Available Fighter could not be hired into the party")
		return
	if not CampaignState.assign_to_facility(&"fighter", "Cafe"):
		_fail("Player could not choose staffing instead of adventuring")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Campaign save failed")
		return

	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Campaign load failed")
		return
	if CampaignState.duckets != 127 or CampaignState.built_facilities.size() != 3:
		_fail("Currency or facilities did not survive save/load")
		return
	if CampaignState.facility_assignments.get("Cafe") != "fighter":
		_fail("Facility staffing did not survive save/load")
		return
	if not CampaignState.add_to_party(&"fighter") or CampaignState.party != [&"ben", &"fighter"]:
		_fail("Staffed recruit could not be returned to the party")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("CAMPAIGN_STATE_SMOKE_OK save_load=true party=%s duckets=%d" % [CampaignState.party, CampaignState.duckets])
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_STATE_SMOKE_FAILED: " + message)
	get_tree().quit(1)
