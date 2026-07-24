class_name CampaignNewPhiladelphiaDistrictProps
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
	for profile_id in _layout.get("propProfileIds", []) as Array:
		_textures[profile_id] = _profiles.texture(profile_id)
	queue_redraw()


func _draw() -> void:
	var props: Array = _layout.get("propProfileIds", [])
	if props.is_empty():
		return
	var dimensions: Vector2i = _layout.get("dimensions", Vector2i.ZERO)
	for index in props.size():
		var profile_id := StringName(props[index])
		var cell := Vector2i(5 + index * 7, 7) if index < 2 else Vector2i(4 + index * 5, dimensions.y - 4)
		_draw_profile(profile_id, cell)


func _draw_profile(profile_id: StringName, cell: Vector2i) -> void:
	var texture: Texture2D = _textures.get(profile_id) as Texture2D
	if not texture:
		return
	var size: Vector2 = _profiles.world_draw_size(profile_id)
	draw_texture_rect_region(texture, Rect2(Vector2(cell) * 48.0 - Vector2(size.x * 0.5, size.y), size), _profiles.region(profile_id))
