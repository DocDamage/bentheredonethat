extends Node

## Records comparable, machine-specific campaign timings from a rendered Godot
## session. This diagnostic intentionally has no performance thresholds: export
## hardware targets and a human benchmark matrix still need to be declared.

const TEST_SAVE := "user://campaign_performance_baseline.json"
const FRAME_SAMPLE_COUNT := 120
const AREA_STOPS := [
	[Vector2i(50, 8), &"town"],
	[Vector2i(12, 36), &"mansion_archive"],
	[Vector2i(40, 38), &"station_dock"],
	[Vector2i(76, 38), &"primeval_grove"],
	[Vector2i(112, 38), &"helios_skybridge"],
	[Vector2i(148, 38), &"frosthold_gate"],
	[Vector2i(184, 38), &"moonpetal_gate"],
	[Vector2i(220, 38), &"empyreal_landing"],
]


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	var metrics := _environment_metrics()
	var main_scene := load("res://src/main.tscn") as PackedScene
	if not main_scene:
		_fail("The campaign main scene could not be loaded")
		return

	var title_start := Time.get_ticks_usec()
	var main := main_scene.instantiate()
	main.campaign_save_path = TEST_SAVE
	get_tree().root.add_child(main)
	var title := await _wait_for_title(main)
	if not title:
		_fail("The campaign title did not become available")
		return
	metrics["startup_to_title_ms"] = _elapsed_ms(title_start)

	var field_start := Time.get_ticks_usec()
	if not title.choose_mode(&"sandbox"):
		_fail("Sandbox launch was rejected by the title screen")
		return
	await _settle(6)
	if main.has_node("CampaignTitleScreen") or CampaignState.party.is_empty():
		_fail("The title did not enter a playable field state")
		return
	metrics["title_to_field_ms"] = _elapsed_ms(field_start)

	var visual := main.get_node_or_null("Field/Map/CampaignWorld/GroundLayer/Visuals") as CampaignMapVisual
	if not visual:
		_fail("The campaign field visual layer was not available")
		return
	var transition_timings: Dictionary = {}
	for stop in AREA_STOPS:
		var cell: Vector2i = stop[0]
		var expected_area: StringName = stop[1]
		var transition_start := Time.get_ticks_usec()
		_place_player(main, cell)
		await _settle(3)
		if visual.active_area != expected_area:
			_fail("Expected %s after activation, received %s" % [expected_area, visual.active_area])
			return
		transition_timings[String(expected_area)] = _elapsed_ms(transition_start)
	metrics["area_activation_ms"] = transition_timings

	var battle := main.get_node_or_null("CampaignBattle") as CampaignBattle
	if not battle:
		_fail("The campaign battle controller was not available")
		return
	battle.suppress_persistence = true
	var battle_start := Time.get_ticks_usec()
	if not battle.begin(&"mansion_foyer_intro", 10444):
		_fail("The benchmark battle did not begin")
		return
	await _settle(2)
	if not battle.active:
		_fail("The benchmark battle did not remain active")
		return
	metrics["battle_enter_ms"] = _elapsed_ms(battle_start)

	var result_start := Time.get_ticks_usec()
	battle.debug_force_victory()
	await _settle(2)
	if not battle._results_panel.visible:
		_fail("The benchmark battle did not reach its results presentation")
		return
	metrics["battle_results_ms"] = _elapsed_ms(result_start)
	var return_start := Time.get_ticks_usec()
	battle._leave_battle(true)
	await _settle(2)
	if battle.active or not main.get_node("Field").visible:
		_fail("The benchmark battle did not return to the field")
		return
	metrics["battle_return_to_field_ms"] = _elapsed_ms(return_start)

	var save_start := Time.get_ticks_usec()
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("The benchmark save could not be written")
		return
	metrics["save_ms"] = _elapsed_ms(save_start)
	var expected_duckets := CampaignState.duckets
	CampaignState.duckets += 1
	var load_start := Time.get_ticks_usec()
	if CampaignState.load_game(TEST_SAVE) != OK or CampaignState.duckets != expected_duckets:
		_fail("The benchmark save could not be loaded faithfully")
		return
	metrics["load_ms"] = _elapsed_ms(load_start)
	metrics["memory_bytes"] = _memory_metrics()
	metrics["frame_interval_ms"] = await _frame_interval_metrics()

	print("CAMPAIGN_PERFORMANCE_BASELINE " + JSON.stringify(metrics))
	main.queue_free()
	await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(0)


func _wait_for_title(main: Node) -> CampaignTitleScreen:
	for _frame in range(20):
		await get_tree().process_frame
		var title := main.get_node_or_null("CampaignTitleScreen") as CampaignTitleScreen
		if title:
			return title
	return null


func _place_player(main: Node, cell: Vector2i) -> void:
	var player := Player.gamepiece
	if player.is_moving():
		player.stop()
	if GamepieceRegistry.get_cell(player) != cell:
		GamepieceRegistry.move_gamepiece(player, cell)
	player.position = Gameboard.cell_to_pixel(cell)
	player.rest_position = player.position
	main._update_camera_limits(true)


func _frame_interval_metrics() -> Dictionary:
	var intervals: Array[float] = []
	var previous_tick := Time.get_ticks_usec()
	for _frame in range(FRAME_SAMPLE_COUNT):
		await get_tree().process_frame
		var current_tick := Time.get_ticks_usec()
		intervals.append(float(current_tick - previous_tick) / 1000.0)
		previous_tick = current_tick
	intervals.sort()
	var total := 0.0
	for interval in intervals:
		total += interval
	return {
		"samples": intervals.size(),
		"mean": snappedf(total / intervals.size(), 0.001),
		"p95": snappedf(intervals[ceili(float(intervals.size()) * 0.95) - 1], 0.001),
		"max": snappedf(intervals.back(), 0.001),
	}


func _environment_metrics() -> Dictionary:
	var window_size := DisplayServer.window_get_size()
	return {
		"engine": String(Engine.get_version_info().get("string", "unknown")),
		"platform": OS.get_name(),
		"window_size": [window_size.x, window_size.y],
		"benchmark_note": "Windowed diagnostic only; values are not portable performance targets.",
	}


func _memory_metrics() -> Dictionary:
	return {
		"static": int(Performance.get_monitor(Performance.MEMORY_STATIC)),
		"static_peak": int(Performance.get_monitor(Performance.MEMORY_STATIC_MAX)),
	}


func _elapsed_ms(start_usec: int) -> float:
	return snappedf(float(Time.get_ticks_usec() - start_usec) / 1000.0, 0.001)


func _settle(frames := 6) -> void:
	for _frame in range(frames):
		await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("CAMPAIGN_PERFORMANCE_BASELINE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
