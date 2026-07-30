extends Node

const TEST_SAVE := "user://bestiary_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	if CampaignCombatDatabase.bestiary_ids().size() != 39:
		_fail("The bestiary does not enumerate every authored combat species")
		return
	if not CampaignState.discovered_bestiary_ids().is_empty():
		_fail("A new campaign revealed monster records before an encounter")
		return

	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	battle.suppress_persistence = true
	if not battle.begin(&"mansion_foyer_intro", 1776):
		_fail("The integration battle would not start")
		return
	var ghost_record := CampaignState.bestiary_record(&"schoolgirl_ghost")
	var book_record := CampaignState.bestiary_record(&"war_book")
	if int(ghost_record.get("seen", 0)) != 1 or int(book_record.get("seen", 0)) != 1:
		_fail("Beginning a battle did not record every visible enemy species")
		return
	battle.debug_force_victory()
	ghost_record = CampaignState.bestiary_record(&"schoolgirl_ghost")
	book_record = CampaignState.bestiary_record(&"war_book")
	if int(ghost_record.get("defeated", 0)) != 1 or int(book_record.get("defeated", 0)) != 1:
		_fail("Victory did not increment species defeat counts")
		return
	if ghost_record.get("drops", []).is_empty() or book_record.get("drops", []).is_empty():
		_fail("Observed battle spoils were not attached to the encounter's species records")
		return
	battle._leave_battle(true)
	if not battle.begin(&"ashfall_cinder_gate_arrival_raid", 1777):
		_fail("The admitted Cinder Gate arrival raid would not start")
		return
	var raider_record := CampaignState.bestiary_record(&"ashfall_raider")
	if int(raider_record.get("seen", 0)) != 2:
		_fail("The arrival raid did not record both visible Cinder Gate Raiders")
		return
	battle.debug_force_victory()
	if not bool(CampaignState.story_flags.get(&"ashfall_cinder_gate_arrival_raid_cleared", false)):
		_fail("The admitted arrival raid did not persist its stabilized-state flag")
		return
	battle._leave_battle(true)

	var entry := CampaignCombatDatabase.bestiary_entry(&"schoolgirl_ghost")
	if entry.is_empty() or String(entry.get("region", "")) != "Haunted Mansion" or float(entry.get("elements", {}).get(&"lightning", 0.0)) <= 1.0:
		_fail("The bestiary entry does not expose authored identity, region, or elemental analysis")
		return
	if not ResourceLoader.exists(String(entry.get("sprite_path", ""))):
		_fail("The bestiary entry does not resolve its supplied monster artwork")
		return

	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Bestiary progress could not be saved")
		return
	CampaignState.bestiary_records.clear()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Bestiary progress could not be loaded")
		return
	ghost_record = CampaignState.bestiary_record(&"schoolgirl_ghost")
	if int(ghost_record.get("seen", 0)) != 1 or int(ghost_record.get("defeated", 0)) != 1 or ghost_record.get("drops", []).is_empty():
		_fail("Sightings, defeats, or observed drops did not survive save migration")
		return

	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	menu.open_menu(&"bestiary")
	await get_tree().process_frame
	var portrait := menu.find_child("BestiaryPortrait", true, false) as TextureRect
	var species_button := menu.find_child("Bestiary_schoolgirl_ghost", true, false) as Button
	var tab := menu.find_child("BestiaryTab", true, false) as Button
	if not menu.visible or menu.selected_tab != &"bestiary" or not tab or not portrait or not portrait.texture or not species_button:
		_fail("The controller-ready menu did not render its bestiary tab, supplied portrait, and species catalog")
		return
	var summary := CampaignState.library_record_summary()
	if int(summary.get("bestiary_seen", 0)) != 3 or int(summary.get("monsters_defeated", 0)) != 4:
		_fail("The Library record summary did not include bestiary completion")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("BESTIARY_SMOKE_OK species=39 discovery=battle_begin defeats=victory ashfall_arrival=admitted+stateful intel=stats+actions+elements drops=observed ui=supplied_art+controller save=v18")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("BESTIARY_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
