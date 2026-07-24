class_name CampaignNewPhiladelphiaFoundersSquareGround
extends Node2D
const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
var _layout: Dictionary = {}
var _profiles
var _textures := {}
func _ready() -> void:
	_profiles = PROFILES.new()
	for id in [&"sandbox_modern_grass", &"sandbox_modern_cobble"]: _textures[id] = _profiles.texture(id)
func configure(layout: Dictionary) -> void: _layout = layout.duplicate(true); queue_redraw()
func _draw() -> void:
	var d: Vector2i = _layout.get("dimensions", Vector2i.ZERO)
	for y in range(d.y):
		for x in range(d.x):
			var id: StringName = &"sandbox_modern_cobble" if x in [15, 16] or y in [10, 11] else &"sandbox_modern_grass"
			var t: Texture2D = _textures.get(id) as Texture2D
			if t: draw_texture_rect_region(t, Rect2(Vector2(x, y) * 48.0, _profiles.world_draw_size(id)), _profiles.region(id))
