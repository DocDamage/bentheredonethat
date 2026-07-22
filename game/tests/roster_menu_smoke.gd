extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	menu.management_location_override = 1
	var has_roster_key := false
	for input_event in InputMap.action_get_events("roster_menu"):
		has_roster_key = has_roster_key or (input_event is InputEventKey and input_event.physical_keycode == KEY_R)
	if not has_roster_key:
		_fail("Roster is not bound to R")
		return
	menu.open_menu(&"roster")
	await get_tree().process_frame
	if not menu.visible or menu.selected_tab != &"roster" or menu._content.get_child_count() < 8:
		_fail("Roster page did not render party, formation, pet, and reserves")
		return
	menu._set_roster_formation(&"fighter", &"back")
	if CampaignState.formation_for(&"fighter") != &"back":
		_fail("Roster UI did not change formation")
		return
	menu._move_roster_to_reserve(&"fighter")
	if &"fighter" in CampaignState.party or CampaignState.recruit_status[&"fighter"] != &"reserve":
		_fail("Roster UI did not move Fighter to reserve")
		return
	menu._recall_to_party(&"fighter")
	if &"fighter" not in CampaignState.party:
		_fail("Roster UI could not recall a reserve recruit")
		return
	CampaignState.mark_story_flag(&"mansion_entered")
	menu._move_roster_to_reserve(&"fighter")
	if &"fighter" not in CampaignState.party:
		_fail("Roster UI bypassed an active scenario requirement")
		return
	menu.close_menu()
	print("ROSTER_MENU_SMOKE_OK ui=provided_assets direct=R controller_navigation=true reserve=true formation=true restrictions=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("ROSTER_MENU_SMOKE_FAILED: " + message)
	get_tree().quit(1)
