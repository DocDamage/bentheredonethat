class_name CampaignBattleLifecycle
extends RefCounted

## Campaign-state transitions belong at this boundary, not in the CanvasLayer
## that renders combat. This keeps the ATB model and future address encounter
## records independent from menu and stage construction.


static func clear_encounter_pressure() -> void:
	CampaignState.clear_encounter_pressure()


static func record_encounter_sighting(encounter_id: StringName, enemy_types: Array[StringName]) -> void:
	CampaignState.record_bestiary_sighting(encounter_id, enemy_types)


static func apply_victory(encounter_id: StringName, enemy_types: Array[StringName], reward: Dictionary) -> Dictionary:
	CampaignState.record_bestiary_victory(encounter_id, enemy_types, reward.get("loot", []))
	var levels := CampaignState.apply_battle_victory(int(reward.get("experience", 0)), int(reward.get("duckets", 0)), reward.get("loot", []))
	if encounter_id == &"mansion_foyer_intro":
		CampaignState.story_flags[&"mansion_foyer_cleared"] = true
	if encounter_id == &"ashfall_cinder_gate_arrival_raid":
		CampaignState.story_flags[&"ashfall_cinder_gate_arrival_raid_cleared"] = true
	return levels


static func commit_victory_autosave() -> int:
	return CampaignState.save_game()


static func retry_last_save() -> void:
	CampaignState.load_game()


static func return_party_to_town() -> void:
	CampaignState.revive_party_at_one()
