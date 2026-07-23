class_name CampaignHeliosRoom
extends Node2D
const INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
var _size := Vector2i.ZERO
func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id; set_meta(&"room_id", room_id); _size = definition.get("dimensions", Vector2i.ZERO); position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * 48); INSTALLER.install(self, room_id, definition); queue_redraw()
func _draw() -> void:
	if _size == Vector2i.ZERO: return
	var bounds := Rect2(Vector2.ZERO, Vector2(_size * 48)); draw_rect(bounds, Color("17112d"), true); draw_rect(Rect2(Vector2(48,48), Vector2((_size.x-2)*48,(_size.y-2)*48)), Color("3a235c"), true); draw_rect(bounds, Color("ff5fc5"), false, 2.0)
