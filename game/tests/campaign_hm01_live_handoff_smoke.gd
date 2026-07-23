extends Node

const STAGING_ORIGIN := Vector2i(300, 0)
const ENTRY_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const EXIT_PORT_CELL := STAGING_ORIGIN + Vector2i(6, 1)
const FOYER_SAFE_CELL := STAGING_ORIGIN + Vector2i(8, 3)
const STUDY_SAFE_CELL := STAGING_ORIGIN + Vector2i(7, 3)
const PASSAGE_SAFE_CELL := STAGING_ORIGIN + Vector2i(4, 3)
const ARCHIVE_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const ARCHIVE_SAVE_CELL := STAGING_ORIGIN + Vector2i(9, 7)
const BALCONY_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const GALLERY_SAFE_CELL := STAGING_ORIGIN + Vector2i(8, 3)
const MIRROR_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const MIRROR_CONSERVATORY_SAFE_CELL := STAGING_ORIGIN + Vector2i(14, 3)
const NURSERY_SAFE_CELL := STAGING_ORIGIN + Vector2i(7, 3)
const ANTECHAMBER_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const ANTECHAMBER_SAVE_CELL := STAGING_ORIGIN + Vector2i(9, 8)
const BALLROOM_SAFE_CELL := STAGING_ORIGIN + Vector2i(8, 3)
const CONSERVATORY_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const KITCHEN_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const ANTECHAMBER_LIFT_SAFE_CELL := STAGING_ORIGIN + Vector2i(14, 10)
const CHAPEL_SAFE_CELL := STAGING_ORIGIN + Vector2i(7, 3)
const NURSERY_CHAPEL_SAFE_CELL := STAGING_ORIGIN + Vector2i(18, 4)
const UNDERCROFT_SAFE_CELL := STAGING_ORIGIN + Vector2i(16, 3)
const ATTIC_SAFE_CELL := STAGING_ORIGIN + Vector2i(6, 3)
const ANTECHAMBER_ATTIC_SAFE_CELL := STAGING_ORIGIN + Vector2i(14, 5)


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
	# Facility portals are now resolved through the room registry. Exercise the
	# production facade rather than the removed Mansion-only transition builder.
	main._create_manifest_facility_portal(0, &"Haunted Mansion")
	var entrance := main.get_node_or_null("Field/Map/CampaignWorld/HauntedMansionEntrance") as AreaTransition
	var exit := main.get_node_or_null("Field/Map/CampaignWorld/HauntedMansionExit") as AreaTransition
	assert(entrance and exit, "Mansion facility must own manifest entry and exit transitions.")
	assert(Gameboard.pixel_to_cell(entrance.arrival_coordinates) == ENTRY_SAFE_CELL)
	assert(Gameboard.pixel_to_cell(exit.position) == EXIT_PORT_CELL)
	if not Gameboard.pathfinder.has_cell(ENTRY_SAFE_CELL):
		printerr("HM-01 safe arrival is not navigable")
		main.queue_free()
		await get_tree().process_frame
		get_tree().quit(1)
		return
	assert(Gameboard.pathfinder.has_cell(EXIT_PORT_CELL), "HM-01 enabled return port must be navigable.")
	main._place_player(ENTRY_SAFE_CELL)
	for _frame in range(2):
		await get_tree().process_frame
	assert(main._camera_area == "manifest:HM-01")
	var streamer: Node = main.get_node("Field/Map/CampaignWorld/RoomStreamer")
	assert(streamer.call(&"active_room_id") == &"HM-01")
	var runtime: Node = main.get_node("Field/Map/CampaignWorld/ManifestRoomRuntime")
	var foyer_port: Node = runtime.get_node_or_null("ManifestPort_HM-01_Ne")
	assert(foyer_port and Gameboard.pixel_to_cell(foyer_port.arrival_coordinates) == FOYER_SAFE_CELL)
	foyer_port.call(&"_on_blackout")
	main._place_player(FOYER_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-02")
	assert(streamer.call(&"active_room_id") == &"HM-02")
	assert(Gameboard.pathfinder.has_cell(FOYER_SAFE_CELL))
	assert(runtime.has_node("ManifestPort_HM-02_Nw"), "HM-02 must retain its reciprocal return port.")
	var study_port: Node = runtime.get_node_or_null("ManifestPort_HM-02_Ne")
	assert(study_port and Gameboard.pixel_to_cell(study_port.arrival_coordinates) == STUDY_SAFE_CELL)
	study_port.call(&"_on_blackout")
	main._place_player(STUDY_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-03")
	assert(streamer.call(&"active_room_id") == &"HM-03")
	assert(runtime.has_node("ManifestPort_HM-03_Nw"), "HM-03 must retain its reciprocal foyer return port.")
	var study_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(study_root.has_node("InteractionLayer/ManifestInteraction/Feature_false_book_row"))
	assert(study_root.has_node("InteractionLayer/ManifestInteraction/Feature_household_ledger"))
	runtime.call(&"activate", &"HM-02")
	main._place_player(FOYER_SAFE_CELL)
	await get_tree().process_frame
	assert(not runtime.has_node("ManifestPort_HM-02_E1"), "HM-02's 4:44 route must be closed before the clock flag.")
	assert(not Gameboard.pathfinder.has_cell(STAGING_ORIGIN + Vector2i(24, 6)))
	CampaignState.mark_story_flag(&"mansion_first_room_complete")
	await get_tree().process_frame
	assert(runtime.has_node("ManifestPort_HM-02_E1"), "HM-02's 4:44 route must open after the clock flag.")
	var passage_port: Node = runtime.get_node("ManifestPort_HM-02_E1")
	assert(Gameboard.pixel_to_cell(passage_port.arrival_coordinates) == PASSAGE_SAFE_CELL)
	passage_port.call(&"_on_blackout")
	main._place_player(PASSAGE_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-04")
	var passage_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(passage_root.has_node("InteractionLayer/ManifestInteraction/Feature_pendulum_blade_timing"))
	assert(passage_root.has_node("InteractionLayer/ManifestInteraction/Feature_clock_444_gate"))
	var archive_port: Node = runtime.get_node_or_null("ManifestPort_HM-04_Ne")
	assert(archive_port and Gameboard.pixel_to_cell(archive_port.arrival_coordinates) == ARCHIVE_SAFE_CELL)
	archive_port.call(&"_on_blackout")
	main._place_player(ARCHIVE_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-05")
	var archive_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(archive_root.has_node("InteractionLayer/ManifestInteraction/Feature_servant_records"))
	var archive_anchor: Node = archive_root.get_node_or_null("InteractionLayer/ArchiveAnchorClock")
	assert(archive_anchor and archive_anchor.get("save_point_id") == &"mansion_archive")
	CampaignState.set_character_vitals(&"ben", 1, 0, 140, 36)
	archive_anchor.call("activate_anchor", false)
	assert(bool(CampaignState.story_flags.get(&"mansion_archive_save_found", false)))
	assert(CampaignState.activated_save_point_near(ARCHIVE_SAVE_CELL).get("id", &"") == &"mansion_archive")
	var balcony_port: Node = runtime.get_node_or_null("ManifestPort_HM-05_E1")
	assert(balcony_port and Gameboard.pixel_to_cell(balcony_port.arrival_coordinates) == BALCONY_SAFE_CELL)
	balcony_port.call(&"_on_blackout")
	main._place_player(BALCONY_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-14")
	var balcony_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(balcony_root.has_node("InteractionLayer/ManifestInteraction/Feature_portrait_balcony"))
	var gallery_port: Node = runtime.get_node_or_null("ManifestPort_HM-14_Ne")
	if not gallery_port:
		_fail("HM-14 did not install its Gallery port")
		return
	if Gameboard.pixel_to_cell(gallery_port.arrival_coordinates) != GALLERY_SAFE_CELL:
		_fail("HM-14 Gallery arrival was %s, expected %s" % [Gameboard.pixel_to_cell(gallery_port.arrival_coordinates), GALLERY_SAFE_CELL])
		return
	gallery_port.call(&"_on_blackout")
	main._place_player(GALLERY_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-06")
	var gallery_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(gallery_root.has_node("InteractionLayer/ManifestInteraction/Feature_portrait_ambush"))
	assert(gallery_root.has_node("InteractionLayer/ManifestInteraction/Feature_silver_hour_hand"))
	var gallery_portrait: Node = gallery_root.get_node_or_null("InteractionLayer/GalleryPortrait")
	assert(gallery_portrait)
	CampaignState.mark_story_flag(&"mansion_gallery_ambush_cleared")
	gallery_portrait.call("apply_interaction", false)
	assert(bool(CampaignState.story_flags.get(&"mansion_hour_hand_found", false)))
	var mirror_port: Node = runtime.get_node_or_null("ManifestPort_HM-06_Ne")
	assert(mirror_port and Gameboard.pixel_to_cell(mirror_port.arrival_coordinates) == MIRROR_SAFE_CELL)
	mirror_port.call(&"_on_blackout")
	main._place_player(MIRROR_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-15")
	var mirror_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(mirror_root.has_node("InteractionLayer/ManifestInteraction/Feature_false_reflection_encounter"))
	var nursery_port: Node = runtime.get_node_or_null("ManifestPort_HM-15_Ne")
	assert(nursery_port and Gameboard.pixel_to_cell(nursery_port.arrival_coordinates) == NURSERY_SAFE_CELL)
	nursery_port.call(&"_on_blackout")
	main._place_player(NURSERY_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-07")
	var nursery_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(nursery_root.has_node("InteractionLayer/ManifestInteraction/Feature_doll_ambush"))
	assert(nursery_root.has_node("InteractionLayer/ManifestInteraction/Feature_brass_minute_hand"))
	var music_box: Node = nursery_root.get_node_or_null("InteractionLayer/NurseryMusicBox")
	assert(music_box)
	CampaignState.mark_story_flag(&"mansion_nursery_ambush_cleared")
	music_box.call("apply_interaction", false)
	assert(bool(CampaignState.story_flags.get(&"mansion_minute_hand_found", false)))
	var antechamber_port: Node = runtime.get_node_or_null("ManifestPort_HM-07_Ne")
	assert(antechamber_port and Gameboard.pixel_to_cell(antechamber_port.arrival_coordinates) == ANTECHAMBER_SAFE_CELL)
	antechamber_port.call(&"_on_blackout")
	main._place_player(ANTECHAMBER_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-08")
	var antechamber_root: Node2D = streamer.call(&"active_root") as Node2D
	var respite_clock: Node = antechamber_root.get_node_or_null("InteractionLayer/NurseryRespiteClock")
	assert(respite_clock and respite_clock.get("save_point_id") == &"mansion_ballroom_antechamber")
	respite_clock.call("activate_anchor", false)
	var active_respite: Dictionary = CampaignState.activated_save_point_near(ANTECHAMBER_SAVE_CELL)
	if active_respite.get("id", &"") != &"mansion_ballroom_antechamber":
		_fail("HM-08 respite anchor registered at the wrong cell: %s" % [active_respite])
		return
	var ballroom_gate: Node = antechamber_root.get_node_or_null("InteractionLayer/BallroomGate")
	assert(ballroom_gate)
	ballroom_gate.call("apply_interaction", false)
	assert(bool(CampaignState.story_flags.get(&"mansion_ballroom_open", false)))
	var ballroom_port: Node = runtime.get_node_or_null("ManifestPort_HM-08_Ne")
	assert(ballroom_port and Gameboard.pixel_to_cell(ballroom_port.arrival_coordinates) == BALLROOM_SAFE_CELL)
	ballroom_port.call(&"_on_blackout")
	main._place_player(BALLROOM_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-09")
	var ballroom_root: Node2D = streamer.call(&"active_root") as Node2D
	var appointment: Node = ballroom_root.get_node_or_null("InteractionLayer/The444Appointment")
	assert(appointment and appointment.call("begin_encounter"))
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	assert(battle.active and battle.model.encounter_id == &"mansion_archive_boss")
	battle.debug_force_victory()
	await get_tree().process_frame
	battle._leave_battle(true)
	await get_tree().process_frame
	assert(bool(CampaignState.story_flags.get(&"mansion_archive_boss_defeated", false)))
	assert(int(CampaignState.inventory.get(&"anchor_core", 0)) == 1)
	runtime.call(&"activate", &"HM-02")
	main._place_player(FOYER_SAFE_CELL)
	await get_tree().process_frame
	var conservatory_port: Node = runtime.get_node_or_null("ManifestPort_HM-02_E2")
	assert(conservatory_port and Gameboard.pixel_to_cell(conservatory_port.arrival_coordinates) == CONSERVATORY_SAFE_CELL)
	conservatory_port.call(&"_on_blackout")
	main._place_player(CONSERVATORY_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-10")
	var conservatory_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(conservatory_root.has_node("InteractionLayer/ManifestInteraction/Feature_cursed_tree_elite"))
	var mirror_return_port: Node = runtime.get_node_or_null("ManifestPort_HM-10_Ne")
	if not mirror_return_port:
		_fail("HM-10 did not install its Mirror Corridor port")
		return
	if Gameboard.pixel_to_cell(mirror_return_port.arrival_coordinates) != MIRROR_CONSERVATORY_SAFE_CELL:
		_fail("HM-10 Mirror Corridor arrival was %s, expected %s" % [Gameboard.pixel_to_cell(mirror_return_port.arrival_coordinates), MIRROR_CONSERVATORY_SAFE_CELL])
		return
	runtime.call(&"activate", &"HM-05")
	main._place_player(ARCHIVE_SAFE_CELL)
	await get_tree().process_frame
	var kitchen_port: Node = runtime.get_node_or_null("ManifestPort_HM-05_E2")
	assert(kitchen_port and Gameboard.pixel_to_cell(kitchen_port.arrival_coordinates) == KITCHEN_SAFE_CELL)
	kitchen_port.call(&"_on_blackout")
	main._place_player(KITCHEN_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-16")
	var kitchen_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(kitchen_root.has_node("InteractionLayer/ManifestInteraction/Feature_service_lift"))
	var antechamber_return_port: Node = runtime.get_node_or_null("ManifestPort_HM-16_Ne")
	assert(antechamber_return_port and Gameboard.pixel_to_cell(antechamber_return_port.arrival_coordinates) == ANTECHAMBER_LIFT_SAFE_CELL)
	runtime.call(&"activate", &"HM-05")
	main._place_player(ARCHIVE_SAFE_CELL)
	await get_tree().process_frame
	var chapel_port: Node = runtime.get_node_or_null("ManifestPort_HM-05_Ne")
	assert(chapel_port and Gameboard.pixel_to_cell(chapel_port.arrival_coordinates) == CHAPEL_SAFE_CELL)
	chapel_port.call(&"_on_blackout")
	main._place_player(CHAPEL_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-11")
	var chapel_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(chapel_root.has_node("InteractionLayer/ManifestInteraction/Feature_stained_glass_alignment"))
	var chapel_glass: Node = chapel_root.get_node_or_null("InteractionLayer/ChapelGlass")
	assert(chapel_glass)
	CampaignState.mark_story_flag(&"mansion_temporal_secret_found")
	chapel_glass.call("apply_interaction", false)
	assert(bool(CampaignState.story_flags.get(&"mansion_crypt_key_found", false)))
	var nursery_latch: Node = runtime.get_node_or_null("ManifestPort_HM-11_Ne")
	assert(nursery_latch and Gameboard.pixel_to_cell(nursery_latch.arrival_coordinates) == NURSERY_CHAPEL_SAFE_CELL)
	var undercroft_port: Node = runtime.get_node_or_null("ManifestPort_HM-11_E1")
	assert(undercroft_port and Gameboard.pixel_to_cell(undercroft_port.arrival_coordinates) == UNDERCROFT_SAFE_CELL)
	undercroft_port.call(&"_on_blackout")
	main._place_player(UNDERCROFT_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-12")
	var undercroft_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(undercroft_root.has_node("InteractionLayer/ManifestInteraction/Feature_temporal_field_note"))
	assert(runtime.has_node("ManifestPort_HM-12_Ne"))
	runtime.call(&"activate", &"HM-14")
	main._place_player(BALCONY_SAFE_CELL)
	await get_tree().process_frame
	var attic_port: Node = runtime.get_node_or_null("ManifestPort_HM-14_E1")
	assert(attic_port and Gameboard.pixel_to_cell(attic_port.arrival_coordinates) == ATTIC_SAFE_CELL)
	attic_port.call(&"_on_blackout")
	main._place_player(ATTIC_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-13")
	var attic_root: Node2D = streamer.call(&"active_root") as Node2D
	assert(attic_root.has_node("InteractionLayer/ManifestInteraction/Feature_dollmaker_invoice"))
	var attic_stair: Node = attic_root.get_node_or_null("InteractionLayer/AtticStair")
	assert(attic_stair)
	attic_stair.call("apply_interaction", false)
	assert(bool(CampaignState.story_flags.get(&"mansion_attic_latch_open", false)))
	var antechamber_attic_port: Node = runtime.get_node_or_null("ManifestPort_HM-13_Ne")
	assert(antechamber_attic_port and Gameboard.pixel_to_cell(antechamber_attic_port.arrival_coordinates) == ANTECHAMBER_ATTIC_SAFE_CELL)
	antechamber_attic_port.call(&"_on_blackout")
	main._place_player(ANTECHAMBER_ATTIC_SAFE_CELL)
	await get_tree().process_frame
	assert(runtime.call(&"active_room_id") == &"HM-08")
	assert(runtime.has_node("ManifestPort_HM-08_E1"))
	print("CAMPAIGN_HM01_LIVE_HANDOFF_SMOKE_OK entry=FI-05 HM-critical-spine=true clock_mirror_boss=true optional_loops=HM10+HM16+HM11+HM12+HM13 navigation=true archive+respite_save=true features=room_owned legacy_renderer=hidden camera=manifest")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit()


func _fail(message: String) -> void:
	printerr("CAMPAIGN_HM01_LIVE_HANDOFF_SMOKE_FAILED: " + message)
	get_tree().quit(1)
