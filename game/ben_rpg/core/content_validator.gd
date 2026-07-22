class_name ContentValidator
extends RefCounted

const ACTION_KINDS := [&"physical", &"magic", &"heal", &"item_heal", &"item_mp", &"revive", &"cleanse", &"defend", &"rally", &"aegis", &"delay", &"damage_delay", &"escape"]
const ACTION_SELECTORS := [&"single", &"all", &"ko_single", &"self"]
const ACTION_RELATIONS := [&"hostile", &"ally", &"self"]
const HOSTILE_KINDS := [&"physical", &"magic", &"delay", &"damage_delay"]
const ALLY_KINDS := [&"heal", &"item_heal", &"item_mp", &"revive", &"cleanse", &"rally", &"aegis"]
const SAVE_MIGRATOR := preload("res://ben_rpg/core/save_migrator.gd")
const SETTINGS_REPOSITORY := preload("res://ben_rpg/core/settings_repository.gd")


static func validate_all() -> PackedStringArray:
	var errors: Array[String] = []
	_validate_actions(errors)
	_validate_bestiary(errors)
	_validate_encounters(errors)
	_validate_universes(errors)
	_validate_facilities(errors)
	_validate_quests(errors)
	_validate_skill_trees(errors)
	_validate_persistence_contracts(errors)
	return PackedStringArray(errors)


static func _validate_actions(errors: Array[String]) -> void:
	var action_ids := CampaignCombatDatabase.action_ids()
	if action_ids.is_empty():
		errors.append("Combat action catalog is empty.")
	for action_id in action_ids:
		var action := CampaignCombatDatabase.action(action_id)
		if action.is_empty():
			errors.append("Action '%s' has an invalid targeting contract." % action_id)
			continue
		var kind := StringName(action.get("kind", &""))
		var relation := StringName(action.get("relation", &""))
		var selector := StringName(action.get("selector", &""))
		if String(action.get("name", "")).is_empty():
			errors.append("Action '%s' is missing a display name." % action_id)
		if kind not in ACTION_KINDS:
			errors.append("Action '%s' has unsupported kind '%s'." % [action_id, kind])
		if relation not in ACTION_RELATIONS or selector not in ACTION_SELECTORS:
			errors.append("Action '%s' has invalid relation/selector '%s/%s'." % [action_id, relation, selector])
		if kind in HOSTILE_KINDS and relation != &"hostile":
			errors.append("Hostile action '%s' must target the opposing team." % action_id)
		if kind in ALLY_KINDS and relation != &"ally":
			errors.append("Support action '%s' must target allies." % action_id)
		if kind == &"revive" and selector != &"ko_single":
			errors.append("Revive action '%s' must target one fallen ally." % action_id)
		if kind == &"aegis" and (relation != &"ally" or selector != &"all"):
			errors.append("Heavenly Aegis-style action '%s' must protect all allies." % action_id)
		var item_id := StringName(action.get("item", &""))
		if item_id != &"" and not CampaignState.SERVICE_ITEM_CATALOG.has(item_id):
			errors.append("Action '%s' references missing item '%s'." % [action_id, item_id])
	var aegis := CampaignCombatDatabase.action(&"heavenly_aegis")
	if aegis.is_empty() or StringName(aegis.get("kind", &"")) != &"aegis":
		errors.append("Heavenly Aegis is missing or does not apply formation protection.")


