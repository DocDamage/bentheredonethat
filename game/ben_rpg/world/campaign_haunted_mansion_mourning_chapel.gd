class_name CampaignHauntedMansionMourningChapel
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
var _dimensions := Vector2i.ZERO
var _profiles
var _curtain: Texture2D
var _left_frame: Texture2D
var _right_frame: Texture2D

func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * 48)
	FEATURE_INSTALLER.install(self, room_id, definition)
	queue_redraw()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	_curtain = _profiles.texture(&"mansion_gallery_stage_curtain")
	_left_frame = _profiles.texture(&"mansion_gallery_upper_left_frame")
	_right_frame = _profiles.texture(&"mansion_gallery_upper_right_frame")
	queue_redraw()

func _draw() -> void:
	if _dimensions == Vector2i.ZERO: return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(bounds, Color("17131e"), true)
	draw_rect(Rect2(Vector2(48, 3 * 48), Vector2((_dimensions.x - 2) * 48, (_dimensions.y - 4) * 48)), Color("3b3048"), true)
	draw_line(Vector2(_dimensions.x * 24, 3 * 48), Vector2(_dimensions.x * 24, (_dimensions.y - 1) * 48), Color("b8a0d0"), 3.0)
	_draw_profile(&"mansion_gallery_stage_curtain", _curtain, Vector2((_dimensions.x / 2.0 - 2) * 48, 2 * 48))
	_draw_profile(&"mansion_gallery_upper_left_frame", _left_frame, Vector2(3 * 48, 3 * 48))
	_draw_profile(&"mansion_gallery_upper_right_frame", _right_frame, Vector2((_dimensions.x - 7) * 48, 3 * 48))
	draw_rect(bounds, Color("c9b4db"), false, 2.0)

func _draw_profile(profile_id: StringName, texture: Texture2D, draw_position: Vector2) -> void:
	if texture and _profiles and _profiles.has(profile_id):
		draw_texture_rect_region(texture, Rect2(draw_position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
