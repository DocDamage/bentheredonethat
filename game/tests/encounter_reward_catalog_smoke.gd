extends Node

const CATALOG := preload("res://ben_rpg/combat/campaign_encounter_reward_catalog.gd")
const DATABASE := preload("res://ben_rpg/combat/campaign_combat_database.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Encounter reward validation failed: %s" % errors)
	for encounter_id in CATALOG.FIXED_REWARD_ENCOUNTERS:
		var rng := RandomNumberGenerator.new()
		rng.seed = 20260723
		var drops := DATABASE.roll_loot(encounter_id, rng)
		assert(not drops.is_empty(), "%s must preserve its reward contract." % encounter_id)
		assert(StringName(drops[0].get("id", &"")) != &"")
	for encounter_id in [&"mansion_foyer_intro", &"asterion_dock_intro", &"primeval_grove_intro", &"helios_skybridge_intro", &"frosthold_gate_intro", &"moonpetal_gate_intro", &"empyreal_landing_intro"]:
		var rng := RandomNumberGenerator.new()
		rng.seed = 20260723
		assert(not DATABASE.roll_loot(encounter_id, rng).is_empty(), "%s must retain its introductory reward." % encounter_id)
	var fallback_drops := DATABASE.roll_loot(&"unknown_encounter", RandomNumberGenerator.new())
	for drop in fallback_drops:
		assert(StringName(drop.get("id", &"")) != &"" and String(drop.get("kind", "")).is_empty() == false)
	print("ENCOUNTER_REWARD_CATALOG_SMOKE_OK source=content_facade=database fixed=%d" % CATALOG.FIXED_REWARD_ENCOUNTERS.size())
	get_tree().quit(0)
