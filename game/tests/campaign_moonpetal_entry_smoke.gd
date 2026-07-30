extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")


func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	for room_id in REGISTRY.MOONPETAL_ROOM_IDS:
		var scene := load(String(REGISTRY.room(room_id).get("scenePath", ""))) as PackedScene
		var root := scene.instantiate() as Node2D
		root.configure(room_id, REGISTRY.room(room_id))
		add_child(root)
		assert(root.get_node_or_null("InteractionLayer/ManifestInteraction"))
		root.queue_free()
	assert(StringName(ROUTER.resolve(&"MP-01", &"Ne").get("destinationRoom", &"")) == &"MP-02")
	assert(StringName(ROUTER.resolve(&"MP-02", &"Ne").get("destinationRoom", &"")) == &"MP-03")
	assert(StringName(ROUTER.resolve(&"MP-03", &"Ne").get("destinationRoom", &"")) == &"MP-04")
	assert(StringName(ROUTER.resolve(&"MP-04", &"Ne").get("destinationRoom", &"")) == &"MP-05")
	assert(StringName(ROUTER.resolve(&"MP-05", &"Ne").get("destinationRoom", &"")) == &"MP-06")
	assert(StringName(ROUTER.resolve(&"MP-06", &"Ne").get("destinationRoom", &"")) == &"MP-07")
	assert(StringName(ROUTER.resolve(&"MP-07", &"Ne").get("destinationRoom", &"")) == &"MP-08")
	assert(StringName(ROUTER.resolve(&"MP-09", &"Ne").get("destinationRoom", &"")) == &"MP-13")
	assert(StringName(ROUTER.resolve(&"MP-11", &"Ne").get("destinationRoom", &"")) == &"MP-12")
	assert(StringName(ROUTER.resolve(&"MP-14", &"Ne").get("destinationRoom", &"")) == &"MP-07")
	print("CAMPAIGN_MOONPETAL_ENTRY_SMOKE_OK rooms=14 art=approved_profiles")
	get_tree().quit()
