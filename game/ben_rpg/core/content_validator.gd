class_name ContentValidator
extends RefCounted

const ACTION_KINDS := [&"physical", &"magic", &"heal", &"item_heal", &"item_mp", &"revive", &"cleanse", &"defend", &"rally", &"aegis", &"delay", &"damage_delay", &"time_tune", &"escape"]
const ACTION_SELECTORS := [&"single", &"all", &"ko_single", &"self"]
const ACTION_RELATIONS := [&"hostile", &"ally", &"self"]
const HOSTILE_KINDS := [&"physical", &"magic", &"delay", &"damage_delay", &"time_tune"]
const ALLY_KINDS := [&"heal", &"item_heal", &"item_mp", &"revive", &"cleanse", &"rally", &"aegis"]
const SAVE_MIGRATOR := preload("res://ben_rpg/core/save_migrator.gd")
const SETTINGS_REPOSITORY := preload("res://ben_rpg/core/settings_repository.gd")
const CAMPAIGN_BALANCE_HARNESS := preload("res://ben_rpg/core/campaign_balance_harness.gd")
const CAMPAIGN_ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const MANSION_LEGACY_ADAPTER := preload("res://ben_rpg/world/campaign_mansion_legacy_adapter.gd")
const CAMPAIGN_ROOM_STREAMER := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const CAMPAIGN_TRANSITION_ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const CAMPAIGN_NAVIGATION_BUILDER := preload("res://ben_rpg/world/campaign_navigation_builder.gd")
const CAMPAIGN_CAMERA_CONTROLLER := preload("res://ben_rpg/world/campaign_camera_controller.gd")
const MANIFEST_SAVE_LOCATION_MIGRATOR := preload("res://ben_rpg/world/campaign_manifest_save_location_migrator.gd")
const CAMPAIGN_ROOM_GRAPH_REPORT := preload("res://ben_rpg/world/campaign_room_graph_report.gd")
const CAMPAIGN_POPULATION_SCHEDULER := preload("res://ben_rpg/world/campaign_population_scheduler.gd")
const CAMPAIGN_ENCOUNTER_RUNTIME := preload("res://ben_rpg/world/campaign_encounter_runtime.gd")
const CAMPAIGN_FIELD_SCALE := preload("res://ben_rpg/world/campaign_field_scale.gd")
const NEW_PHILADELPHIA_CATALOG := preload("res://ben_rpg/world/campaign_new_philadelphia_catalog.gd")
const REQUIRED_ADDRESS_CATALOG := preload("res://ben_rpg/world/campaign_required_address_catalog.gd")
const ADDRESS_ENCOUNTER_CATALOG := preload("res://ben_rpg/combat/campaign_address_encounter_catalog.gd")
const ENCOUNTER_CATALOG := preload("res://ben_rpg/combat/campaign_encounter_catalog.gd")
const ACTION_CATALOG := preload("res://ben_rpg/combat/campaign_action_catalog.gd")
const BESTIARY_CATALOG := preload("res://ben_rpg/combat/campaign_bestiary_catalog.gd")
const ENCOUNTER_REWARD_CATALOG := preload("res://ben_rpg/combat/campaign_encounter_reward_catalog.gd")
const ADDRESS_ROOM_RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")
const ADDRESS_POPULATION_CATALOG := preload("res://ben_rpg/world/campaign_address_population_catalog.gd")
const ADDRESS_FIELD_ACTOR_CATALOG := preload("res://ben_rpg/world/campaign_address_field_actor_catalog.gd")
const CAMPAIGN_VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")


static func validate_all() -> PackedStringArray:
	var errors: Array[String] = []
	_validate_actions(errors)
	_validate_bestiary(errors)
	_validate_encounters(errors)
	_validate_universes(errors)
	_validate_facilities(errors)
	_validate_inventions(errors)
	_validate_armory_stock(errors)
	_validate_facility_upgrades(errors)
	_validate_quests(errors)
	_validate_skill_trees(errors)
	_validate_balance_contracts(errors)
	_validate_persistence_contracts(errors)
	_validate_room_registry(errors)
	return PackedStringArray(errors)


