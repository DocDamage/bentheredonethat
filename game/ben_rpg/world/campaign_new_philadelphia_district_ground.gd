class_name CampaignNewPhiladelphiaDistrictGround
extends Node2D

const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _layout: Dictionary = {}
var _profiles
var _textures: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = PROFILES.new()


func configure(layout: Dictionary) -> void:
	_layout = layout.duplicate(true)
	for profile_id in _layout.get("terrainProfileIds", []) as Array:
		_textures[profile_id] = _profiles.texture(profile_id)
	queue_redraw()


func _draw() -> void:
	var dimensions: Vector2i = _layout.get("dimensions", Vector2i.ZERO)
	var terrain: Array = _layout.get("terrainProfileIds", [])
	if terrain.is_empty():
		return
	var base_id := StringName(terrain[0])
	var road_id := StringName(terrain[1]) if terrain.size() > 1 else base_id
	var lot_id := StringName(terrain[2]) if terrain.size() > 2 else base_id
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var profile_id := road_id if x in [int(dimensions.x / 2), int(dimensions.x / 2) - 1] or y in [int(dimensions.y / 2), int(dimensions.y / 2) - 1] else base_id
			if terrain.size() > 2 and ((x >= 3 and x < 12 and y >= 3 and y < 9) or (x >= dimensions.x - 12 and x < dimensions.x - 3 and y >= 3 and y < 9)):
				profile_id = lot_id
			_draw_profile(profile_id, Vector2(x, y) * 48.0)


func _draw_profile(profile_id: StringName, position: Vector2) -> void:
	var texture: Texture2D = _textures.get(profile_id) as Texture2D
	if texture:
		draw_texture_rect_region(texture, Rect2(position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
