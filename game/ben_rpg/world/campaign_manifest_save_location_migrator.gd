class_name CampaignManifestSaveLocationMigrator
extends RefCounted

## Converts the seven retired quadrant maps into stable manifest room context.
## The streamed rooms of each universe share a staging origin, so the resulting
## room id is persisted alongside the safe arrival cell instead of inferring a
## room from an ambiguous coordinate on every load.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")

const LEGACY_UNIVERSE_ORIGINS := {
	&"HM": Vector2i(0, 32),
	&"AS": Vector2i(36, 32),
	&"PV": Vector2i(72, 32),
	&"HE": Vector2i(108, 32),
	&"FR": Vector2i(144, 32),
	&"MP": Vector2i(180, 32),
	&"EM": Vector2i(216, 32),
}

const LEGACY_UNIVERSE_SIZE := Vector2i(28, 18)

const LEGACY_ROOM_IDS := {
	&"HM": [&"HM-01", &"HM-02", &"HM-09", &"HM-04", &"HM-05"],
	&"AS": [&"AS-01", &"AS-03", &"AS-06", &"AS-05", &"AS-08"],
	&"PV": [&"PV-01", &"PV-03", &"PV-05", &"PV-07", &"PV-08"],
	&"HE": [&"HE-01", &"HE-03", &"HE-04", &"HE-06", &"HE-08"],
	&"FR": [&"FR-01", &"FR-03", &"FR-04", &"FR-06", &"FR-08"],
	&"MP": [&"MP-01", &"MP-02", &"MP-04", &"MP-06", &"MP-08"],
	&"EM": [&"EM-01", &"EM-03", &"EM-04", &"EM-07", &"EM-09"],
}


static func migrate(payload: Dictionary) -> Dictionary:
	if not String(payload.get("last_manifest_room_id", "")).is_empty():
		return payload
	var raw_cell: Array = payload.get("last_save_cell", [])
	if raw_cell.size() < 2:
		return payload
	var room_id := legacy_room_id_for_cell(Vector2i(int(raw_cell[0]), int(raw_cell[1])))
	if room_id == &"":
		return payload
	var definition := ROOM_REGISTRY.room(room_id)
	var world_origin: Vector2i = definition.get("worldOrigin", Vector2i.ZERO)
	var safe_arrival := TRANSITION_ROUTER.safe_arrival_cell(room_id, &"Nw")
	payload["last_manifest_room_id"] = String(room_id)
	payload["last_save_cell"] = [world_origin.x + safe_arrival.x, world_origin.y + safe_arrival.y]
	payload["last_location"] = "Migrated manifest room %s" % room_id
	return payload


static func legacy_room_id_for_cell(cell: Vector2i) -> StringName:
	for universe_prefix in LEGACY_UNIVERSE_ORIGINS:
		var origin: Vector2i = LEGACY_UNIVERSE_ORIGINS[universe_prefix]
		if not Rect2i(origin, LEGACY_UNIVERSE_SIZE).has_point(cell):
			continue
		var local := cell - origin
		var room_index := 0
		if local.x >= 20:
			room_index = 2 if local.y < 10 else 4
		elif local.y >= 10:
			room_index = 3
		elif local.x >= 10:
			room_index = 1
		return LEGACY_ROOM_IDS[universe_prefix][room_index]
	return &""


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for universe_prefix in LEGACY_ROOM_IDS:
		var room_ids: Array = LEGACY_ROOM_IDS[universe_prefix]
		if room_ids.size() != 5:
			errors.append("Legacy save migration must map five areas for %s." % universe_prefix)
			continue
		for room_id in room_ids:
			if not ROOM_REGISTRY.is_authored_room(room_id):
				errors.append("Legacy save migration targets unknown authored room %s." % room_id)
	return PackedStringArray(errors)
