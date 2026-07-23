extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")


func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	for room_id in REGISTRY.FROSTHOLD_ROOM_IDS:
		var scene := load(String(REGISTRY.room(room_id).get("scenePath", ""))) as PackedScene
		var root := scene.instantiate() as Node2D
		root.configure(room_id, REGISTRY.room(room_id))
		add_child(root)
		assert(root.get_node_or_null("InteractionLayer/ManifestInteraction"))
		root.queue_free()
	assert(StringName(ROUTER.resolve(&"FR-01", &"Ne").get("destinationRoom", &"")) == &"FR-02")
	assert(StringName(ROUTER.resolve(&"FR-02", &"Ne").get("destinationRoom", &"")) == &"FR-03")
	assert(StringName(ROUTER.resolve(&"FR-03", &"Ne").get("destinationRoom", &"")) == &"FR-04")
	assert(StringName(ROUTER.resolve(&"FR-04", &"Ne").get("destinationRoom", &"")) == &"FR-05")
	assert(StringName(ROUTER.resolve(&"FR-05", &"Ne").get("destinationRoom", &"")) == &"FR-06")
	assert(StringName(ROUTER.resolve(&"FR-06", &"Ne").get("destinationRoom", &"")) == &"FR-07")
	assert(StringName(ROUTER.resolve(&"FR-07", &"Ne").get("destinationRoom", &"")) == &"FR-08")
	assert(StringName(ROUTER.resolve(&"FR-10", &"Ne").get("destinationRoom", &"")) == &"FR-11")
	assert(StringName(ROUTER.resolve(&"FR-11", &"Ne").get("destinationRoom", &"")) == &"FR-06")
	assert(StringName(ROUTER.resolve(&"FR-14", &"E1").get("destinationRoom", &"")) == &"FR-08")
	print("CAMPAIGN_FROSTHOLD_ENTRY_SMOKE_OK rooms=14 art=approved_profiles")
	get_tree().quit()
