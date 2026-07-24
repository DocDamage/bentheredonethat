extends Node

const SAVE_MIGRATOR := preload("res://ben_rpg/core/save_migrator.gd")


func _ready() -> void:
	var current := SAVE_MIGRATOR.migrate({"version": 21, "duckets": 73})
	assert(bool(current.get("ok", false)) and int(current["data"]["version"]) == 21, "The current fixture schema must remain stable")
	assert((current.get("steps", PackedInt32Array()) as PackedInt32Array).is_empty(), "Current saves should not run legacy migrations")
	var v20 := SAVE_MIGRATOR.migrate({"version": 20, "duckets": 73})
	assert(bool(v20.get("ok", false)) and int(v20["data"]["version"]) == 21 and v20["steps"].size() == 1, "Version-20 saves should traverse the explicit v20-to-v21 boundary")
	var v19 := SAVE_MIGRATOR.migrate({"version": 19, "duckets": 73})
	assert(bool(v19.get("ok", false)) and int(v19["data"]["version"]) == 21 and v19["steps"].size() == 2, "Version-19 saves should traverse both explicit migration boundaries")
	var legacy := SAVE_MIGRATOR.migrate({"version": 11, "built_facilities": {3: "Haunted Mansion"}})
	assert(bool(legacy.get("ok", false)) and int(legacy["source_version"]) == 11, "Legacy saves should report their original schema")
	assert(int(legacy["data"]["version"]) == 21 and legacy["steps"].size() == 10, "Legacy saves should traverse every required migration boundary")
	assert(not bool(SAVE_MIGRATOR.migrate({"version": 22}).get("ok", false)), "Future unknown schemas must be rejected")
	print("SAVE_MIGRATOR_SMOKE_OK current=v21 migration=v20_to_v21 legacy=v11_to_v21 future=rejected")
	get_tree().quit()
