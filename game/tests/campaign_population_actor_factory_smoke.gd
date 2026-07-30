extends Node

const FACTORY := preload("res://ben_rpg/world/campaign_population_actor_factory.gd")


func _ready() -> void:
	assert(FACTORY.create({}) == null, "The actor factory must reject incomplete assignments.")
	assert(FACTORY.create({
		"identityId": &"blocked",
		"runtimeProfileId": &"not-a-profile",
		"room": &"TEST-01",
		"anchor": &"P1",
		"cell": Vector2i(6, 6),
	}) == null, "The actor factory must reject unadmitted runtime profiles.")
	var actor := FACTORY.create({
		"identityId": &"sakpix:test/caretaker",
		"runtimeProfileId": &"af01_scrap_kid_south",
		"room": &"TEST-01",
		"anchor": &"P1",
		"cell": Vector2i(6, 6),
	})
	assert(actor != null, "An admitted field profile must produce a room-owned actor.")
	assert(actor.position == Vector2(288, 288))
	assert(actor.get_meta(&"identity_id") == &"sakpix:test/caretaker")
	assert(actor.get_meta(&"room_id") == &"TEST-01")
	assert(actor.get_node_or_null("ProfileSprite") is Sprite2D)
	actor.free()
	print("CAMPAIGN_POPULATION_ACTOR_FACTORY_SMOKE_OK rejected=incomplete+unadmitted admitted=field_profile ownership=cohort_child")
	get_tree().quit()
