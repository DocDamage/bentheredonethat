extends Node

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")

const ROOM_SCENES := {
	&"AS-01": preload("res://ben_rpg/world/rooms/asterion_docking_collar.tscn"),
	&"AS-02": preload("res://ben_rpg/world/rooms/asterion_customs_cargo_intake.tscn"),
	&"AS-03": preload("res://ben_rpg/world/rooms/asterion_mess_deck.tscn"),
}


func _ready() -> void:
	assert(ROOM_REGISTRY.validate().is_empty(), "Asterion room contracts must preserve the complete graph.")
	for room_id in ROOM_SCENES:
		var root := (ROOM_SCENES[room_id] as PackedScene).instantiate() as Node2D
		assert(root, "%s scene must instantiate." % room_id)
		root.configure(room_id, ROOM_REGISTRY.room(room_id))
		add_child(root)
		assert(root.get_meta(&"room_id") == room_id, "%s scene must retain its manifest id." % room_id)
		assert(root.get_node_or_null("InteractionLayer/ManifestInteraction"), "%s must own its manifest interaction root." % room_id)
		assert(root.get_node_or_null("YSortedActorsAndProps/PopulationCohort"), "%s must own its scheduled population cohort." % room_id)
		root.queue_free()
	var as02_route := TRANSITION_ROUTER.resolve(&"AS-01", &"Ne")
	assert(StringName(as02_route.get("destinationRoom", &"")) == &"AS-02", "AS-01 must route to AS-02.")
	assert(as02_route.get("arrivalCell") == Vector2i(6, 3), "AS-02 arrival must be two cells inside its Nw port.")
	var as03_route := TRANSITION_ROUTER.resolve(&"AS-02", &"Ne")
	assert(StringName(as03_route.get("destinationRoom", &"")) == &"AS-03", "AS-02 must route to AS-03.")
	print("CAMPAIGN_ASTERION_FIRST_ROOMS_SMOKE_OK rooms=AS-01+AS-02+AS-03 handoff=FI-06 routes=reciprocal")
	get_tree().quit()
