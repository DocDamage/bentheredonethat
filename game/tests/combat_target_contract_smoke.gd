extends Node


func _ready() -> void:
	CampaignState.reset_new_game()
	for recruit_id in [&"fighter", &"archangel_commander"]:
		CampaignState.recruit_status[recruit_id] = &"reserve"
		assert(CampaignState.add_to_party(recruit_id), "%s should join the combat party" % recruit_id)
	var model := AtbBattleModel.new()
	model.setup(&"mansion_foyer_intro", CampaignState.party, CampaignState.character_progress, 1776)
	_test_enemy_targeting(model)
	_test_heavenly_aegis(model)
	print("COMBAT_TARGET_CONTRACT_SMOKE_OK enemy=opponents aegis=formation_guard revival=25pct")
	get_tree().quit()


func _test_enemy_targeting(model: AtbBattleModel) -> void:
	var enemy: Dictionary = model.living("enemy")[0]
	var targets := model.valid_targets(StringName(enemy["id"]), &"spectral_touch")
	assert(not targets.is_empty(), "Enemy actions need available targets")
	for target in targets:
		assert(target["team"] == "party", "Enemy attacks must target the party, never their own team")
	var ben := model.get_actor(&"ben")
	var ben_hp := int(ben["hp"])
	enemy["atb"] = 100.0
	model.resolve_action(StringName(enemy["id"]), &"spectral_touch", [&"ben"])
	assert(int(ben["hp"]) < ben_hp, "Enemy action should damage its selected party target")


func _test_heavenly_aegis(model: AtbBattleModel) -> void:
	var commander := model.get_actor(&"archangel_commander")
	commander["atb"] = 100.0
	var aegis_events := model.resolve_action(&"archangel_commander", &"heavenly_aegis", [])
	assert(aegis_events.any(func(event: Dictionary) -> bool: return event.get("status", &"") == &"aegis"), "Heavenly Aegis should report its defensive effect")
	for ally in model.living("party"):
		assert(ally["guarding"], "Heavenly Aegis must guard every living ally")
		assert(int(ally["attack_bonus"]) == 0, "Heavenly Aegis must not apply Rally's attack bonus")
	var target: Dictionary = model.living("enemy")[0]
	target["hp"] = 9999
	for action in [{"actor": &"ben", "action": &"cane_tap"}, {"actor": &"fighter", "action": &"attack"}, {"actor": &"archangel_commander", "action": &"seraph_strike"}, {"actor": &"velociraptor", "action": &"raptor_pounce"}]:
		var actor := model.get_actor(action["actor"])
		actor["atb"] = 100.0
		model.resolve_action(action["actor"], action["action"], [StringName(target["id"])])
		assert(not actor["guarding"], "Aegis protection should expire after that ally's next action")
