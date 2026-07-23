class_name CampaignHauntedMansionKitchenLift
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _dimensions := Vector2i.ZERO
var _profiles
var _cabinet: Texture2D
var _shelves: Texture2D
var _lift: Texture2D

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
	_cabinet = _profiles.texture(&"mansion_archive_cabinet")
	_shelves = _profiles.texture(&"mansion_archive_shelving")
	_lift = _profiles.texture(&"mansion_foyer_passage_door")
	queue_redraw()

func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(bounds, Color("211b1a"), true)
	draw_rect(Rect2(Vector2(48, 4 * 48), Vector2((_dimensions.x - 2) * 48, (_dimensions.y - 5) * 48)), Color("604330"), true)
	for y in range(4, _dimensions.y - 1):
		draw_line(Vector2(48, y * 48), Vector2((_dimensions.x - 1) * 48, y * 48), Color("38261c"), 2.0)
	_draw_profile(&"mansion_archive_shelving", _shelves, Vector2(48, 48))
	_draw_profile(&"mansion_archive_cabinet", _cabinet, Vector2((_dimensions.x - 5) * 48, 4 * 48))
	_draw_profile(&"mansion_foyer_passage_door", _lift, Vector2((_dimensions.x / 2.0 - 1) * 48, 2 * 48))
	draw_rect(bounds, Color("c29b75"), false, 2.0)

func _draw_profile(profile_id: StringName, texture: Texture2D, draw_position: Vector2) -> void:
	if texture and _profiles and _profiles.has(profile_id):
		draw_texture_rect_region(texture, Rect2(draw_position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
