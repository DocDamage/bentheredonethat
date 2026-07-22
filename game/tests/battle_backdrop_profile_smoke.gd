extends Node

const PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const CASES := [
	[&"mansion_foyer_intro", &"mansion_foyer_battle_backdrop"],
	[&"mansion_gallery_ambush", &"mansion_gallery_battle_backdrop"],
	[&"asterion_dock_intro", &"asterion_dock_battle_backdrop"],
	[&"asterion_greenhouse_patrol", &"asterion_hydro_battle_backdrop"],
	[&"asterion_medical_ambush", &"asterion_medical_battle_backdrop"],
	[&"asterion_mother_computer", &"asterion_command_battle_backdrop"],
	[&"primeval_grove_intro", &"primeval_ground_battle_backdrop"],
	[&"helios_skybridge_intro", &"helios_skybridge_battle_backdrop"],
	[&"helios_market_patrol", &"helios_market_battle_backdrop"],
	[&"helios_transit_patrol", &"helios_transit_battle_backdrop"],
	[&"helios_clinic_ambush", &"helios_clinic_battle_backdrop"],
	[&"helios_civic_sun", &"helios_civic_sun_battle_backdrop"],
	[&"frosthold_gate_intro", &"frosthold_snow_battle_backdrop"],
	[&"moonpetal_gate_intro", &"moonpetal_gate_battle_backdrop"],
	[&"moonpetal_court_patrol", &"moonpetal_court_battle_backdrop"],
	[&"moonpetal_garden_patrol", &"moonpetal_garden_battle_backdrop"],
	[&"moonpetal_bell_ambush", &"moonpetal_bell_battle_backdrop"],
	[&"moonpetal_magistrate_enma", &"moonpetal_palace_battle_backdrop"],
	[&"empyreal_landing_intro", &"empyreal_landing_battle_backdrop"],
	[&"empyreal_garden_patrol", &"empyreal_garden_battle_backdrop"],
	[&"empyreal_forum_patrol", &"empyreal_forum_battle_backdrop"],
	[&"empyreal_aerie_ambush", &"empyreal_aerie_battle_backdrop"],
	[&"empyreal_aerie_patrol", &"empyreal_upper_aerie_battle_backdrop"],
	[&"empyreal_high_comptroller", &"empyreal_tribunal_battle_backdrop"],
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	var main: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	await _settle()
	var battle := main.get_node_or_null("CampaignBattle") as CampaignBattle
	var registry = PROFILE_REGISTRY.new()
	if not battle:
		_fail("The campaign battle controller was not available")
		return
	battle.suppress_persistence = true
	var encounter_ids := CampaignCombatDatabase.encounter_ids()
	for encounter_id in encounter_ids:
		var encounter := CampaignCombatDatabase.encounter(encounter_id)
		var profile_id := StringName(encounter.get("backdrop_profile", &""))
		if profile_id == &"" or not registry.has(profile_id):
			_fail("%s has no approved battle backdrop profile" % encounter_id)
			return
		if encounter.has("backdrop_path") or encounter.has("backdrop_region"):
			_fail("%s still declares a raw battle atlas crop" % encounter_id)
			return
	for case_data in CASES:
		var encounter_id: StringName = case_data[0]
		var profile_id: StringName = case_data[1]
		var encounter := CampaignCombatDatabase.encounter(encounter_id)
		if StringName(encounter.get("backdrop_profile", &"")) != profile_id:
			_fail("%s did not declare %s" % [encounter_id, profile_id])
			return
		if not battle.begin(encounter_id, 10444):
			_fail("%s did not start" % encounter_id)
			return
		await _settle(2)
		var atlas := battle._backdrop_crop.atlas as Texture2D
		if not atlas or atlas.resource_path != registry.texture_path(profile_id):
			_fail("%s did not resolve its profile texture" % encounter_id)
			return
		if battle._backdrop_crop.region != registry.region(profile_id):
			_fail("%s did not resolve its profile region" % encounter_id)
			return
		battle._leave_battle(false)
		await _settle(2)
	print("BATTLE_BACKDROP_PROFILE_SMOKE_OK catalog=%d live_samples=%d manifest_texture+region=true" % [encounter_ids.size(), CASES.size()])
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _settle(frames := 6) -> void:
	for _frame in range(frames):
		await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("BATTLE_BACKDROP_PROFILE_SMOKE_FAILED: " + message)
	get_tree().quit(1)
