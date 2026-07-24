extends Node

const CATALOG := preload("res://ben_rpg/combat/campaign_action_catalog.gd")
const DATABASE := preload("res://ben_rpg/combat/campaign_combat_database.gd")


func _ready() -> void:
	var errors := CATALOG.validate()
	assert(errors.is_empty(), "Action content validation failed: %s" % errors)
	assert(CATALOG.ids().size() == DATABASE.action_ids().size())
	for action_id in CATALOG.ids():
		assert(DATABASE.action(action_id) == CATALOG.definition(action_id))
	assert(CATALOG.definition(&"heavenly_aegis").get("relation", &"") == &"ally")
	print("ACTION_CATALOG_SMOKE_OK source=content_facade=database actions=%d" % CATALOG.ids().size())
	get_tree().quit(0)
