extends Node

## Locks the declared non-baseline capture matrix to real room-state contracts.
## Rendering is deliberately left to the windowed capture runner; this smoke
## test makes missing or untraceable matrix records fail quickly in CI.

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	var errors := REGISTRY.validate()
	assert(errors.is_empty(), "Room registry validation failed: %s" % errors)
	var variants := REGISTRY.capture_variants()
	var expected_keys: Dictionary = {}
	var actual_keys: Dictionary = {}
	var kinds: Dictionary = {}
	for room_id in REGISTRY.room_ids():
		var definition := REGISTRY.room(room_id)
		for raw_flag in (definition.get("portGates", {}) as Dictionary).values():
			expected_keys["%s|%s" % [room_id, raw_flag]] = true
		var boss: Dictionary = definition.get("bossEncounter", {})
		var defeated_flag := StringName(boss.get("defeatedFlag", &""))
		if defeated_flag != &"":
			expected_keys["%s|%s" % [room_id, defeated_flag]] = true
		for raw_feature_id in definition.get("featureIds", []):
			if String(raw_feature_id).contains("postgame"):
				expected_keys["%s|postgame_unlocked" % room_id] = true
	for variant in variants:
		var key := "%s|%s" % [variant.get("roomId", &""), variant.get("flag", &"")]
		assert(not actual_keys.has(key), "Capture matrix duplicated %s" % key)
		actual_keys[key] = true
		for raw_kind in variant.get("kinds", []):
			var kind := StringName(raw_kind)
			kinds[kind] = int(kinds.get(kind, 0)) + 1
		assert(StringName(variant.get("state", &"")) != &"", "Capture matrix state is required for %s" % key)
		assert(StringName(variant.get("sourceState", &"")) in [&"fresh", &"postgame"], "Capture matrix source state is invalid for %s" % key)
	assert(actual_keys == expected_keys, "Capture matrix must cover every declared gate, boss, and postgame variant.")
	assert(int(kinds.get(&"gate", 0)) > 0)
	assert(int(kinds.get(&"restoration", 0)) > 0)
	assert(int(kinds.get(&"boss", 0)) > 0)
	assert(int(kinds.get(&"postgame", 0)) > 0)
	print("CAMPAIGN_CAPTURE_MATRIX_SMOKE_OK baseline=%d variants=%d gate=%d restoration=%d boss=%d postgame=%d" % [REGISTRY.room_ids().size() * 2, variants.size(), int(kinds.get(&"gate", 0)), int(kinds.get(&"restoration", 0)), int(kinds.get(&"boss", 0)), int(kinds.get(&"postgame", 0))])
	get_tree().quit(0)