static func _validate_bestiary(errors: Array[String]) -> void:
	var seen := {}
	for enemy_id in CampaignCombatDatabase.BESTIARY_ORDER:
		if seen.has(enemy_id):
			errors.append("Bestiary contains duplicate enemy '%s'." % enemy_id)
			continue
		seen[enemy_id] = true
		var enemy := CampaignCombatDatabase.enemy_actor(enemy_id, 0)
		if String(enemy.get("display_name", "")).is_empty() or String(enemy.get("display_name", "")) == "Unknown Horror":
			errors.append("Bestiary enemy '%s' has no catalog entry." % enemy_id)
		var region := String(CampaignCombatDatabase.BESTIARY_REGIONS.get(enemy_id, ""))
		var available_elements: Array = CampaignCombatDatabase.FIRST_VISIT_AVAILABLE_ELEMENTS_BY_REGION.get(region, [])
		if available_elements.is_empty():
			errors.append("Bestiary enemy '%s' has no first-visit element availability policy." % enemy_id)
		for element in (enemy.get("element_rates", {}) as Dictionary):
			if float(enemy["element_rates"][element]) > 1.0 and StringName(element) not in available_elements:
				errors.append("Enemy '%s' is weak to unavailable first-visit element '%s' in %s." % [enemy_id, element, region])
		for action_id in enemy.get("actions", []):
			var action := CampaignCombatDatabase.action(StringName(action_id))
			if action.is_empty():
				errors.append("Enemy '%s' references missing action '%s'." % [enemy_id, action_id])
			elif StringName(action.get("relation", &"")) != &"hostile":
				errors.append("Enemy '%s' action '%s' does not target opponents." % [enemy_id, action_id])


static func _validate_encounters(errors: Array[String]) -> void:
	var seen := {}
	for encounter_id in CampaignCombatDatabase.encounter_ids():
		if seen.has(encounter_id):
			errors.append("Encounter catalog contains duplicate '%s'." % encounter_id)
			continue
		seen[encounter_id] = true
		var encounter := CampaignCombatDatabase.encounter(encounter_id)
		if String(encounter.get("name", "")).is_empty():
			errors.append("Encounter '%s' is missing a name." % encounter_id)
		if encounter.get("enemies", []).is_empty():
			errors.append("Encounter '%s' has no enemies." % encounter_id)
		for enemy_id in encounter.get("enemies", []):
			if StringName(enemy_id) not in CampaignCombatDatabase.BESTIARY_ORDER:
				errors.append("Encounter '%s' references unknown enemy '%s'." % [encounter_id, enemy_id])
		var backdrop_path := String(encounter.get("backdrop_path", ""))
		if not backdrop_path.is_empty() and not ResourceLoader.exists(backdrop_path):
			errors.append("Encounter '%s' backdrop is missing: %s." % [encounter_id, backdrop_path])


static func _validate_universes(errors: Array[String]) -> void:
	var first_universe_count := 0
	for universe_id in CampaignState.UNIVERSE_DEFINITIONS:
		var universe: Dictionary = CampaignState.UNIVERSE_DEFINITIONS[universe_id]
		if String(universe.get("name", "")).is_empty() or String(universe.get("destination", "")).is_empty():
			errors.append("Universe '%s' is missing a name or destination." % universe_id)
		if not CampaignState.FACILITY_DEFINITIONS.has(String(universe.get("building", ""))):
			errors.append("Universe '%s' references missing facility '%s'." % [universe_id, universe.get("building", "")])
		if bool(universe.get("mandatory_first", false)):
			first_universe_count += 1
	if first_universe_count != 1:
		errors.append("Exactly one universe must be marked mandatory_first (found %d)." % first_universe_count)


static func _validate_facilities(errors: Array[String]) -> void:
	var job_ids := {}
	for facility_name in CampaignState.FACILITY_DEFINITIONS:
		var facility: Dictionary = CampaignState.FACILITY_DEFINITIONS[facility_name]
		for job in facility.get("jobs", []):
			var job_id := StringName(job.get("id", &""))
			if job_id == &"" or job_ids.has(job_id):
				errors.append("Facility '%s' has a missing or duplicate job id '%s'." % [facility_name, job_id])
			job_ids[job_id] = true
			for item_id in (job.get("items", {}) as Dictionary).keys():
				if not _known_item_id(StringName(item_id)):
					errors.append("Facility job '%s' grants unknown item '%s'." % [job_id, item_id])