static func _validate_room_registry(errors: Array[String]) -> void:
	for error in CAMPAIGN_ROOM_REGISTRY.validate():
		errors.append(error)
	for error in MANSION_LEGACY_ADAPTER.validate():
		errors.append(error)
	for error in CAMPAIGN_ROOM_STREAMER.validate():
		errors.append(error)
	for error in CAMPAIGN_TRANSITION_ROUTER.validate():
		errors.append(error)
	for error in CAMPAIGN_NAVIGATION_BUILDER.validate():
		errors.append(error)
	for error in CAMPAIGN_CAMERA_CONTROLLER.validate():
		errors.append(error)
	for error in MANIFEST_SAVE_LOCATION_MIGRATOR.validate():
		errors.append(error)
	for error in CAMPAIGN_ROOM_GRAPH_REPORT.validate():
		errors.append(error)
	for error in CAMPAIGN_POPULATION_SCHEDULER.validate():
		errors.append(error)
	for error in CAMPAIGN_ENCOUNTER_RUNTIME.validate():
		errors.append(error)
	for error in CAMPAIGN_FIELD_SCALE.validate():
		errors.append(error)
	for error in NEW_PHILADELPHIA_CATALOG.validate():
		errors.append(error)
	for error in REQUIRED_ADDRESS_CATALOG.validate():
		errors.append(error)
	for error in ADDRESS_ENCOUNTER_CATALOG.validate():
		errors.append(error)
	for error in ADDRESS_ROOM_RECORDS.validate():
		errors.append(error)
	for error in ADDRESS_POPULATION_CATALOG.validate():
		errors.append(error)
	for error in ADDRESS_FIELD_ACTOR_CATALOG.validate():
		errors.append(error)
	var visual_profiles := CAMPAIGN_VISUAL_PROFILE_REGISTRY.new()
	for error in visual_profiles.validate():
		errors.append(error)


static func _validate_actions(errors: Array[String]) -> void:
	errors.append_array(ACTION_CATALOG.validate())
	var action_ids := CampaignCombatDatabase.action_ids()
	if action_ids.is_empty():
		errors.append("Combat action catalog is empty.")
	for action_id in action_ids:
		var action := CampaignCombatDatabase.action(action_id)
		if action != ACTION_CATALOG.definition(action_id):
			errors.append("Combat database facade diverges from action content %s." % action_id)
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
	errors.append_array(BESTIARY_CATALOG.validate())
	var seen := {}
	for enemy_id in CampaignCombatDatabase.BESTIARY_ORDER:
		if seen.has(enemy_id):
			errors.append("Bestiary contains duplicate enemy '%s'." % enemy_id)
			continue
		seen[enemy_id] = true
		if not BESTIARY_CATALOG.has(enemy_id):
			errors.append("Bestiary enemy '%s' is missing from the content catalog." % enemy_id)
			continue
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
	for enemy_id in BESTIARY_CATALOG.ids():
		if enemy_id not in seen:
			errors.append("Bestiary content '%s' is not listed in the campaign bestiary order." % enemy_id)


static func _validate_encounters(errors: Array[String]) -> void:
	errors.append_array(ENCOUNTER_CATALOG.validate())
	errors.append_array(ENCOUNTER_REWARD_CATALOG.validate())
	for encounter_id in ENCOUNTER_REWARD_CATALOG.FIXED_REWARD_ENCOUNTERS:
		if not ENCOUNTER_CATALOG.has(encounter_id):
			errors.append("Reward content references missing encounter '%s'." % encounter_id)
	var seen := {}
	for encounter_id in ENCOUNTER_CATALOG.ids():
		if seen.has(encounter_id):
			errors.append("Encounter catalog contains duplicate '%s'." % encounter_id)
			continue
		seen[encounter_id] = true
		var encounter := ENCOUNTER_CATALOG.definition(encounter_id)
		if CampaignCombatDatabase.encounter(encounter_id) != encounter:
			errors.append("Combat database facade diverges from encounter content %s." % encounter_id)
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


