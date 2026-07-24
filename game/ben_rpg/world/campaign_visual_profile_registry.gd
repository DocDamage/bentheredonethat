class_name CampaignVisualProfileRegistry
extends RefCounted

## Runtime access point for reviewed visual metadata.  Renderers can ask for an
## approved profile by stable id instead of duplicating an atlas rectangle.  The
## manifest is generated and checksum-validated before it is consumed here.

const MANIFEST_PATH := "res://ben_rpg/visual_assets/generated/runtime_visual_manifest.json"
const FIELD_SCALE := preload("res://ben_rpg/world/campaign_field_scale.gd")

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


func profile_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for profile_id in _profiles:
		ids.append(StringName(profile_id))
	ids.sort()
	return ids


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
	if path.is_empty():
		push_error("Visual profile %s has no runtime texture path." % profile_id)
		return null
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	# Deterministic derived PNGs can be present before Godot has generated an
	# import sidecar in an isolated validation project. The profile remains the
	# only asset authority; this fallback merely turns its existing file into an
	# in-memory nearest-neighbor texture.
	var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
	if image:
		return ImageTexture.create_from_image(image)
	push_error("Visual profile %s resolves to a missing texture: %s" % [profile_id, path])
	return null


func world_draw_size(profile_id: StringName) -> Vector2:
	var profile := get_profile(profile_id)
	var values: Array = profile.get("worldDrawSize", [])
	if values.size() != 2:
		push_error("Visual profile %s has no world draw size" % profile_id)
		return Vector2.ZERO
	return Vector2(values[0], values[1])


func render_scale(profile_id: StringName) -> float:
	var profile := get_profile(profile_id)
	return float(profile.get("renderScale", 0.0))


func render_scale_vector(profile_id: StringName) -> Vector2:
	var profile := get_profile(profile_id)
	return Vector2(float(profile.get("renderScale", 0.0)), float(profile.get("renderScaleY", profile.get("renderScale", 0.0))))


func has_legacy_scale_exception(profile_id: StringName) -> bool:
	var profile := get_profile(profile_id)
	return not String(profile.get("legacyScaleException", "")).is_empty()


func field_scale_status(profile_id: StringName) -> StringName:
	var profile := get_profile(profile_id)
	return StringName(profile.get("fieldScaleStatus", &""))


func field_scale_contract_valid(profile_id: StringName) -> bool:
	var profile := get_profile(profile_id)
	if profile.is_empty():
		return false
	var surface := String(profile.get("surface", "field"))
	if surface != "field":
		return true
	return field_scale_status(profile_id) in [&"approved", &"legacy_exception", &"prototype_review_required"]


func is_final_field_scale_approved(profile_id: StringName) -> bool:
	var profile := get_profile(profile_id)
	return String(profile.get("surface", "field")) != "field" or field_scale_status(profile_id) == &"approved"


func world_foot_anchor(profile_id: StringName) -> Vector2:
	var profile := get_profile(profile_id)
	var placement: Dictionary = profile.get("placement", {})
	var values: Array = placement.get("footAnchor", [])
	if values.size() != 2:
		return Vector2.ZERO
	var scale := render_scale_vector(profile_id)
	return FIELD_SCALE.snap_to_world_pixels(Vector2(values[0] * scale.x, values[1] * scale.y))


func doorway(profile_id: StringName) -> Vector2:
	var profile := get_profile(profile_id)
	var placement: Dictionary = profile.get("placement", {})
	var values: Array = placement.get("doorway", [])
	if values.size() != 2:
		return Vector2.ZERO
	return Vector2(values[0], values[1])


func world_doorway(profile_id: StringName) -> Vector2:
	var profile := get_profile(profile_id)
	var placement: Dictionary = profile.get("placement", {})
	var values: Array = placement.get("doorway", [])
	if values.size() != 2:
		return Vector2.ZERO
	var scale := render_scale_vector(profile_id)
	return FIELD_SCALE.snap_to_world_pixels(Vector2(values[0] * scale.x, values[1] * scale.y))


func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if _profiles.is_empty():
		errors.append("Visual profile manifest must contain profiles.")
	for profile_id in profile_ids():
		var profile := get_profile(profile_id)
		var surface := String(profile.get("surface", ""))
		if surface not in ["field", "battle", "portrait", "ui"]:
			errors.append("Visual profile %s has an invalid surface." % profile_id)
			continue
		if surface == "field" and not field_scale_contract_valid(profile_id):
			errors.append("Field profile %s has no auditable scale status." % profile_id)
		if String(profile.get("releaseVisualAcceptance", "")) == "final_approved" and not is_final_field_scale_approved(profile_id):
			errors.append("Final-approved field profile %s has not passed the field-scale contract." % profile_id)
		var foot_anchor := world_foot_anchor(profile_id)
		if not FIELD_SCALE.is_pixel_aligned(foot_anchor):
			errors.append("Visual profile %s resolves its foot anchor to fractional world pixels." % profile_id)
	return PackedStringArray(errors)
