class_name CampaignVisualProfileRegistry
extends RefCounted

## Runtime access point for reviewed visual metadata.  Renderers can ask for an
## approved profile by stable id instead of duplicating an atlas rectangle.  The
## manifest is generated and checksum-validated before it is consumed here.

const MANIFEST_PATH := "res://ben_rpg/visual_assets/generated/runtime_visual_manifest.json"

var _profiles: Dictionary = {}


func _init(manifest_path := MANIFEST_PATH) -> void:
	var raw := FileAccess.get_file_as_string(manifest_path)
	if raw.is_empty():
		push_error("Visual profile manifest is unavailable: %s" % manifest_path)
		return
	var parsed = JSON.parse_string(raw)
	if not parsed is Dictionary:
		push_error("Visual profile manifest is invalid: %s" % manifest_path)
		return
	for profile in parsed.get("profiles", []):
		if profile is Dictionary and profile.get("id", "") is String:
			_profiles[profile.id] = profile


func has(profile_id: StringName) -> bool:
	return _profiles.has(String(profile_id))


func profile_count() -> int:
	return _profiles.size()


func get_profile(profile_id: StringName) -> Dictionary:
	return _profiles.get(String(profile_id), {}) as Dictionary


func region(profile_id: StringName) -> Rect2:
	var profile := get_profile(profile_id)
	var source: Dictionary = profile.get("source", {})
	var values: Array = source.get("region", [])
	if values.size() != 4:
		push_error("Visual profile %s has no source region" % profile_id)
		return Rect2()
	return Rect2(Vector2(values[0], values[1]), Vector2(values[2], values[3]))


func texture_path(profile_id: StringName) -> String:
	var profile := get_profile(profile_id)
	var source: Dictionary = profile.get("source", {})
	var workspace_path := String(source.get("runtimeTexture", ""))
	# The generated manifest deliberately records repository-relative paths so
	# the build tools can verify them. Godot resources live beneath game/, whose
	# contents are exposed as res:// at runtime.
	if workspace_path.begins_with("game/"):
		workspace_path = workspace_path.trim_prefix("game/")
	if workspace_path.is_empty():
		push_error("Visual profile %s has no runtime texture" % profile_id)
		return ""
	return "res://%s" % workspace_path


func texture(profile_id: StringName) -> Texture2D:
	var path := texture_path(profile_id)
	if path.is_empty() or not ResourceLoader.exists(path):
		push_error("Visual profile %s resolves to a missing texture: %s" % [profile_id, path])
		return null
	return load(path) as Texture2D


func world_draw_size(profile_id: StringName) -> Vector2:
	var profile := get_profile(profile_id)
	var values: Array = profile.get("worldDrawSize", [])
	if values.size() != 2:
		push_error("Visual profile %s has no world draw size" % profile_id)
		return Vector2.ZERO
	return Vector2(values[0], values[1])


func doorway(profile_id: StringName) -> Vector2:
	var profile := get_profile(profile_id)
	var placement: Dictionary = profile.get("placement", {})
	var values: Array = placement.get("doorway", [])
	if values.size() != 2:
		return Vector2.ZERO
	return Vector2(values[0], values[1])
