class_name CampaignFacilityCatalog
extends RefCounted

## Stable Phase 3 facility interiors. A facility owns its services, jobs,
## upgrades, population contract, and universe portal; a New Philadelphia lot
## owns only the exterior placement that points at one of these ids.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROOM_ORDER := [&"FI-01", &"FI-02", &"FI-03", &"FI-04", &"FI-05", &"FI-06", &"FI-07", &"FI-08", &"FI-09", &"FI-10", &"FI-11"]
const FACILITY_NAMES := ["Cafe", "Library", "Clinic", "Armory", "Haunted Mansion", "Observatory", "Trailhead Lodge", "Afterlight Club", "Cold Storage", "Tea House", "Belfry"]

static var DEFINITIONS := {
	&"FI-01": _facility("Cafe", &"I2", &"service_counter", &"Tne", 4, &"", [&"morning_service", &"cafe_founders_supper", &"serving_table_automaton", &"hearth_exchange"]),
	&"FI-02": _facility("Library", &"I3", &"catalog_desk", &"Tne", 5, &"", [&"catalog", &"echo_research", &"bestiary_records", &"cataloging_engine", &"tribunal_ledger"]),
	&"FI-03": _facility("Clinic", &"I2", &"treatment_desk", &"Tnw", 4, &"", [&"tonic_rounds", &"emergency_drill", &"medical_kite", &"recovery", &"save_tutorial"]),
	&"FI-04": _facility("Armory", &"I3", &"forge_service", &"Tse", 5, &"", [&"buy_sell", &"reforge", &"salvage", &"field_refit", &"equipment_preview"]),
	&"FI-05": _facility("Haunted Mansion", &"I2", &"anchor_regulator", &"Tnw", 4, &"HM-01", [&"mansion_jobs", &"echo_containment"]),
	&"FI-06": _facility("Observatory", &"I3", &"fault_map", &"Tne", 5, &"AS-01", [&"chart_job", &"salvage_job", &"asterion_anchor"]),
	&"FI-07": _facility("Trailhead Lodge", &"I2", &"expedition_board", &"Tnw", 5, &"PV-01", [&"foraging_job", &"fossil_job", &"telegraph_boost", &"primeval_anchor"]),
	&"FI-08": _facility("Afterlight Club", &"I3", &"stage_console", &"Tse", 6, &"HE-01", [&"house_show_job", &"signal_job", &"helios_anchor"]),
	&"FI-09": _facility("Cold Storage", &"I2", &"thermal_ledger", &"Tne", 4, &"FR-01", [&"inventory_job", &"audit_job", &"coil_boost", &"frosthold_anchor"]),
	&"FI-10": _facility("Tea House", &"I3", &"tea_service", &"Tnw", 6, &"MP-01", [&"tea_service_job", &"memory_audit_job", &"lantern_boost", &"moonpetal_anchor"]),
	&"FI-11": _facility("Belfry", &"I3", &"bell_instrument", &"Tne", 5, &"EM-01", [&"weather_job", &"gravity_job", &"counterweight_boost", &"empyreal_anchor", &"charter_signal"]),
}


static func room(room_id: StringName) -> Dictionary:
	return (DEFINITIONS.get(room_id, {}) as Dictionary).duplicate(true)


static func room_for_facility(facility_name: String) -> StringName:
	var index := FACILITY_NAMES.find(facility_name)
	return ROOM_ORDER[index] if index >= 0 else &""


static func facility_for_room(room_id: StringName) -> String:
	return String(room(room_id).get("facilityName", ""))


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	if DEFINITIONS.size() != 11 or ROOM_ORDER.size() != 11 or FACILITY_NAMES.size() != 11:
		errors.append("Phase 3 must retain exactly eleven stable facility interiors.")
	for index in range(ROOM_ORDER.size()):
		var room_id: StringName = ROOM_ORDER[index]
		var definition: Dictionary = room(room_id)
		var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(definition.get("blueprint", &""), {})
		if definition.is_empty() or String(definition.get("facilityName", "")) != FACILITY_NAMES[index]:
			errors.append("%s has an invalid stable facility identity." % room_id)
			continue
		if blueprint.is_empty() or not ResourceLoader.exists(String(definition.get("scenePath", ""))):
			errors.append("%s is missing its blueprint or authored scene." % room_id)
		if not (definition.get("ports", {}) as Dictionary).has(&"Sw"):
			errors.append("%s must retain its dynamic lot-return port." % room_id)
		if int(definition.get("populationAnchorCount", 0)) < 4 or int(definition.get("populationAnchorCount", 0)) > 6:
			errors.append("%s has an invalid facility population budget." % room_id)
		if (definition.get("serviceContracts", []) as Array).is_empty():
			errors.append("%s must own at least one service or job contract." % room_id)
		var portal_target := StringName(definition.get("portalTarget", &""))
		if portal_target != &"" and StringName((definition.get("ports", {}) as Dictionary).get(&"Ne", &"")) != portal_target:
			errors.append("%s portal target is not bound to Ne." % room_id)
	return PackedStringArray(errors)


static func _facility(facility_name: String, blueprint: StringName, interaction_id: StringName, treasure_anchor: StringName, population_count: int, portal_target: StringName, service_contracts: Array) -> Dictionary:
	var dimensions: Vector2i = (ROOM_REGISTRY.BLUEPRINTS.get(blueprint, {}) as Dictionary).get("dimensions", Vector2i.ZERO)
	var ports := {&"Sw": &"LOT"}
	if portal_target != &"":
		ports[&"Ne"] = portal_target
	var anchors := {}
	var candidates := [Vector2i(dimensions.x / 4, dimensions.y / 3), Vector2i(dimensions.x / 2, dimensions.y / 3), Vector2i(dimensions.x * 3 / 4, dimensions.y / 3), Vector2i(dimensions.x / 4, dimensions.y * 2 / 3), Vector2i(dimensions.x / 2, dimensions.y * 2 / 3), Vector2i(dimensions.x * 3 / 4, dimensions.y * 2 / 3)]
	for index in range(population_count):
		anchors[StringName("P%d" % (index + 1))] = candidates[index]
	return {
		"facilityName": facility_name, "blueprint": blueprint, "dimensions": dimensions,
		"scenePath": "res://ben_rpg/world/rooms/new_philadelphia_facility_interior.tscn",
		"ports": ports, "portalTarget": portal_target, "interactionId": interaction_id,
		"interactionCell": Vector2i(dimensions.x / 2, dimensions.y / 2),
		"treasureAnchor": treasure_anchor, "populationAnchorCount": population_count,
		"populationAnchorCells": anchors, "serviceContracts": service_contracts.duplicate(),
		"encounterPolicy": &"none", "runtimeEnabled": true,
		"implementationState": &"implemented",
	}
