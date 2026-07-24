class_name CampaignNewPhiladelphiaInventionAnnexProps
extends Node2D

const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const PLACEMENTS := [[Vector2i(4, 6), &"laboratory_west_terminal"], [Vector2i(20, 6), &"laboratory_east_reactor"], [Vector2i(4, 11), &"laboratory_east_generator"], [Vector2i(20, 11), &"laboratory_center_storage"], [Vector2i(12, 8), &"laboratory_east_fabricator"]]

var _profiles
var _textures: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = PROFILES.new()
	for placement in PLACEMENTS:
		var profile_id: StringName = placement[1]
		_textures[profile_id] = _profiles.texture(profile_id)


func configure(_layout: Dictionary) -> void:
	queue_redraw()


func _draw() -> void:
	for placement in PLACEMENTS:
		var cell: Vector2i = placement[0]
		var profile_id: StringName = placement[1]
		var texture: Texture2D = _textures.get(profile_id) as Texture2D
		if not texture:
			continue
		var size: Vector2 = _profiles.world_draw_size(profile_id)
		draw_texture_rect_region(texture, Rect2(Vector2(cell) * 48.0 - Vector2(size.x * 0.5, size.y * 0.75), size), _profiles.region(profile_id))
