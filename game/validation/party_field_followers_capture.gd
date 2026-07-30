extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	for recruit_id in [&"fighter", &"astronaut", &"neon_viper", &"mossback_surveyor"]:
		CampaignState.discover_recruit(recruit_id)
		CampaignState.hire_recruit(recruit_id)
		CampaignState.add_to_party(recruit_id)
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	main.get_node("Field/Map/CampaignWorld/TownBuildController").hide()
	main._place_player(Vector2i(50, 11))
	var player: Gamepiece = Player.gamepiece
	var route: Array[Vector2i] = [
		Vector2i(51, 11), Vector2i(52, 11), Vector2i(53, 11), Vector2i(54, 11),
		Vector2i(54, 12), Vector2i(54, 13), Vector2i(54, 14),
	]
	for cell in route:
		player.move_to(Gameboard.cell_to_pixel(cell))
		while player.is_moving():
			await get_tree().process_frame
	for _frame in range(4):
		await get_tree().process_frame
	Camera.zoom = Vector2(0.62, 0.62)
	Camera._on_viewport_resized()
	Camera.reset_position()
	for _frame in range(4):
		await get_tree().process_frame
	var followers := main.get_node("Field/Map/ActivePartyFollowers") as PartyFollowerTrain
	assert(followers.follower_ids().size() == 4)
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/party-field-followers.png")
	if error != OK:
		printerr("PARTY_FIELD_FOLLOWERS_CAPTURE_FAILED error=%d" % error)
		get_tree().quit(1)
		return
	print("PARTY_FIELD_FOLLOWERS_CAPTURE_OK followers=4 route=L_shaped raptor=small_dog")
	get_tree().quit(0)
