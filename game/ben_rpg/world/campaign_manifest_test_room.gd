class_name CampaignManifestTestRoom
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")

var _dimensions := Vector2i.ZERO


func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	FEATURE_INSTALLER.install(self, room_id, definition)
	queue_redraw()


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(bounds, Color("2b2434"), true)
	draw_rect(bounds, Color("b59bb7"), false, 2.0)
