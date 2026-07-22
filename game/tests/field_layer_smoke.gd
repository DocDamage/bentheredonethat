extends Node


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

	var root := main.get_node_or_null("Field/Map/CampaignWorld") as Node2D
	if not root:
		_fail("CampaignWorld was not created")
		return
	var expected_layers := ["GroundLayer", "LowDecorationLayer", "NavigationAndCollision", "YSortedActorsAndProps", "ForegroundLayer", "InteractionLayer", "EncounterLayer"]
	for layer_name in expected_layers:
		if not root.has_node(layer_name):
			_fail("missing field layer: %s" % layer_name)
			return
	var ground := root.get_node("GroundLayer") as Node2D
	var foreground := root.get_node("ForegroundLayer") as Node2D
	var actors := root.get_node("YSortedActorsAndProps") as Node2D
	if ground.z_index >= 0 or foreground.z_index <= 0 or not actors.y_sort_enabled:
		_fail("field layer ordering is not ground < actors < foreground")
		return
	var visual := ground.get_node_or_null("Visuals") as CampaignMapVisual
	var mansion_foreground := foreground.get_node_or_null("MansionForeground") as Node2D
	var town_foreground := foreground.get_node_or_null("TownForeground") as Node2D
	var asterion_foreground := foreground.get_node_or_null("AsterionForeground") as Node2D
	var moonpetal_foreground := foreground.get_node_or_null("MoonpetalForeground") as Node2D
	var empyreal_foreground := foreground.get_node_or_null("EmpyrealForeground") as Node2D
	var frosthold_foreground := foreground.get_node_or_null("FrostholdForeground") as Node2D
	var primeval_foreground := foreground.get_node_or_null("PrimevalForeground") as Node2D
	if not visual or not mansion_foreground or not town_foreground or not asterion_foreground or not moonpetal_foreground or not empyreal_foreground or not frosthold_foreground or not primeval_foreground:
		_fail("field background or foreground renderer was not attached")
		return
	Player.gamepiece.position = Gameboard.cell_to_pixel(Vector2i(12, 36))
	main._update_camera_limits(true)
	await get_tree().process_frame
	if visual.active_area != &"mansion_archive" or mansion_foreground.get("active_area") != &"mansion_archive":
		_fail("Mansion foreground did not follow area activation")
		return
	Player.gamepiece.position = Gameboard.cell_to_pixel(Vector2i(50, 8))
	main._update_camera_limits(true)
	await get_tree().process_frame
	if town_foreground.get("active_area") != &"town":
		_fail("Town foreground did not follow area activation")
		return
	Player.gamepiece.position = Gameboard.cell_to_pixel(Vector2i(40, 38))
	main._update_camera_limits(true)
	await get_tree().process_frame
	if asterion_foreground.get("active_area") != &"station_dock":
		_fail("Asterion foreground did not follow area activation")
		return
	Player.gamepiece.position = Gameboard.cell_to_pixel(Vector2i(184, 38))
	main._update_camera_limits(true)
	await get_tree().process_frame
	if moonpetal_foreground.get("active_area") != &"moonpetal_gate":
		_fail("Moonpetal foreground did not follow area activation")
		return
	Player.gamepiece.position = Gameboard.cell_to_pixel(Vector2i(220, 38))
	main._update_camera_limits(true)
	await get_tree().process_frame
	if empyreal_foreground.get("active_area") != &"empyreal_landing":
		_fail("Empyreal foreground did not follow area activation")
		return
	Player.gamepiece.position = Gameboard.cell_to_pixel(Vector2i(148, 38))
	main._update_camera_limits(true)
	await get_tree().process_frame
	if frosthold_foreground.get("active_area") != &"frosthold_gate":
		_fail("Frosthold foreground did not follow area activation")
		return
	Player.gamepiece.position = Gameboard.cell_to_pixel(Vector2i(76, 38))
	main._update_camera_limits(true)
	await get_tree().process_frame
	if primeval_foreground.get("active_area") != &"primeval_grove":
		_fail("Primeval foreground did not follow area activation")
		return
	print("FIELD_LAYER_SMOKE_OK layers=7 mansion+town+asterion+moonpetal+empyreal+frosthold+primeval_foreground=active y_sort=enabled")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("FIELD_LAYER_SMOKE_FAILED: " + message)
	get_tree().quit(1)
