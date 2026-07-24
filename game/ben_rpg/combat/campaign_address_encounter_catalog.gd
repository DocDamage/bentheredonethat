class_name CampaignAddressEncounterCatalog
extends RefCounted

## Mandatory-address encounter contracts live outside the legacy combat database
## before they receive battle actors, balancing, backdrops, or runtime routing.
## This prevents an address room from inventing a one-off combat dictionary in
## its scene or controller.

const REQUIRED_ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")

static var CONTRACTS := {
	&"ashfall_cinder_gate_arrival_raid": {
		"id": &"ashfall_cinder_gate_arrival_raid",
		"addressId": &"ashfall",
		"roomId": &"AF-01",
		"name": "Cinder Gate Arrival Raid",
		"policy": &"scripted_only",
		"trigger": &"arrival",
		"enemyArchetypes": [&"ashfall_raider", &"ashfall_raider"],
		"battleDefinitionState": &"blocked_pending_combat_database_refactor",
		"runtimeEnabled": false,
	},
}


static func contract(encounter_id: StringName) -> Dictionary:
	return (CONTRACTS.get(encounter_id, {}) as Dictionary).duplicate(true)


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	for raw_encounter_id in CONTRACTS:
		var encounter_id := StringName(raw_encounter_id)
		var definition: Dictionary = CONTRACTS[encounter_id]
		var room_id := StringName(definition.get("roomId", &""))
		var room := REQUIRED_ADDRESS_CATALOG.room(room_id)
		if encounter_id == &"" or room.is_empty() or StringName(room.get("encounterId", &"")) != encounter_id:
			errors.append("%s must be referenced by exactly one required-address room." % encounter_id)
		if StringName(definition.get("addressId", &"")) == &"" or String(definition.get("name", "")).is_empty():
			errors.append("%s is missing address or display metadata." % encounter_id)
		if StringName(definition.get("policy", &"")) != &"scripted_only" or StringName(definition.get("trigger", &"")) != &"arrival":
			errors.append("%s must retain AF-01's arrival-only scripted policy." % encounter_id)
		if (definition.get("enemyArchetypes", []) as Array).is_empty() or bool(definition.get("runtimeEnabled", true)):
			errors.append("%s must remain a non-runtime preproduction contract with enemy archetypes." % encounter_id)
		if StringName(definition.get("battleDefinitionState", &"")) != &"blocked_pending_combat_database_refactor":
			errors.append("%s must not bypass the deferred combat-database refactor." % encounter_id)
	return PackedStringArray(errors)
