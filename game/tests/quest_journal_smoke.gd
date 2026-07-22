extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.mark_story_flag(&"opening_complete")
	CampaignState.mark_story_flag(&"town_entered")
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	CampaignState.build_facility(3, "Haunted Mansion")

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	var has_journal_key := false
	for input_event in InputMap.action_get_events("quest_journal"):
		has_journal_key = has_journal_key or (input_event is InputEventKey and input_event.physical_keycode == KEY_J)
	if not has_journal_key:
		_fail("Quest journal is not bound to J")
		return
	menu.open_menu(&"quests")
	await get_tree().process_frame
	if not menu.visible or menu.selected_tab != &"quests" or menu._content.get_child_count() < 10:
		_fail("Quest Journal did not render discovered quests and details")
		return
	menu._select_quest(&"company_at_work")
	menu._track_selected_quest()
	if CampaignState.tracked_quest != &"company_at_work":
		_fail("Journal track action did not update the campaign")
		return
	var objective := CampaignState.tracked_objective()
	if objective.get("title", "") != "Company at Work" or not String(objective.get("objective", "")).contains("Assign a recruit"):
		_fail("Tracked side-quest objective did not resolve its current step")
		return
	var hud = main.get_node("Field/Map/CampaignWorld/TownBuildController")
	hud._update_hud()
	if not hud._objective_label.text.contains("COMPANY AT WORK"):
		_fail("Field HUD did not display the journal's tracked quest")
		return
	menu.close_menu()
	print("QUEST_JOURNAL_SMOKE_OK ui=provided_assets tracking=true field_hud=true direct=J controller_navigation=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("QUEST_JOURNAL_SMOKE_FAILED: " + message)
	get_tree().quit(1)
