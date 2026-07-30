class_name EmpyrealEncounterController
extends EncounterDirector


func _configure_region() -> void:
	origin = Vector2i(216, 32)
	size = Vector2i(28, 18)
	universe_id = &"empyreal_court"
	encounter_count_flag = &"empyreal_encounter_count"


func _scripted_encounter(local: Vector2i) -> StringName:
	if Rect2i(0, 4, 8, 4).has_point(local) and not CampaignState.story_flags.get(&"empyreal_landing_cleared", false):
		return &"empyreal_landing_intro"
	if Rect2i(10, 14, 8, 4).has_point(local) and not CampaignState.story_flags.get(&"empyreal_aerie_ambush_cleared", false):
		return &"empyreal_aerie_ambush"
	if Rect2i(20, 14, 8, 4).has_point(local) and local.x >= 23 and CampaignState.story_flags.get(&"empyreal_tribunal_open", false) and not CampaignState.story_flags.get(&"empyreal_scenario_complete", false):
		return &"empyreal_high_comptroller"
	return &""


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(10, 4, 8, 4).has_point(local) or Rect2i(20, 4, 8, 4).has_point(local) or Rect2i(10, 14, 8, 4).has_point(local)


func _random_encounter(local: Vector2i) -> StringName:
	if local.y >= 10:
		return &"empyreal_aerie_patrol"
	if local.x >= 20:
		return &"empyreal_forum_patrol"
	return &"empyreal_garden_patrol"


func _apply_victory(encounter_id: StringName) -> void:
	match encounter_id:
		&"empyreal_landing_intro":
			CampaignState.story_flags[&"empyreal_landing_cleared"] = true
		&"empyreal_aerie_ambush":
			CampaignState.story_flags[&"empyreal_aerie_ambush_cleared"] = true
		&"empyreal_high_comptroller":
			CampaignState.story_flags[&"empyreal_scenario_complete"] = true
			CampaignState.story_flags[&"seventh_universe_stabilized"] = true
			CampaignState.discover_recruit(&"archangel_commander")
			CampaignState.commit_campaign_ending_result()
