extends Node

const MANSION_ORIGIN := Vector2i(0, 32)
const ROOMS := {
	"foyer": Rect2i(0, 4, 8, 4),
	"archive": Rect2i(10, 4, 8, 4),
	"gallery": Rect2i(0, 14, 8, 4),
	"nursery": Rect2i(10, 14, 8, 4),
	"ballroom": Rect2i(20, 9, 8, 4),
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
				if Gameboard.pathfinder.has_cell(MANSION_ORIGIN + Vector2i(x, y)):
					open += 1
		if open < 28:
			_fail("%s exposes only %d walkable floor cells" % [room_name, open])
			return
		total_open += open

	# Story gates and physical props must remain solid even after the floor expands.
	for local_cell in [Vector2i(6, 4), Vector2i(16, 14), Vector2i(10, 5), Vector2i(16, 5), Vector2i(24, 9)]:
		if Gameboard.pathfinder.has_cell(MANSION_ORIGIN + local_cell):
			_fail("blocked mansion cell became walkable: %s" % local_cell)
			return

	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	main._on_campaign_state_changed()
	await get_tree().process_frame
	for shortcut_name in ["MansionFoyerServiceShortcut", "MansionGalleryServiceShortcut"]:
		if not main.has_node("Field/Map/CampaignWorld/%s" % shortcut_name):
			_fail("opening puzzle did not create the %s loop" % shortcut_name)
			return

	print("MANSION_LAYOUT_SMOKE_OK rooms=5 open_cells=%d floor=8x4 gates+props=solid loop=service_shortcut" % total_open)
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("MANSION_LAYOUT_SMOKE_FAILED: " + message)
	get_tree().quit(1)
