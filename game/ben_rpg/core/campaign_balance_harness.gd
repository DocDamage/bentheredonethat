class_name CampaignBalanceHarness
extends RefCounted

## Deterministic, economy-only campaign route checks.  This deliberately uses
## authored encounters and quest grants rather than random loot, treasure, or
## jobs, so a passing low-combat route proves the main path cannot depend on
## optional play or real-time work.

const PROFILES := {
	&"low_combat": {"optional_encounters": 0, "optional_spend_ratio": 0.0},
	&"median_combat": {"optional_encounters": 3, "optional_spend_ratio": 0.22},
	&"high_combat": {"optional_encounters": 6, "optional_spend_ratio": 0.32},
	&"missed_treasure": {"optional_encounters": 0, "optional_spend_ratio": 0.0},
	&"no_job": {"optional_encounters": 0, "optional_spend_ratio": 0.0},
	&"heavy_job": {"optional_encounters": 3, "optional_spend_ratio": 0.22, "job_bonus_ratio": 0.18},
	&"minimum_job": {"optional_encounters": 0, "optional_spend_ratio": 0.0, "job_bonus_ratio": 0.0},
	&"offline_heavy": {"optional_encounters": 3, "optional_spend_ratio": 0.22, "job_bonus_ratio": 0.18},
}

const MAIN_PATH := [
	{
		"chapter": &"mansion", "pre_gate": [], "gate_invention": &"",
		"post_gate": [&"mansion_foyer_intro", &"mansion_gallery_ambush", &"mansion_nursery_ambush", &"mansion_archive_boss"],
		"optional": [&"mansion_restless_books", &"mansion_lost_hours", &"mansion_last_dance"],
		"quests": [&"the_house_keeps_time", &"a_portable_way_home", &"a_second_door"],
	},
	{
		"chapter": &"asterion", "pre_gate": [], "gate_invention": &"",
		"post_gate": [&"asterion_dock_intro", &"asterion_medical_ambush", &"asterion_hydro_ambush", &"asterion_mother_computer"],
		"optional": [&"asterion_maintenance_detail", &"asterion_greenhouse_patrol", &"asterion_command_patrol"],
		"quests": [&"the_last_shift", &"the_oldest_address"],
	},
	{
		"chapter": &"primeval", "pre_gate": [&"primeval_grove_intro"], "gate_invention": &"paleo_translator",
		"post_gate": [&"primeval_nest_ambush", &"primeval_commute_tyrant"],
		"optional": [&"primeval_raptor_pack", &"primeval_heavy_herd", &"primeval_nest_patrol"],
		"quests": [&"municipal_extinction", &"a_brighter_night"],
	},
	{
		"chapter": &"helios", "pre_gate": [&"helios_skybridge_intro"], "gate_invention": &"night_phase_inverter",
		"post_gate": [&"helios_clinic_ambush", &"helios_civic_sun"],
		"optional": [&"helios_market_patrol", &"helios_transit_patrol", &"helios_clinic_patrol"],
		"quests": [&"mandatory_daylight", &"a_colder_address"],
	},
	{
		"chapter": &"frosthold", "pre_gate": [&"frosthold_gate_intro"], "gate_invention": &"thermal_arbitration_coil",
		"post_gate": [&"frosthold_rune_ambush", &"frosthold_whiteout_auditor"],
		"optional": [&"frosthold_market_patrol", &"frosthold_causeway_patrol", &"frosthold_rune_patrol"],
		"quests": [&"the_frozen_ledger", &"tea_beyond_winter"],
	},
	{
		"chapter": &"moonpetal", "pre_gate": [&"moonpetal_gate_intro"], "gate_invention": &"veracity_lantern",
		"post_gate": [&"moonpetal_bell_ambush", &"moonpetal_magistrate_enma"],
		"optional": [&"moonpetal_court_patrol", &"moonpetal_garden_patrol", &"moonpetal_bell_patrol"],
		"quests": [&"the_counterfeit_moon", &"bells_above_the_clouds"],
	},
	{
		"chapter": &"empyreal", "pre_gate": [&"empyreal_landing_intro"], "gate_invention": &"galvanic_counterweight",
		"post_gate": [&"empyreal_aerie_ambush", &"empyreal_high_comptroller"],
		"optional": [&"empyreal_garden_patrol", &"empyreal_forum_patrol", &"empyreal_aerie_patrol"],
		"quests": [&"the_weight_of_heaven"],
	},
]

