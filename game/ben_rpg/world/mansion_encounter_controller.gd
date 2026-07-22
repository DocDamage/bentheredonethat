class_name MansionEncounterController
extends EncounterDirector


func _configure_region() -> void:
	origin = Vector2i(0, 32)
	size = Vector2i(28, 18)
	universe_id = &"haunted_mansion"
	encounter_count_flag = &"mansion_encounter_count"
	threshold_min = 10
	threshold_max = 16


func _can_process_player() -> bool:
	return &"fighter" in CampaignState.party


func _scripted_encounter(local: Vector2i) -> StringName:
	if not CampaignState.story_flags.get(&"mansion_foyer_cleared", false):
		return &"mansion_foyer_intro" if local.x < 8 and local.y <= 5 else &""
	if _in_gallery(local) and not CampaignState.story_flags.get(&"mansion_gallery_ambush_cleared", false): return &"mansion_gallery_ambush"
	if _in_nursery(local) and not CampaignState.story_flags.get(&"mansion_nursery_ambush_cleared", false): return &"mansion_nursery_ambush"
	if _in_ballroom(local) and local.x >= 23 and CampaignState.story_flags.get(&"mansion_ballroom_open", false) and not CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false): return &"mansion_archive_boss"
	return &""


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(1, 4, 6, 2).has_point(local) or Rect2i(11, 4, 6, 3).has_point(local) or _in_gallery(local) or _in_nursery(local) or _in_ballroom(local)


func _random_encounter(local: Vector2i) -> StringName:
	if _in_gallery(local): return &"mansion_restless_portraits" if _rng.randf() < 0.6 else &"mansion_lost_hours"
	if _in_nursery(local): return &"mansion_doll_procession" if _rng.randf() < 0.65 else &"mansion_restless_portraits"
	if _in_ballroom(local): return &"mansion_last_dance"
	return &"mansion_lost_hours" if _rng.randf() < 0.42 else &"mansion_restless_books"


func _random_encounter_options(local: Vector2i) -> Array[StringName]:
	if _in_gallery(local): return [&"mansion_restless_portraits", &"mansion_lost_hours"]
	if _in_nursery(local): return [&"mansion_doll_procession", &"mansion_restless_portraits"]
	if _in_ballroom(local): return [&"mansion_last_dance"]
	return [&"mansion_lost_hours", &"mansion_restless_books"]


func _in_gallery(local: Vector2i) -> bool: return Rect2i(1, 14, 6, 3).has_point(local)
func _in_nursery(local: Vector2i) -> bool: return Rect2i(11, 14, 6, 3).has_point(local)
func _in_ballroom(local: Vector2i) -> bool: return Rect2i(21, 9, 6, 4).has_point(local)


func _apply_victory(encounter_id: StringName) -> void:
	match encounter_id:
		&"mansion_foyer_intro": CampaignState.story_flags[&"mansion_foyer_cleared"] = true
		&"mansion_gallery_ambush": CampaignState.story_flags[&"mansion_gallery_ambush_cleared"] = true
		&"mansion_nursery_ambush": CampaignState.story_flags[&"mansion_nursery_ambush_cleared"] = true
		&"mansion_archive_boss":
			CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
			CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
			CampaignState.story_flags[&"first_universe_stabilized"] = true
		&"mansion_rift_jackal_trial":
			CampaignState.story_flags[&"rift_jackal_trial_complete"] = true
			CampaignState.story_flags[&"rift_jackal_recruit_unlocked"] = true
			CampaignState.discover_recruit(&"rift_jackal")
