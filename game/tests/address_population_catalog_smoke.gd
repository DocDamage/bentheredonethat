extends Node

const CATALOG := preload("res://ben_rpg/world/campaign_address_population_catalog.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Address population catalog validation failed: %s" % errors)
	var contract := CATALOG.contract_for_room(&"AF-01")
	assert(not contract.is_empty())
	assert(not bool(contract.get("runtimeEnabled", true)))
	assert(CATALOG.resident_ids(&"af01-survivor-watch-v1") == [CATALOG.AF01_SCRAP_KID, CATALOG.AF01_DUST_HUNTER])
	var visitor: Dictionary = (contract.get("temporaryVisitors", []) as Array)[0]
	assert(visitor.get("identityId", &"") == CATALOG.AF01_IRON_SENTINEL_VISITOR)
	assert(visitor.get("anchor", &"") == &"P3" and visitor.get("canonicalHome", &"") == &"AF-05")
	print("ADDRESS_POPULATION_CATALOG_SMOKE_OK room=AF-01 residents=2 visitor=iron_sentinel runtime_gated=true")
	get_tree().quit(0)
