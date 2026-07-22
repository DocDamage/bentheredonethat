extends Node

const BATTLE_SCENE := preload("res://ben_rpg/combat/campaign_battle.tscn")


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.recruit_status[&"fighter"] = &"reserve"
	CampaignState.add_to_party(&"fighter")
	var battle := BATTLE_SCENE.instantiate() as CampaignBattle
	battle.suppress_persistence = true
	add_child(battle)
	await get_tree().process_frame
	battle.begin(&"mansion_foyer_intro", 1776)
