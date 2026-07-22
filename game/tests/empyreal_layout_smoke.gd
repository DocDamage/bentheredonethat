extends Node

const EMPYREAL_ORIGIN := Vector2i(216, 32)
const ROOMS := {
	"landing": Rect2i(0, 4, 8, 4),
	"garden": Rect2i(10, 4, 8, 4),
	"forum": Rect2i(20, 4, 8, 4),
	"aerie": Rect2i(10, 14, 8, 4),
	"tribunal": Rect2i(20, 14, 8, 4),
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
				if Gameboard.pathfinder.has_cell(EMPYREAL_ORIGIN + Vector2i(x, y)):
					open += 1
		if open < 28:
			_fail("%s exposes only %d walkable floor cells" % [room_name, open])
			return
		total_open += open
	if Gameboard.pathfinder.has_cell(main.EMPYREAL_GARDEN_TO_AERIE):
		_fail("gravity route is open before the counterweight is earned")
		return
	CampaignState.story_flags[&"empyreal_anchor_built"] = true
	CampaignState.story_flags[&"empyreal_aerie_open"] = true
	main._on_campaign_state_changed()
	await get_tree().process_frame
	for shortcut_name in ["EmpyrealGardenToAerie", "EmpyrealAerieToGarden"]:
		if not main.has_node("Field/Map/CampaignWorld/%s" % shortcut_name):
			_fail("counterweight did not create %s" % shortcut_name)
			return
	print("EMPYREAL_LAYOUT_SMOKE_OK rooms=5 open_cells=%d floor=8x4 gate=counterweight loop=gravity_route" % total_open)
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("EMPYREAL_LAYOUT_SMOKE_FAILED: " + message)
	get_tree().quit(1)
