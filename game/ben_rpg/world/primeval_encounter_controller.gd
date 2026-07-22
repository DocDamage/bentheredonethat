class_name PrimevalEncounterController
extends EncounterDirector


func _configure_region() -> void:
	origin = Vector2i(72, 32)
	size = Vector2i(28, 18)
	universe_id = &"primeval_expanse"
	encounter_count_flag = &"primeval_encounter_count"


func _scripted_encounter(local: Vector2i) -> StringName:
	if Rect2i(1, 4, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"primeval_grove_cleared", false): return &"primeval_grove_intro"
	if _in_nest(local) and not CampaignState.story_flags.get(&"primeval_nest_ambush_cleared", false): return &"primeval_nest_ambush"
	if _in_caldera(local) and local.x >= 23 and CampaignState.story_flags.get(&"primeval_caldera_open", false) and not CampaignState.story_flags.get(&"primeval_scenario_complete", false): return &"primeval_commute_tyrant"
	return &""


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(11, 4, 6, 3).has_point(local) or Rect2i(21, 4, 6, 3).has_point(local) or _in_nest(local) or _in_caldera(local)


func _random_encounter(local: Vector2i) -> StringName:
	if _in_caldera(local): return &"primeval_caldera_patrol"
	if _in_nest(local): return &"primeval_nest_patrol"
	return &"primeval_raptor_pack" if _rng.randf() < 0.62 else &"primeval_heavy_herd"


func _random_encounter_options(local: Vector2i) -> Array[StringName]:
	if _in_caldera(local): return [&"primeval_caldera_patrol"]
	if _in_nest(local): return [&"primeval_nest_patrol"]
	return [&"primeval_raptor_pack", &"primeval_heavy_herd"]


func _in_nest(local: Vector2i) -> bool: return Rect2i(11, 14, 6, 3).has_point(local)
func _in_caldera(local: Vector2i) -> bool: return Rect2i(21, 14, 6, 3).has_point(local)


func _apply_victory(encounter_id: StringName) -> void:
	match encounter_id:
		&"primeval_grove_intro": CampaignState.story_flags[&"primeval_grove_cleared"] = true
		&"primeval_nest_ambush": CampaignState.story_flags[&"primeval_nest_ambush_cleared"] = true
		&"primeval_commute_tyrant":
			CampaignState.story_flags[&"primeval_scenario_complete"] = true
			CampaignState.story_flags[&"third_universe_stabilized"] = true
		&"primeval_mossback_trial":
			CampaignState.story_flags[&"mossback_surveyor_trial_complete"] = true
			CampaignState.story_flags[&"mossback_surveyor_recruit_unlocked"] = true
			CampaignState.discover_recruit(&"mossback_surveyor")
