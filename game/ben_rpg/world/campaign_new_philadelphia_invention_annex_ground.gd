class_name CampaignNewPhiladelphiaInventionAnnexGround
extends Node2D

const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _layout: Dictionary = {}
var _profiles
var _textures: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = PROFILES.new()
	for profile_id in [&"laboratory_floor_tile", &"laboratory_wall_tile"]:
		_textures[profile_id] = _profiles.texture(profile_id)


func configure(layout: Dictionary) -> void:
	_layout = layout.duplicate(true)
	queue_redraw()


func _draw() -> void:
	var dimensions: Vector2i = _layout.get("dimensions", Vector2i.ZERO)
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var profile_id: StringName = &"laboratory_wall_tile" if x == 0 or y == 0 or x == dimensions.x - 1 or y == dimensions.y - 1 else &"laboratory_floor_tile"
			var texture: Texture2D = _textures.get(profile_id) as Texture2D
			if texture:
				draw_texture_rect_region(texture, Rect2(Vector2(x, y) * 48.0, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
