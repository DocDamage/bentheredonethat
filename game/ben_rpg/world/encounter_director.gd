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
var anti_repeat_depth := 2
var _steps_in_danger := 0
var _encounter_threshold := 13
var _cooldown_steps := 0
var _rng := RandomNumberGenerator.new()
var _recent_formations: Array[StringName] = []
var _last_danger_cell := Vector2i(-1, -1)


func _ready() -> void:
	_configure_region()
	_rng.randomize()
	_encounter_threshold = _rng.randi_range(threshold_min, threshold_max)
	_restore_runtime()
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
		_last_danger_cell = Vector2i(-1, -1)
		CampaignState.clear_encounter_pressure(universe_id)
		_persist_runtime()
		return
	var local := cell - origin
	var scripted := _scripted_encounter(local)
	if scripted != &"":
		battle.begin(scripted)
		return
	if _cooldown_steps > 0:
		if cell == _last_danger_cell:
			return
		_last_danger_cell = cell
		_cooldown_steps -= 1
		CampaignState.report_encounter_pressure(universe_id, 0, _encounter_threshold, false, _cooldown_steps)
		_persist_runtime()
		return
	if not _is_danger_region(local):
		_last_danger_cell = Vector2i(-1, -1)
		CampaignState.report_encounter_pressure(universe_id, _steps_in_danger, _encounter_threshold, false)
		_persist_runtime()
		return
	if cell == _last_danger_cell:
		return
	_last_danger_cell = cell
	if CampaignState.consume_encounter_ward_step(universe_id):
		_steps_in_danger = 0
		_persist_runtime()
		return
	_steps_in_danger += 1
	CampaignState.report_encounter_pressure(universe_id, _steps_in_danger, _encounter_threshold)
	if _steps_in_danger >= _encounter_threshold:
		_steps_in_danger = 0
		_encounter_threshold = _rng.randi_range(threshold_min, threshold_max)
		var encounter_id := _choose_random_encounter(local)
		if encounter_id != &"":
			_record_random_encounter(encounter_id)
			battle.begin(encounter_id)
	_persist_runtime()


func _can_process_player() -> bool:
	return true


func _scripted_encounter(_local: Vector2i) -> StringName:
	return &""


func _is_danger_region(_local: Vector2i) -> bool:
	return false


func _random_encounter(_local: Vector2i) -> StringName:
	return &""


func _random_encounter_options(_local: Vector2i) -> Array[StringName]:
	return []


func _choose_random_encounter(local: Vector2i) -> StringName:
	var options := _random_encounter_options(local)
	if options.is_empty():
		return _random_encounter(local)
	var allowed: Array[StringName] = []
	for option in options:
		if option != &"" and option not in _recent_formations:
			allowed.append(option)
	if allowed.is_empty():
		allowed = options
	return allowed[_rng.randi_range(0, allowed.size() - 1)]


func _record_random_encounter(encounter_id: StringName) -> void:
	if encounter_id == &"":
		return
	_recent_formations.append(encounter_id)
	while _recent_formations.size() > maxi(0, anti_repeat_depth):
		_recent_formations.pop_front()


func _on_battle_finished(victory: bool, encounter_id: StringName) -> void:
	if not victory:
		return
	_cooldown_steps = 8
	CampaignState.report_encounter_pressure(universe_id, 0, _encounter_threshold, false, _cooldown_steps)
	if encounter_count_flag != &"":
		CampaignState.story_flags[encounter_count_flag] = int(CampaignState.story_flags.get(encounter_count_flag, 0)) + 1
	_apply_victory(encounter_id)
	_persist_runtime()
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


func _restore_runtime() -> void:
	var runtime := CampaignState.encounter_director_state(universe_id)
	if runtime.is_empty():
		return
	_steps_in_danger = int(runtime.get("steps_in_danger", 0))
	_encounter_threshold = clampi(int(runtime.get("encounter_threshold", _encounter_threshold)), threshold_min, threshold_max)
	_cooldown_steps = int(runtime.get("cooldown_steps", 0))
	_recent_formations.clear()
	for encounter_id in runtime.get("recent_formations", []):
		_recent_formations.append(StringName(encounter_id))
	var last_cell: Array = runtime.get("last_danger_cell", [-1, -1])
	if last_cell.size() >= 2:
		_last_danger_cell = Vector2i(int(last_cell[0]), int(last_cell[1]))
	var rng_state := int(runtime.get("rng_state", 0))
	if rng_state != 0:
		_rng.state = rng_state


func _persist_runtime() -> void:
	CampaignState.store_encounter_director_state(universe_id, {
		"steps_in_danger": _steps_in_danger,
		"encounter_threshold": _encounter_threshold,
		"cooldown_steps": _cooldown_steps,
		"recent_formations": _recent_formations,
		"last_danger_cell": _last_danger_cell,
		"rng_state": _rng.state,
	})
