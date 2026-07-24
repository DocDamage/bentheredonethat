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
	_assert_legacy_save_contract()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	print("CORE_PROTAGONIST_TRIO_SMOKE_OK ids=ben_lincoln_gandhi opening_party=3 profiles=4 combat_roles=distinct migration=v20_to_v21")
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