# Each required material has two authored, no-job, no-treasure grants before
# the indicated invention gate.  The harness validates these claims against
# the quest data as part of every suite run.
const REQUIRED_MATERIAL_SOURCES := {
	&"paleo_translator": {
		&"research_notes": [&"a_second_door", &"the_oldest_address"],
		&"anchor_dust": [&"the_house_keeps_time", &"a_second_door"],
	},
	&"night_phase_inverter": {
		&"research_notes": [&"municipal_extinction", &"a_brighter_night"],
		&"anchor_dust": [&"municipal_extinction", &"a_brighter_night"],
	},
	&"thermal_arbitration_coil": {
		&"research_notes": [&"mandatory_daylight", &"a_colder_address"],
		&"anchor_dust": [&"mandatory_daylight", &"a_colder_address"],
	},
	&"veracity_lantern": {
		&"research_notes": [&"the_frozen_ledger", &"tea_beyond_winter"],
		&"anchor_dust": [&"the_frozen_ledger", &"tea_beyond_winter"],
	},
	&"galvanic_counterweight": {
		&"research_notes": [&"the_counterfeit_moon", &"bells_above_the_clouds"],
		&"anchor_dust": [&"the_counterfeit_moon", &"bells_above_the_clouds"],
	},
}

# The harness runs hundreds of economy-only simulations. Encounter rewards are
# static campaign data, so cache their resolved Ducket totals instead of
# rebuilding battle actors on every seeded route.
static var _encounter_ducket_rewards: Dictionary = {}


static func run_suite(runs_per_profile := 100) -> Dictionary:
	var source_errors := validate_material_sources()
	var profiles := {}
	var failures: Array[Dictionary] = []
	var alarms: Dictionary = {}
	for raw_profile_id in PROFILES.keys():
		var profile_id := StringName(raw_profile_id)
		var aggregate := _empty_aggregate()
		for run_index in range(runs_per_profile):
			var result := run_profile(profile_id, run_index + 1)
			aggregate["runs"] = int(aggregate["runs"]) + 1
			if bool(result.get("passed", false)):
				aggregate["passed"] = int(aggregate["passed"]) + 1
			else:
				failures.append({"profile": profile_id, "seed": run_index + 1, "failures": result.get("failures", [])})
			for alarm in result.get("alarms", []):
				alarms[String(alarm)] = int(alarms.get(String(alarm), 0)) + 1
			_accumulate_chapters(aggregate["chapters"], result.get("chapters", []))
		profiles[profile_id] = aggregate
	return {
		"runs_per_profile": runs_per_profile,
		"profiles": profiles,
		"source_errors": source_errors,
		"failures": failures,
		"alarms": alarms,
		"passed": source_errors.is_empty() and failures.is_empty(),
	}


static func run_profile(profile_id: StringName, seed: int) -> Dictionary:
	var profile: Dictionary = PROFILES.get(profile_id, {})
	if profile.is_empty():
		return {"passed": false, "failures": ["Unknown profile %s" % profile_id], "alarms": [], "chapters": []}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var state := {"duckets": 0, "items": {}}
	var failures: Array[String] = []
	var alarms: Array[String] = []
	var chapters: Array[Dictionary] = []
	for raw_step in MAIN_PATH:
		var step: Dictionary = raw_step
		var chapter := StringName(step["chapter"])
		var income := 0
		for encounter_id in step.get("pre_gate", []):
			income += _grant_encounter_rewards(state, StringName(encounter_id))
		var invention_id := StringName(step.get("gate_invention", &""))
		var required_spend := 0
		if invention_id != &"":
			var invention_result := _pay_invention(state, invention_id)
			required_spend = int(invention_result.get("duckets", 0))
			if not bool(invention_result.get("paid", false)):
				failures.append("%s cannot afford %s: %s" % [chapter, invention_id, invention_result.get("reason", "unknown")])
		for encounter_id in step.get("post_gate", []):
			income += _grant_encounter_rewards(state, StringName(encounter_id))
		var optional: Array = step.get("optional", [])
		for _encounter_index in range(int(profile.get("optional_encounters", 0))):
			if optional.is_empty():
				break
			income += _grant_encounter_rewards(state, StringName(optional[rng.randi_range(0, optional.size() - 1)]))
		for quest_id in step.get("quests", []):
			income += _grant_quest_rewards(state, StringName(quest_id))
		var job_bonus := int(round(float(income) * float(profile.get("job_bonus_ratio", 0.0))))
		state["duckets"] = int(state["duckets"]) + job_bonus
		income += job_bonus
		var optional_spend := mini(int(state["duckets"]), int(round(float(income) * float(profile.get("optional_spend_ratio", 0.0)))))
		state["duckets"] = int(state["duckets"]) - optional_spend
		if int(state["duckets"]) < 0:
			failures.append("%s created a negative Ducket balance" % chapter)
		var required_ratio := float(required_spend) / float(maxi(1, income))
		if required_spend > 0 and (required_ratio < 0.35 or required_ratio > 0.50):
			alarms.append("%s required spend %.0f%% is outside the 35-50%% target" % [chapter, required_ratio * 100.0])
		chapters.append({
			"chapter": chapter,
			"income": income,
			"required_spend": required_spend,
			"optional_spend": optional_spend,
			"duckets_held": int(state["duckets"]),
			"required_spend_ratio": required_ratio,
		})
	return {"passed": failures.is_empty(), "failures": failures, "alarms": alarms, "chapters": chapters}