static func _validate_inventions(errors: Array[String]) -> void:
	for invention_id in CampaignState.INVENTION_DEFINITIONS:
		var invention: Dictionary = CampaignState.INVENTION_DEFINITIONS[invention_id]
		if String(invention.get("name", "")).is_empty():
			errors.append("Invention '%s' is missing a display name." % invention_id)
		if not CampaignState.FACILITY_DEFINITIONS.has(String(invention.get("facility", ""))):
			errors.append("Invention '%s' references missing facility '%s'." % [invention_id, invention.get("facility", "")])
		for item_id in (invention.get("items", {}) as Dictionary).keys():
			if not _known_item_id(StringName(item_id)):
				errors.append("Invention '%s' requires unknown item '%s'." % [invention_id, item_id])
	for invention_id in CampaignState.EXPEDITION_TOOL_CONTRACTS:
		if not CampaignState.INVENTION_DEFINITIONS.has(invention_id):
			errors.append("Expedition tool '%s' has no invention definition." % invention_id)
			continue
		if CampaignState.invention_category(StringName(invention_id)) != &"expedition_tool":
			errors.append("Expedition tool '%s' has the wrong invention category." % invention_id)
		var contract: Dictionary = CampaignState.EXPEDITION_TOOL_CONTRACTS[invention_id]
		for required_field in [&"story_use", &"optional_use", &"town_use"]:
			if String(contract.get(required_field, "")).is_empty():
				errors.append("Expedition tool '%s' is missing %s." % [invention_id, required_field])
		var action_id := StringName(contract.get("battle_action", &""))
		if CampaignCombatDatabase.action(action_id).is_empty():
			errors.append("Expedition tool '%s' references missing battle action '%s'." % [invention_id, action_id])
		var town_job_id := StringName(contract.get("town_job", &""))
		var town_use_found := false
		for facility_name in CampaignState.FACILITY_DEFINITIONS:
			for job in (CampaignState.FACILITY_DEFINITIONS[facility_name] as Dictionary).get("jobs", []):
				if StringName(job.get("id", &"")) == town_job_id:
					town_use_found = CampaignState.job_supports_invention(String(facility_name), town_job_id, StringName(invention_id))
		if not town_use_found:
			errors.append("Expedition tool '%s' does not accelerate its declared town job '%s'." % [invention_id, town_job_id])


static func _validate_armory_stock(errors: Array[String]) -> void:
	var supported_elements := {}
	var known_affinities := {}
	for character_id in CampaignState.EQUIPMENT_AFFINITIES:
		for affinity in CampaignState.EQUIPMENT_AFFINITIES[character_id]:
			known_affinities[StringName(affinity)] = true
	for action_id in CampaignCombatDatabase.action_ids():
		var element := StringName(CampaignCombatDatabase.action(action_id).get("element", &""))
		if element != &"":
			supported_elements[element] = true
	for stock_id in CampaignState.ARMORY_STOCK:
		var item: Dictionary = CampaignState.ARMORY_STOCK[stock_id]
		if StringName(item.get("id", &"")) != StringName(stock_id):
			errors.append("Armory item '%s' has a missing or mismatched id." % stock_id)
		if String(item.get("base_name", "")).is_empty() or int(item.get("price", 0)) <= 0:
			errors.append("Armory item '%s' is missing a name or positive price." % stock_id)
		if StringName(item.get("slot", &"")) not in CampaignState.EQUIPMENT_SLOTS:
			errors.append("Armory item '%s' uses invalid equipment slot '%s'." % [stock_id, item.get("slot", "")])
		var icon_path := String(item.get("icon", ""))
		if icon_path.is_empty() or not ResourceLoader.exists(icon_path):
			errors.append("Armory item '%s' has a missing icon: %s." % [stock_id, icon_path])
		for raw_element in (item.get("element_rates", {}) as Dictionary):
			var element := StringName(raw_element)
			var rate := float(item["element_rates"][raw_element])
			if not supported_elements.has(element):
				errors.append("Armory item '%s' resists unsupported element '%s'." % [stock_id, element])
			elif rate < 0.25 or rate > 0.9:
				errors.append("Armory item '%s' has invalid resistance rate %.2f for '%s'." % [stock_id, rate, element])
		for raw_affinity in item.get("required_affinities", []):
			if not known_affinities.has(StringName(raw_affinity)):
				errors.append("Armory item '%s' requires unknown equipment affinity '%s'." % [stock_id, raw_affinity])


static func _validate_facility_upgrades(errors: Array[String]) -> void:
	for upgrade_id in CampaignState.FACILITY_UPGRADE_DEFINITIONS:
		var upgrade: Dictionary = CampaignState.FACILITY_UPGRADE_DEFINITIONS[upgrade_id]
		var facility_name := String(upgrade.get("facility", ""))
		if not CampaignState.FACILITY_DEFINITIONS.has(facility_name):
			errors.append("Facility upgrade '%s' references missing facility '%s'." % [upgrade_id, facility_name])
		if String(upgrade.get("field_benefit", "")).is_empty():
			errors.append("Facility upgrade '%s' is missing its field benefit." % upgrade_id)
		for item_id in (upgrade.get("items", {}) as Dictionary).keys():
			if not _known_item_id(StringName(item_id)):
				errors.append("Facility upgrade '%s' requires unknown item '%s'." % [upgrade_id, item_id])


