extends Node

const STATION_ORIGIN := Vector2i(36, 32)
const ROOMS := {
	"dock": Rect2i(0, 4, 8, 4),
	"mess": Rect2i(10, 4, 8, 4),
	"hydro": Rect2i(20, 4, 8, 4),
	"medical": Rect2i(10, 14, 8, 4),
	"control": Rect2i(20, 14, 8, 4),
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame

	var total_open := 0
	for room_name in ROOMS:
		var room: Rect2i = ROOMS[room_name]
		var open := 0
		for y in range(room.position.y, room.end.y):
			for x in range(room.position.x, room.end.x):
				if Gameboard.pathfinder.has_cell(STATION_ORIGIN + Vector2i(x, y)):
					open += 1
		if open < 30:
			_fail("%s exposes only %d walkable floor cells" % [room_name, open])
			return
		total_open += open

	if Gameboard.pathfinder.has_cell(main.STATION_HYDRO_TO_CONTROL):
		_fail("oxygen gate is walkable before restoration")
		return
	CampaignState.story_flags[&"asterion_anchor_built"] = true
	CampaignState.story_flags[&"asterion_station_restored"] = true
	main._on_campaign_state_changed()
	await get_tree().process_frame
	for shortcut_name in ["StationDockServiceShortcut", "StationMedicalServiceShortcut"]:
		if not main.has_node("Field/Map/CampaignWorld/%s" % shortcut_name):
			_fail("life-support restoration did not create %s" % shortcut_name)
			return
	if not Gameboard.pathfinder.has_cell(main.STATION_HYDRO_TO_CONTROL):
		_fail("oxygen gate did not open after restoration")
		return

	print("ASTERION_LAYOUT_SMOKE_OK rooms=5 open_cells=%d floor=8x4 oxygen_gate=restored loop=service_lift" % total_open)
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("ASTERION_LAYOUT_SMOKE_FAILED: " + message)
	get_tree().quit(1)
