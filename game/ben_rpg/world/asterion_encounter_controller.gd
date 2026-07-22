class_name AsterionEncounterController
extends EncounterDirector


func _configure_region() -> void:
	origin = Vector2i(36, 32)
	size = Vector2i(28, 18)
	universe_id = &"asterion_station"
	encounter_count_flag = &"asterion_encounter_count"


func _scripted_encounter(local: Vector2i) -> StringName:
	if not CampaignState.story_flags.get(&"asterion_dock_cleared", false) and Rect2i(1, 4, 6, 3).has_point(local):
		return &"asterion_dock_intro"
	if _in_medical(local) and not CampaignState.story_flags.get(&"asterion_medical_ambush_cleared", false):
		return &"asterion_medical_ambush"
	if _in_hydro(local) and not CampaignState.story_flags.get(&"asterion_hydro_ambush_cleared", false):
		return &"asterion_hydro_ambush"
	if _in_control(local) and local.x >= 23 and CampaignState.story_flags.get(&"asterion_station_restored", false) and not CampaignState.story_flags.get(&"asterion_station_complete", false):
		return &"asterion_mother_computer"
	return &""


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(11, 4, 6, 3).has_point(local) or _in_hydro(local) or _in_medical(local) or _in_control(local)


func _in_hydro(local: Vector2i) -> bool:
	return Rect2i(21, 4, 6, 3).has_point(local)


func _in_medical(local: Vector2i) -> bool:
	return Rect2i(11, 14, 6, 3).has_point(local)


func _in_control(local: Vector2i) -> bool:
	return Rect2i(21, 14, 6, 3).has_point(local)


func _random_encounter(local: Vector2i) -> StringName:
	if _in_hydro(local):
		return &"asterion_greenhouse_patrol" if _rng.randf() < 0.65 else &"asterion_maintenance_detail"
	if _in_medical(local):
		return &"asterion_medical_patrol"
	if _in_control(local):
		return &"asterion_command_patrol"
	return &"asterion_maintenance_detail"


func _random_encounter_options(local: Vector2i) -> Array[StringName]:
	if _in_hydro(local): return [&"asterion_greenhouse_patrol", &"asterion_maintenance_detail"]
	if _in_medical(local): return [&"asterion_medical_patrol"]
	if _in_control(local): return [&"asterion_command_patrol"]
	return [&"asterion_maintenance_detail"]


func _apply_victory(encounter_id: StringName) -> void:
	match encounter_id:
		&"asterion_dock_intro": CampaignState.story_flags[&"asterion_dock_cleared"] = true
		&"asterion_medical_ambush": CampaignState.story_flags[&"asterion_medical_ambush_cleared"] = true
		&"asterion_hydro_ambush": CampaignState.story_flags[&"asterion_hydro_ambush_cleared"] = true
		&"asterion_mother_computer":
			CampaignState.story_flags[&"asterion_station_complete"] = true
			CampaignState.story_flags[&"second_universe_stabilized"] = true
		&"asterion_bulkhead_warden_trial":
			CampaignState.story_flags[&"bulkhead_warden_trial_complete"] = true
			CampaignState.story_flags[&"bulkhead_warden_recruit_unlocked"] = true
			CampaignState.discover_recruit(&"bulkhead_warden")
