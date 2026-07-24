class_name CampaignAshfallCinderGateProps
extends Node2D

const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _layout: Dictionary = {}
var _profiles
var _textures: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILES.new()
	queue_redraw()


func configure(layout: Dictionary) -> void:
	_layout = layout.duplicate(true)
	queue_redraw()


func _draw() -> void:
	if not _profiles:
		return
	for placement in _layout.get("propPlacements", []):
		var profile_id := StringName(placement.get("profileId", &""))
		if profile_id == &"" or not _profiles.has(profile_id):
			continue
		var texture := _texture(profile_id)
		if not texture:
			continue
		var source: Rect2 = _profiles.region(profile_id)
		var draw_size: Vector2 = _profiles.world_draw_size(profile_id)
		var draw_position: Vector2i = placement.get("drawPosition", Vector2i.ZERO)
		draw_texture_rect_region(texture, Rect2(Vector2(draw_position), draw_size), source)


func _texture(profile_id: StringName) -> Texture2D:
	if _textures.has(profile_id):
		return _textures[profile_id] as Texture2D
	var texture: Texture2D = _profiles.texture(profile_id)
	if texture:
		_textures[profile_id] = texture
	return texture
