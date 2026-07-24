class_name CampaignNewPhiladelphiaEmbassyGreenProps
extends Node2D

const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
var _profiles
var _textures: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = PROFILES.new()
	for profile_id in [&"town_ranch_tree_small", &"town_ranch_tree_tall"]:
		_textures[profile_id] = _profiles.texture(profile_id)

func configure(_layout: Dictionary) -> void:
	queue_redraw()

func _draw() -> void:
	for entry in [[Vector2(4, 5), &"town_ranch_tree_small"], [Vector2(26, 5), &"town_ranch_tree_tall"], [Vector2(4, 15), &"town_ranch_tree_tall"], [Vector2(26, 15), &"town_ranch_tree_small"]]:
		var profile_id: StringName = entry[1]
		if not _profiles or not _profiles.has(profile_id): continue
		var texture: Texture2D = _textures.get(profile_id) as Texture2D
		if texture:
			var size: Vector2 = _profiles.world_draw_size(profile_id)
			draw_texture_rect_region(texture, Rect2(entry[0] * 48.0 - Vector2(size.x * 0.5, size.y * 0.75), size), _profiles.region(profile_id))
