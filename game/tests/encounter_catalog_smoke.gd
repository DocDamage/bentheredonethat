extends Node

const CATALOG := preload("res://ben_rpg/combat/campaign_encounter_catalog.gd")
const DATABASE := preload("res://ben_rpg/combat/campaign_combat_database.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Encounter content validation failed: %s" % errors)
	assert(CATALOG.ids().size() == DATABASE.encounter_ids().size())
	for encounter_id in CATALOG.ids():
		assert(DATABASE.encounter(encounter_id) == CATALOG.definition(encounter_id))
	assert(CATALOG.definition(&"mansion_archive_boss").get("boss_policy", {}).get("id", &"") == &"mansion_clock_mirror")
	assert(CATALOG.definition(&"ashfall_cinder_gate_arrival_raid").get("backdrop_profile", &"") == &"ashfall_cinder_gate_battle_backdrop")
	print("ENCOUNTER_CATALOG_SMOKE_OK source=content_facade=database contracts=%d" % CATALOG.ids().size())
	get_tree().quit(0)
