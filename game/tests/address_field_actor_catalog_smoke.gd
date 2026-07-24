extends Node

const CATALOG := preload("res://ben_rpg/world/campaign_address_field_actor_catalog.gd")

func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Address field-actor catalog validation failed: %s" % errors)
	for actor_id in CATALOG.ACTORS:
		var actor := CATALOG.actor(actor_id)
		assert(not bool(actor.get("runtimeEnabled", true)))
		assert((actor.get("directionProfiles", {}) as Dictionary).size() == 8)
	print("ADDRESS_FIELD_ACTOR_CATALOG_SMOKE_OK actors=3 rotations=24 runtime_gated=true")
	get_tree().quit(0)
