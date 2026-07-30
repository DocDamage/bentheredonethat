extends Node

const TEST_SAVE := "user://equipment_loadout_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.hire_recruit(&"fighter")
	for item in [
		{"instance_id": "loadout-saber", "slot": &"weapon", "modifiers": []},
		{"instance_id": "loadout-cap", "slot": &"head", "modifiers": []},
	]:
		CampaignState.loot_inventory.append(item)
	if not CampaignState.equip_loot(&"ben", "loadout-saber") or not CampaignState.equip_loot(&"ben", "loadout-cap"):
		_fail("Gear setup failed")
		return
	if not CampaignState.save_equipment_loadout(&"ben", "Field"):
		_fail("Loadout was not saved")
		return
	CampaignState.unequip_slot(&"ben", &"weapon")
	CampaignState.equip_loot(&"fighter", "loadout-cap")
	if not CampaignState.apply_equipment_loadout(&"ben", "Field"):
		_fail("Saved loadout was not restored")
		return
	if String(CampaignState.character_progress[&"ben"]["equipment"].get(&"weapon", "")) != "loadout-saber" or String(CampaignState.character_progress[&"ben"]["equipment"].get(&"head", "")) != "loadout-cap" or CampaignState.loot_owner("loadout-cap") != &"ben":
		_fail("Loadout did not restore slots or transfer duplicated gear safely")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Loadout save failed")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK or not CampaignState.equipment_loadouts_for(&"ben").has("Field"):
		_fail("Loadout did not persist")
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("EQUIPMENT_LOADOUT_SMOKE_OK save+apply=true unique_ownership=true persistence=true")
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("EQUIPMENT_LOADOUT_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
