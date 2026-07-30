extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	var room_ids: Array = []
	room_ids.append_array(REGISTRY.MANSION_ROOM_IDS)
	room_ids.append_array(REGISTRY.ASTERION_ROOM_IDS)
	room_ids.append_array(REGISTRY.PRIMEVAL_ROOM_IDS)
	room_ids.append_array(REGISTRY.HELIOS_ROOM_IDS)
	room_ids.append_array(REGISTRY.FROSTHOLD_ROOM_IDS)
	room_ids.append_array(REGISTRY.MOONPETAL_ROOM_IDS)
	room_ids.append_array(REGISTRY.EMPYREAL_ROOM_IDS)
	for room_id in room_ids:
		var definition := REGISTRY.room(room_id)
		var scene_path := String(definition.get("scenePath", ""))
		assert(not scene_path.is_empty(), "%s must resolve to an authored room scene." % room_id)
		assert(ResourceLoader.exists(scene_path), "%s scene path must exist: %s" % [room_id, scene_path])
		var scene := load(scene_path) as PackedScene
		assert(scene, "%s scene must load." % room_id)
		var root := scene.instantiate() as Node2D
		assert(root and root.has_method("configure"), "%s scene must expose the room configuration contract." % room_id)
		root.configure(room_id, definition)
		add_child(root)
		assert(root.get_node_or_null("GroundLayer"), "%s must own its ground layer." % room_id)
		assert(root.get_node_or_null("YSortedActorsAndProps"), "%s must own its actor layer." % room_id)
		assert(root.get_node_or_null("InteractionLayer/ManifestInteraction"), "%s must own its manifest interactions." % room_id)
		root.queue_free()
	print("CAMPAIGN_MANIFEST_SCENE_COVERAGE_SMOKE_OK rooms=%d manifests=scene_backed" % room_ids.size())
	get_tree().quit()
