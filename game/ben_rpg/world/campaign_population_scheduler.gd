class_name CampaignPopulationScheduler
extends RefCounted

## Resolves room/phase cohorts from the generated 258-identity registry. It is
## deliberately unable to spawn an identity until a reviewed runtime profile is
## admitted, and reserves only the room's P anchors—not ports, encounter zones,
## treasure cells, or interaction cells.

const REGISTRY_PATH := "res://ben_rpg/population/generated/population_registry.json"
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")

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


static func reserved_cells_for_room(room_id: StringName, definition: Dictionary) -> Dictionary:
	## Reserve every non-resident location that the active scene exposes. The
	## scheduler can therefore remain data-only while room installation ensures
	## no cohort actor occupies a port, arrival, feature, treasure, boss, or save.
	var reserved: Dictionary = {}
	for port_id in (definition.get("portCells", {}) as Dictionary).keys():
		var port_cell: Vector2i = definition["portCells"][port_id]
		reserved[port_cell] = "port:%s" % port_id
		var arrival := TRANSITION_ROUTER.safe_arrival_cell(room_id, StringName(port_id))
		if arrival != Vector2i.ZERO:
			reserved[arrival] = "safe_arrival:%s" % port_id
	for property_name in [&"chapterInteractions", &"asterionInteractions", &"primevalInteractions", &"heliosInteractions", &"frostholdInteractions", &"moonpetalInteractions", &"empyrealInteractions", &"universeTreasures"]:
		for feature in definition.get(property_name, []):
			if feature is Dictionary:
				_reserve_feature_cell(reserved, feature.get("cell", Vector2i.ZERO), property_name)
	var save_point: Dictionary = definition.get("savePoint", {})
	if not save_point.is_empty():
		_reserve_feature_cell(reserved, save_point.get("cell", Vector2i.ZERO), "save_point")
	var boss: Dictionary = definition.get("bossEncounter", {})
	if not boss.is_empty():
		_reserve_feature_cell(reserved, boss.get("cell", Vector2i.ZERO), "boss")
	return reserved


static func schedule_profiles(room_id: StringName, identities: Array[Dictionary], anchors: Dictionary, reserved_cells: Dictionary = {}) -> Dictionary:
	var assignments: Array[Dictionary] = []
	var unavailable: Array[StringName] = []
	var occupied: Dictionary = reserved_cells.duplicate(true)
	for profile in identities:
		var identity_id := StringName(profile.get("id", &""))
		var anchor_id := StringName(profile.get("anchor", &""))
		var anchor_cell: Vector2i = anchors.get(anchor_id, Vector2i.ZERO)
		if identity_id == &"" or _runtime_profile_id(profile) == &"" or bool(profile.get("blocked", false)) or anchor_cell == Vector2i.ZERO or occupied.has(anchor_cell):
			unavailable.append(identity_id)
			continue
		occupied[anchor_cell] = identity_id
		assignments.append({"identityId": identity_id, "runtimeProfileId": _runtime_profile_id(profile), "anchor": anchor_id, "cell": anchor_cell, "room": room_id})
	return {"assignments": assignments, "unavailable": unavailable}


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	_ensure_loaded()
	if _identities.size() != 258:
		errors.append("Population registry must expose exactly 258 eligible canonical identities.")
	for identity_id in _identities:
		var profile: Dictionary = _identities[identity_id]
		var is_complete := _string_field(profile, "sourceRotationState") == "complete"
		if not is_complete:
			errors.append("Planned identity %s does not have all eight source rotations." % identity_id)
	return PackedStringArray(errors)


static func _runtime_profile_id(profile: Dictionary) -> StringName:
	var value: Variant = profile.get("runtimeProfileId")
	if value is StringName:
		return value
	return StringName(value) if value is String else &""


static func _reserve_feature_cell(reserved: Dictionary, value: Variant, label: String) -> void:
	if value is Vector2i and value != Vector2i.ZERO:
		reserved[value] = label


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
