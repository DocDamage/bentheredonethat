extends Node

const CATALOG := preload("res://ben_rpg/combat/campaign_address_encounter_catalog.gd")
const ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Address encounter catalog validation failed: %s" % errors)
	var encounter := CATALOG.contract(&"ashfall_cinder_gate_arrival_raid")
	assert(not encounter.is_empty())
	assert(encounter.get("roomId", &"") == &"AF-01")
	assert(bool(encounter.get("runtimeEnabled", false)))
	assert(encounter.get("battleDefinitionState", &"") == &"admitted_battle_content")
	assert(encounter.get("battleEncounterId", &"") == &"ashfall_cinder_gate_arrival_raid")
	assert(ADDRESS_CATALOG.room(&"AF-01").get("encounterId", &"") == &"ashfall_cinder_gate_arrival_raid")
	assert(CATALOG.CONTRACTS.size() == 41, "Every declared address encounter needs a stable runtime contract.")
	assert(ADDRESS_CATALOG.room(&"AF-07").get("encounterId", &"") == &"ashfall_furnace_pact")
	for encounter_id in CATALOG.CONTRACTS:
		assert(bool(CATALOG.CONTRACTS[encounter_id].get("runtimeEnabled", false)))
	print("ADDRESS_ENCOUNTER_CATALOG_SMOKE_OK contracts=41 addresses=6 bosses=6 runtime_admitted=true")
	get_tree().quit(0)
