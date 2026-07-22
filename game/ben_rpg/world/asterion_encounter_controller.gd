class_name AsterionEncounterController
extends Node

const STATION_ORIGIN := Vector2i(36, 32)
const STATION_SIZE := Vector2i(28, 18)
const TOWN_ARRIVAL := Vector2i(50, 8)

var battle: CampaignBattle
var suppress_persistence := false
var _steps_in_danger := 0
var _encounter_threshold := 13
var _cooldown_steps := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_encounter_threshold = _rng.randi_range(11, 17)
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
	if not Rect2i(STATION_ORIGIN, STATION_SIZE).has_point(cell):
		_steps_in_danger = 0
		CampaignState.clear_encounter_pressure(&"asterion_station")
		return
	var local := cell - STATION_ORIGIN
	if not CampaignState.story_flags.get(&"asterion_dock_cleared", false) and Rect2i(1, 4, 6, 3).has_point(local):
		battle.begin(&"asterion_dock_intro")
		return
	if _in_medical(local) and not CampaignState.story_flags.get(&"asterion_medical_ambush_cleared", false):
		battle.begin(&"asterion_medical_ambush")
		return
	if _in_hydro(local) and not CampaignState.story_flags.get(&"asterion_hydro_ambush_cleared", false):
		battle.begin(&"asterion_hydro_ambush")
		return
	if _in_control(local) and local.x >= 23 and CampaignState.story_flags.get(&"asterion_station_restored", false) and not CampaignState.story_flags.get(&"asterion_station_complete", false):
		battle.begin(&"asterion_mother_computer")
		return
	if _cooldown_steps > 0:
		_cooldown_steps -= 1
		CampaignState.report_encounter_pressure(&"asterion_station", 0, _encounter_threshold, false, _cooldown_steps)
		return
	if not _is_danger_region(local):
		CampaignState.report_encounter_pressure(&"asterion_station", _steps_in_danger, _encounter_threshold, false)
		return
	if CampaignState.consume_encounter_ward_step(&"asterion_station"):
		_steps_in_danger = 0
		return
	_steps_in_danger += 1
	CampaignState.report_encounter_pressure(&"asterion_station", _steps_in_danger, _encounter_threshold)
	if _steps_in_danger >= _encounter_threshold:
		_steps_in_danger = 0
		_encounter_threshold = _rng.randi_range(11, 17)
		battle.begin(_random_encounter(local))


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


func _on_battle_finished(victory: bool, encounter_id: StringName) -> void:
	if not victory:
		return
	_cooldown_steps = 8
	CampaignState.report_encounter_pressure(&"asterion_station", 0, _encounter_threshold, false, _cooldown_steps)
	CampaignState.story_flags[&"asterion_encounter_count"] = int(CampaignState.story_flags.get(&"asterion_encounter_count", 0)) + 1
	match encounter_id:
		&"asterion_dock_intro":
			CampaignState.story_flags[&"asterion_dock_cleared"] = true
		&"asterion_medical_ambush":
			CampaignState.story_flags[&"asterion_medical_ambush_cleared"] = true
		&"asterion_hydro_ambush":
			CampaignState.story_flags[&"asterion_hydro_ambush_cleared"] = true
		&"asterion_mother_computer":
			CampaignState.story_flags[&"asterion_station_complete"] = true
			CampaignState.story_flags[&"second_universe_stabilized"] = true
		&"asterion_bulkhead_warden_trial":
			CampaignState.story_flags[&"bulkhead_warden_trial_complete"] = true
			CampaignState.story_flags[&"bulkhead_warden_recruit_unlocked"] = true
			CampaignState.discover_recruit(&"bulkhead_warden")
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
