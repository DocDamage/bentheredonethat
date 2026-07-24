extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")


func _ready() -> void:
	assert(RECORDS.validate().is_empty(), "New Philadelphia second district slice must validate.")
	var expectations := {
		&"NP-08": {"scene": "res://ben_rpg/world/rooms/new_philadelphia_farm_spring_terraces.tscn", "blocked": 89, "lot": &"LOT-07", "feature": &"irrigation_pump"},
		&"NP-09": {"scene": "res://ben_rpg/world/rooms/new_philadelphia_riverside_harbor_walk.tscn", "blocked": 85, "lot": &"", "feature": &"ferry_board"},
		&"NP-10": {"scene": "res://ben_rpg/world/rooms/new_philadelphia_clinic_gardens.tscn", "blocked": 97, "lot": &"LOT-08", "feature": &"public_recovery_fountain"},
	}
	for raw_room_id in expectations:
		var room_id := StringName(raw_room_id)
		var expected: Dictionary = expectations[room_id]
		var scene := load(String(expected["scene"])) as PackedScene
		assert(scene)
		var room := scene.instantiate() as Node2D
		add_child(room)
		assert(room.get_meta(&"room_id", &"") == room_id and bool(room.get_meta(&"runtime_gated", false)))
		assert(room.get_node("NavigationAndCollision").call(&"blocked_cell_count") == expected["blocked"])
		assert(room.get_node("InteractionLayer").has_node("NewPhiladelphiaFeature_%s" % StringName(expected["feature"])))
		var lot_id := StringName(expected["lot"])
		if lot_id == &"":
			assert((RECORDS.record(room_id).get("layout", {}) as Dictionary).get("lotIds", []).is_empty())
		else:
			assert((RECORDS.record(room_id).get("layout", {}) as Dictionary).get("lotIds", []) == [lot_id])
		room.queue_free()
		await get_tree().process_frame
	print("NEW_PHILADELPHIA_TERRACES_HARBOR_CLINIC_SMOKE_OK rooms=3 lots=2 scene_collision=authored")
	get_tree().quit()
