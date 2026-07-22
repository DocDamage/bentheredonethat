class_name EncounterDirector
extends Node

## Shared deterministic encounter flow. Universe controllers only declare their
## authored regions, scripted encounters, formation selection, and world-state
## consequences; this is the single authority for pressure, wards, cooldowns,
## and return-to-town behavior.

var battle: CampaignBattle
var suppress_persistence := false
var origin := Vector2i.ZERO
var size := Vector2i.ZERO
var universe_id: StringName = &""
var return_cell := Vector2i(50, 8)
var threshold_min := 11
var threshold_max := 17
var encounter_count_flag: StringName = &""
var _steps_in_danger := 0
var _encounter_threshold := 13
var _cooldown_steps := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_configure_region()
	_rng.randomize()
	_encounter_threshold = _rng.randi_range(threshold_min, threshold_max)
	if battle:
		battle.battle_finished.connect(_on_battle_finished)
		battle.return_to_town_requested.connect(_return_player_to_town)
	var player := Player.gamepiece
	if player and not player.arrived.is_connected(_on_player_arrived):
		player.arrived.connect(_on_player_arrived)


func _configure_region() -> void:
	push_error("EncounterDirector subclasses must configure their region.")


func _on_player_arrived() -> void:
	if not battle or battle.active or Cutscene.is_cutscene_in_progress() or not _can_process_player():
		return
	var player := Player.gamepiece
	if not player:
		return
	var cell := Gameboard.pixel_to_cell(player.position)
	if not Rect2i(origin, size).has_point(cell):
		_steps_in_danger = 0
		CampaignState.clear_encounter_pressure(universe_id)
		return
	var local := cell - origin
	var scripted := _scripted_encounter(local)
	if scripted != &"":
		battle.begin(scripted)
		return
	if _cooldown_steps > 0:
		_cooldown_steps -= 1
		CampaignState.report_encounter_pressure(universe_id, 0, _encounter_threshold, false, _cooldown_steps)
		return
	if not _is_danger_region(local):
		CampaignState.report_encounter_pressure(universe_id, _steps_in_danger, _encounter_threshold, false)
		return
	if CampaignState.consume_encounter_ward_step(universe_id):
		_steps_in_danger = 0
		return
	_steps_in_danger += 1
	CampaignState.report_encounter_pressure(universe_id, _steps_in_danger, _encounter_threshold)
	if _steps_in_danger >= _encounter_threshold:
		_steps_in_danger = 0
		_encounter_threshold = _rng.randi_range(threshold_min, threshold_max)
		battle.begin(_random_encounter(local))


func _can_process_player() -> bool:
	return true


func _scripted_encounter(_local: Vector2i) -> StringName:
	return &""


func _is_danger_region(_local: Vector2i) -> bool:
	return false


func _random_encounter(_local: Vector2i) -> StringName:
	return &""


func _on_battle_finished(victory: bool, encounter_id: StringName) -> void:
	if not victory:
		return
	_cooldown_steps = 8
	CampaignState.report_encounter_pressure(universe_id, 0, _encounter_threshold, false, _cooldown_steps)
	if encounter_count_flag != &"":
		CampaignState.story_flags[encounter_count_flag] = int(CampaignState.story_flags.get(encounter_count_flag, 0)) + 1
	_apply_victory(encounter_id)
	CampaignState.state_changed.emit()


func _apply_victory(_encounter_id: StringName) -> void:
	pass


func _return_player_to_town() -> void:
	var player := Player.gamepiece
	if not player:
		return
	if player.is_moving():
		player.stop()
	player.position = Gameboard.cell_to_pixel(return_cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, return_cell)
	Camera.reset_position()
