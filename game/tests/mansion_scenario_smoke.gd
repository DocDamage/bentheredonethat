extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame

	var runtime: Node = main.get_node("Field/Map/CampaignWorld/ManifestRoomRuntime")
	var streamer: Node = main.get_node("Field/Map/CampaignWorld/RoomStreamer")
	runtime.call(&"activate", &"HM-02")
	await get_tree().process_frame
	if runtime.get_node_or_null("ManifestPort_HM-02_E1"):
		_fail("The 4:44 route was open before the clock puzzle")
		return
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	CampaignState.state_changed.emit()
	await get_tree().process_frame
	if not runtime.get_node_or_null("ManifestPort_HM-02_E1"):
		_fail("Solving 4:44 did not open the authored Clock Passage port")
		return

	runtime.call(&"activate", &"HM-05")
	await get_tree().process_frame
	var archive := streamer.call(&"active_root") as Node2D
	var archive_anchor: MansionSavePoint = archive.get_node_or_null("InteractionLayer/ArchiveAnchorClock")
	if not archive_anchor:
		_fail("The Archive save point was not installed in HM-05")
		return
	CampaignState.set_character_vitals(&"ben", 1, 0, 140, 36)
	archive_anchor.activate_anchor(false)
	if int(CampaignState.character_progress[&"ben"].get("hp", 0)) != 140 or int(CampaignState.character_progress[&"ben"].get("mp", 0)) != 36:
		_fail("Archive anchor did not fully restore the party")
		return

	runtime.call(&"activate", &"HM-06")
	await get_tree().process_frame
	var gallery := streamer.call(&"active_root") as Node2D
	var portrait: MansionChapterInteraction = gallery.get_node_or_null("InteractionLayer/GalleryPortrait")
	CampaignState.story_flags[&"mansion_gallery_ambush_cleared"] = true
	if not portrait:
		_fail("The Gallery portrait interaction was not installed in HM-06")
		return
	portrait.apply_interaction(false)
	if int(CampaignState.inventory.get(&"silver_hour_hand", 0)) != 1:
		_fail("The portrait gallery did not grant the Silver Hour Hand")
		return

	runtime.call(&"activate", &"HM-07")
	await get_tree().process_frame
	var nursery := streamer.call(&"active_root") as Node2D
	var music_box: MansionChapterInteraction = nursery.get_node_or_null("InteractionLayer/NurseryMusicBox")
	CampaignState.story_flags[&"mansion_nursery_ambush_cleared"] = true
	if not music_box:
		_fail("The Nursery music-box interaction was not installed in HM-07")
		return
	music_box.apply_interaction(false)
	if int(CampaignState.inventory.get(&"brass_minute_hand", 0)) != 1:
		_fail("The nursery music box did not grant the Brass Minute Hand")
		return

	runtime.call(&"activate", &"HM-08")
	await get_tree().process_frame
	var antechamber := streamer.call(&"active_root") as Node2D
	var ballroom_gate: MansionChapterInteraction = antechamber.get_node_or_null("InteractionLayer/BallroomGate")
	if not ballroom_gate:
		_fail("The Ballroom gate interaction was not installed in HM-08")
		return
	ballroom_gate.apply_interaction(false)
	if not CampaignState.story_flags.get(&"mansion_ballroom_open", false):
		_fail("Both clock hands did not open the Ballroom")
		return
	if not runtime.get_node_or_null("ManifestPort_HM-08_Ne"):
		_fail("Opening the Ballroom did not enable HM-08's boss-room port")
		return

	print("MANSION_SCENARIO_SMOKE_OK rooms=HM02+HM05+HM06+HM07+HM08 gate=4:44 hands=gallery+nursery archive_save=true ballroom_port=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("MANSION_SCENARIO_SMOKE_FAILED: " + message)
	get_tree().quit(1)
