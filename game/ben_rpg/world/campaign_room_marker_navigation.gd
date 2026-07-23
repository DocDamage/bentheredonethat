class_name CampaignRoomMarkerNavigation
extends RefCounted

## Manifest-relative anchors for visual boss markers. These markers remain
## world nodes for compatibility, but their positions and visibility must track
## the streamed room that owns the encounter.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

const BOSS_ANCHORS := {
	&"mansion_appointment": {"roomId": &"HM-09", "cell": Vector2i(12, 10)},
	&"mother_computer": {"roomId": &"AS-08", "cell": Vector2i(12, 10)},
	&"commute_tyrant": {"roomId": &"PV-08", "cell": Vector2i(12, 10)},
	&"civic_sun": {"roomId": &"HE-08", "cell": Vector2i(12, 10)},
	&"whiteout_auditor": {"roomId": &"FR-08", "cell": Vector2i(12, 10)},
	&"magistrate_enma": {"roomId": &"MP-08", "cell": Vector2i(12, 10)},
	&"high_comptroller": {"roomId": &"EM-09", "cell": Vector2i(12, 10)},
}


static func world_cell(marker_id: StringName) -> Vector2i:
	var anchor: Dictionary = BOSS_ANCHORS.get(marker_id, {})
	if anchor.is_empty():
		push_error("Missing authored boss marker anchor: %s" % marker_id)
		return Vector2i.ZERO
	return ROOM_REGISTRY.room(anchor.get("roomId", &"")).get("worldOrigin", Vector2i.ZERO) + anchor.get("cell", Vector2i.ZERO)


static func room_id(marker_id: StringName) -> StringName:
	return (BOSS_ANCHORS.get(marker_id, {}) as Dictionary).get("roomId", &"")


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for marker_id in BOSS_ANCHORS:
		var anchor: Dictionary = BOSS_ANCHORS[marker_id]
		var room := ROOM_REGISTRY.room(anchor.get("roomId", &""))
		var dimensions: Vector2i = room.get("dimensions", Vector2i.ZERO)
		if room.is_empty() or not Rect2i(Vector2i.ZERO, dimensions).has_point(anchor.get("cell", Vector2i.ZERO)):
			errors.append("Boss marker %s is outside its authored room." % marker_id)
	return PackedStringArray(errors)
