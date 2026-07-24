extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	var model := AtbBattleModel.new()
	var fixture_party: Array[StringName] = [&"ben", &"fighter"]
	model.setup(&"mansion_foyer_intro", fixture_party, CampaignState.character_progress, 1776)
	assert(model.actors.size() == 5, "Expected Ben, Fighter, pet, and two enemies")
	for actor in model.actors:
		actor["atb"] = 0.0
	var ready := model.tick_atb(3.0)
	assert(&"velociraptor" in ready, "The fastest combatant should fill its ATB first")
	assert(&"fighter" not in ready, "Slower gauges must still be filling")
	var enemy: Dictionary = model.living("enemy")[0]
	var enemy_hp := int(enemy["hp"])
	model.get_actor(&"velociraptor")["atb"] = 100.0
	var events := model.resolve_action(&"velociraptor", &"raptor_pounce", [StringName(enemy["id"])])
	assert(not events.is_empty() and int(enemy["hp"]) < enemy_hp, "Raptor pounce should cause damage")
	var guard_target := model.get_actor(&"ben")
	guard_target["atb"] = 100.0
	model.resolve_action(&"ben", &"defend", [&"ben"])
	assert(guard_target["guarding"], "Defend should persist until Ben's next action")
	for foe in model.living("enemy"):
		while foe["alive"]:
			var fighter := model.get_actor(&"fighter")
			fighter["atb"] = 100.0
			model.resolve_action(&"fighter", &"attack", [StringName(foe["id"])])
	assert(model.outcome() == &"victory", "Defeating every enemy should end the encounter")
	var reward := model.rewards()
	assert(int(reward["experience"]) == 50 and int(reward["duckets"]) == 19, "Encounter rewards should match its formation")
	var old_duckets := CampaignState.duckets
	CampaignState.apply_battle_victory(reward["experience"], reward["duckets"], reward["loot"])
	assert(CampaignState.duckets == old_duckets + 19, "Duckets should persist")
	assert(int(CampaignState.character_progress[&"ben"]["level"]) == 2, "EXP should level Ben")
	assert(not CampaignState.loot_inventory.is_empty(), "The scripted first encounter must drop randomized gear")
	print("ATB_BATTLE_SMOKE_OK ready=%s reward=%dEXP/%dD loot=%s" % [ready, reward["experience"], reward["duckets"], CampaignState.loot_inventory[0]["display_name"]])
	get_tree().quit()
