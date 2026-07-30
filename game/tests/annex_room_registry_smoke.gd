extends Node
const REGISTRY := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
func _ready() -> void:
	var errors := REGISTRY.validate()
	assert(errors.is_empty(), "Annex registry validation failed: %s" % errors)
	assert(REGISTRY.is_runtime_admitted(&"NP-15") and REGISTRY.is_runtime_admitted(&"AF-01"))
	assert(REGISTRY.route(&"NP-15", &"E2").get("arrivalCell", Vector2i.ZERO) == Vector2i(8, 3))
	assert(REGISTRY.route(&"AF-01", &"Nw").get("arrivalCell", Vector2i.ZERO) == Vector2i(26, 13))
	assert((REGISTRY.room(&"NP-15").get("ports", {}) as Dictionary).get(&"Se", &"") == &"WF-01")
	assert((REGISTRY.room(&"NP-15").get("portGates", {}) as Dictionary).get(&"Se", &"") == &"warfront_ledger_received")
	assert(REGISTRY.room_ids().size() == 27)
	print("ANNEX_ROOM_REGISTRY_SMOKE_OK rooms=27 phase3=26 route=NP15_AF01 runtime_admitted=true")
	get_tree().quit()
