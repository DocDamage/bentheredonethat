class_name CampaignPopulationVisualRegistry
extends RefCounted

const PROFILE_PATH := "res://ben_rpg/population/generated/population_visual_profiles.json"

static var _profiles: Dictionary = {}
static var _texture_path := ""
static var _atlas_checksum := ""
static var _texture: Texture2D


static func profile(profile_id: StringName) -> Dictionary:
	_ensure_loaded()
	return (_profiles.get(profile_id, {}) as Dictionary).duplicate(true)


static func has(profile_id: StringName) -> bool:
	_ensure_loaded()
	return _profiles.has(profile_id)


static func texture() -> Texture2D:
	_ensure_loaded()
	if _texture:
		return _texture
	if ResourceLoader.exists(_texture_path):
		_texture = load(_texture_path) as Texture2D
	else:
		var image := Image.load_from_file(ProjectSettings.globalize_path(_texture_path))
		if image:
			_texture = ImageTexture.create_from_image(image)
	return _texture


static func validate() -> PackedStringArray:
	_ensure_loaded()
	var errors: Array[String] = []
	if _profiles.size() != 258:
		errors.append("Population visual registry must expose exactly 258 profiles.")
	if _texture_path.is_empty() or _atlas_checksum.length() != 64 or not texture():
		errors.append("Population field atlas is unavailable or has no checksum contract.")
	for profile_id in _profiles:
		var record: Dictionary = _profiles[profile_id]
		if (record.get("directions", {}) as Dictionary).size() != 8:
			errors.append("Population profile %s does not expose eight directions." % profile_id)
		if String(record.get("fieldScaleStatus", "")) != "approved" or String(record.get("provenanceStatus", "")) != "distribution_confirmed":
			errors.append("Population profile %s is not production-approved." % profile_id)
	return PackedStringArray(errors)


static func _ensure_loaded() -> void:
	if not _profiles.is_empty():
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PROFILE_PATH))
	if not parsed is Dictionary:
		return
	var atlas: Dictionary = parsed.get("atlas", {})
	_texture_path = String(atlas.get("runtimeTexture", ""))
	_atlas_checksum = String(atlas.get("sha256", ""))
	for raw_profile in parsed.get("profiles", []):
		if raw_profile is Dictionary:
			var profile_id := StringName(raw_profile.get("id", &""))
			if profile_id != &"":
				_profiles[profile_id] = raw_profile
