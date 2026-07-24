class_name CampaignAddressPopulationCatalog
extends RefCounted

## Mandatory-address population is authored separately from the core 102-room
## registry until its field profiles and live address gateway are admitted. A
## contract may name complete source identities and exact anchors, but it must
## not make an unprofiled character appear in a runtime scene.

const POPULATION_SCHEDULER := preload("res://ben_rpg/world/campaign_population_scheduler.gd")
const REQUIRED_ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ADDRESS_ROOM_RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")

const AF01_SCRAP_KID := &"sakpix:☢️ WASTELAND LEGENDS/1._SCRAP_KID_FREE"
const AF01_DUST_HUNTER := &"sakpix:☢️ WASTELAND LEGENDS/4._DUST_HUNTER"
const AF01_IRON_SENTINEL_VISITOR := &"sakpix:☢️ WASTELAND LEGENDS/9._IRON_SENTINEL"

static var CONTRACTS := {
	&"af01-survivor-watch-v1": {
		"id": &"af01-survivor-watch-v1",
		"roomId": &"AF-01",
		"activationState": &"post_arrival_raid_stabilized",
		"runtimeEnabled": false,
		"runtimeBlocker": "The source identities are complete, but their field profiles, actor scenes, and address gateway have not been admitted.",
		"residents": [
			{"identityId": AF01_SCRAP_KID, "anchor": &"P1", "route": &"anchor_to_interaction", "phase": &"S"},
			{"identityId": AF01_DUST_HUNTER, "anchor": &"P2", "route": &"anchor_to_interaction", "phase": &"S"},
		],
		"temporaryVisitors": [
			{"identityId": AF01_IRON_SENTINEL_VISITOR, "anchor": &"P3", "route": &"anchor_to_interaction", "phase": &"S", "canonicalHome": &"AF-05", "condition": &"af05_defense_line_cleared"},
		],
	},
}


static func contract(contract_id: StringName) -> Dictionary:
	return (CONTRACTS.get(contract_id, {}) as Dictionary).duplicate(true)


static func contract_for_room(room_id: StringName) -> Dictionary:
	for definition in CONTRACTS.values():
		if StringName((definition as Dictionary).get("roomId", &"")) == room_id:
			return (definition as Dictionary).duplicate(true)
	return {}


static func resident_ids(contract_id: StringName) -> Array[StringName]:
	var ids: Array[StringName] = []
	for role in (contract(contract_id).get("residents", []) as Array):
		ids.append(StringName((role as Dictionary).get("identityId", &"")))
	return ids


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if CONTRACTS.size() != 1:
		errors.append("The first address population milestone must define exactly one AF-01 contract.")
	for raw_contract_id in CONTRACTS:
		var contract_id := StringName(raw_contract_id)
		var definition: Dictionary = CONTRACTS[contract_id]
		var room_id := StringName(definition.get("roomId", &""))
		var room := REQUIRED_ADDRESS_CATALOG.room(room_id)
		var room_record := ADDRESS_ROOM_RECORDS.record(room_id)
		if contract_id == &"" or room.is_empty() or room_record.is_empty() or room_id != &"AF-01":
			errors.append("%s must bind the authored AF-01 address record." % contract_id)
			continue
		if bool(definition.get("runtimeEnabled", true)) or StringName(definition.get("activationState", &"")) != &"post_arrival_raid_stabilized" or String(definition.get("runtimeBlocker", "")).is_empty():
			errors.append("%s must stay explicitly runtime-gated until population admission completes." % contract_id)
		var population_anchors: Dictionary = (room_record.get("layout", {}) as Dictionary).get("populationAnchors", {})
		_validate_roles(contract_id, definition.get("residents", []) as Array, population_anchors, room_id, &"AF-01", false, errors)
		_validate_roles(contract_id, definition.get("temporaryVisitors", []) as Array, population_anchors, room_id, &"AF-05", true, errors)
	return PackedStringArray(errors)


static func _validate_roles(contract_id: StringName, roles: Array, anchors: Dictionary, room_id: StringName, expected_home: StringName, temporary: bool, errors: Array[String]) -> void:
	var expected_count := 1 if temporary else 2
	if roles.size() != expected_count:
		errors.append("%s must define %d %s role(s)." % [contract_id, expected_count, "temporary visitor" if temporary else "resident"])
		return
	var occupied: Dictionary = {}
	for raw_role in roles:
		var role := raw_role as Dictionary
		var identity_id := StringName(role.get("identityId", &""))
		var identity := POPULATION_SCHEDULER.identity(identity_id)
		var anchor := StringName(role.get("anchor", &""))
		if identity.is_empty() or anchor == &"" or not anchors.has(anchor) or occupied.has(anchor):
			errors.append("%s references an unknown or overlapping %s role." % [contract_id, "visitor" if temporary else "resident"])
			continue
		occupied[anchor] = identity_id
		var schedule: Dictionary = identity.get("schedule", {})
		if StringName(identity.get("canonicalHome", &"")) != expected_home or String(identity.get("sourceRotationState", "")) != "complete":
			errors.append("%s identity %s has the wrong canonical home or incomplete rotations." % [contract_id, identity_id])
		if StringName(role.get("route", &"")) != &"anchor_to_interaction" or StringName(role.get("phase", &"")) != &"S" or StringName(schedule.get("route", &"")) != &"anchor_to_interaction" or StringName(schedule.get("phase", &"")) != &"S":
			errors.append("%s identity %s must retain its stabilized anchor-to-interaction schedule." % [contract_id, identity_id])
		if not temporary and StringName(schedule.get("anchor", &"")) != anchor:
			errors.append("%s resident %s must retain the registry anchor %s." % [contract_id, identity_id, anchor])
		if temporary and (StringName(role.get("canonicalHome", &"")) != expected_home or StringName(role.get("condition", &"")) != &"af05_defense_line_cleared"):
			errors.append("%s temporary visitor %s must retain its AF-05 home and post-defense condition." % [contract_id, identity_id])
