extends Node

const PRESENTATION := preload("res://ben_rpg/combat/battle_presentation_catalog.gd")


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.recruit_status[&"fighter"] = &"reserve"
	assert(CampaignState.add_to_party(&"fighter"), "Fighter should join the combat-depth test party")
	_test_elements_and_statuses()
	_test_consumables_and_revival()
	_test_smart_ai_and_escape()
	_test_supplied_presentation_assets()
	print("JRPG_COMBAT_DEPTH_SMOKE_OK elements=weak+resist statuses=poison+slow+shock items=hp+mp+cleanse+revive ai=threat+boss_pattern escape=random_only vfx=8x30 sfx=true")
	get_tree().quit(0)


func _test_elements_and_statuses() -> void:
	var model := AtbBattleModel.new()
	model.setup(&"mansion_foyer_intro", CampaignState.party, CampaignState.character_progress, 1944)
	var ben := model.get_actor(&"ben")
	ben["atb"] = 100.0
	var events := model.resolve_action(&"ben", &"static_discharge", [])
	var reactions: Dictionary = {}
	for event in events:
		if event.get("type") != "damage":
			continue
		var target: Dictionary = model.get_actor(StringName(event["target"]))
		reactions[StringName(target.get("enemy_type", &""))] = StringName(event.get("reaction", &""))
	assert(reactions.get(&"schoolgirl_ghost") == &"weak", "Lightning should expose the apparition's weakness")
	assert(reactions.get(&"war_book") == &"resist", "The War Book should visibly resist lightning")

	var fighter := model.get_actor(&"fighter")
	var status_events: Array[Dictionary] = []
	model._apply_action_status(fighter, {"status": &"poisoned", "status_chance": 1.0}, status_events)
	assert((fighter["statuses"] as Dictionary).has(&"poisoned"), "Poison should be a timed actor ailment")
	var hp_before := int(fighter["hp"])
	fighter["atb"] = 100.0
	model.resolve_action(&"fighter", &"defend", [&"fighter"])
	assert(int(fighter["hp"]) < hp_before, "Poison should deal max-HP-based damage after an action")

	ben["statuses"] = {&"slow": 3, &"shocked": 2}
	ben["atb"] = 0.0
	fighter["atb"] = 0.0
	model.tick_atb(1.0)
	assert(float(ben["atb"]) < float(fighter["atb"]), "Slow and Shock should reduce ATB fill rather than being cosmetic labels")
	assert(model.status_summary(&"ben").contains("SLOW") and model.status_summary(&"ben").contains("SHOCK"), "Visible status summary should expose active ailments")


func _test_consumables_and_revival() -> void:
	var model := AtbBattleModel.new()
	model.setup(&"mansion_restless_books", CampaignState.party, CampaignState.character_progress, 1776)
	var ben := model.get_actor(&"ben")
	var fighter := model.get_actor(&"fighter")
	CampaignState.inventory[&"ether"] = 1
	ben["mp"] = 0
	fighter["atb"] = 100.0
	model.resolve_action(&"fighter", &"ether", [&"ben"])
	assert(int(ben["mp"]) == 24 and int(CampaignState.inventory[&"ether"]) == 0, "Leyden Ether should restore MP and consume inventory")

	CampaignState.inventory[&"smelling_salts"] = 1
	ben["statuses"] = {&"poisoned": 4, &"slow": 3, &"shocked": 2}
	fighter["atb"] = 100.0
	model.resolve_action(&"fighter", &"smelling_salts", [&"ben"])
	assert((ben["statuses"] as Dictionary).is_empty(), "Smelling Salts should cleanse all supported ailments")

	CampaignState.inventory[&"phoenix_tonic"] = 1
	fighter["hp"] = 0
	fighter["alive"] = false
	ben["atb"] = 100.0
	var revive_targets := model.valid_targets(&"ben", &"phoenix_tonic")
	assert(revive_targets.size() == 1 and revive_targets[0]["id"] == &"fighter", "Revival should target fallen company members, not living actors or the pet")
	model.resolve_action(&"ben", &"phoenix_tonic", [&"fighter"])
	assert(fighter["alive"] and int(fighter["hp"]) == int(round(float(fighter["max_hp"]) * 0.25)), "Phoenix Tonic should revive at 25 percent HP")
	assert(int(CampaignState.inventory[&"phoenix_tonic"]) == 0, "Revival must consume the persistent item")


func _test_smart_ai_and_escape() -> void:
	var model := AtbBattleModel.new()
	model.setup(&"mansion_lost_hours", CampaignState.party, CampaignState.character_progress, 42)
	var enemies := model.living("enemy")
	enemies[0]["atb"] = 35.0
	enemies[1]["atb"] = 86.0
	var raptor_choice := model.choose_ai_action(&"velociraptor")
	assert(raptor_choice["action"] == &"raptor_distract" and raptor_choice["targets"][0] == enemies[1]["id"], "The raptor should disrupt the enemy closest to acting")

	var boss_model := AtbBattleModel.new()
	boss_model.setup(&"mansion_archive_boss", CampaignState.party, CampaignState.character_progress, 9)
	var boss: Dictionary = boss_model.living("enemy")[0]
	boss["atb"] = 100.0
	var boss_choice := boss_model.choose_ai_action(StringName(boss["id"]))
	assert(boss_choice["action"] == &"spectral_touch" and boss_model.status_summary(StringName(boss["id"])).contains("TICKING"), "Boss AI should begin in a readable clock state")
	assert(not boss_model.can_escape(), "Boss encounters must seal escape")
	var ben := boss_model.get_actor(&"ben")
	ben["atb"] = 100.0
	var failed_escape := boss_model.resolve_action(&"ben", &"escape", [&"ben"])
	assert(failed_escape.any(func(event: Dictionary) -> bool: return event.get("type") == "escape_failed"), "Scripted escape should fail with explicit feedback")

	var random_model := AtbBattleModel.new()
	random_model.setup(&"mansion_restless_books", CampaignState.party, CampaignState.character_progress, 5)
	assert(random_model.can_escape(), "Random encounters should allow escape attempts")
	for actor in random_model.living("party"):
		actor["speed"] = 100
	for actor in random_model.living("enemy"):
		actor["speed"] = 1
	for _attempt in range(8):
		var runner := random_model.get_actor(&"ben")
		runner["atb"] = 100.0
		random_model.resolve_action(&"ben", &"escape", [&"ben"])
		if random_model.outcome() == &"escape":
			break
	assert(random_model.outcome() == &"escape", "A fast party should be able to escape a random encounter")


func _test_supplied_presentation_assets() -> void:
	var represented_actions := [&"attack", &"static_discharge", &"field_triage", &"phoenix_tonic", &"rally", &"spectral_touch", &"ink_blight", &"steal_time"]
	var unique_folders: Dictionary = {}
	for action_id in represented_actions:
		var frames := PRESENTATION.effect_frames(action_id)
		assert(frames.size() == 30, "Every represented action should use a complete 30-frame supplied VFX animation")
		assert(ResourceLoader.exists(frames.front()) and ResourceLoader.exists(frames.back()), "VFX frames must be imported from the preserved Alenia pack")
		unique_folders[frames.front().get_base_dir()] = true
		assert(ResourceLoader.exists(PRESENTATION.action_sound(action_id)), "Each combat family should use supplied RPG sound effects")
	assert(unique_folders.size() == 8, "The combat layer should exercise eight distinct supplied VFX families")
