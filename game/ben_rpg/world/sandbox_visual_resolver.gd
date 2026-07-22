class_name SandboxVisualResolver
extends RefCounted

## Resolves sandbox catalog entries through approved visual profiles while
## retaining a checked fallback for catalog entries still awaiting migration.

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _profiles


func texture_path(definition: Dictionary) -> String:
	var profile_id := StringName(definition.get("visual_profile", &""))
	if profile_id != &"":
		if not _profiles:
			_profiles = VISUAL_PROFILE_REGISTRY.new()
		if _profiles.has(profile_id):
			return _profiles.texture_path(profile_id)
	return String(definition.get("texture", ""))


func texture(definition: Dictionary) -> Texture2D:
	var profile_id := StringName(definition.get("visual_profile", &""))
	if profile_id != &"":
		if not _profiles:
			_profiles = VISUAL_PROFILE_REGISTRY.new()
		if _profiles.has(profile_id):
			return _profiles.texture(profile_id)
	var path := texture_path(definition)
	return load(path) as Texture2D if ResourceLoader.exists(path) else null


func region(definition: Dictionary, texture: Texture2D = null) -> Rect2:
	var profile_id := StringName(definition.get("visual_profile", &""))
	if profile_id != &"":
		if not _profiles:
			_profiles = VISUAL_PROFILE_REGISTRY.new()
		if _profiles.has(profile_id):
			return _profiles.region(profile_id)
	return definition.get("region", Rect2(Vector2.ZERO, texture.get_size() if texture else Vector2.ZERO))
