class_name CampaignHeliosRoom
extends Node2D

const INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const PROFILE_BY_ROOM := {
	&"HE-01": &"helios_skybridge_quadrant",
	&"HE-02": &"helios_market_quadrant",
	&"HE-03": &"helios_market_quadrant",
	&"HE-04": &"helios_transit_quadrant",
	&"HE-05": &"helios_core_quadrant",
	&"HE-06": &"helios_clinic_quadrant",
	&"HE-07": &"helios_transit_quadrant",
	&"HE-08": &"helios_core_quadrant",
	&"HE-13": &"helios_transit_quadrant",
}

var _size := Vector2i.ZERO
var _profile_id: StringName = &""
var _profiles


func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_size = definition.get("dimensions", Vector2i.ZERO)
	position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * 48)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	_profile_id = PROFILE_BY_ROOM.get(room_id, &"")
	_install_approved_ground()
	INSTALLER.install(self, room_id, definition)
	queue_redraw()


func _install_approved_ground() -> void:
	if _profile_id == &"" or not _profiles or not _profiles.has(_profile_id):
		return
	var ground_layer := get_node_or_null("GroundLayer") as Node2D
	var texture: Texture2D = _profiles.texture(_profile_id)
	if not ground_layer or not texture:
		return
	var panel := Sprite2D.new()
	panel.name = "ApprovedGroundPanel"
	panel.texture = texture
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	panel.region_enabled = true
	panel.region_rect = _profiles.region(_profile_id)
	panel.centered = false
	var panel_size: Vector2 = _profiles.world_draw_size(_profile_id)
	var room_size := Vector2(_size * 48)
	panel.position = Vector2(maxf(0.0, floorf((room_size.x - panel_size.x) * 0.5)), maxf(0.0, floorf((room_size.y - panel_size.y) * 0.5)))
	panel.set_meta(&"visual_profile_id", _profile_id)
	ground_layer.add_child(panel)


func _draw() -> void:
	if _size == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_size * 48))
	draw_rect(bounds, Color("172b3f"), true)
	draw_rect(bounds, Color("79d7ff"), false, 2.0)
