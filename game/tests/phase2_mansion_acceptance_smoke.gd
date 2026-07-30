extends Node

const SAVE_PATH := "user://phase2_mansion_acceptance_smoke.json"
const REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ROUTER := preload("res://ben_rpg/world/campaign_transition_router.gd")
const LIFECYCLE := preload("res://ben_rpg/combat/campaign_battle_lifecycle.gd")
const CHAPTER_INTERACTION := preload("res://ben_rpg/world/mansion_chapter_interaction.gd")
const CLUE_INTERACTION := preload("res://ben_rpg/world/mansion_clue_interaction.gd")
const PACING := preload("res://ben_rpg/core/campaign_mansion_pacing.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.party = [&"ben", &"fighter", &"lincoln", &"gandhi"]
	_assert_contracts()
	assert(PACING.validate().is_empty())
	assert(PACING.totals() == {"min": 90, "target": 117, "max": 150})
	_assert_first_visit_progression()
	_assert_optional_and_shortcut_progression()
	_assert_save_boundaries()
	_assert_battle_results()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	print("PHASE2_MANSION_ACCEPTANCE_SMOKE_OK rooms=16 interactions=room_owned route=444 optional=independent saves=partial+stabilized battle_results=scene_safe")
	get_tree().quit(0)


func _assert_contracts() -> void:
	assert(REGISTRY.validate().is_empty())
	assert(REGISTRY.MANSION_ROOM_IDS.size() == 16)
	for room_id in REGISTRY.MANSION_ROOM_IDS:
		var definition := REGISTRY.room(room_id)
		assert(String(definition.get("scenePath", "")).begins_with("res://ben_rpg/world/rooms/"), "%s must be scene-owned" % room_id)
		assert(StringName(definition.get("navigationId", &"")).begins_with("authored:"), "%s must own navigation" % room_id)
		assert(StringName(definition.get("collisionMaskId", &"")).begins_with("authored:"), "%s must own collision" % room_id)
		for port in REGISTRY.ports(room_id):
			var port_id := StringName(port.get("id", &""))
			assert(ROUTER.safe_arrival_cell(room_id, port_id) != Vector2i.ZERO, "%s.%s needs a safe arrival" % [room_id, port_id])
	var hm01 := REGISTRY.room(&"HM-01")
	var hm06 := REGISTRY.room(&"HM-06")
	var hm07 := REGISTRY.room(&"HM-07")
	assert((hm01.get("scriptedEncounters", []) as Array).size() == 1)
	assert((hm06.get("scriptedEncounters", []) as Array).size() == 1)
	assert((hm07.get("scriptedEncounters", []) as Array).size() == 1)


func _assert_first_visit_progression() -> void:
	for character_id in [&"ben", &"fighter", &"lincoln", &"gandhi"]:
		assert(character_id in CampaignState.party, "Opening party continuity lost %s" % character_id)
	_victory(&"mansion_foyer_intro")
	assert(CampaignState.story_flags.get(&"mansion_foyer_cleared", false))
	var clock := CLUE_INTERACTION.new()
	clock.clue_kind = &"clock"
	clock.apply_interaction(false)
	var ledger := CLUE_INTERACTION.new()
	ledger.clue_kind = &"bookcase"
	ledger.apply_interaction(false)
	assert(not CampaignState.story_flags.get(&"mansion_first_room_complete", false))
	clock.set_clock_time(&"03:13", false)
	assert(not CampaignState.story_flags.get(&"mansion_first_room_complete", false))
	clock.set_clock_time(&"04:44", false)
	clock.free()
	ledger.free()
	assert(CampaignState.story_flags.get(&"mansion_first_room_complete", false))
	_victory(&"mansion_gallery_ambush")
	_apply(&"gallery_portrait")
	_victory(&"mansion_nursery_ambush")
	_apply(&"nursery_music_box")
	_apply(&"ballroom_gate")
	assert(CampaignState.story_flags.get(&"mansion_ballroom_open", false))
	assert(int(CampaignState.inventory.get(&"silver_hour_hand", 0)) == 1)
	assert(int(CampaignState.inventory.get(&"brass_minute_hand", 0)) == 1)


func _assert_optional_and_shortcut_progression() -> void:
	_apply(&"conservatory_cache")
	_apply(&"mirror_reflection")
	_apply(&"attic_cache")
	_apply(&"attic_stair")
	_apply(&"service_lift")
	_apply(&"kitchen_pantry")
	CampaignState.story_flags[&"mansion_temporal_secret_found"] = true
	_apply(&"chapel_alignment")
	_apply(&"undercroft_cache")
	assert(CampaignState.story_flags.get(&"mansion_conservatory_shutter_open", false))
	assert(CampaignState.story_flags.get(&"mansion_false_reflection_cleared", false))
	assert(CampaignState.story_flags.get(&"mansion_attic_latch_open", false))
	assert(CampaignState.story_flags.get(&"mansion_service_lift_open", false))
	assert(CampaignState.story_flags.get(&"mansion_undercroft_exit_open", false))
	# Optional rooms reward the player but never participate in the Ballroom gate.
	for optional_flag in [&"mansion_conservatory_cache_opened", &"mansion_crypt_key_found", &"mansion_undercroft_cache_opened", &"mansion_attic_cache_opened"]:
		CampaignState.story_flags.erase(optional_flag)
	assert(CampaignState.story_flags.get(&"mansion_ballroom_open", false))


func _assert_save_boundaries() -> void:
	CampaignState.story_flags[&"mansion_clock_time"] = "03:13"
	CampaignState.story_flags.erase(&"mansion_first_room_complete")
	CampaignState.last_manifest_room_id = &"HM-02"
	CampaignState.last_save_cell = REGISTRY.room(&"HM-02").get("worldOrigin", Vector2i.ZERO) + ROUTER.safe_arrival_cell(&"HM-02", &"Nw")
	assert(CampaignState.save_game(SAVE_PATH) == OK)
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(SAVE_PATH) == OK)
	assert(CampaignState.story_flags.get(&"mansion_clock_time", "") == "03:13")
	assert(not CampaignState.story_flags.get(&"mansion_first_room_complete", false))
	assert(CampaignState.last_manifest_room_id == &"HM-02")
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	CampaignState.story_flags[&"mansion_hour_hand_found"] = true
	CampaignState.story_flags[&"mansion_minute_hand_found"] = true
	CampaignState.story_flags[&"mansion_ballroom_open"] = true
	CampaignState.last_manifest_room_id = &"HM-08"
	assert(CampaignState.save_game(SAVE_PATH) == OK)
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(SAVE_PATH) == OK)
	assert(CampaignState.last_manifest_room_id == &"HM-08")
	assert(CampaignState.story_flags.get(&"mansion_ballroom_open", false))


func _assert_battle_results() -> void:
	_victory(&"mansion_archive_boss")
	assert(CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false))
	assert(CampaignState.story_flags.get(&"haunted_mansion_scenario_complete", false))
	assert(CampaignState.story_flags.get(&"first_universe_stabilized", false))
	_apply(&"rain_gate")
	assert(CampaignState.story_flags.get(&"mansion_watch_post_established", false))


func _apply(kind: StringName) -> Array[String]:
	var interaction := CHAPTER_INTERACTION.new()
	interaction.interaction_kind = kind
	var result := interaction.apply_interaction(false)
	interaction.free()
	return result


func _victory(encounter_id: StringName) -> void:
	var enemy_types: Array[StringName] = []
	var loot: Array[Dictionary] = []
	LIFECYCLE.apply_victory(encounter_id, enemy_types, {"experience": 0, "duckets": 0, "loot": loot})
