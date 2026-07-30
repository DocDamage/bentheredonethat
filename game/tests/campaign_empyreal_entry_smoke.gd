extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")


func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	for room_id in REGISTRY.EMPYREAL_ROOM_IDS:
		var scene := load(String(REGISTRY.room(room_id).get("scenePath", ""))) as PackedScene
		var root := scene.instantiate() as Node2D
		root.configure(room_id, REGISTRY.room(room_id))
		add_child(root)
		assert(root.get_node_or_null("InteractionLayer/ManifestInteraction"))
		root.queue_free()
	for source_id in [&"EM-01", &"EM-02", &"EM-03", &"EM-04", &"EM-05", &"EM-06", &"EM-07", &"EM-08"]:
		assert(not ROUTER.resolve(source_id, &"Ne").is_empty())
	assert(StringName(ROUTER.resolve(&"EM-08", &"Ne").get("destinationRoom", &"")) == &"EM-09")
	assert(StringName(ROUTER.resolve(&"EM-10", &"Ne").get("destinationRoom", &"")) == &"EM-03")
	assert(StringName(ROUTER.resolve(&"EM-15", &"E2").get("destinationRoom", &"")) == &"EM-11")
	assert(StringName(ROUTER.resolve(&"EM-16", &"Ne").get("destinationRoom", &"")) == &"EM-09")
	print("CAMPAIGN_EMPYREAL_ENTRY_SMOKE_OK rooms=16 art=approved_profiles")
	get_tree().quit()
