class_name CampaignAddressEncounterCatalog
extends RefCounted

## Production encounter contracts for every critical Phase 5 room. AF-01 keeps
## its fully admitted combat-database formation; the remaining contracts are
## consumed by the address encounter runtime and share deterministic balance.

const REQUIRED_ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ARCHETYPES := {
	&"ashfall": [&"ashfall_raider", &"mutated_patrol"], &"pelagic": [&"reef_guard", &"abyssal_hunter"],
	&"steamforge": [&"clockwork_guard", &"boiler_construct"], &"frontier": [&"claim_jumper", &"canyon_beast"],
	&"warfront": [&"rift_soldier", &"siege_construct"], &"liminal": [&"null_attendant", &"pool_echo"],
}
const BATTLE_FORMATIONS := {
	&"ashfall": {"enemies": [&"ashfall_raider", &"ashfall_raider"], "backdrop": &"ashfall_cinder_gate_battle_backdrop"},
	&"pelagic": {"enemies": [&"primeval_raptor", &"schoolgirl_ghost"], "backdrop": &"primeval_ground_battle_backdrop"},
	&"steamforge": {"enemies": [&"work_robot", &"sentry_drone"], "backdrop": &"asterion_dock_battle_backdrop"},
	&"frontier": {"enemies": [&"stone_triceratops", &"primeval_raptor"], "backdrop": &"primeval_ground_battle_backdrop"},
	&"warfront": {"enemies": [&"helios_gunner", &"helios_security"], "backdrop": &"helios_transit_battle_backdrop"},
	&"liminal": {"enemies": [&"schoolgirl_ghost", &"clock_mirror"], "backdrop": &"mansion_gallery_battle_backdrop"},
}

static var CONTRACTS := _build_contracts()


static func contract(encounter_id: StringName) -> Dictionary:
	return (CONTRACTS.get(encounter_id, {}) as Dictionary).duplicate(true)


static func battle_definition(encounter_id: StringName) -> Dictionary:
	var definition := contract(encounter_id)
	if definition.is_empty(): return {}
	var formation: Dictionary = BATTLE_FORMATIONS.get(definition.get("addressId", &""), {})
	return {"name": definition.get("name", "Address Encounter"), "enemies": formation.get("enemies", []), "backdrop_profile": formation.get("backdrop", &""), "scripted": StringName(definition.get("policy", &"")) != &"zone", "boss": StringName(definition.get("policy", &"")) == &"boss"}


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	var bosses := {}
	for encounter_id in CONTRACTS:
		var definition: Dictionary = CONTRACTS[encounter_id]
		var room_id := StringName(definition.get("roomId", &""))
		var address_id := StringName(definition.get("addressId", &""))
		if REQUIRED_ADDRESS_CATALOG.room(room_id).get("encounterId", &"") != encounter_id:
			errors.append("%s must be owned by its required-address room." % encounter_id)
		if not bool(definition.get("runtimeEnabled", false)) or (definition.get("enemyArchetypes", []) as Array).is_empty():
			errors.append("%s needs an enabled encounter and enemy set." % encounter_id)
		var battle := battle_definition(encounter_id)
		if (battle.get("enemies", []) as Array).is_empty() or StringName(battle.get("backdrop_profile", &"")) == &"": errors.append("%s needs an executable battle formation." % encounter_id)
		if StringName(definition.get("policy", &"")) == &"boss": bosses[address_id] = int(bosses.get(address_id, 0)) + 1
	for address_id in REQUIRED_ADDRESS_CATALOG.ADDRESS_ORDER:
		if int(bosses.get(address_id, 0)) != 1: errors.append("%s requires exactly one boss contract." % address_id)
	return PackedStringArray(errors)


static func _build_contracts() -> Dictionary:
	var result := {}
	for address_id in REQUIRED_ADDRESS_CATALOG.ADDRESS_ORDER:
		var chapter := REQUIRED_ADDRESS_CATALOG.address(address_id)
		var critical_index := 0
		var critical_count := int((chapter.get("classBudget", []) as Array)[0])
		for room in chapter.get("rooms", []) as Array:
			var encounter_id := StringName(room.get("encounterId", &""))
			var is_critical := StringName(room.get("class", &"")) == &"C"
			if is_critical: critical_index += 1
			if encounter_id == &"": continue
			var is_boss := is_critical and critical_index == critical_count
			result[encounter_id] = {"id": encounter_id, "addressId": address_id, "roomId": room.get("id", &""), "name": "%s %s" % [room.get("title", "Address"), "Boss" if is_boss else "Encounter"], "policy": &"boss" if is_boss else (&"scripted_only" if critical_index in [1, critical_count - 1] else &"zone"), "trigger": &"interaction" if is_boss else &"exploration", "enemyArchetypes": ARCHETYPES[address_id], "battleDefinitionState": &"admitted_battle_content" if encounter_id == &"ashfall_cinder_gate_arrival_raid" else &"production_address_runtime", "runtimeEnabled": true, "battleEncounterId": encounter_id, "balanceContractId": StringName("%s-balance-v1" % String(address_id))}
	return result
