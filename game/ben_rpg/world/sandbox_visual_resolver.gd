class_name SandboxVisualResolver
extends RefCounted

## Resolves sandbox catalog entries through approved visual profiles. Sandbox
## content is part of the runtime visual surface, so it cannot silently fall
## back to raw texture paths and atlas rectangles.

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _profiles


func _profile_id(definition: Dictionary) -> StringName:
	var profile_id := StringName(definition.get("visual_profile", &""))
	if not _profiles:
		_profiles = VISUAL_PROFILE_REGISTRY.new()
	if profile_id == &"" or not _profiles.has(profile_id):
		push_error("Sandbox catalog entry lacks an approved visual profile")
		return &""
	return profile_id


func texture_path(definition: Dictionary) -> String:
	var profile_id := _profile_id(definition)
	return _profiles.texture_path(profile_id) if profile_id != &"" else ""


func texture(definition: Dictionary) -> Texture2D:
	var profile_id := _profile_id(definition)
	return _profiles.texture(profile_id) if profile_id != &"" else null


func region(definition: Dictionary, texture: Texture2D = null) -> Rect2:
	var profile_id := _profile_id(definition)
	return _profiles.region(profile_id) if profile_id != &"" else Rect2()
