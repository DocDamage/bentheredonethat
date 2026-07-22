class_name HeliosEncounterController
extends EncounterDirector


func _configure_region() -> void:
	origin = Vector2i(108, 32)
	size = Vector2i(28, 18)
	universe_id = &"helios_arcology"
	encounter_count_flag = &"helios_encounter_count"


func _scripted_encounter(local: Vector2i) -> StringName:
	if Rect2i(1, 4, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"helios_skybridge_cleared", false): return &"helios_skybridge_intro"
	if Rect2i(11, 14, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"helios_clinic_ambush_cleared", false): return &"helios_clinic_ambush"
	if Rect2i(21, 14, 6, 3).has_point(local) and local.x >= 23 and CampaignState.story_flags.get(&"helios_core_open", false) and not CampaignState.story_flags.get(&"helios_scenario_complete", false): return &"helios_civic_sun"
	return &""


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(11, 4, 6, 3).has_point(local) or Rect2i(21, 4, 6, 3).has_point(local) or Rect2i(11, 14, 6, 3).has_point(local)


func _random_encounter(local: Vector2i) -> StringName:
	if local.y >= 10: return &"helios_clinic_patrol"
	if local.x >= 20: return &"helios_transit_patrol"
	return &"helios_market_patrol"


func _apply_victory(encounter_id: StringName) -> void:
	match encounter_id:
		&"helios_skybridge_intro": CampaignState.story_flags[&"helios_skybridge_cleared"] = true
		&"helios_clinic_ambush": CampaignState.story_flags[&"helios_clinic_ambush_cleared"] = true
		&"helios_civic_sun":
			CampaignState.story_flags[&"helios_scenario_complete"] = true
			CampaignState.story_flags[&"fourth_universe_stabilized"] = true
		&"helios_cobalt_courier_trial":
			CampaignState.story_flags[&"cobalt_courier_trial_complete"] = true
			CampaignState.story_flags[&"cobalt_courier_recruit_unlocked"] = true
			CampaignState.discover_recruit(&"cobalt_courier")
