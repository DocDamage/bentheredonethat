class_name CampaignHauntedMansionRainGate
extends Node2D

## First real authored Mansion scene. It owns its bounded forecourt composition
## and installs room-scoped features from its manifest; it does not draw through
## CampaignMapVisual. The active campaign still uses the compatibility adapter
## until the FI-05 entry, collision, and interaction parity handoff is complete.

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")

var _dimensions := Vector2i.ZERO


func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	var world_origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	position = Vector2(world_origin * 48)
	var navigation_layer := get_node_or_null("NavigationAndCollision") as Node2D
	if navigation_layer:
		navigation_layer.set_meta(&"navigation_id", definition.get("navigationId", &""))
		navigation_layer.set_meta(&"collision_mask_id", definition.get("collisionMaskId", &""))
		navigation_layer.set_meta(&"navigation_layout", definition.get("navigationLayout", {}))
	FEATURE_INSTALLER.install(self, room_id, definition)
	for layer_name in [&"GroundLayer", &"LowDecorationLayer", &"ForegroundLayer"]:
		var layer := get_node_or_null(NodePath(layer_name))
		if layer and layer.has_method(&"configure"):
			layer.call(&"configure", _dimensions)
