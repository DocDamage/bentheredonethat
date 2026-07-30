class_name CampaignMansionBossInteraction
extends Interaction

@export var encounter_id: StringName = &"mansion_archive_boss"
@export var defeated_flag: StringName = &"mansion_archive_boss_defeated"


func _execute() -> void:
	begin_encounter()


func begin_encounter() -> bool:
	if bool(CampaignState.story_flags.get(defeated_flag, false)):
		return false
	var battle := _campaign_battle()
	return battle.begin(encounter_id) if battle else false


func _campaign_battle() -> CampaignBattle:
	for root_child in get_tree().root.get_children():
		var battle := root_child.get_node_or_null("CampaignBattle") as CampaignBattle
		if battle:
			return battle
	return null
