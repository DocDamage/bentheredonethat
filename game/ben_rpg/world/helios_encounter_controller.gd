class_name HeliosEncounterController
extends Node

const HELIOS_ORIGIN := Vector2i(108, 32)
const HELIOS_SIZE := Vector2i(28, 18)
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
	var cell := Gameboard.pixel_to_cell(Player.gamepiece.position)
	if not Rect2i(HELIOS_ORIGIN, HELIOS_SIZE).has_point(cell):
		_steps_in_danger = 0
		CampaignState.clear_encounter_pressure(&"helios_arcology")
		return
	var local := cell - HELIOS_ORIGIN
	if Rect2i(1, 4, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"helios_skybridge_cleared", false):
		battle.begin(&"helios_skybridge_intro")
		return
	if Rect2i(11, 14, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"helios_clinic_ambush_cleared", false):
		battle.begin(&"helios_clinic_ambush")
		return
	if Rect2i(21, 14, 6, 3).has_point(local) and local.x >= 23 and CampaignState.story_flags.get(&"helios_core_open", false) and not CampaignState.story_flags.get(&"helios_scenario_complete", false):
		battle.begin(&"helios_civic_sun")
		return
	if _cooldown_steps > 0:
		_cooldown_steps -= 1
		CampaignState.report_encounter_pressure(&"helios_arcology", 0, _encounter_threshold, false, _cooldown_steps)
		return
	if not _is_danger_region(local):
		CampaignState.report_encounter_pressure(&"helios_arcology", _steps_in_danger, _encounter_threshold, false)
		return
	if CampaignState.consume_encounter_ward_step(&"helios_arcology"):
		_steps_in_danger = 0
		return
	_steps_in_danger += 1
	CampaignState.report_encounter_pressure(&"helios_arcology", _steps_in_danger, _encounter_threshold)
	if _steps_in_danger >= _encounter_threshold:
		_steps_in_danger = 0
		_encounter_threshold = _rng.randi_range(11, 17)
		battle.begin(_random_encounter(local))


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(11, 4, 6, 3).has_point(local) or Rect2i(21, 4, 6, 3).has_point(local) or Rect2i(11, 14, 6, 3).has_point(local)


func _random_encounter(local: Vector2i) -> StringName:
	if local.y >= 10:
		return &"helios_clinic_patrol"
	if local.x >= 20:
		return &"helios_transit_patrol"
	return &"helios_market_patrol"


func _on_battle_finished(victory: bool, encounter_id: StringName) -> void:
	if not victory:
		return
	_cooldown_steps = 8
	CampaignState.report_encounter_pressure(&"helios_arcology", 0, _encounter_threshold, false, _cooldown_steps)
	CampaignState.story_flags[&"helios_encounter_count"] = int(CampaignState.story_flags.get(&"helios_encounter_count", 0)) + 1
	match encounter_id:
		&"helios_skybridge_intro":
			CampaignState.story_flags[&"helios_skybridge_cleared"] = true
		&"helios_clinic_ambush":
			CampaignState.story_flags[&"helios_clinic_ambush_cleared"] = true
		&"helios_civic_sun":
			CampaignState.story_flags[&"helios_scenario_complete"] = true
			CampaignState.story_flags[&"fourth_universe_stabilized"] = true
		&"helios_cobalt_courier_trial":
			CampaignState.story_flags[&"cobalt_courier_trial_complete"] = true
			CampaignState.story_flags[&"cobalt_courier_recruit_unlocked"] = true
			CampaignState.discover_recruit(&"cobalt_courier")
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
