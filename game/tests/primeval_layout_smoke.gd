extends Node

const PRIMEVAL_ORIGIN := Vector2i(72, 32)
const ROOMS := {
	"grove": Rect2i(0, 4, 8, 4),
	"village": Rect2i(10, 4, 8, 4),
	"ruins": Rect2i(20, 4, 8, 4),
	"nest": Rect2i(10, 14, 8, 4),
	"caldera": Rect2i(20, 14, 8, 4),
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
				if Gameboard.pathfinder.has_cell(PRIMEVAL_ORIGIN + Vector2i(x, y)):
					open += 1
		if open < 30:
			_fail("%s exposes only %d walkable floor cells" % [room_name, open])
			return
		total_open += open
	if Gameboard.pathfinder.has_cell(main.PRIMEVAL_VILLAGE_TO_NEST):
		_fail("relay nest gate is open before terminal decoding")
		return
	CampaignState.story_flags[&"primeval_anchor_built"] = true
	CampaignState.story_flags[&"primeval_terminal_decoded"] = true
	main._on_campaign_state_changed()
	await get_tree().process_frame
	for shortcut_name in ["PrimevalGroveCanopyShortcut", "PrimevalNestCanopyShortcut"]:
		if not main.has_node("Field/Map/CampaignWorld/%s" % shortcut_name):
			_fail("decoded relay did not create %s" % shortcut_name)
			return
	print("PRIMEVAL_LAYOUT_SMOKE_OK rooms=5 open_cells=%d floor=8x4 gate=terminal loop=canopy" % total_open)
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("PRIMEVAL_LAYOUT_SMOKE_FAILED: " + message)
	get_tree().quit(1)
