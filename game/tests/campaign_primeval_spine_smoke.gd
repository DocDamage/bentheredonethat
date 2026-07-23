extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const SCENES := {
	&"PV-01": preload("res://ben_rpg/world/rooms/primeval_thunderfern_grove.tscn"), &"PV-02": preload("res://ben_rpg/world/rooms/primeval_stone_signal_crossing.tscn"), &"PV-03": preload("res://ben_rpg/world/rooms/primeval_borough.tscn"),
	&"PV-04": preload("res://ben_rpg/world/rooms/primeval_canopy_causeway.tscn"), &"PV-05": preload("res://ben_rpg/world/rooms/primeval_jungle_ruins_court.tscn"), &"PV-06": preload("res://ben_rpg/world/rooms/primeval_cave_computer_vault.tscn"),
	&"PV-07": preload("res://ben_rpg/world/rooms/primeval_relay_nest.tscn"), &"PV-08": preload("res://ben_rpg/world/rooms/primeval_caldera_crown.tscn"), &"PV-14": preload("res://ben_rpg/world/rooms/primeval_lava_tube_bypass.tscn"),
	&"PV-09": preload("res://ben_rpg/world/rooms/primeval_luminous_fungal_hollow.tscn"), &"PV-10": preload("res://ben_rpg/world/rooms/primeval_fossil_survey_quarry.tscn"), &"PV-11": preload("res://ben_rpg/world/rooms/primeval_raptor_nursery.tscn"), &"PV-12": preload("res://ben_rpg/world/rooms/primeval_storm_dragon_roost.tscn"), &"PV-13": preload("res://ben_rpg/world/rooms/primeval_river_switchbacks.tscn"),
}

func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	for room_id in SCENES:
		var root := (SCENES[room_id] as PackedScene).instantiate() as Node2D
		root.configure(room_id, REGISTRY.room(room_id)); add_child(root)
		assert(root.get_node_or_null("InteractionLayer/ManifestInteraction"))
		root.queue_free()
	assert(StringName(ROUTER.resolve(&"PV-03", &"Ne").get("destinationRoom", &"")) == &"PV-04")
	assert(StringName(ROUTER.resolve(&"PV-04", &"Ne").get("destinationRoom", &"")) == &"PV-05")
	assert(StringName(ROUTER.resolve(&"PV-05", &"Ne").get("destinationRoom", &"")) == &"PV-06")
	assert(REGISTRY.room(&"PV-06").get("primevalInteractions", []).size() == 1)
	assert(StringName(ROUTER.resolve(&"PV-03", &"E1").get("destinationRoom", &"")) == &"PV-07")
	assert(StringName(ROUTER.resolve(&"PV-07", &"Ne").get("destinationRoom", &"")) == &"PV-08")
	assert(REGISTRY.room(&"PV-07").get("primevalInteractions", []).size() == 2)
	assert(not (REGISTRY.room(&"PV-08").get("bossEncounter", {}) as Dictionary).is_empty())
	assert(REGISTRY.streamed_room_ids().filter(func(room_id): return String(room_id).begins_with("PV-")).size() == 14)
	print("CAMPAIGN_PRIMEVAL_SPINE_SMOKE_OK rooms=PV-01..PV-14 relay=room_owned")
	get_tree().quit()
