extends Node

const TEST_SAVE := "user://core_protagonist_trio_smoke.json"
const CORE_TRIO := [&"ben", &"lincoln", &"gandhi"]
const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	_assert_new_campaign_contract()
	_assert_combat_contract()
	_assert_progression_equipment_and_defeat_contract()
	_assert_story_participation_contract()
	_assert_legacy_save_contract()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	print("CORE_PROTAGONIST_TRIO_SMOKE_OK ids=ben_lincoln_gandhi opening_party=3 formation+equipment+progression+revival=true profiles=4 combat_roles=distinct story=opening+ending migration=v20_to_v21")
	get_tree().quit(0)


func _assert_new_campaign_contract() -> void:
	assert(CampaignState.party == CORE_TRIO, "A new campaign must begin with the complete protagonist trio.")
	var profiles = VISUAL_PROFILES.new()
	for recruit_id in CORE_TRIO:
		assert(CampaignState.recruit_status.get(recruit_id) == &"party", "%s must join during the opening chapter." % recruit_id)
		var definition: Dictionary = CampaignState.recruit_catalog.get(recruit_id, {})
		assert(not definition.is_empty(), "%s needs a stable campaign catalog record." % recruit_id)
		var animation_scene := String(definition.get("field_animation_scene", ""))
		if recruit_id != &"ben":
			assert(ResourceLoader.exists(animation_scene), "%s needs a field/follower animation scene." % recruit_id)
		assert(profiles.has(StringName(definition.get("battle_profile", &""))), "%s needs a battle profile." % recruit_id)
		assert(profiles.has(StringName(definition.get("portrait_profile", &""))), "%s needs a portrait profile." % recruit_id)


func _assert_combat_contract() -> void:
	var lincoln := CampaignCombatDatabase.party_actor(&"lincoln", CampaignState.character_progress[&"lincoln"])
	var gandhi := CampaignCombatDatabase.party_actor(&"gandhi", CampaignState.character_progress[&"gandhi"])
	assert(lincoln.get("id") == &"lincoln" and &"rally" in lincoln.get("actions", []), "Lincoln must retain a protection/leadership combat identity.")
	assert(gandhi.get("id") == &"gandhi" and &"field_triage" in gandhi.get("actions", []), "Gandhi must retain a recovery/de-escalation combat identity.")
	var model := AtbBattleModel.new()
	var battle_party: Array[StringName] = [ &"ben", &"lincoln", &"gandhi" ]
	model.setup(&"mansion_restless_books", battle_party, CampaignState.character_progress, 1776)
	for recruit_id in CORE_TRIO:
		assert(not model.get_actor(recruit_id).is_empty(), "%s was lost from the trio battle formation." % recruit_id)


func _assert_progression_equipment_and_defeat_contract() -> void:
	assert(CampaignState.party_formation == {&"ben": &"back", &"lincoln": &"front", &"gandhi": &"back"}, "The opening trio needs an authored support/frontline formation.")
	CampaignState.loot_inventory.append_array([
		{"instance_id": "lincoln-charter-coat", "id": &"charter_coat", "slot": &"body", "kind": "gear", "required_affinities": [&"frontline"], "modifiers": [{"stat": "defense", "value": 4}]},
		{"instance_id": "gandhi-mercy-charm", "id": &"mercy_charm", "slot": &"accessory", "kind": "gear", "required_affinities": [&"radiant"], "modifiers": [{"stat": "spirit", "value": 4}]},
	])
	assert(CampaignState.equip_loot(&"lincoln", "lincoln-charter-coat"), "Lincoln must support compatible protection equipment.")
	assert(CampaignState.equip_loot(&"gandhi", "gandhi-mercy-charm"), "Gandhi must support compatible equipment.")
	CampaignState.character_progress[&"lincoln"]["skill_points"] = 2
	CampaignState.character_progress[&"gandhi"]["skill_points"] = 2
	assert(CampaignState.learn_skill(&"lincoln", &"charter_guard") and CampaignState.learn_skill(&"lincoln", &"civic_resolve"), "Lincoln must retain a dedicated protection progression path.")
	assert(CampaignState.learn_skill(&"gandhi", &"mercy_practice") and CampaignState.learn_skill(&"gandhi", &"field_medicine"), "Gandhi must retain a dedicated recovery progression path.")
	CampaignState.apply_battle_victory(120, 0, [])
	for recruit_id in CORE_TRIO:
		assert(int(CampaignState.character_progress[recruit_id].get("exp", 0)) > 0, "%s must receive victory progression." % recruit_id)
		var stats: Dictionary = CampaignState.recruit_catalog[recruit_id].get("combat_stats", {})
		CampaignState.set_character_vitals(recruit_id, 0, 0, int(stats.get("max_hp", 140)), int(stats.get("max_mp", 36)))
		CampaignState.add_item(&"phoenix_tonic", 1, false)
		assert(bool(CampaignState.use_field_item(&"phoenix_tonic", recruit_id).get("used", false)), "%s must be revivable after a knockout." % recruit_id)
		assert(int(CampaignState.character_progress[recruit_id].get("hp", 0)) > 0, "%s revival did not restore HP." % recruit_id)
	assert(CampaignState.save_game(TEST_SAVE) == OK, "The trio's formation, equipment, and progress must save.")
	CampaignState.reset_new_game()
	assert(CampaignState.load_game(TEST_SAVE) == OK and CampaignState.party == CORE_TRIO, "The trio must restore after save/load.")
	assert(CampaignState.character_progress[&"lincoln"].get("equipment", {}).get(&"body", "") == "lincoln-charter-coat", "Lincoln's equipment did not persist.")
	assert(CampaignState.character_progress[&"gandhi"].get("equipment", {}).get(&"accessory", "") == "gandhi-mercy-charm", "Gandhi's equipment did not persist.")


func _assert_story_participation_contract() -> void:
	var opening_text := FileAccess.get_file_as_string("res://overworld/maps/opening_cutscene.dtl")
	assert("LINCOLN:" in opening_text and "GANDHI:" in opening_text, "Lincoln and Gandhi must participate in the authored opening dialogue.")


func _assert_legacy_save_contract() -> void:
	var legacy := CampaignState.call(&"_serialize") as Dictionary
	legacy["version"] = 20
	legacy["party"] = [&"ben", &"fighter"]
	legacy["party_formation"] = {&"ben": &"back", &"fighter": &"front"}
	legacy["recruit_status"] = {&"ben": &"party", &"fighter": &"party"}
	var migration := CampaignState.SAVE_MIGRATOR.migrate(legacy)
	assert(bool(migration.get("ok", false)) and int(migration.get("data", {}).get("version", 0)) == CampaignState.SAVE_VERSION, "v20 saves must migrate to the trio schema.")
	assert((migration.get("steps", PackedInt32Array()) as PackedInt32Array).size() == 1, "v20 saves must cross the explicit v20-to-v21 boundary.")
	var file := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	assert(file != null)
	file.store_string(JSON.stringify(legacy))
	file.close()
	assert(CampaignState.load_game(TEST_SAVE) == OK)
	assert(CampaignState.party == [&"ben", &"fighter"], "Migration must not displace a player's existing active formation.")
	for recruit_id in [&"lincoln", &"gandhi"]:
		assert(CampaignState.recruit_status.get(recruit_id) == &"reserve", "%s must remain available after migration." % recruit_id)
