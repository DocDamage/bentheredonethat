extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")


func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	for room_id in [&"EM-01", &"EM-02", &"EM-03", &"EM-04", &"EM-05", &"EM-06", &"EM-07", &"EM-08", &"EM-09"]:
		var scene := load(String(REGISTRY.room(room_id).get("scenePath", ""))) as PackedScene
		var root := scene.instantiate() as Node2D
		root.configure(room_id, REGISTRY.room(room_id))
		add_child(root)
		assert(root.get_node_or_null("InteractionLayer/ManifestInteraction"))
		root.queue_free()
	for source_id in [&"EM-01", &"EM-02", &"EM-03", &"EM-04", &"EM-05", &"EM-06", &"EM-07", &"EM-08"]:
		assert(not ROUTER.resolve(source_id, &"Ne").is_empty())
	assert(StringName(ROUTER.resolve(&"EM-08", &"Ne").get("destinationRoom", &"")) == &"EM-09")
	print("CAMPAIGN_EMPYREAL_ENTRY_SMOKE_OK rooms=EM-01..EM-09 art=approved_profiles")
	get_tree().quit()
