class_name FrostholdEncounterController
extends EncounterDirector


func _configure_region() -> void:
	origin = Vector2i(144, 32)
	size = Vector2i(28, 18)
	universe_id = &"frosthold_kingdom"
	encounter_count_flag = &"frosthold_encounter_count"


func _scripted_encounter(local: Vector2i) -> StringName:
	if Rect2i(1, 4, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"frosthold_gate_cleared", false):
		return &"frosthold_gate_intro"
	if Rect2i(11, 14, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"frosthold_rune_ambush_cleared", false):
		return &"frosthold_rune_ambush"
	if Rect2i(21, 14, 6, 3).has_point(local) and local.x >= 23 and CampaignState.story_flags.get(&"frosthold_throne_open", false) and not CampaignState.story_flags.get(&"frosthold_scenario_complete", false):
		return &"frosthold_whiteout_auditor"
	return &""


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(11, 4, 6, 3).has_point(local) or Rect2i(21, 4, 6, 3).has_point(local) or Rect2i(11, 14, 6, 3).has_point(local)


func _random_encounter(local: Vector2i) -> StringName:
	if local.y >= 10:
		return &"frosthold_rune_patrol"
	if local.x >= 20:
		return &"frosthold_causeway_patrol"
	return &"frosthold_market_patrol"


func _apply_victory(encounter_id: StringName) -> void:
	match encounter_id:
		&"frosthold_gate_intro":
			CampaignState.story_flags[&"frosthold_gate_cleared"] = true
		&"frosthold_rune_ambush":
			CampaignState.story_flags[&"frosthold_rune_ambush_cleared"] = true
		&"frosthold_whiteout_auditor":
			CampaignState.story_flags[&"frosthold_scenario_complete"] = true
			CampaignState.story_flags[&"fifth_universe_stabilized"] = true
