extends Node

const CATALOG := preload("res://ben_rpg/core/campaign_world_catalog.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "World catalog validation failed: %s" % errors)
	assert(CampaignState.UNIVERSE_DEFINITIONS == CATALOG.UNIVERSE_DEFINITIONS)
	assert(CampaignState.TOWN_STATE_OVERLAYS == CATALOG.TOWN_STATE_OVERLAYS)
	assert(StringName(CampaignState.universe_definition(&"haunted_mansion").get("destination", &"")) == &"haunted_mansion")
	assert(CampaignState.town_state_overlay().has("tint"))
	print("CAMPAIGN_WORLD_CATALOG_SMOKE_OK universes=7 overlays=5 compatibility_aliases=true")
	get_tree().quit()
