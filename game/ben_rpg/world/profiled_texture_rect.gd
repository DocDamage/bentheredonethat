class_name ProfiledTextureRect
extends TextureRect

## TextureRect counterpart to ProfiledSprite2D for legacy battle backdrops.

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

@export var visual_profile: StringName


func _ready() -> void:
	if visual_profile == &"":
		return
	var profiles := VISUAL_PROFILE_REGISTRY.new()
	if not profiles.has(visual_profile):
		push_error("Profiled texture rect references missing visual profile: %s" % visual_profile)
		return
	texture = profiles.texture(visual_profile)
