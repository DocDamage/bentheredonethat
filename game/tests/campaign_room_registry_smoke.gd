extends Node

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	var errors := ROOM_REGISTRY.validate()
	for error in errors:
		push_error(error)
	assert(errors.is_empty(), "Room registry validation failed with %d error(s)." % errors.size())
	assert(ROOM_REGISTRY.room_ids().size() == 16, "Expected the locked 16-room Mansion graph.")
	assert(ROOM_REGISTRY.room(&"HM-09").get("encounterPolicy") == &"boss", "HM-09 must remain the boss room.")
	assert(ROOM_REGISTRY.ports(&"HM-01").size() == 2, "HM-01 requires facility and Mansion entry ports.")
	var foyer := ROOM_REGISTRY.room(&"HM-02")
	assert(foyer.get("dimensions") == Vector2i(26, 18), "HM-02 must resolve the locked L2 footprint.")
	assert(foyer.get("cameraBounds") == Rect2i(0, 0, 1248, 864), "HM-02 camera bounds must use 48px cells.")
	assert((foyer.get("portCells") as Dictionary).get(&"E1") == Vector2i(24, 6), "HM-02 must bind E1 to the L2 port cell.")
	assert(foyer.get("populationAnchors") == [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"])
	assert((foyer.get("populationAnchorCells") as Dictionary).get(&"P1") == Vector2i(6, 6))
	assert(foyer.get("collisionMaskId") == &"generated:L2-collision")
	print("CAMPAIGN_ROOM_REGISTRY_SMOKE_OK rooms=16 entry=HM-01 boss=HM-09 graph=connected blueprints=resolved")
	get_tree().quit()
