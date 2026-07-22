extends Node


const BLOCKED_CELLS := [
	# Laboratory worktops and lower machinery.
	Vector2i(3, 3), Vector2i(16, 9),
	# Town laboratory roof and authored trees.
	Vector2i(48, 3), Vector2i(37, 1), Vector2i(64, 2), Vector2i(38, 19),
	# Solid universe floor props.
	Vector2i(156, 47), Vector2i(158, 36),
	Vector2i(201, 46), Vector2i(205, 46), Vector2i(204, 46),
	Vector2i(228, 36), Vector2i(231, 36), Vector2i(230, 47), Vector2i(237, 46),
]

const CLEAR_APPROACHES := [
	Vector2i(10, 9), Vector2i(50, 7),
	Vector2i(158, 37), Vector2i(203, 47),
	Vector2i(229, 47), Vector2i(230, 48),
]


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_run()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Haunted Mansion")
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for cell in BLOCKED_CELLS:
		if Gameboard.pathfinder.has_cell(cell):
			_fail("Visible solid footprint remained walkable at %s" % cell)
			return
	for cell in CLEAR_APPROACHES:
		if not Gameboard.pathfinder.has_cell(cell):
			_fail("Interaction approach or doorway became blocked at %s" % cell)
			return
	print("WORLD_COLLISION_FOOTPRINTS_SMOKE_OK lab=full_machines town=roof+trees universes=props+bosses approaches=clear")
	main.queue_free()
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("WORLD_COLLISION_FOOTPRINTS_SMOKE_FAILED: " + message)
	get_tree().quit(1)
