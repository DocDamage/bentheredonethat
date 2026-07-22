extends Node

const TEST_SAVE := "user://facility_upgrade_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	CampaignState.duckets = 200
	CampaignState.add_item(&"provisions", 2, false)
	var before_estimate := CampaignState.job_estimate("Cafe", &"cafe_morning_service", true)
	var ward_price_before := CampaignState.service_item_price("Cafe", &"rift_ward")
	if not CampaignState.upgrade_facility(&"cafe_hearth_exchange"):
		_fail("Cafe upgrade could not be installed with its documented materials")
		return
	if not CampaignState.facility_has_upgrade("Cafe", &"cafe_hearth_exchange"):
		_fail("Installed facility upgrade was not retained")
		return
	var modifiers := CampaignState.facility_upgrade_modifiers("Cafe")
	if float(modifiers.get("service_discount", 0.0)) != 0.05 or int(modifiers.get("job_quality_bonus", 0)) != 1:
		_fail("Cafe upgrade modifiers were not exposed")
		return
	if CampaignState.service_item_price("Cafe", &"rift_ward") >= ward_price_before:
		_fail("Cafe upgrade did not improve a visible direct service price")
		return
	var after_estimate := CampaignState.job_estimate("Cafe", &"cafe_morning_service", true)
	if int(after_estimate.get("duration_seconds", 9999)) >= int(before_estimate.get("duration_seconds", 9999)) or int(after_estimate.get("quality", 0)) != int(before_estimate.get("quality", 0)) + 1:
		_fail("Cafe upgrade did not improve job time and quality")
		return
	if not CampaignState.prepare_cafe_expedition_meal() or CampaignState.expedition_meal_charges != 1:
		_fail("Cafe upgrade did not unlock its reusable expedition preparation service")
		return
	var ben_exp := int(CampaignState.character_progress[&"ben"].get("exp", 0))
	CampaignState.apply_battle_victory(10, 0, [])
	if CampaignState.expedition_meal_charges != 0 or int(CampaignState.character_progress[&"ben"].get("exp", 0)) != ben_exp + 12:
		_fail("Packed meal did not apply its once-only 20-percent victory experience benefit")
		return
	if not CampaignState.prepare_cafe_expedition_meal() or CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Prepared Café state could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or not CampaignState.facility_has_upgrade("Cafe", &"cafe_hearth_exchange") or CampaignState.expedition_meal_charges != 1:
		_fail("Facility upgrade or field preparation did not survive save/load")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("FACILITY_UPGRADE_SMOKE_OK cafe=hearth_exchange services+jobs=true expedition_benefit=true persistence=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("FACILITY_UPGRADE_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
