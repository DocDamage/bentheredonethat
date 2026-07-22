extends Node

const MOONPETAL_ORIGIN := Vector2i(180, 32)
const ROOMS := {
	"gate": Rect2i(0, 4, 8, 4),
	"court": Rect2i(10, 4, 8, 4),
	"garden": Rect2i(20, 4, 8, 4),
	"bell_walk": Rect2i(10, 14, 8, 4),
	"palace": Rect2i(20, 14, 8, 4),
}
const MINIMUM_OPEN_CELLS := {
	"gate": 30,
	"court": 30,
	"garden": 30,
	"bell_walk": 30,
	# The palace deliberately reserves nine cells for the two visible garden
	# islands and the boss dais; the remaining 23 still form a full approach.
	"palace": 22,
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var main := (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	var total_open := 0
	for room_name in ROOMS:
		var open := 0
		var room: Rect2i = ROOMS[room_name]
		for y in range(room.position.y, room.end.y):
			for x in range(room.position.x, room.end.x):
				if Gameboard.pathfinder.has_cell(MOONPETAL_ORIGIN + Vector2i(x, y)):
					open += 1
		if open < MINIMUM_OPEN_CELLS[room_name]:
			_fail("%s exposes only %d walkable floor cells" % [room_name, open])
			return
		total_open += open
	if Gameboard.pathfinder.has_cell(main.MOONPETAL_COURT_TO_BELL_WALK):
		_fail("bell-walk shortcut is open before the garden seal")
		return
	CampaignState.story_flags[&"moonpetal_anchor_built"] = true
	CampaignState.story_flags[&"moonpetal_bell_walk_open"] = true
	main._on_campaign_state_changed()
	await get_tree().process_frame
	for shortcut_name in ["MoonpetalCourtToBellWalk", "MoonpetalBellWalkToCourt"]:
		if not main.has_node("Field/Map/CampaignWorld/%s" % shortcut_name):
			_fail("opened garden seal did not create %s" % shortcut_name)
			return
	print("MOONPETAL_LAYOUT_SMOKE_OK rooms=5 open_cells=%d floor=8x4 gate=lantern loop=bell_walk" % total_open)
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("MOONPETAL_LAYOUT_SMOKE_FAILED: " + message)
	get_tree().quit(1)
