extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const SCENES := {
	&"PV-01": preload("res://ben_rpg/world/rooms/primeval_thunderfern_grove.tscn"), &"PV-02": preload("res://ben_rpg/world/rooms/primeval_stone_signal_crossing.tscn"), &"PV-03": preload("res://ben_rpg/world/rooms/primeval_borough.tscn"),
	&"PV-04": preload("res://ben_rpg/world/rooms/primeval_canopy_causeway.tscn"), &"PV-05": preload("res://ben_rpg/world/rooms/primeval_jungle_ruins_court.tscn"), &"PV-06": preload("res://ben_rpg/world/rooms/primeval_cave_computer_vault.tscn"),
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
	print("CAMPAIGN_PRIMEVAL_SPINE_SMOKE_OK rooms=PV-01..PV-06 terminal=room_owned")
	get_tree().quit()
