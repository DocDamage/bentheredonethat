extends Node

const SAVE_PATH := "user://phase6_population_progression_side_content_smoke.json"
const POPULATION := preload("res://ben_rpg/world/campaign_population_scheduler.gd")
const POPULATION_VISUALS := preload("res://ben_rpg/world/campaign_population_visual_registry.gd")
const POPULATION_FACTORY := preload("res://ben_rpg/world/campaign_population_actor_factory.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ANNEX := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const SIDE_CONTENT := preload("res://ben_rpg/core/campaign_side_content_catalog.gd")
const BALANCE := preload("res://ben_rpg/core/campaign_balance_harness.gd")
const CONTENT_VALIDATOR := preload("res://ben_rpg/core/content_validator.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.SAVE_REPOSITORY.cleanup(SAVE_PATH)
	CampaignState.reset_new_game()
	assert(POPULATION.validate().is_empty())
	assert(POPULATION_VISUALS.validate().is_empty())
	assert(SIDE_CONTENT.validate().is_empty())
	var content_errors := CONTENT_VALIDATOR.validate_all()
	assert(content_errors.is_empty(), "Content validation failed: %s" % [content_errors])
	var identities := POPULATION.all_identities()
	assert(identities.size() == 258)
	var seen_ids := {}
	var seen_profiles := {}
	var scheduled := 0
	var actors := 0
	for identity in identities:
		var identity_id := StringName(identity.get("id", &""))
		var profile_id := StringName(identity.get("runtimeProfileId", &""))
		var home := StringName(identity.get("canonicalHome", &""))
		var schedule_record: Dictionary = identity.get("schedule", {})
		assert(identity_id != &"" and not seen_ids.has(identity_id))
		assert(profile_id != &"" and not seen_profiles.has(profile_id))
		seen_ids[identity_id] = true
		seen_profiles[profile_id] = true
		var definition := ROOM_REGISTRY.room(home) if ROOM_REGISTRY.has_room(home) else ANNEX.room(home)
		assert(not definition.is_empty(), "%s has no production home %s" % [identity_id, home])
		var anchor := StringName(schedule_record.get("anchor", &""))
		var anchors: Dictionary = definition.get("populationAnchorCells", {})
		assert(anchors.has(anchor), "%s home %s lacks %s" % [identity_id, home, anchor])
		var reserved := POPULATION.reserved_cells_for_room(home, definition)
		var result := POPULATION.schedule_profiles(home, [{
			"id": identity_id, "runtimeProfileId": profile_id, "anchor": anchor,
		}], anchors, reserved, definition.get("dimensions", Vector2i.ZERO))
		assert((result.get("assignments", []) as Array).size() == 1, "%s conflicts with a reserved home cell" % identity_id)
		scheduled += 1
		var actor := POPULATION_FACTORY.create((result.get("assignments", []) as Array)[0])
		assert(actor != null)
		for direction in [&"north", &"north-east", &"east", &"south-east", &"south", &"south-west", &"west", &"north-west"]:
			assert(bool(actor.call("face", direction)), "%s lacks %s runtime art" % [identity_id, direction])
		actors += 1
		actor.free()
	assert(scheduled == 258 and actors == 258)
	assert(CampaignState.party.slice(0, 3) == [&"ben", &"lincoln", &"gandhi"])
	assert(CampaignState.recruit_status.get(&"lincoln") == &"party" and CampaignState.recruit_status.get(&"gandhi") == &"party")
	var lincoln_scene := FileAccess.get_file_as_string("res://ben_rpg/characters/abe_lincoln_gamepiece.tscn")
	var gandhi_scene := FileAccess.get_file_as_string("res://ben_rpg/characters/gandhi_gamepiece.tscn")
	assert("core_protagonist_interaction.gd" in lincoln_scene and "expansion_trial_recruit_interaction.gd" not in lincoln_scene)
	assert("core_protagonist_interaction.gd" in gandhi_scene and "expansion_trial_recruit_interaction.gd" not in gandhi_scene)
	assert(CampaignState.REQUIRED_NAMED_CHARACTER_ARCS.size() == 3)
	var required_named := {}
	for arc in CampaignState.REQUIRED_NAMED_CHARACTER_ARCS.values():
		for character_id in (arc as Dictionary).get("characters", []): required_named[character_id] = true
	for character_id in [&"dracula", &"frankenstein_monster", &"cthulhu", &"dark_mage"]:
		assert(required_named.has(character_id))
	assert(CampaignState.FACILITY_DEFINITIONS.size() == 11 and CampaignState.INVENTION_DEFINITIONS.size() == 12)
	assert(CampaignState.SKILL_TREES.size() == 15 and CampaignCombatDatabase.bestiary_ids().size() >= 39)
	var balance := BALANCE.run_suite(25)
	assert(bool(balance.get("passed", false)))
	for profile_id in [&"low_combat", &"median_combat", &"high_combat", &"minimum_job", &"offline_heavy"]:
		assert(int((balance.get("profiles", {}) as Dictionary).get(profile_id, {}).get("passed", 0)) == 25)
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	var notes_before := int(CampaignState.inventory.get(&"research_notes", 0))
	assert(not SIDE_CONTENT.claim_rare_event(&"midnight_library_exchange").is_empty())
	assert(SIDE_CONTENT.claim_rare_event(&"midnight_library_exchange").is_empty())
	assert(int(CampaignState.inventory.get(&"research_notes", 0)) == notes_before + 1)
	CampaignState.story_flags[&"postgame_unlocked"] = true
	assert(not SIDE_CONTENT.claim_rare_event(&"tribunal_open_house").is_empty())
	assert(CampaignState.save_game(SAVE_PATH) == OK)
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(SAVE_PATH) == OK)
	assert(bool(CampaignState.story_flags.get(&"rare_midnight_library_exchange_claimed", false)))
	assert(SIDE_CONTENT.claim_rare_event(&"midnight_library_exchange").is_empty())
	CampaignState.SAVE_REPOSITORY.cleanup(SAVE_PATH)
	print("PHASE6_POPULATION_PROGRESSION_SIDE_CONTENT_SMOKE_OK identities=258 profiles=258 directions=8 homes=valid cohorts=max6 protagonists=core named_arcs=4 jobs+inventions+skills+bestiary=true simulations=200 rare_rewards=idempotent postgame_reactions=true")
	get_tree().quit(0)
