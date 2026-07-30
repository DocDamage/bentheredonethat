extends Node

const CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Required address catalog validation failed: %s" % errors)
	var total := 0
	for address_id in CATALOG.ADDRESS_ORDER:
		var definition := CATALOG.address(address_id)
		var rooms: Array = definition.get("rooms", [])
		total += rooms.size()
		assert(bool(definition.get("runtimeEnabled", false)), "%s must be admitted after its Phase 5 production gate." % address_id)
		assert(not StringName(definition.get("resolutionFlag", &"")) == &"")
		assert(CATALOG.room(StringName(rooms[0].get("id", &""))).get("title", "") == rooms[0].get("title", ""))
	assert(total == 64, "The six mandatory addresses must retain their locked 64-room budget.")
	assert((CATALOG.address(&"liminal").get("rooms", []) as Array).size() == 8)
	print("REQUIRED_ADDRESS_CATALOG_SMOKE_OK addresses=6 rooms=64 budgets=12+12+12+10+10+8 runtime_admitted=true")
	get_tree().quit(0)
