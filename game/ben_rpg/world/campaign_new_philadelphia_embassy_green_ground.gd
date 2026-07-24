class_name CampaignNewPhiladelphiaEmbassyGreenGround
extends Node2D

const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
var _layout: Dictionary = {}
var _profiles

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = PROFILES.new()

func configure(layout: Dictionary) -> void:
	_layout = layout.duplicate(true)
	queue_redraw()

func _draw() -> void:
	var dimensions: Vector2i = _layout.get("dimensions", Vector2i.ZERO)
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			_draw_profile(&"town_road_tile" if x in [14, 15] or y in [9, 10] else &"town_grass_tile", Vector2(x, y) * 48.0)

func _draw_profile(profile_id: StringName, position: Vector2) -> void:
	if not _profiles or not _profiles.has(profile_id): return
	var texture: Texture2D = _profiles.texture(profile_id)
	if texture: draw_texture_rect_region(texture, Rect2(position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
