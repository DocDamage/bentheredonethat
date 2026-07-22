class_name MansionEncounterController
extends Node

const MANSION_ORIGIN := Vector2i(0, 32)
const MANSION_SIZE := Vector2i(28, 18)
const TOWN_ARRIVAL := Vector2i(50, 8)

var battle: CampaignBattle
var suppress_persistence := false
var _steps_in_danger := 0
var _encounter_threshold := 12
var _cooldown_steps := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_encounter_threshold = _rng.randi_range(10, 16)
	if battle:
		battle.battle_finished.connect(_on_battle_finished)
		battle.return_to_town_requested.connect(_return_player_to_town)
	var player := Player.gamepiece
	if player and not player.arrived.is_connected(_on_player_arrived):
		player.arrived.connect(_on_player_arrived)


func _on_player_arrived() -> void:
	if not battle or battle.active or Cutscene.is_cutscene_in_progress():
		return
	var player := Player.gamepiece
	if not player:
		return
	var cell := Gameboard.pixel_to_cell(player.position)
	if not Rect2i(MANSION_ORIGIN, MANSION_SIZE).has_point(cell):
		_steps_in_danger = 0
		CampaignState.clear_encounter_pressure(&"haunted_mansion")
		return
	if &"fighter" not in CampaignState.party:
		return
	var local := cell - MANSION_ORIGIN
	if not CampaignState.story_flags.get(&"mansion_foyer_cleared", false):
		# Passing the first interior arch begins the mandatory, scripted encounter.
		if local.x < 8 and local.y <= 5:
			battle.begin(&"mansion_foyer_intro")
		return
	if _in_gallery(local) and not CampaignState.story_flags.get(&"mansion_gallery_ambush_cleared", false):
		battle.begin(&"mansion_gallery_ambush")
		return
	if _in_nursery(local) and not CampaignState.story_flags.get(&"mansion_nursery_ambush_cleared", false):
		battle.begin(&"mansion_nursery_ambush")
		return
	if _in_ballroom(local) and local.x >= 23 and CampaignState.story_flags.get(&"mansion_ballroom_open", false) and not CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false):
		battle.begin(&"mansion_archive_boss")
		return
	if _cooldown_steps > 0:
		_cooldown_steps -= 1
		CampaignState.report_encounter_pressure(&"haunted_mansion", 0, _encounter_threshold, false, _cooldown_steps)
		return
	if not _is_danger_region(local):
		CampaignState.report_encounter_pressure(&"haunted_mansion", _steps_in_danger, _encounter_threshold, false)
		return
	if CampaignState.consume_encounter_ward_step(&"haunted_mansion"):
		_steps_in_danger = 0
		return
	_steps_in_danger += 1
	CampaignState.report_encounter_pressure(&"haunted_mansion", _steps_in_danger, _encounter_threshold)
	if _steps_in_danger >= _encounter_threshold:
		_steps_in_danger = 0
		_encounter_threshold = _rng.randi_range(10, 16)
		var encounter := _random_encounter_for_room(local)
		battle.begin(encounter)


func _is_danger_region(local: Vector2i) -> bool:
	# Encounter regions are authored explicitly per map room; the safe entry foyer
	# and doorway tiles never roll random battles.
	return Rect2i(1, 4, 6, 2).has_point(local) \
		or Rect2i(11, 4, 6, 3).has_point(local) \
		or _in_gallery(local) or _in_nursery(local) or _in_ballroom(local)


func _in_gallery(local: Vector2i) -> bool:
	return Rect2i(1, 14, 6, 3).has_point(local)


func _in_nursery(local: Vector2i) -> bool:
	return Rect2i(11, 14, 6, 3).has_point(local)


func _in_ballroom(local: Vector2i) -> bool:
	return Rect2i(21, 9, 6, 4).has_point(local)


func _random_encounter_for_room(local: Vector2i) -> StringName:
	if _in_gallery(local):
		return &"mansion_restless_portraits" if _rng.randf() < 0.6 else &"mansion_lost_hours"
	if _in_nursery(local):
		return &"mansion_doll_procession" if _rng.randf() < 0.65 else &"mansion_restless_portraits"
	if _in_ballroom(local):
		return &"mansion_last_dance"
	return &"mansion_lost_hours" if _rng.randf() < 0.42 else &"mansion_restless_books"


func _on_battle_finished(victory: bool, encounter_id: StringName) -> void:
	if victory:
		_cooldown_steps = 8
		CampaignState.report_encounter_pressure(&"haunted_mansion", 0, _encounter_threshold, false, _cooldown_steps)
		CampaignState.story_flags[&"mansion_encounter_count"] = int(CampaignState.story_flags.get(&"mansion_encounter_count", 0)) + 1
		if encounter_id == &"mansion_foyer_intro":
			CampaignState.story_flags[&"mansion_foyer_cleared"] = true
		elif encounter_id == &"mansion_gallery_ambush":
			CampaignState.story_flags[&"mansion_gallery_ambush_cleared"] = true
		elif encounter_id == &"mansion_nursery_ambush":
			CampaignState.story_flags[&"mansion_nursery_ambush_cleared"] = true
		elif encounter_id == &"mansion_archive_boss":
			CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
			CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
			CampaignState.story_flags[&"first_universe_stabilized"] = true
		elif encounter_id == &"mansion_rift_jackal_trial":
			CampaignState.story_flags[&"rift_jackal_trial_complete"] = true
			CampaignState.story_flags[&"rift_jackal_recruit_unlocked"] = true
			CampaignState.discover_recruit(&"rift_jackal")
		CampaignState.state_changed.emit()
		if not suppress_persistence:
			CampaignState.save_game()


func _return_player_to_town() -> void:
	var player := Player.gamepiece
	if not player:
		return
	if player.is_moving():
		player.stop()
	player.position = Gameboard.cell_to_pixel(TOWN_ARRIVAL)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, TOWN_ARRIVAL)
	Camera.reset_position()
