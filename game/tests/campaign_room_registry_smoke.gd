extends Node

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	var errors := ROOM_REGISTRY.validate()
	for error in errors:
		push_error(error)
	assert(errors.is_empty(), "Room registry validation failed with %d error(s)." % errors.size())
	assert(ROOM_REGISTRY.room_ids().size() == 102, "Expected the locked seven-world, 102-room core graph.")
	assert(ROOM_REGISTRY.ports(&"PV-01").size() == 3, "PV-01 requires Trailhead, Primeval, and switchback ports.")
	assert(ROOM_REGISTRY.room(&"HM-09").get("encounterPolicy") == &"boss", "HM-09 must remain the boss room.")
	assert(ROOM_REGISTRY.ports(&"HM-01").size() == 2, "HM-01 requires facility and Mansion entry ports.")
	assert(ROOM_REGISTRY.ports(&"AS-01").size() == 3, "AS-01 requires Observatory, Asterion, and tram ports.")
	assert(ROOM_REGISTRY.room(&"AS-02").get("dimensions") == Vector2i(20, 14), "AS-02 must resolve the locked M2 footprint.")
	var foyer := ROOM_REGISTRY.room(&"HM-02")
	assert(foyer.get("dimensions") == Vector2i(26, 18), "HM-02 must resolve the locked L2 footprint.")
	assert(foyer.get("cameraBounds") == Rect2i(0, 0, 1248, 864), "HM-02 camera bounds must use 48px cells.")
	assert((foyer.get("portCells") as Dictionary).get(&"E1") == Vector2i(24, 6), "HM-02 must bind E1 to the L2 port cell.")
	assert(foyer.get("populationAnchors") == [&"P1", &"P2", &"P3", &"P4", &"P5", &"P6"])
	assert((foyer.get("populationAnchorCells") as Dictionary).get(&"P1") == Vector2i(6, 6))
	assert(foyer.get("collisionMaskId") == &"generated:L2-collision")
	assert(ROOM_REGISTRY.room(&"FR-08").get("encounterPolicy") == &"boss", "FR-08 must remain the Frosthold boss room.")
	assert(ROOM_REGISTRY.room(&"MP-08").get("encounterPolicy") == &"boss", "MP-08 must remain the Moonpetal boss room.")
	assert(ROOM_REGISTRY.room(&"EM-09").get("encounterPolicy") == &"boss", "EM-09 must remain the Empyreal boss room.")
	assert(ROOM_REGISTRY.ports(&"FR-01").size() == 3 and ROOM_REGISTRY.ports(&"MP-01").size() == 3 and ROOM_REGISTRY.ports(&"EM-01").size() == 3)
	print("CAMPAIGN_ROOM_REGISTRY_SMOKE_OK rooms=102 entries=HM-01+AS-01+PV-01+FR-01+MP-01+EM-01 bosses=locked graph=connected blueprints=resolved")
	get_tree().quit()
