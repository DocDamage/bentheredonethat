extends Node

const TEST_SAVE := "user://roster_formation_smoke.json"
const RESTRICTED_TRANSITION := preload("res://ben_rpg/world/restricted_area_transition.tscn")


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	if CampaignState.formation_for(&"ben") != &"back" or CampaignState.formation_for(&"fighter") != &"front":
		_fail("Default support/frontline formation was not assigned")
		return

	for recruit_id in [&"scout", &"medic", &"scholar"]:
		CampaignState.recruit_catalog[recruit_id] = {"name": String(recruit_id).capitalize(), "specialty": "Test specialty", "work_specialties": [], "work_adjacent": []}
		CampaignState.recruit_status[recruit_id] = &"reserve"
		CampaignState.ensure_character_progress(recruit_id, 120, 24)
		if not CampaignState.add_to_party(recruit_id):
			_fail("Five-slot party could not be filled with a future recruit")
			return
	if CampaignState.party.size() != 5 or CampaignState.party[0] != &"ben":
		_fail("Party capacity or fixed leader slot failed")
		return
	if CampaignState.formation_row_count(&"front") != 3 or CampaignState.formation_row_count(&"back") != 2:
		_fail("New recruits were not balanced into three-person formation rows")
		return
	if CampaignState.set_party_formation(&"scholar", &"front"):
		_fail("Formation allowed more than three adventurers in one row")
		return
	if not CampaignState.move_party_member(&"scholar", -1) or CampaignState.party[0] != &"ben":
		_fail("Party ordering failed or displaced Ben from the leader slot")
		return

	# Return to the authored two-person party for battle and restriction checks.
	for recruit_id in [&"scout", &"medic", &"scholar"]:
		CampaignState.move_to_reserve(recruit_id)
	if not CampaignState.move_to_reserve(&"fighter"):
		_fail("Fighter could not enter reserve before the Mansion scenario began")
		return
	var gate = RESTRICTED_TRANSITION.instantiate()
	gate.required_members = CampaignState.destination_party_requirements(&"haunted_mansion")
	gate.waiver_story_flag = &"haunted_mansion_scenario_complete"
	if gate.requirements_met() or gate.missing_member_names() != ["Fighter"]:
		_fail("Haunted Mansion gate did not identify its missing required recruit")
		return
	CampaignState.add_to_party(&"fighter")
	if not gate.requirements_met():
		_fail("Valid Mansion party was rejected")
		return
	gate.queue_free()

	CampaignState.mark_story_flag(&"mansion_entered")
	if CampaignState.can_remove_from_party(&"fighter") or CampaignState.move_to_reserve(&"fighter") or CampaignState.assign_to_facility(&"fighter", "Cafe"):
		_fail("Active scenario did not lock its required party member")
		return

	CampaignState.party_formation[&"fighter"] = &"front"
	var front_model := AtbBattleModel.new()
	front_model.setup(&"mansion_foyer_intro", CampaignState.party, CampaignState.character_progress, 1776)
	var front_fighter := front_model.get_actor(&"fighter")
	var front_target: Dictionary = front_model.living("enemy")[0]
	front_fighter["atb"] = 100.0
	var front_before := int(front_target["hp"])
	front_model.resolve_action(&"fighter", &"attack", [StringName(front_target["id"])])
	var front_damage := front_before - int(front_target["hp"])

	CampaignState.party_formation[&"fighter"] = &"back"
	var back_model := AtbBattleModel.new()
	back_model.setup(&"mansion_foyer_intro", CampaignState.party, CampaignState.character_progress, 1776)
	var back_fighter := back_model.get_actor(&"fighter")
	var back_target: Dictionary = back_model.living("enemy")[0]
	back_fighter["atb"] = 100.0
	var back_before := int(back_target["hp"])
	back_model.resolve_action(&"fighter", &"attack", [StringName(back_target["id"])])
	var back_damage := back_before - int(back_target["hp"])
	if front_damage <= back_damage or back_fighter.get("formation", &"") != &"back":
		_fail("Back-row physical damage penalty did not reach the real ATB model")
		return

	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Party order and formation could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.formation_for(&"fighter") != &"back":
		_fail("Party formation did not survive save/load")
		return
	CampaignState.mark_story_flag(&"haunted_mansion_scenario_complete")
	if not CampaignState.move_to_reserve(&"fighter"):
		_fail("Completed scenario did not release its party restriction")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("ROSTER_FORMATION_SMOKE_OK party=5 leader=ben rows=3+3 combat=front>back restriction=fighter gate=true save_load=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("ROSTER_FORMATION_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
