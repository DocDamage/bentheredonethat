class_name MoonpetalEncounterController
extends EncounterDirector


func _configure_region() -> void:
	origin = Vector2i(180, 32)
	size = Vector2i(28, 18)
	universe_id = &"moonpetal_court"
	encounter_count_flag = &"moonpetal_encounter_count"


func _scripted_encounter(local: Vector2i) -> StringName:
	if Rect2i(1, 4, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"moonpetal_gate_cleared", false):
		return &"moonpetal_gate_intro"
	if Rect2i(11, 14, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"moonpetal_bell_ambush_cleared", false):
		return &"moonpetal_bell_ambush"
	if Rect2i(21, 14, 6, 3).has_point(local) and local.x >= 23 and CampaignState.story_flags.get(&"moonpetal_palace_open", false) and not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false):
		return &"moonpetal_magistrate_enma"
	return &""


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(11, 4, 6, 3).has_point(local) or Rect2i(21, 4, 6, 3).has_point(local) or Rect2i(11, 14, 6, 3).has_point(local)


func _random_encounter(local: Vector2i) -> StringName:
	if local.y >= 10:
		return &"moonpetal_bell_patrol"
	if local.x >= 20:
		return &"moonpetal_garden_patrol"
	return &"moonpetal_court_patrol"


func _apply_victory(encounter_id: StringName) -> void:
	match encounter_id:
		&"moonpetal_gate_intro":
			CampaignState.story_flags[&"moonpetal_gate_cleared"] = true
		&"moonpetal_bell_ambush":
			CampaignState.story_flags[&"moonpetal_bell_ambush_cleared"] = true
		&"moonpetal_magistrate_enma":
			CampaignState.story_flags[&"moonpetal_scenario_complete"] = true
			CampaignState.story_flags[&"sixth_universe_stabilized"] = true
		&"moonpetal_crimson_oni_trial":
			CampaignState.story_flags[&"crimson_oni_trial_complete"] = true
			CampaignState.story_flags[&"crimson_oni_recruit_unlocked"] = true
			CampaignState.discover_recruit(&"crimson_oni")
