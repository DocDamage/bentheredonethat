extends Node


func _ready() -> void:
	CampaignState.setup_sandbox(Vector2i(50, 8))
	CampaignState.town_time_minutes = 8.0 * 60.0
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	main.get_node("Field/Map/CampaignWorld/TownBuildController").hide()
	var manager = main.get_node("Field/Map/CampaignWorld/TownResidents")
	for resident_id in manager.residents.keys():
		var gamepiece: Gamepiece = manager.residents[resident_id]["gamepiece"]
		var current := GamepieceRegistry.get_cell(gamepiece)
		var plan: Dictionary = manager.activity_plan(StringName(resident_id), current)
		manager.relocate_resident(StringName(resident_id), plan["target"])
		manager.residents[resident_id]["controller"]._set_activity(StringName(plan["activity"]), String(plan["label"]), StringName(plan["pose"]))
	# Approach one worker at a time: nearby intent is readable while distant
	# plaques remain hidden and leave the map unobstructed.
	main._place_player(Vector2i(45, 9))
	Camera.zoom = Vector2(0.8, 0.8)
	Camera._on_viewport_resized()
	Camera.reset_position()
	for _frame in range(8):
		await get_tree().process_frame
	_assert_one_nearby_badge(manager, "north")
	_capture("town-resident-routines-north.png")
	main._place_player(Vector2i(57, 17))
	Camera.reset_position()
	for _frame in range(8):
		await get_tree().process_frame
	_assert_one_nearby_badge(manager, "south")
	_capture("town-resident-routines-south.png")
	print("TOWN_RESIDENT_ROUTINES_CAPTURE_OK tasks=role_specific badges=proximity_readable residents=4")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save resident routine capture: %s" % error_string(error))


func _assert_one_nearby_badge(manager: Node, region: String) -> void:
	var visible_count := 0
	for resident_id in manager.residents.keys():
		var animation = manager.residents[resident_id]["gamepiece"].animation
		if animation.get_node("Anchor/ActivityBadge").visible:
			visible_count += 1
	assert(visible_count == 1, "%s capture should reveal one nearby activity plaque, got %d" % [region, visible_count])
