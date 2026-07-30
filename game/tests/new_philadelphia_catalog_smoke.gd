extends Node

const CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "New Philadelphia catalog validation failed: %s" % errors)
	assert(CATALOG.ROOM_ORDER.size() == 15)
	assert(CATALOG.LOT_DEFINITIONS.size() == 11)
	var embassy := CATALOG.room(&"NP-15")
	assert(embassy.get("blueprint", &"") == &"H1")
	assert(embassy.get("ports", {}) == {&"Ne": &"NP-07", &"E1": &"NP-12", &"E2": &"AF-01", &"Se": &"WF-01"})
	assert(bool(embassy.get("runtimeEnabled", false)))
	var layout := CATALOG.resolved_layout(&"NP-15")
	assert(layout.get("dimensions", Vector2i.ZERO) == Vector2i(30, 20))
	assert(layout.get("cameraBounds", Rect2i()) == Rect2i(0, 0, 1440, 960))
	assert((layout.get("populationAnchors", {}) as Dictionary).get(&"P1") == Vector2i(7, 6))
	var market_lot := CATALOG.lot(&"LOT-01")
	assert(market_lot.get("district", &"") == &"NP-05" and market_lot.get("doorCell", Vector2i.ZERO) == Vector2i(7, 9))
	print("NEW_PHILADELPHIA_CATALOG_SMOKE_OK rooms=15 lots=11 embassy=NP-15 runtime_enabled=true")
	get_tree().quit(0)
