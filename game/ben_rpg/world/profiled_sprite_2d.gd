class_name ProfiledSprite2D
extends Sprite2D

## Compatibility bridge for scene-owned sprites while their art is migrated to
## the campaign visual manifest. The scene records only a stable profile ID;
## the texture path remains centralized in the generated manifest.

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

@export var visual_profile: StringName


func _ready() -> void:
	if visual_profile == &"":
		return
	var profiles := VISUAL_PROFILE_REGISTRY.new()
	if not profiles.has(visual_profile):
		push_error("Profiled sprite references missing visual profile: %s" % visual_profile)
		return
	texture = profiles.texture(visual_profile)
