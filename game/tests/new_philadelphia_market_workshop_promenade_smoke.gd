extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")


func _ready() -> void:
	assert(RECORDS.validate().is_empty(), "New Philadelphia district records must validate.")
	var expectations := {
		&"NP-05": {"scene": "res://ben_rpg/world/rooms/new_philadelphia_old_town_market.tscn", "blocked": 117, "lots": [&"LOT-01", &"LOT-02"], "feature": &""},
		&"NP-06": {"scene": "res://ben_rpg/world/rooms/new_philadelphia_civic_workshop_row.tscn", "blocked": 121, "lots": [&"LOT-03", &"LOT-04"], "feature": &"public_repair_board"},
		&"NP-07": {"scene": "res://ben_rpg/world/rooms/new_philadelphia_anchor_promenade.tscn", "blocked": 101, "lots": [&"LOT-05", &"LOT-06"], "feature": &"anchor_status_map"},
	}
	for raw_room_id in expectations:
		var room_id := StringName(raw_room_id)
		var expected: Dictionary = expectations[room_id]
		var record := RECORDS.record(room_id)
		assert((record.get("layout", {}) as Dictionary).get("lotIds", []) == expected["lots"])
		var scene := load(String(expected["scene"])) as PackedScene
		assert(scene, "%s scene must load." % room_id)
		var room := scene.instantiate() as Node2D
		add_child(room)
		assert(room.get_meta(&"room_id", &"") == room_id and bool(room.get_meta(&"runtime_gated", false)))
		assert(room.get_node("NavigationAndCollision").call(&"blocked_cell_count") == expected["blocked"])
		var feature_id := StringName(expected["feature"])
		if feature_id != &"":
			assert(room.get_node("InteractionLayer").has_node("NewPhiladelphiaFeature_%s" % feature_id))
		room.queue_free()
		await get_tree().process_frame
	print("NEW_PHILADELPHIA_MARKET_WORKSHOP_PROMENADE_SMOKE_OK rooms=3 lots=6 scene_collision=authored")
	get_tree().quit()
