class_name CampaignAddressFieldActorCatalog
extends RefCounted

## Owns the pre-runtime visual contract for mandatory-address population. The
## address's approved annex runtime admits exact eight-direction derivatives
## and profile IDs. The catalog remains the authority for actor admission.

const POPULATION := preload("res://ben_rpg/world/campaign_address_population_catalog.gd")
const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const DIRECTIONS := [&"north", &"north-east", &"east", &"south-east", &"south", &"south-west", &"west", &"north-west"]

static var ACTORS := {
	&"af01_scrap_kid_field_actor": _actor(POPULATION.AF01_SCRAP_KID, &"P1", &"scrap_kid"),
	&"af01_dust_hunter_field_actor": _actor(POPULATION.AF01_DUST_HUNTER, &"P2", &"dust_hunter"),
	&"af01_iron_sentinel_field_actor": _actor(POPULATION.AF01_IRON_SENTINEL_VISITOR, &"P3", &"iron_sentinel"),
}


static func _actor(identity_id: StringName, anchor: StringName, visual_stem: StringName) -> Dictionary:
	var profiles: Dictionary = {}
	for direction in DIRECTIONS:
		profiles[direction] = StringName("af01_%s_%s" % [visual_stem, direction])
	return {"identityId": identity_id, "roomId": &"AF-01", "anchor": anchor, "directionProfiles": profiles, "runtimeEnabled": true}


static func actor(actor_id: StringName) -> Dictionary:
	return (ACTORS.get(actor_id, {}) as Dictionary).duplicate(true)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if ACTORS.size() != 3:
		errors.append("AF-01 field-actor admission must define exactly its two residents and one visitor.")
	var profiles := VISUAL_PROFILES.new()
	for raw_actor_id in ACTORS:
		var actor_id := StringName(raw_actor_id)
		var definition: Dictionary = ACTORS[actor_id]
		if not bool(definition.get("runtimeEnabled", false)) or not String(definition.get("runtimeBlocker", "")).is_empty():
			errors.append("%s must be admitted without a stale runtime blocker." % actor_id)
		var directions: Dictionary = definition.get("directionProfiles", {})
		if directions.size() != DIRECTIONS.size():
			errors.append("%s must retain all eight direction profiles." % actor_id)
		for direction in DIRECTIONS:
			var profile_id := StringName(directions.get(direction, &""))
			if profile_id == &"" or not profiles.has(profile_id):
				errors.append("%s is missing visual profile %s." % [actor_id, direction])
			elif not profiles.is_final_field_scale_approved(profile_id):
				errors.append("%s requires a final-approved field-scale profile %s." % [actor_id, profile_id])
	return PackedStringArray(errors)
