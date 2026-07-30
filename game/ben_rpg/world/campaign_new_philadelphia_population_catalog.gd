class_name CampaignNewPhiladelphiaPopulationCatalog
extends RefCounted

## Phase 3 district population contract. Phase 6 owns the final 258 named
## identities; this catalog owns the hub's bounded cohorts, route reservations,
## construction phases, universe imports, and post-stabilization presentation.

const NP_CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const PHASE_ORDER := [&"founding", &"construction", &"connected", &"stabilized"]
const COHORTS := [&"founders", &"trades", &"builders", &"growers", &"visitors", &"imports"]
const UNIVERSE_FLAGS := {
	&"asterion": &"asterion_scenario_complete", &"primeval": &"primeval_scenario_complete",
	&"helios": &"helios_scenario_complete", &"frosthold": &"frosthold_scenario_complete",
	&"moonpetal": &"moonpetal_scenario_complete", &"empyreal": &"empyreal_scenario_complete",
}


static func town_phase(story_flags: Dictionary = CampaignState.story_flags, lot_placements: Dictionary = CampaignState.new_philadelphia_lot_placements) -> StringName:
	var stabilized_count := 0
	for flag_id in UNIVERSE_FLAGS.values():
		if bool(story_flags.get(flag_id, false)): stabilized_count += 1
	if stabilized_count == UNIVERSE_FLAGS.size(): return &"stabilized"
	if stabilized_count > 0: return &"connected"
	if bool(story_flags.get(&"town_foundations_complete", false)) or not lot_placements.is_empty(): return &"construction"
	return &"founding"


static func contract(room_id: StringName, story_flags: Dictionary = CampaignState.story_flags, lot_placements: Dictionary = CampaignState.new_philadelphia_lot_placements) -> Dictionary:
	var room := NP_CATALOG.room(room_id)
	if room.is_empty(): return {}
	var phase := town_phase(story_flags, lot_placements)
	var phase_budget := {&"founding": 2, &"construction": 4, &"connected": 5, &"stabilized": 6}
	var anchor_ids: Array = room.get("populationAnchorIds", [])
	var anchor_cells: Dictionary = NP_CATALOG.resolved_layout(room_id).get("populationAnchors", {})
	var count: int = mini(int(phase_budget.get(phase, 2)), anchor_ids.size())
	var imports: Array[StringName] = []
	for universe_id in UNIVERSE_FLAGS:
		if bool(story_flags.get(UNIVERSE_FLAGS[universe_id], false)): imports.append(StringName(universe_id))
	var assignments: Array[Dictionary] = []
	for index in range(count):
		var anchor_id := StringName(anchor_ids[index])
		var cohort_id := StringName(COHORTS[index])
		assignments.append({
			"id": StringName("%s_%s" % [String(room_id).to_lower(), cohort_id]),
			"cohortId": cohort_id, "anchor": anchor_id,
			"cell": anchor_cells.get(anchor_id, Vector2i.ZERO),
			"route": [anchor_cells.get(anchor_id, Vector2i.ZERO)],
			"activity": _activity(cohort_id, phase, imports),
		})
	return {
		"roomId": room_id, "townPhase": phase, "constructionState": phase,
		"assignments": assignments, "universeImports": imports,
		"postStabilization": phase == &"stabilized",
	}


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	var phase_flags := {
		&"founding": {},
		&"construction": {&"town_foundations_complete": true},
		&"connected": {&"asterion_scenario_complete": true},
		&"stabilized": _all_universe_flags(),
	}
	for room_id in NP_CATALOG.ROOM_ORDER:
		var room := NP_CATALOG.room(room_id)
		var blueprint: Dictionary = ROOM_REGISTRY.BLUEPRINTS.get(room.get("blueprint", &""), {})
		var reserved := (blueprint.get("ports", {}) as Dictionary).values()
		reserved.append(NP_CATALOG.resolved_layout(room_id).get("interactionCell", Vector2i(-1, -1)))
		for phase in PHASE_ORDER:
			var value := contract(room_id, phase_flags[phase], {})
			var assignments: Array = value.get("assignments", [])
			if StringName(value.get("townPhase", &"")) != phase or assignments.size() > 6:
				errors.append("%s has an invalid %s population budget." % [room_id, phase])
			for assignment in assignments:
				var cell: Vector2i = assignment.get("cell", Vector2i.ZERO)
				if cell == Vector2i.ZERO or reserved.has(cell) or (assignment.get("route", []) as Array).is_empty():
					errors.append("%s %s cohort overlaps a reserved cell or lacks a route." % [room_id, phase])
	if not errors.is_empty(): return PackedStringArray(errors)
	return PackedStringArray()


static func _all_universe_flags() -> Dictionary:
	var flags := {}
	for flag_id in UNIVERSE_FLAGS.values(): flags[flag_id] = true
	return flags


static func _activity(cohort_id: StringName, phase: StringName, imports: Array[StringName]) -> StringName:
	if phase == &"stabilized": return &"post_stabilization_civic_life"
	if cohort_id == &"imports" and not imports.is_empty(): return StringName("%s_exchange" % imports.back())
	return StringName("%s_%s" % [phase, cohort_id])
