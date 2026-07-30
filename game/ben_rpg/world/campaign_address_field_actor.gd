class_name CampaignAddressFieldActor
extends Node2D

## Scene-owned actor renderer for a mandatory-address population contract.
## The catalog remains the authority for identity, anchor, and all directional
## profiles; this node only realizes one admitted facing at one locked cell.

const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var actor_id: StringName = &""
var identity_id: StringName = &""
var profile_id: StringName = &""
var anchor: StringName = &""


func configure(requested_actor_id: StringName, definition: Dictionary, cell: Vector2i, facing: StringName = &"south") -> bool:
	actor_id = requested_actor_id
	identity_id = StringName(definition.get("identityId", &""))
	anchor = StringName(definition.get("anchor", &""))
	var directions: Dictionary = definition.get("directionProfiles", {})
	profile_id = StringName(directions.get(facing, &""))
	if actor_id == &"" or identity_id == &"" or anchor == &"" or profile_id == &"":
		push_error("Address field actor is missing an admitted identity, anchor, or profile.")
		return false
	var profiles := VISUAL_PROFILES.new()
	var profile: Dictionary = profiles.get_profile(profile_id)
	var placement: Dictionary = profile.get("placement", {})
	var foot_anchor: Array = placement.get("footAnchor", [])
	var texture: Texture2D = profiles.texture(profile_id)
	if profile.is_empty() or foot_anchor.size() != 2 or not texture:
		push_error("Address field actor %s cannot resolve profile %s." % [actor_id, profile_id])
		return false
	name = "AddressActor_%s" % actor_id
	position = Vector2(cell * 48)
	set_meta(&"actor_id", actor_id)
	set_meta(&"identity_id", identity_id)
	set_meta(&"anchor", anchor)
	set_meta(&"profile_id", profile_id)
	var sprite := Sprite2D.new()
	sprite.name = "ProfileSprite"
	sprite.centered = false
	sprite.texture = texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = -Vector2(foot_anchor[0], foot_anchor[1])
	add_child(sprite)
	return true
