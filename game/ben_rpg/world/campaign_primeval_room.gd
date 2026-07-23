class_name CampaignPrimevalRoom
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")

var _dimensions := Vector2i.ZERO

func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * 48)
	FEATURE_INSTALLER.install(self, room_id, definition)
	queue_redraw()

func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(bounds, Color("102e27"), true)
	draw_rect(Rect2(Vector2(48, 48), Vector2((_dimensions.x - 2) * 48, (_dimensions.y - 2) * 48)), Color("4a703f"), true)
	for x in range(2, _dimensions.x - 1, 3):
		draw_circle(Vector2(x * 48, 3 * 48), 22.0, Color("28603c"))
	draw_rect(bounds, Color("9fca65"), false, 2.0)
