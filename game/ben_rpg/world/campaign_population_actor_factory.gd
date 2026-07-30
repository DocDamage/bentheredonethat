class_name CampaignPopulationActorFactory
extends RefCounted

## Realizes scheduler assignments without deciding identity placement. The
## scheduler owns room/phase/occupancy decisions; this factory only accepts an
## admitted runtime visual profile and builds the corresponding room-owned
## actor. Actors are children of the streamed cohort and therefore unload with
## the active room.

const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TILE := 48.0


static func create(assignment: Dictionary) -> Node2D:
	var identity_id := StringName(assignment.get("identityId", &""))
	var profile_id := StringName(assignment.get("runtimeProfileId", &""))
	var room_id := StringName(assignment.get("room", &""))
	var anchor := StringName(assignment.get("anchor", &""))
	var cell: Vector2i = assignment.get("cell", Vector2i.ZERO)
	if identity_id == &"" or profile_id == &"" or room_id == &"" or anchor == &"" or cell == Vector2i.ZERO:
		return null

	var profiles := VISUAL_PROFILES.new()
	var profile := profiles.get_profile(profile_id)
	if profile.is_empty() or String(profile.get("surface", "")) != "field" or not profiles.field_scale_contract_valid(profile_id):
		return null
	var texture := profiles.texture(profile_id)
	var source_region := profiles.region(profile_id)
	var foot_anchor := profiles.world_foot_anchor(profile_id)
	var scale := profiles.render_scale_vector(profile_id)
	if not texture or source_region.size == Vector2.ZERO or scale == Vector2.ZERO:
		return null

	var actor := Node2D.new()
	actor.name = "PopulationActor_%s" % _safe_name(identity_id)
	actor.position = Vector2(cell) * TILE
	actor.set_meta(&"identity_id", identity_id)
	actor.set_meta(&"runtime_profile_id", profile_id)
	actor.set_meta(&"room_id", room_id)
	actor.set_meta(&"anchor", anchor)
	actor.set_meta(&"cell", cell)

	var sprite := Sprite2D.new()
	sprite.name = "ProfileSprite"
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = false
	sprite.region_enabled = true
	sprite.region_rect = source_region
	sprite.scale = scale
	sprite.position = -foot_anchor
	actor.add_child(sprite)
	return actor


static func _safe_name(identity_id: StringName) -> String:
	var result := String(identity_id)
	for character in [":", "/", "\\", " ", "."]:
		result = result.replace(character, "_")
	return result
