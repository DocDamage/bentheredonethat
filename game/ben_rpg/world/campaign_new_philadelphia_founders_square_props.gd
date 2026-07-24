class_name CampaignNewPhiladelphiaFoundersSquareProps
extends Node2D
const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
var _profiles
var _texture: Texture2D
func _ready() -> void: _profiles = PROFILES.new(); _texture = _profiles.texture(&"town_foundation_stone_tile")
func configure(_layout: Dictionary) -> void: queue_redraw()
func _draw() -> void:
	if _texture: draw_texture_rect_region(_texture, Rect2(Vector2(16, 11) * 48.0, _profiles.world_draw_size(&"town_foundation_stone_tile")), _profiles.region(&"town_foundation_stone_tile"))
