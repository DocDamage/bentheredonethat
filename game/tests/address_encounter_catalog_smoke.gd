extends Node

const CATALOG := preload("res://ben_rpg/combat/campaign_address_encounter_catalog.gd")
const ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Address encounter catalog validation failed: %s" % errors)
	var encounter := CATALOG.contract(&"ashfall_cinder_gate_arrival_raid")
	assert(not encounter.is_empty())
	assert(encounter.get("roomId", &"") == &"AF-01")
	assert(not bool(encounter.get("runtimeEnabled", true)))
	assert(encounter.get("battleDefinitionState", &"") == &"blocked_pending_combat_database_refactor")
	assert(ADDRESS_CATALOG.room(&"AF-01").get("encounterId", &"") == &"ashfall_cinder_gate_arrival_raid")
	print("ADDRESS_ENCOUNTER_CATALOG_SMOKE_OK contracts=1 room=AF-01 runtime_gated=true")
	get_tree().quit(0)
