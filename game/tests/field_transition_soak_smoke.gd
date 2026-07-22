extends Node

## Repeats cross-universe camera/area activation with save-load checkpoints.
## This is a bounded regression probe, not a substitute for the release
## multi-hour soak, but it catches duplicate field layers or saved-state damage
## caused by repeated transition cycles.

const TEST_SAVE := "user://field_transition_soak.json"
const ROUTE := [
	[Vector2i(12, 36), &"mansion_archive"],
	[Vector2i(50, 8), &"town"],
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
	CampaignState.reset_new_game()
	var main: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	await _settle()

	var world := main.get_node_or_null("Field/Map/CampaignWorld") as Node2D
	var visual := world.get_node_or_null("GroundLayer/Visuals") as CampaignMapVisual if world else null
	var foreground := world.get_node_or_null("ForegroundLayer") as Node2D if world else null
	if not world or not visual or not foreground:
		_fail("campaign field layers were not created")
		return
	var world_children := world.get_child_count()
	var foreground_children := foreground.get_child_count()

	for cycle in range(12):
		for stop in ROUTE:
			var cell: Vector2i = stop[0]
			var expected_area: StringName = stop[1]
			Player.gamepiece.position = Gameboard.cell_to_pixel(cell)
			Player.gamepiece.rest_position = Player.gamepiece.position
			main._update_camera_limits(true)
			await _settle(2)
			if visual.active_area != expected_area:
				_fail("cycle %d activated %s instead of %s" % [cycle, visual.active_area, expected_area])
				return
			if world.get_child_count() != world_children or foreground.get_child_count() != foreground_children:
				_fail("cycle %d duplicated a field layer" % cycle)
				return
		if cycle % 3 == 2:
			if CampaignState.save_game(TEST_SAVE) != OK or CampaignState.load_game(TEST_SAVE) != OK:
				_fail("cycle %d save-load checkpoint failed" % cycle)
				return

	print("FIELD_TRANSITION_SOAK_SMOKE_OK cycles=12 areas=8 saves=4 layers=stable")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _settle(frames := 6) -> void:
	for _frame in range(frames):
		await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("FIELD_TRANSITION_SOAK_SMOKE_FAILED: " + message)
	get_tree().quit(1)
