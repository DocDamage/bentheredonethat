extends Node

const FROSTHOLD_ORIGIN := Vector2i(144, 32)
const ROOMS := {
	"gate": Rect2i(0, 4, 8, 4),
	"market": Rect2i(10, 4, 8, 4),
	"causeway": Rect2i(20, 4, 8, 4),
	"rune_hall": Rect2i(10, 14, 8, 4),
	"throne": Rect2i(20, 14, 8, 4),
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
				if Gameboard.pathfinder.has_cell(FROSTHOLD_ORIGIN + Vector2i(x, y)):
					open += 1
		if open < 30:
			_fail("%s exposes only %d walkable floor cells" % [room_name, open])
			return
		total_open += open
	if Gameboard.pathfinder.has_cell(main.FROSTHOLD_MARKET_TO_RUNE_HALL):
		_fail("rune-hall shortcut is open before the causeway seal")
		return
	CampaignState.story_flags[&"frosthold_anchor_built"] = true
	CampaignState.story_flags[&"frosthold_causeway_seal_open"] = true
	main._on_campaign_state_changed()
	await get_tree().process_frame
	for shortcut_name in ["FrostholdMarketToRuneHall", "FrostholdRuneHallToMarket"]:
		if not main.has_node("Field/Map/CampaignWorld/%s" % shortcut_name):
			_fail("opened causeway seal did not create %s" % shortcut_name)
			return
	print("FROSTHOLD_LAYOUT_SMOKE_OK rooms=5 open_cells=%d floor=8x4 gate=causeway loop=rune_hall" % total_open)
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("FROSTHOLD_LAYOUT_SMOKE_FAILED: " + message)
	get_tree().quit(1)
