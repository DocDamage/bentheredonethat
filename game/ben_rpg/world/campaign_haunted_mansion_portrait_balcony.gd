class_name CampaignHauntedMansionPortraitBalcony
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const MANSION_ROOM_ART := preload("res://ben_rpg/world/campaign_mansion_room_art.gd")

var _dimensions := Vector2i.ZERO
var _profiles
var _left_portrait: Texture2D
var _right_portrait: Texture2D
var _curtain: Texture2D


func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * 48)
	var navigation_layer := get_node_or_null("NavigationAndCollision") as Node2D
	if navigation_layer:
		navigation_layer.set_meta(&"navigation_id", definition.get("navigationId", &""))
		navigation_layer.set_meta(&"collision_mask_id", definition.get("collisionMaskId", &""))
		navigation_layer.set_meta(&"navigation_layout", definition.get("navigationLayout", {}))
	FEATURE_INSTALLER.install(self, room_id, definition)
	queue_redraw()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	_left_portrait = _profiles.texture(&"mansion_gallery_left_portrait")
	_right_portrait = _profiles.texture(&"mansion_gallery_right_portrait")
	_curtain = _profiles.texture(&"mansion_gallery_stage_curtain")
	queue_redraw()


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(bounds, Color("1a1320"), true)
	draw_rect(Rect2(Vector2(48, 4 * 48), Vector2((_dimensions.x - 2) * 48, 7 * 48)), Color("4a3037"), true)
	for x in range(2, _dimensions.x - 1, 2):
		draw_line(Vector2(x * 48, 4 * 48), Vector2(x * 48, 11 * 48), Color("2d1c27"), 3.0)
	draw_line(Vector2(48, 8 * 48), Vector2((_dimensions.x - 1) * 48, 8 * 48), Color("bd9690"), 5.0)
	MANSION_ROOM_ART.draw_interior(self, _dimensions, _profiles)
	_draw_profile(&"mansion_gallery_left_portrait", _left_portrait, Vector2(3 * 48, 3 * 48))
	_draw_profile(&"mansion_gallery_right_portrait", _right_portrait, Vector2((_dimensions.x - 6) * 48, 3 * 48))
	_draw_profile(&"mansion_gallery_stage_curtain", _curtain, Vector2((_dimensions.x / 2.0 - 2.0) * 48, 2 * 48))
	draw_rect(bounds, Color("bf99a2"), false, 2.0)


func _draw_profile(profile_id: StringName, texture: Texture2D, draw_position: Vector2) -> void:
	if texture and _profiles and _profiles.has(profile_id):
		draw_texture_rect_region(texture, Rect2(draw_position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
