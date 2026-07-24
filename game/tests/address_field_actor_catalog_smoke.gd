extends Node

const CATALOG := preload("res://ben_rpg/world/campaign_address_field_actor_catalog.gd")
const FIELD_ACTOR := preload("res://ben_rpg/world/campaign_address_field_actor.gd")

func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Address field-actor catalog validation failed: %s" % errors)
	for actor_id in CATALOG.ACTORS:
		var actor := CATALOG.actor(actor_id)
		assert(not bool(actor.get("runtimeEnabled", true)))
		assert((actor.get("directionProfiles", {}) as Dictionary).size() == 8)
	var preview := FIELD_ACTOR.new() as Node2D
	assert(preview and preview.call(&"configure", &"af01_scrap_kid_field_actor", CATALOG.actor(&"af01_scrap_kid_field_actor"), Vector2i(6, 6)))
	add_child(preview)
	assert(preview.get_meta(&"anchor", &"") == &"P1")
	assert(preview.get_meta(&"profile_id", &"") == &"af01_scrap_kid_south")
	assert(preview.has_node("ProfileSprite"))
	print("ADDRESS_FIELD_ACTOR_CATALOG_SMOKE_OK actors=3 rotations=24 renderer=profile_backed runtime_gated=true")
	get_tree().quit(0)
