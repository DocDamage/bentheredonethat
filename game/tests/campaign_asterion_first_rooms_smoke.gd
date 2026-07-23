extends Node

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")

const ROOM_SCENES := {
	&"AS-01": preload("res://ben_rpg/world/rooms/asterion_docking_collar.tscn"),
	&"AS-02": preload("res://ben_rpg/world/rooms/asterion_customs_cargo_intake.tscn"),
	&"AS-03": preload("res://ben_rpg/world/rooms/asterion_mess_deck.tscn"),
	&"AS-13": preload("res://ben_rpg/world/rooms/asterion_pressure_lock_junction.tscn"),
	&"AS-04": preload("res://ben_rpg/world/rooms/asterion_medical_triage.tscn"),
	&"AS-05": preload("res://ben_rpg/world/rooms/asterion_hydroponics_outer_walk.tscn"),
	&"AS-06": preload("res://ben_rpg/world/rooms/asterion_oxygen_biocircuit_core.tscn"),
	&"AS-07": preload("res://ben_rpg/world/rooms/asterion_command_spine.tscn"),
	&"AS-08": preload("res://ben_rpg/world/rooms/asterion_station_control.tscn"),
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
	assert(StringName(TRANSITION_ROUTER.resolve(&"AS-03", &"E1").get("destinationRoom", &"")) == &"AS-13", "Mess must route to the pressure-lock junction.")
	assert(StringName(TRANSITION_ROUTER.resolve(&"AS-13", &"Ne").get("destinationRoom", &"")) == &"AS-04", "Junction must route to Medical.")
	assert(StringName(TRANSITION_ROUTER.resolve(&"AS-13", &"E1").get("destinationRoom", &"")) == &"AS-05", "Junction must route to Hydroponics.")
	assert(StringName(TRANSITION_ROUTER.resolve(&"AS-05", &"Ne").get("destinationRoom", &"")) == &"AS-06", "Hydroponics must route to the oxygen core.")
	var medical := ROOM_REGISTRY.room(&"AS-04")
	assert(medical.get("asterionInteractions", []).size() == 2, "Medical must own both Biocircuit and save beacon interactions.")
	assert(ROOM_REGISTRY.room(&"AS-06").get("asterionInteractions", []).size() == 1, "Oxygen core must own the Biocircuit installation console.")
	assert(StringName(TRANSITION_ROUTER.resolve(&"AS-06", &"Ne").get("destinationRoom", &"")) == &"AS-07", "Oxygen restoration must route into Command Spine.")
	assert(StringName(TRANSITION_ROUTER.resolve(&"AS-07", &"Ne").get("destinationRoom", &"")) == &"AS-08", "Command Spine must route into Station Control.")
	assert(not (ROOM_REGISTRY.room(&"AS-08").get("bossEncounter", {}) as Dictionary).is_empty(), "Station Control must own the Mother Computer encounter.")
	print("CAMPAIGN_ASTERION_FIRST_ROOMS_SMOKE_OK rooms=AS-01+AS-02+AS-03+AS-13+AS-04+AS-05+AS-06+AS-07+AS-08 handoff=FI-06 oxygen_spine=reciprocal")
	get_tree().quit()
