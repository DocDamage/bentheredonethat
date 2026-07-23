extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

const INTERACTION_PROPERTIES := ["heliosInteractions", "frostholdInteractions", "moonpetalInteractions", "empyrealInteractions"]


func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	var checked := 0
	for room_id in _room_ids_with_universe_interactions():
		var definition := REGISTRY.room(room_id)
		var scene := load(String(definition.get("scenePath", ""))) as PackedScene
		var root := scene.instantiate() as Node2D
		root.configure(room_id, definition)
		add_child(root)
		for property_name in INTERACTION_PROPERTIES:
			for interaction_definition in definition.get(property_name, []):
				var node_name := String(interaction_definition.get("nodeName", ""))
				var interaction := root.get_node_or_null(NodePath("InteractionLayer/%s" % node_name))
				assert(interaction, "%s must own %s." % [room_id, node_name])
				assert(interaction.get("interaction_kind") == interaction_definition.get("kind", &""))
				assert(interaction.position == Vector2((interaction_definition.get("cell", Vector2i.ZERO) as Vector2i) * 48))
				checked += 1
		root.queue_free()
	assert(checked == 16)
	print("CAMPAIGN_UNIVERSE_ROOM_INTERACTIONS_SMOKE_OK interactions=%d ownership=scene_local" % checked)
	get_tree().quit()


func _room_ids_with_universe_interactions() -> Array[StringName]:
	var room_ids: Array[StringName] = []
	for candidate_room_id in REGISTRY.HELIOS_ROOM_IDS + REGISTRY.FROSTHOLD_ROOM_IDS + REGISTRY.MOONPETAL_ROOM_IDS + REGISTRY.EMPYREAL_ROOM_IDS:
		var definition := REGISTRY.room(candidate_room_id)
		for property_name in INTERACTION_PROPERTIES:
			if not (definition.get(property_name, []) as Array).is_empty():
				room_ids.append(candidate_room_id)
				break
	return room_ids
