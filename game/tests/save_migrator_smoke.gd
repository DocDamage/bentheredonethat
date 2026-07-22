extends Node

const SAVE_MIGRATOR := preload("res://ben_rpg/core/save_migrator.gd")


func _ready() -> void:
	var current := SAVE_MIGRATOR.migrate({"version": 18, "duckets": 73})
	assert(bool(current.get("ok", false)) and int(current["data"]["version"]) == 18, "The current fixture schema must remain stable")
	assert((current.get("steps", PackedInt32Array()) as PackedInt32Array).is_empty(), "Current saves should not run legacy migrations")
	var legacy := SAVE_MIGRATOR.migrate({"version": 11, "built_facilities": {3: "Haunted Mansion"}})
	assert(bool(legacy.get("ok", false)) and int(legacy["source_version"]) == 11, "Legacy saves should report their original schema")
	assert(int(legacy["data"]["version"]) == 18 and legacy["steps"].size() == 7, "Legacy saves should traverse every required migration boundary")
	assert(not bool(SAVE_MIGRATOR.migrate({"version": 19}).get("ok", false)), "Future unknown schemas must be rejected")
	print("SAVE_MIGRATOR_SMOKE_OK current=v18 legacy=v11_to_v18 future=rejected")
	get_tree().quit()
