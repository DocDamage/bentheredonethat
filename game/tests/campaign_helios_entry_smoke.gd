extends Node
const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	for room_id in [&"HE-01", &"HE-02", &"HE-03", &"HE-06", &"HE-07", &"HE-08"]:
		var scene := load(String(REGISTRY.room(room_id).get("scenePath", ""))) as PackedScene
		var root := scene.instantiate() as Node2D; root.configure(room_id, REGISTRY.room(room_id)); add_child(root)
		assert(root.get_node_or_null("InteractionLayer/ManifestInteraction")); root.queue_free()
		assert(root.get_node_or_null("GroundLayer/ApprovedGroundPanel"))
	assert(StringName(ROUTER.resolve(&"HE-01", &"Ne").get("destinationRoom", &"")) == &"HE-02")
	assert(StringName(ROUTER.resolve(&"HE-02", &"Ne").get("destinationRoom", &"")) == &"HE-03")
	assert(StringName(ROUTER.resolve(&"HE-06", &"Ne").get("destinationRoom", &"")) == &"HE-07")
	assert(StringName(ROUTER.resolve(&"HE-07", &"Ne").get("destinationRoom", &"")) == &"HE-08")
	print("CAMPAIGN_HELIOS_ENTRY_SMOKE_OK rooms=HE-01..HE-03+HE-06..HE-08 art=approved_quadrants")
	get_tree().quit()
