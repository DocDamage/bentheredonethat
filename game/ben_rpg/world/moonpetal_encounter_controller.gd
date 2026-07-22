class_name MoonpetalEncounterController
extends Node

const MOONPETAL_ORIGIN := Vector2i(180, 32)
const MOONPETAL_SIZE := Vector2i(28, 18)
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
	if not Rect2i(MOONPETAL_ORIGIN, MOONPETAL_SIZE).has_point(cell):
		_steps_in_danger = 0
		CampaignState.clear_encounter_pressure(&"moonpetal_court")
		return
	var local := cell - MOONPETAL_ORIGIN
	if Rect2i(1, 4, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"moonpetal_gate_cleared", false):
		battle.begin(&"moonpetal_gate_intro")
		return
	if Rect2i(11, 14, 6, 3).has_point(local) and not CampaignState.story_flags.get(&"moonpetal_bell_ambush_cleared", false):
		battle.begin(&"moonpetal_bell_ambush")
		return
	if Rect2i(21, 14, 6, 3).has_point(local) and local.x >= 23 and CampaignState.story_flags.get(&"moonpetal_palace_open", false) and not CampaignState.story_flags.get(&"moonpetal_scenario_complete", false):
		battle.begin(&"moonpetal_magistrate_enma")
		return
	if _cooldown_steps > 0:
		_cooldown_steps -= 1
		CampaignState.report_encounter_pressure(&"moonpetal_court", 0, _encounter_threshold, false, _cooldown_steps)
		return
	if not _is_danger_region(local):
		CampaignState.report_encounter_pressure(&"moonpetal_court", _steps_in_danger, _encounter_threshold, false)
		return
	if CampaignState.consume_encounter_ward_step(&"moonpetal_court"):
		_steps_in_danger = 0
		return
	_steps_in_danger += 1
	CampaignState.report_encounter_pressure(&"moonpetal_court", _steps_in_danger, _encounter_threshold)
	if _steps_in_danger >= _encounter_threshold:
		_steps_in_danger = 0
		_encounter_threshold = _rng.randi_range(11, 17)
		battle.begin(_random_encounter(local))


func _is_danger_region(local: Vector2i) -> bool:
	return Rect2i(11, 4, 6, 3).has_point(local) or Rect2i(21, 4, 6, 3).has_point(local) or Rect2i(11, 14, 6, 3).has_point(local)


func _random_encounter(local: Vector2i) -> StringName:
	if local.y >= 10:
		return &"moonpetal_bell_patrol"
	if local.x >= 20:
		return &"moonpetal_garden_patrol"
	return &"moonpetal_court_patrol"


func _on_battle_finished(victory: bool, encounter_id: StringName) -> void:
	if not victory:
		return
	_cooldown_steps = 8
	CampaignState.report_encounter_pressure(&"moonpetal_court", 0, _encounter_threshold, false, _cooldown_steps)
	CampaignState.story_flags[&"moonpetal_encounter_count"] = int(CampaignState.story_flags.get(&"moonpetal_encounter_count", 0)) + 1
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