static func _validate_quests(errors: Array[String]) -> void:
	var visit_states := {}
	for quest_id in CampaignState.QUEST_DEFINITIONS:
		var quest: Dictionary = CampaignState.QUEST_DEFINITIONS[quest_id]
		if String(quest.get("title", "")).is_empty() or quest.get("steps", []).is_empty():
			errors.append("Quest '%s' is missing a title or steps." % quest_id)
		for required_quest in quest.get("requires_quests", []):
			if not CampaignState.QUEST_DEFINITIONS.has(required_quest):
				errors.append("Quest '%s' requires missing quest '%s'." % [quest_id, required_quest])
		for required_quest in quest.get("requires_any_quests", []):
			if not CampaignState.QUEST_DEFINITIONS.has(required_quest):
				errors.append("Quest '%s' has missing alternate prerequisite '%s'." % [quest_id, required_quest])
		for item_id in (quest.get("rewards", {}).get("items", {}) as Dictionary).keys():
			if not _known_item_id(StringName(item_id)):
				errors.append("Quest '%s' rewards unknown item '%s'." % [quest_id, item_id])
		var choice_ids := {}
		for raw_choice in quest.get("choices", []):
			var choice: Dictionary = raw_choice
			var choice_id := StringName(choice.get("id", &""))
			if choice_id == &"" or choice_ids.has(choice_id):
				errors.append("Quest '%s' has a missing or duplicate choice id '%s'." % [quest_id, choice_id])
			choice_ids[choice_id] = true
			if String(choice.get("name", "")).is_empty() or String(choice.get("outcome", "")).is_empty():
				errors.append("Quest '%s' choice '%s' is missing a name or committed outcome." % [quest_id, choice_id])
			for item_id in (choice.get("rewards", {}).get("items", {}) as Dictionary).keys():
				if not _known_item_id(StringName(item_id)):
					errors.append("Quest '%s' choice '%s' rewards unknown item '%s'." % [quest_id, choice_id, item_id])
		var objectives_by_id := {}
		for raw_objective in quest.get("objectives", []):
			var objective: Dictionary = raw_objective
			var objective_id := StringName(objective.get("id", ""))
			if objective_id == &"" or objectives_by_id.has(objective_id):
				errors.append("Quest '%s' has a missing or duplicate objective id '%s'." % [quest_id, objective_id])
			objectives_by_id[objective_id] = objective
		for objective_id in objectives_by_id:
			for required_id in objectives_by_id[objective_id].get("requires", []):
				if not objectives_by_id.has(StringName(required_id)):
					errors.append("Quest '%s' objective '%s' requires missing objective '%s'." % [quest_id, objective_id, required_id])
		var objective_visit_states := {}
		for objective_id in objectives_by_id:
			_visit_objective_dependencies(StringName(objective_id), objectives_by_id, objective_visit_states, errors, StringName(quest_id))
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


static func _validate_balance_contracts(errors: Array[String]) -> void:
	for source_error in CAMPAIGN_BALANCE_HARNESS.validate_material_sources():
		errors.append("Balance material contract: %s." % source_error)


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


static func _visit_objective_dependencies(objective_id: StringName, objectives_by_id: Dictionary, visit_states: Dictionary, errors: Array[String], quest_id: StringName) -> void:
	var state := int(visit_states.get(objective_id, 0))
	if state == 1:
		errors.append("Quest '%s' objective tree has a dependency cycle at '%s'." % [quest_id, objective_id])
		return
	if state == 2:
		return
	visit_states[objective_id] = 1
	for required_id in objectives_by_id[objective_id].get("requires", []):
		var normalized_id := StringName(required_id)
		if objectives_by_id.has(normalized_id):
			_visit_objective_dependencies(normalized_id, objectives_by_id, visit_states, errors, quest_id)
	visit_states[objective_id] = 2


static func _known_item_id(item_id: StringName) -> bool:
	return CampaignState.SERVICE_ITEM_CATALOG.has(item_id) or item_id in [&"research_notes", &"anchor_dust", &"anchor_shard", &"anchor_core", &"ectoplasm"]
