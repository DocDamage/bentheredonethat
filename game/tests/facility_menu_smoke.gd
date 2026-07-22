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
	CampaignState.duckets = 120

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var menu: CampaignMenu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	menu.management_location_override = 1
	var has_key := false
	var has_controller := false
	for input_event in InputMap.action_get_events("facility_management"):
		has_key = has_key or (input_event is InputEventKey and input_event.physical_keycode == KEY_M)
		has_controller = has_controller or (input_event is InputEventJoypadButton and input_event.button_index == JOY_BUTTON_BACK)
	if not has_key or not has_controller:
		_fail("Facility management is not bound to M and controller Select")
		return

	menu.open_menu(&"facilities")
	await get_tree().process_frame
	if not menu.visible or menu.selected_tab != &"facilities" or menu.selected_facility != "Cafe":
		_fail("Direct facility menu did not open on the first built facility")
		return
	if menu._content.get_child_count() < 8:
		_fail("Facility screen did not render staffing, jobs, and inventions")
		return

	menu._assign_facility_worker(&"fighter")
	if CampaignState.facility_worker("Cafe") != &"fighter" or &"fighter" in CampaignState.party:
		_fail("Facility UI did not move Fighter out of the party")
		return
	menu._start_facility_job(&"cafe_founders_supper", true)
	if CampaignState.facility_job_status("Cafe").is_empty():
		_fail("Facility UI could not start an assisted assignment")
		return
	CampaignState.active_facility_jobs["Cafe"]["finishes_at"] = 0
	CampaignState.refresh_facility_jobs()
	menu._collect_facility_job()
	if menu._last_facility_result.is_empty() or CampaignState.duckets <= 120:
		_fail("Facility UI could not collect completed idle rewards")
		return
	menu._release_facility_worker()
	if CampaignState.recruit_status[&"fighter"] != &"reserve":
		_fail("Facility UI could not release a finished worker")
		return
	menu._craft_invention(&"serving_automaton")
	if &"serving_automaton" not in CampaignState.owned_inventions:
		_fail("Laboratory invention action was not connected")
		return

	menu.close_menu()
	print("FACILITY_MENU_SMOKE_OK ui=provided_assets direct=M+Select controller=true staffing=true jobs=true inventions=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("FACILITY_MENU_SMOKE_FAILED: " + message)
	get_tree().quit(1)
