class_name CampaignPopulationScheduler
extends RefCounted

## Resolves room/phase cohorts from the generated 267-identity registry. It is
## deliberately unable to spawn an identity until a reviewed runtime profile is
## admitted, and reserves only the room's P anchors—not ports, encounter zones,
## treasure cells, or interaction cells.

const REGISTRY_PATH := "res://ben_rpg/population/generated/population_registry.json"

static var _identities: Dictionary = {}


static func identity(identity_id: StringName) -> Dictionary:
	_ensure_loaded()
	return (_identities.get(identity_id, {}) as Dictionary).duplicate(true)


static func schedule(room_id: StringName, definition: Dictionary, reserved_cells: Dictionary = {}) -> Dictionary:
	var requested: Array = definition.get("populationIds", [])
	var anchors: Dictionary = definition.get("populationAnchorCells", {})
	var assignments: Array[Dictionary] = []
	var unavailable: Array[StringName] = []
	var occupied: Dictionary = reserved_cells.duplicate(true)
	for requested_id in requested:
		var identity_id := StringName(requested_id)
		var profile := identity(identity_id)
		if profile.is_empty() or _runtime_profile_id(profile) == &"" or _string_field(profile, "sourceRotationState") != "complete":
			unavailable.append(identity_id)
			continue
		var anchor_id := StringName(profile.get("schedule", {}).get("anchor", &""))
		var anchor_cell: Vector2i = anchors.get(anchor_id, Vector2i.ZERO)
		if anchor_id == &"" or anchor_cell == Vector2i.ZERO or occupied.has(anchor_cell):
			unavailable.append(identity_id)
			continue
		occupied[anchor_cell] = identity_id
		assignments.append({"identityId": identity_id, "runtimeProfileId": _runtime_profile_id(profile), "anchor": anchor_id, "cell": anchor_cell, "room": room_id})
	return {"assignments": assignments, "unavailable": unavailable}


static func schedule_profiles(room_id: StringName, identities: Array[Dictionary], anchors: Dictionary, reserved_cells: Dictionary = {}) -> Dictionary:
	var assignments: Array[Dictionary] = []
	var unavailable: Array[StringName] = []
	var occupied: Dictionary = reserved_cells.duplicate(true)
	for profile in identities:
		var identity_id := StringName(profile.get("id", &""))
		var anchor_id := StringName(profile.get("anchor", &""))
		var anchor_cell: Vector2i = anchors.get(anchor_id, Vector2i.ZERO)
		if identity_id == &"" or _runtime_profile_id(profile) == &"" or bool(profile.get("quarantined", false)) or anchor_cell == Vector2i.ZERO or occupied.has(anchor_cell):
			unavailable.append(identity_id)
			continue
		occupied[anchor_cell] = identity_id
		assignments.append({"identityId": identity_id, "runtimeProfileId": _runtime_profile_id(profile), "anchor": anchor_id, "cell": anchor_cell, "room": room_id})
	return {"assignments": assignments, "unavailable": unavailable}


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	_ensure_loaded()
	if _identities.size() != 267:
		errors.append("Population registry must expose exactly 267 canonical identities.")
	var quarantined := 0
	for identity_id in _identities:
		var profile: Dictionary = _identities[identity_id]
		var is_complete := _string_field(profile, "sourceRotationState") == "complete"
		if not is_complete:
			quarantined += 1
			if _runtime_profile_id(profile) != &"":
				errors.append("Quarantined identity %s has a runtime profile binding." % identity_id)
	if quarantined != 9:
		errors.append("Population registry must quarantine exactly nine incomplete identities.")
	return PackedStringArray(errors)


static func _runtime_profile_id(profile: Dictionary) -> StringName:
	var value: Variant = profile.get("runtimeProfileId")
	if value is StringName:
		return value
	return StringName(value) if value is String else &""


static func _string_field(profile: Dictionary, key: String) -> String:
	var value: Variant = profile.get(key)
	return value if value is String else ""


static func _ensure_loaded() -> void:
	if not _identities.is_empty():
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(REGISTRY_PATH))
	if not parsed is Dictionary:
		return
	for profile in parsed.get("identities", []):
		if profile is Dictionary:
			var identity_id := StringName(profile.get("id", &""))
			if identity_id != &"":
				_identities[identity_id] = profile
