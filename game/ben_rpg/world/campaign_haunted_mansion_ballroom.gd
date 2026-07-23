class_name CampaignHauntedMansionBallroom
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _dimensions := Vector2i.ZERO
var _profiles
var _chandelier: Texture2D
var _door_frame: Texture2D
var _mirror: Texture2D

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
	_chandelier = _profiles.texture(&"mansion_ballroom_chandelier")
	_door_frame = _profiles.texture(&"mansion_ballroom_door_frame")
	_mirror = _profiles.texture(&"clock_mirror_battle_actor")
	queue_redraw()

func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(bounds, Color("190f1b"), true)
	draw_rect(Rect2(Vector2(48, 4 * 48), Vector2((_dimensions.x - 2) * 48, (_dimensions.y - 5) * 48)), Color("542e3a"), true)
	for x in range(2, _dimensions.x - 1, 3):
		draw_line(Vector2(x * 48, 4 * 48), Vector2(x * 48, (_dimensions.y - 1) * 48), Color("2b1728"), 3.0)
	_draw_profile(&"mansion_ballroom_chandelier", _chandelier, Vector2((_dimensions.x / 2.0 - 2) * 48, 2 * 48))
	_draw_profile(&"mansion_ballroom_door_frame", _door_frame, Vector2(48, 48))
	_draw_profile(&"clock_mirror_battle_actor", _mirror, Vector2((_dimensions.x / 2.0 - 1) * 48, 7 * 48))
	draw_rect(bounds, Color("d8a0ae"), false, 2.0)

func _draw_profile(profile_id: StringName, texture: Texture2D, draw_position: Vector2) -> void:
	if texture and _profiles and _profiles.has(profile_id):
		draw_texture_rect_region(texture, Rect2(draw_position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
