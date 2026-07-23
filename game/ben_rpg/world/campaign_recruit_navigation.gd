class_name CampaignRecruitNavigation
extends RefCounted

## Stable world locations for recruit interactions owned by authored campaign
## rooms. Keeping these anchors in manifest-relative cells prevents new scene
## origins from silently leaving a recruit in retired procedural map space.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

const ANCHORS := {
	&"neon_viper": {"roomId": &"HE-03", "cell": Vector2i(12, 5)},
	&"frost_lich_emperor": {"roomId": &"FR-03", "cell": Vector2i(12, 5)},
	&"kitsune_empress": {"roomId": &"MP-02", "cell": Vector2i(12, 5)},
	&"archangel_commander": {"roomId": &"EM-03", "cell": Vector2i(12, 5)},
}


static func world_cell(recruit_id: StringName) -> Vector2i:
	var anchor: Dictionary = ANCHORS.get(recruit_id, {})
	if anchor.is_empty():
		push_error("Missing authored recruit anchor: %s" % recruit_id)
		return Vector2i.ZERO
	var room_id: StringName = anchor.get("roomId", &"")
	var definition := ROOM_REGISTRY.room(room_id)
	if definition.is_empty():
		push_error("Recruit %s references an unknown room: %s" % [recruit_id, room_id])
		return Vector2i.ZERO
	return definition.get("worldOrigin", Vector2i.ZERO) + anchor.get("cell", Vector2i.ZERO)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for recruit_id in ANCHORS:
		var anchor: Dictionary = ANCHORS[recruit_id]
		var room_id: StringName = anchor.get("roomId", &"")
		var definition := ROOM_REGISTRY.room(room_id)
		var dimensions: Vector2i = definition.get("dimensions", Vector2i.ZERO)
		var cell: Vector2i = anchor.get("cell", Vector2i.ZERO)
		if definition.is_empty():
			errors.append("Recruit %s references unknown room %s." % [recruit_id, room_id])
		elif not Rect2i(Vector2i.ZERO, dimensions).has_point(cell):
			errors.append("Recruit %s anchor is outside %s." % [recruit_id, room_id])
	return PackedStringArray(errors)
