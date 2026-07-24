extends Node

const TEST_SAVE := "user://party_field_followers_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	_use_ben_only_fixture()
	for recruit_id in [&"fighter", &"astronaut", &"neon_viper", &"mossback_surveyor"]:
		CampaignState.discover_recruit(recruit_id)
		CampaignState.hire_recruit(recruit_id)
		CampaignState.add_to_party(recruit_id)
	for recruit_id in CampaignState.recruit_catalog.keys():
		if recruit_id == &"ben":
			continue
		var scene_path := String(CampaignState.recruit_catalog[recruit_id].get("field_animation_scene", ""))
		if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
			_fail("A recruit is missing an authored field-follower animation: %s" % String(recruit_id))
			return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	var followers := main.get_node("Field/Map/ActivePartyFollowers") as PartyFollowerTrain
	var expected: Array[StringName] = [&"fighter", &"astronaut", &"neon_viper", &"mossback_surveyor"]
	if followers.follower_ids() != expected or followers.get_child_count() != 4:
		_fail("The field train did not mirror Ben's four active hires")
		return
	for recruit_id in expected:
		var animation := followers.follower_animation(recruit_id)
		if not animation or animation.get_parent() != followers or animation.find_child("RecruitInteraction", true, false):
			_fail("A follower was not an animation-only, interaction-free field actor: %s" % String(recruit_id))
			return
	var registered_before := GamepieceRegistry.get_gamepieces().size()
	for gamepiece in GamepieceRegistry.get_gamepieces():
		if String(gamepiece.name).begins_with("Follower_"):
			_fail("A follower occupied a pathfinding cell")
			return

	var player: Gamepiece = Player.gamepiece
	var route: Array[Vector2i] = [
		Vector2i(11, 9), Vector2i(12, 9), Vector2i(13, 9), Vector2i(14, 9),
		Vector2i(14, 8), Vector2i(14, 7), Vector2i(14, 6),
	]
	for cell in route:
		player.move_to(Gameboard.cell_to_pixel(cell))
		while player.is_moving():
			await get_tree().process_frame
	await get_tree().process_frame
	var leader_position := followers.to_local(player.animation.global_position)
	var previous := leader_position
	for recruit_id in expected:
		var follower := followers.follower_animation(recruit_id)
		if previous.distance_to(follower.position) < 34.0:
			_fail("Follower spacing collapsed and sprites overlapped: %s" % String(recruit_id))
			return
		var on_vertical_leg := absf(follower.position.x - Gameboard.cell_to_pixel(Vector2i(14, 9)).x) < 2.0
		var on_horizontal_leg := absf(follower.position.y - Gameboard.cell_to_pixel(Vector2i(11, 9)).y) < 2.0
		if not on_vertical_leg and not on_horizontal_leg:
			_fail("A follower cut diagonally through the L-shaped route: %s at %s" % [String(recruit_id), follower.position])
			return
		previous = follower.position
	if GamepieceRegistry.get_gamepieces().size() != registered_before:
		_fail("Animation-only followers changed gamepiece occupancy during movement")
		return

	CampaignState.move_to_reserve(&"astronaut")
	await get_tree().process_frame
	if &"astronaut" in followers.follower_ids() or followers.get_child_count() != 3:
		_fail("Moving a hire to reserve did not remove their field follower")
		return
	CampaignState.discover_recruit(&"caveman")
	CampaignState.hire_recruit(&"caveman")
	CampaignState.add_to_party(&"caveman")
	await get_tree().process_frame
	if followers.follower_ids() != [&"fighter", &"neon_viper", &"mossback_surveyor", &"caveman"]:
		_fail("Adding a reserve hire did not rebuild the field train in party order")
		return
	CampaignState.move_party_member(&"caveman", -1)
	await get_tree().process_frame
	if followers.follower_ids() != [&"fighter", &"neon_viper", &"caveman", &"mossback_surveyor"]:
		_fail("Roster reordering did not reorder the visible follower train")
		return

	main._place_player(main.TOWN_ARRIVAL)
	await get_tree().process_frame
	leader_position = followers.to_local(player.animation.global_position)
	for recruit_id in followers.follower_ids():
		var follower := followers.follower_animation(recruit_id)
		if follower.position.distance_to(leader_position) > 235.0:
			_fail("A field transition left a follower stranded in the previous map: %s" % String(recruit_id))
			return
	if GamepieceRegistry.get_gamepieces().size() != registered_before:
		_fail("Teleporting the follower train changed navigation occupancy")
		return

	var raptor := player.animation.get_node_or_null("Anchor/Raptor") as Sprite2D
	if not raptor or raptor.scale.x > 0.9 or raptor.scale.y > 0.9:
		_fail("The autonomous velociraptor no longer has its separate small-dog field scale")
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("The reordered party could not be saved")
		return
	CampaignState.move_to_reserve(&"caveman")
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("The reordered party could not be loaded")
		return
	await get_tree().process_frame
	if followers.follower_ids() != [&"fighter", &"neon_viper", &"caveman", &"mossback_surveyor"]:
		_fail("Loading a party did not restore its field follower order")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("PARTY_FIELD_FOLLOWERS_SMOKE_OK hires=4 authored_animations=11 route=L_shaped collision=none roster=live transition=snap save_load=true raptor=small_dog")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("PARTY_FIELD_FOLLOWERS_SMOKE_FAILED: " + message)
	get_tree().quit(1)


func _use_ben_only_fixture() -> void:
	# Keep four follower slots available for this train-behavior fixture now that
	# the authored opening party has three core protagonists.
	CampaignState.party.assign([&"ben"])
	CampaignState.party_formation = {&"ben": &"back"}
	CampaignState.recruit_status[&"ben"] = &"party"
	CampaignState.recruit_status[&"lincoln"] = &"reserve"
	CampaignState.recruit_status[&"gandhi"] = &"reserve"