static func validate_material_sources() -> Array[String]:
	var errors: Array[String] = []
	for raw_invention_id in REQUIRED_MATERIAL_SOURCES.keys():
		var invention_id := StringName(raw_invention_id)
		var recipe: Dictionary = CampaignState.INVENTION_DEFINITIONS.get(invention_id, {})
		var source_materials: Dictionary = REQUIRED_MATERIAL_SOURCES[invention_id]
		for raw_item_id in recipe.get("items", {}).keys():
			var item_id := StringName(raw_item_id)
			var sources: Array = source_materials.get(item_id, [])
			if sources.size() < 2:
				errors.append("%s needs two declared sources for %s" % [invention_id, item_id])
				continue
			for raw_quest_id in sources:
				var quest_id := StringName(raw_quest_id)
				var rewards: Dictionary = CampaignState.QUEST_DEFINITIONS.get(quest_id, {}).get("rewards", {})
				var items: Dictionary = rewards.get("items", {})
				if int(items.get(item_id, 0)) <= 0:
					errors.append("%s does not award declared %s source %s" % [quest_id, item_id, invention_id])
	return errors


static func _grant_encounter_rewards(state: Dictionary, encounter_id: StringName) -> int:
	var earned := int(_encounter_ducket_rewards.get(encounter_id, -1))
	if earned < 0:
		var encounter := CampaignCombatDatabase.encounter(encounter_id)
		earned = 0
		for index in range((encounter.get("enemies", []) as Array).size()):
			var enemy_id := StringName(encounter["enemies"][index])
			earned += int(CampaignCombatDatabase.enemy_actor(enemy_id, index).get("duckets", 0))
		_encounter_ducket_rewards[encounter_id] = earned
	state["duckets"] = int(state["duckets"]) + earned
	return earned


static func _grant_quest_rewards(state: Dictionary, quest_id: StringName) -> int:
	var rewards: Dictionary = CampaignState.QUEST_DEFINITIONS.get(quest_id, {}).get("rewards", {})
	var duckets := int(rewards.get("duckets", 0))
	state["duckets"] = int(state["duckets"]) + duckets
	var items: Dictionary = state["items"]
	for raw_item_id in (rewards.get("items", {}) as Dictionary).keys():
		var item_id := StringName(raw_item_id)
		items[item_id] = int(items.get(item_id, 0)) + int(rewards["items"][raw_item_id])
	return duckets


static func _pay_invention(state: Dictionary, invention_id: StringName) -> Dictionary:
	var recipe: Dictionary = CampaignState.INVENTION_DEFINITIONS.get(invention_id, {})
	var cost := int(recipe.get("duckets", 0))
	if int(state["duckets"]) < cost:
		return {"paid": false, "duckets": cost, "reason": "not enough Duckets"}
	var items: Dictionary = state["items"]
	for raw_item_id in (recipe.get("items", {}) as Dictionary).keys():
		var item_id := StringName(raw_item_id)
		var required := int(recipe["items"][raw_item_id])
		if int(items.get(item_id, 0)) < required:
			return {"paid": false, "duckets": cost, "reason": "missing %s" % item_id}
	state["duckets"] = int(state["duckets"]) - cost
	for raw_item_id in (recipe.get("items", {}) as Dictionary).keys():
		var item_id := StringName(raw_item_id)
		items[item_id] = int(items.get(item_id, 0)) - int(recipe["items"][raw_item_id])
	return {"paid": true, "duckets": cost}


static func _empty_aggregate() -> Dictionary:
	return {"runs": 0, "passed": 0, "chapters": {}}


static func _accumulate_chapters(aggregate: Dictionary, chapters: Array) -> void:
	for raw_chapter in chapters:
		var chapter: Dictionary = raw_chapter
		var chapter_id := StringName(chapter.get("chapter", &"unknown"))
		if not aggregate.has(chapter_id):
			aggregate[chapter_id] = {"income": 0, "required_spend": 0, "optional_spend": 0, "duckets_held": 0, "samples": 0}
		var totals: Dictionary = aggregate[chapter_id]
		for metric in [&"income", &"required_spend", &"optional_spend", &"duckets_held"]:
			totals[metric] = int(totals[metric]) + int(chapter.get(metric, 0))
		totals["samples"] = int(totals["samples"]) + 1
