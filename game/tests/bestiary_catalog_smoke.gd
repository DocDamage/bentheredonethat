extends Node

const CATALOG := preload("res://ben_rpg/combat/campaign_bestiary_catalog.gd")
const DATABASE := preload("res://ben_rpg/combat/campaign_combat_database.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Bestiary content validation failed: %s" % errors)
	assert(CATALOG.ids().size() == DATABASE.bestiary_ids().size())
	for enemy_id in DATABASE.bestiary_ids():
		var definition := CATALOG.definition(enemy_id)
		var actor := DATABASE.enemy_actor(enemy_id, 0)
		assert(not definition.is_empty(), "%s must be content-owned." % enemy_id)
		assert(String(actor.get("display_name", "")) == String(definition.get("name", "")))
		assert(int(actor.get("max_hp", 0)) == int(definition.get("hp", 0)))
		assert(int(actor.get("experience", -1)) == int(definition.get("exp", -1)))
		assert(actor.get("actions", []) == definition.get("actions", []))
	assert(CATALOG.definition(&"clock_mirror_boss").get("sprite_profile", &"") == &"mansion_foyer_clock")
	assert(CATALOG.definition(&"ashfall_raider").get("sprite_profile", &"") == &"ashfall_raider_battle_actor")
	print("BESTIARY_CATALOG_SMOKE_OK source=content_actor=database enemies=%d" % CATALOG.ids().size())
	get_tree().quit(0)
