class_name CampaignAddressEncounterCatalog
extends RefCounted

## Mandatory-address encounter contracts live outside the legacy combat database
## before they receive battle actors, balancing, backdrops, or runtime routing.
## This prevents an address room from inventing a one-off combat dictionary in
## its scene or controller.

const REQUIRED_ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const COMBAT_ENCOUNTER_CATALOG := preload("res://ben_rpg/combat/campaign_encounter_catalog.gd")

static var CONTRACTS := {
	&"ashfall_cinder_gate_arrival_raid": {
		"id": &"ashfall_cinder_gate_arrival_raid",
		"addressId": &"ashfall",
		"roomId": &"AF-01",
		"name": "Cinder Gate Arrival Raid",
		"policy": &"scripted_only",
		"trigger": &"arrival",
		"enemyArchetypes": [&"ashfall_raider", &"ashfall_raider"],
		"battleDefinitionState": &"admitted_battle_content",
		"runtimeEnabled": true,
		"battleEncounterId": &"ashfall_cinder_gate_arrival_raid",
		"balanceContractId": &"ashfall-cinder-gate-arrival-v1",
	},
	&"ashfall_green_ruins_patrol": _ashfall_contract(&"ashfall_green_ruins_patrol", &"AF-03", "Green Ruins Patrol", &"zone", &"exploration", [&"mutated_patrol", &"mutated_patrol"]),
	&"ashfall_polluted_causeway_hazards": _ashfall_contract(&"ashfall_polluted_causeway_hazards", &"AF-04", "Polluted Causeway Hazards", &"zone", &"exploration", [&"toxic_hazard", &"sand_viper"]),
	&"ashfall_bunker_defense_line": _ashfall_contract(&"ashfall_bunker_defense_line", &"AF-05", "Bunker Defense Line", &"scripted_only", &"interaction", [&"iron_sentinel"]),
	&"ashfall_continuity_defenses": _ashfall_contract(&"ashfall_continuity_defenses", &"AF-06", "Continuity Bunker Defenses", &"zone", &"exploration", [&"malfunctioning_defense", &"malfunctioning_defense"]),
	&"ashfall_furnace_pact": _ashfall_contract(&"ashfall_furnace_pact", &"AF-07", "Furnace of False Salvation", &"boss", &"interaction", [&"wasteland_emperor", &"infernal_warlord"]),
	&"ashfall_supermarket_scavengers": _ashfall_contract(&"ashfall_supermarket_scavengers", &"AF-08", "Abandoned Supermarket Scavengers", &"zone", &"exploration", [&"scavenger_formation"]),
	&"ashfall_school_memory_echo": _ashfall_contract(&"ashfall_school_memory_echo", &"AF-10", "Wasteland School Memory Echo", &"scripted_only", &"interaction", [&"bone_reaper_echo"]),
	&"ashfall_bone_service_patrol": _ashfall_contract(&"ashfall_bone_service_patrol", &"AF-12", "Bone-Service Tunnel Patrol", &"scripted_only", &"exploration", [&"doom_vanguard_patrol"]),
}


static func contract(encounter_id: StringName) -> Dictionary:
	return (CONTRACTS.get(encounter_id, {}) as Dictionary).duplicate(true)


static func _ashfall_contract(encounter_id: StringName, room_id: StringName, display_name: String, policy: StringName, trigger: StringName, enemy_archetypes: Array) -> Dictionary:
	return {
		"id": encounter_id,
		"addressId": &"ashfall",
		"roomId": room_id,
		"name": display_name,
		"policy": policy,
		"trigger": trigger,
		"enemyArchetypes": enemy_archetypes,
		"battleDefinitionState": &"blocked_pending_combat_database_refactor",
		"runtimeEnabled": false,
	}


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
		if StringName(definition.get("policy", &"")) not in [&"zone", &"scripted_only", &"boss"] or StringName(definition.get("trigger", &"")) == &"":
			errors.append("%s has an invalid Ashfall encounter policy or trigger." % encounter_id)
		if (definition.get("enemyArchetypes", []) as Array).is_empty():
			errors.append("%s must define at least one planned enemy archetype." % encounter_id)
		if encounter_id == &"ashfall_cinder_gate_arrival_raid":
			var battle_encounter_id := StringName(definition.get("battleEncounterId", &""))
			if not bool(definition.get("runtimeEnabled", false)) or StringName(definition.get("battleDefinitionState", &"")) != &"admitted_battle_content" or battle_encounter_id != encounter_id or not COMBAT_ENCOUNTER_CATALOG.has(battle_encounter_id) or StringName(definition.get("balanceContractId", &"")) != &"ashfall-cinder-gate-arrival-v1":
				errors.append("%s must bind the admitted AF-01 battle definition and balance contract." % encounter_id)
		elif bool(definition.get("runtimeEnabled", true)) or StringName(definition.get("battleDefinitionState", &"")) != &"blocked_pending_combat_database_refactor":
			errors.append("%s must remain a non-runtime preproduction contract until its battle content is admitted." % encounter_id)
	return PackedStringArray(errors)
