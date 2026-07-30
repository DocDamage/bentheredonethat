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
	&"HE-09": &"helios_transit_quadrant",
	&"HE-10": &"helios_skybridge_quadrant",
	&"HE-11": &"helios_market_quadrant",
	&"HE-12": &"helios_clinic_quadrant",
	&"HE-13": &"helios_transit_quadrant",
	&"HE-14": &"helios_transit_quadrant",
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
	var panel_size: Vector2 = _profiles.world_draw_size(_profile_id)
	var room_size := Vector2(_size * 48)
	var pair_width := panel_size.x * 2.0
	for index in range(2):
		var panel := Sprite2D.new()
		panel.name = "ApprovedGroundPanel" if index == 0 else "ApprovedGroundPanel_2"
		panel.texture = texture
		panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		panel.region_enabled = true
		panel.region_rect = _profiles.region(_profile_id)
		panel.centered = false
		panel.flip_h = false
		panel.position = Vector2(floorf((room_size.x - pair_width) * 0.5 + index * panel_size.x), minf(3.0 * 48.0, floorf((room_size.y - panel_size.y) * 0.5)))
		panel.set_meta(&"visual_profile_id", _profile_id)
		ground_layer.add_child(panel)


func _draw() -> void:
	if _size == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_size * 48))
	draw_rect(Rect2(Vector2(-8 * 48, -8 * 48), Vector2((_size.x + 16) * 48, (_size.y + 16) * 48)), Color("071422"), true)
	draw_rect(bounds, Color("172b3f"), true)
	for y in range(48, int(bounds.size.y), 96):
		draw_line(Vector2(0, y), Vector2(bounds.size.x, y), Color(0.19, 0.45, 0.62, 0.28), 2.0)
	for x in range(48, int(bounds.size.x), 96):
		draw_line(Vector2(x, 0), Vector2(x, bounds.size.y), Color(0.12, 0.35, 0.52, 0.22), 2.0)
	var transit_lane := Rect2(Vector2(2 * 48, bounds.size.y * 0.46), Vector2(bounds.size.x - 4 * 48, 2 * 48))
	draw_rect(transit_lane, Color(0.04, 0.14, 0.22, 0.72), true)
	draw_rect(transit_lane, Color("56c9ef"), false, 3.0)
	draw_rect(bounds, Color("79d7ff"), false, 2.0)
