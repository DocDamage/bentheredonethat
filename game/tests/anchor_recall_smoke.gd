extends Node

const TEST_SAVE := "user://anchor_recall_smoke.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Armory")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.build_facility(4, "Haunted Mansion")
	for flag in [
		&"opening_complete", &"town_entered", &"mansion_entered", &"mansion_foyer_cleared",
		&"mansion_clock_examined", &"mansion_ledger_found", &"mansion_first_room_complete",
		&"mansion_archive_save_found", &"mansion_gallery_ambush_cleared", &"mansion_hour_hand_found",
		&"mansion_nursery_ambush_cleared", &"mansion_minute_hand_found", &"mansion_ballroom_open",
		&"mansion_archive_boss_defeated", &"haunted_mansion_scenario_complete", &"first_universe_stabilized",
	]:
		CampaignState.mark_story_flag(flag)
	CampaignState.add_item(&"anchor_core", 1, false)
	CampaignState.sync_quests()
	if StringName(CampaignState.quest_state(&"a_portable_way_home").get("status", "")) != &"active":
		_fail("The post-Mansion recall quest did not unlock")
		return
	if not CampaignState.craft_invention(&"continuity_kite"):
		_fail("The recovered Anchor Core could not be installed in the Continuity Kite")
		return
	if int(CampaignState.inventory.get(&"anchor_core", 0)) != 0 or &"continuity_kite" not in CampaignState.owned_inventions:
		_fail("Crafting did not consume and persist the unique Anchor Core")
		return
	if int(CampaignState.quest_state(&"a_portable_way_home").get("step", 0)) != 1:
		_fail("Building the Continuity Kite did not advance its tutorial quest")
		return

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	main.campaign_save_path = TEST_SAVE
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	main._place_player(Vector2i(4, 38))
	CampaignState.character_progress[&"ben"]["hp"] = 31
	var mansion_cell := GamepieceRegistry.get_cell(Player.gamepiece)
	if not bool(main.anchor_recall_availability().get("allowed", false)):
		_fail("The Continuity Kite was not available from an unrestricted universe")
		return

	CampaignState.story_flags[&"anchor_recall_suppressed"] = true
	CampaignState.story_flags[&"anchor_recall_lock_reason"] = "The test scenario is pinning the party in place."
	var denied: Dictionary = main.anchor_recall_availability()
	if bool(denied.get("allowed", true)) or not String(denied.get("reason", "")).contains("pinning"):
		_fail("Scenario recall suppression did not expose its authored reason")
		return
	if main.anchor_recall_to_town() or GamepieceRegistry.get_cell(Player.gamepiece) != mansion_cell:
		_fail("A scenario lockout failed to keep the party in place")
		return
	CampaignState.story_flags.erase(&"anchor_recall_suppressed")
	CampaignState.story_flags.erase(&"anchor_recall_lock_reason")

	var has_k := false
	var has_l3 := false
	for event in InputMap.action_get_events("anchor_recall"):
		has_k = has_k or (event is InputEventKey and event.physical_keycode == KEY_K)
		has_l3 = has_l3 or (event is InputEventJoypadButton and event.button_index == JOY_BUTTON_LEFT_STICK)
	if not has_k or not has_l3:
		_fail("Recall was not mapped for both keyboard and modern controllers")
		return
	Input.action_press("anchor_recall")
	await get_tree().process_frame
	Input.action_release("anchor_recall")
	await get_tree().process_frame
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	if not menu.visible or menu.selected_tab != &"recall":
		_fail("The K/L3 shortcut did not open the supplied-asset recall page")
		return
	var recall_button := menu.find_child("ContinuityKiteRecall", true, false) as Button
	if not recall_button or recall_button.disabled:
		_fail("The recall page did not expose an enabled destination command")
		return
	recall_button.pressed.emit()
	for _frame in range(3):
		await get_tree().process_frame
	if GamepieceRegistry.get_cell(Player.gamepiece) != Vector2i(50, 8):
		_fail("Continuity Kite did not return the party to New Philadelphia")
		return
	if int(CampaignState.character_progress[&"ben"]["hp"]) != 31:
		_fail("Normal field recall incorrectly restored party HP")
		return
	if not CampaignState.story_flags.get(&"continuity_kite_used", false) or int(CampaignState.story_flags.get(&"continuity_kite_use_count", 0)) != 1:
		_fail("Recall usage was not recorded exactly once")
		return
	if StringName(CampaignState.quest_state(&"a_portable_way_home").get("status", "")) != &"complete":
		_fail("The first successful field recall did not complete its tutorial quest")
		return
	if CampaignState.load_game(TEST_SAVE) != OK or &"continuity_kite" not in CampaignState.owned_inventions or not CampaignState.story_flags.get(&"continuity_kite_used", false):
		_fail("Town arrival autosave did not preserve the invention and tutorial state")
		return

	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	print("ANCHOR_RECALL_SMOKE_OK invention=anchor_core>continuity_kite shortcut=K+L3 ui=provided_assets lockout=authored town=(50,8) heal=false autosave=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("ANCHOR_RECALL_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