static func _validate_quests(errors: Array[String]) -> void:
	var visit_states := {}
	for quest_id in CampaignState.QUEST_DEFINITIONS:
		var quest: Dictionary = CampaignState.QUEST_DEFINITIONS[quest_id]
		if String(quest.get("title", "")).is_empty() or quest.get("steps", []).is_empty():
			errors.append("Quest '%s' is missing a title or steps." % quest_id)
		for required_quest in quest.get("requires_quests", []):
			if not CampaignState.QUEST_DEFINITIONS.has(required_quest):
				errors.append("Quest '%s' requires missing quest '%s'." % [quest_id, required_quest])
		for item_id in (quest.get("rewards", {}).get("items", {}) as Dictionary).keys():
			if not _known_item_id(StringName(item_id)):
				errors.append("Quest '%s' rewards unknown item '%s'." % [quest_id, item_id])
	for quest_id in CampaignState.QUEST_DEFINITIONS:
		_visit_quest_dependencies(StringName(quest_id), visit_states, errors)


static func _validate_skill_trees(errors: Array[String]) -> void:
	for character_id in CampaignState.SKILL_TREES:
		var nodes_by_id := {}
		for node in CampaignState.SKILL_TREES[character_id]:
			var node_id := StringName(node.get("id", &""))
			if node_id == &"" or nodes_by_id.has(node_id):
				errors.append("Skill tree '%s' has a missing or duplicate node id '%s'." % [character_id, node_id])
			nodes_by_id[node_id] = node
			var action_id := StringName(node.get("action", &""))
			if action_id != &"" and CampaignCombatDatabase.action(action_id).is_empty():
				errors.append("Skill node '%s' references missing action '%s'." % [node_id, action_id])
		for node_id in nodes_by_id:
			for required_node in nodes_by_id[node_id].get("requires", []):
				if not nodes_by_id.has(required_node):
					errors.append("Skill node '%s' requires missing node '%s'." % [node_id, required_node])
		var visit_states := {}
		for node_id in nodes_by_id:
			_visit_skill_dependencies(node_id, nodes_by_id, visit_states, errors, StringName(character_id))


static func _validate_persistence_contracts(errors: Array[String]) -> void:
	if SAVE_MIGRATOR.CURRENT_VERSION != CampaignState.SAVE_VERSION:
		errors.append("Save migrator version does not match CampaignState.SAVE_VERSION.")
	for version in range(SAVE_MIGRATOR.FIRST_SUPPORTED_VERSION, SAVE_MIGRATOR.CURRENT_VERSION):
		if not SAVE_MIGRATOR.has_step(version):
			errors.append("Save migration step %d -> %d is missing." % [version, version + 1])
	var defaults := SETTINGS_REPOSITORY.default_settings()
	for section in [&"audio", &"display", &"battle", &"accessibility", &"input", &"telemetry"]:
		if not defaults.has(section):
			errors.append("Settings defaults are missing '%s'." % section)


static func _visit_quest_dependencies(quest_id: StringName, visit_states: Dictionary, errors: Array[String]) -> void:
	var state := int(visit_states.get(quest_id, 0))
	if state == 1:
		errors.append("Quest dependency cycle reaches '%s'." % quest_id)
		return
	if state == 2:
		return
	visit_states[quest_id] = 1
	var quest: Dictionary = CampaignState.QUEST_DEFINITIONS.get(quest_id, {})
	for required_quest in quest.get("requires_quests", []):
		if CampaignState.QUEST_DEFINITIONS.has(required_quest):
			_visit_quest_dependencies(StringName(required_quest), visit_states, errors)
	visit_states[quest_id] = 2


static func _visit_skill_dependencies(node_id: StringName, nodes_by_id: Dictionary, visit_states: Dictionary, errors: Array[String], character_id: StringName) -> void:
	var state := int(visit_states.get(node_id, 0))
	if state == 1:
		errors.append("Skill tree '%s' has a dependency cycle at '%s'." % [character_id, node_id])
		return
	if state == 2:
		return
	visit_states[node_id] = 1
	for required_node in nodes_by_id[node_id].get("requires", []):
		if nodes_by_id.has(required_node):
			_visit_skill_dependencies(StringName(required_node), nodes_by_id, visit_states, errors, character_id)
	visit_states[node_id] = 2


static func _known_item_id(item_id: StringName) -> bool:
	return CampaignState.SERVICE_ITEM_CATALOG.has(item_id) or item_id in [&"research_notes", &"anchor_dust", &"ectoplasm"]
