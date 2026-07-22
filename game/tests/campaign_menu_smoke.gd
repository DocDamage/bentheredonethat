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
	CampaignState.character_progress[&"ben"]["skill_points"] = 2
	CampaignState.loot_inventory.append({
		"instance_id": "menu-test-saber", "id": &"iron_saber", "base_name": "Iron Saber",
		"display_name": "Rare Iron Saber of Force", "slot": "weapon",
		"icon": "res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png",
		"rarity": "Rare", "rarity_color": "#58a6ff",
		"modifiers": [{"name": "of Force", "stat": "attack", "value": 6}],
		"granted_action": &"borrowed_second", "kind": "gear", "source_pack": "armory",
	})
	if CampaignState.EQUIPMENT_SLOTS.size() != 6 or not ResourceLoader.exists("res://game_assets/items/armory/Singles/Weapon_Singles/Iron/Iron_Weapon1.png"):
		_fail("Six-slot configuration or imported armory icon is missing")
		return

	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(6):
		await get_tree().process_frame
	var menu = main.get_node("CampaignMenu")
	menu.suppress_persistence = true
	var has_start_binding := false
	for input_event in InputMap.action_get_events("campaign_menu"):
		has_start_binding = has_start_binding or (input_event is InputEventJoypadButton and input_event.button_index == JOY_BUTTON_START)
	if not has_start_binding:
		_fail("Company menu is not bound to the modern-controller Start button")
		return
	menu.open_menu()
	await get_tree().process_frame
	if not menu.visible or not menu._at_laboratory() or menu._content.get_child_count() < 2:
		_fail("Company menu did not open in the laboratory with rendered content")
		return

	menu._equip_item("menu-test-saber")
	var actor := CampaignCombatDatabase.party_actor(&"ben", CampaignState.character_progress[&"ben"])
	if actor["attack"] != 22 or &"borrowed_second" not in actor["actions"]:
		_fail("Equipped modifiers or equipment-granted action did not reach combat stats")
		return
	menu._select_tab(&"skills")
	menu._learn_skill(&"efficient_capacitor")
	menu._learn_skill(&"voltaic_cage_training")
	actor = CampaignCombatDatabase.party_actor(&"ben", CampaignState.character_progress[&"ben"])
	if actor["magic"] != 36 or &"voltaic_cage" not in actor["actions"] or int(CampaignState.character_progress[&"ben"]["skill_points"]) != 0:
		_fail("Specialty prerequisites, passive bonus, or learned action failed")
		return
	var save_path := "user://campaign_menu_smoke.json"
	if CampaignState.save_game(save_path) != OK:
		_fail("Equipment and skill state could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(save_path) != OK:
		_fail("Equipment and skill state could not be loaded")
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	actor = CampaignCombatDatabase.party_actor(&"ben", CampaignState.character_progress[&"ben"])
	if actor["attack"] != 22 or actor["magic"] != 36 or &"borrowed_second" not in actor["actions"] or &"voltaic_cage" not in actor["actions"]:
		_fail("Saved equipment, modifiers, or learned actions did not survive reload")
		return
	menu._reset_skills()
	if int(CampaignState.character_progress[&"ben"]["skill_points"]) != 2 or not CampaignState.character_progress[&"ben"]["learned_skills"].is_empty():
		_fail("Free laboratory reset did not refund learned skill points")
		return

	var player: Gamepiece = Player.gamepiece
	var town_cell := Vector2i(50, 8)
	player.position = Gameboard.cell_to_pixel(town_cell)
	player.rest_position = player.position
	GamepieceRegistry.move_gamepiece(player, town_cell)
	if menu._at_laboratory():
		_fail("Skill reset remained available outside Ben's laboratory")
		return
	menu._select_tab(&"telemetry")
	await get_tree().process_frame
	if menu._content.get_node_or_null("LocalTelemetryToggle") == null:
		_fail("Company menu did not expose the local telemetry opt-in")
		return
	menu._toggle_local_telemetry()
	if not LocalTelemetry.is_enabled() or int(LocalTelemetry.summary().get("events", 0)) < 1:
		_fail("Local telemetry opt-in did not start a local diagnostics session")
		return
	menu._toggle_local_telemetry()
	if LocalTelemetry.is_enabled():
		_fail("Local telemetry opt-out did not persist")
		return
	CampaignState.story_flags[&"empyreal_scenario_complete"] = true
	if not CampaignState.commit_campaign_ending_result() or not CampaignState.complete_campaign_ending(town_cell):
		_fail("Postgame menu setup could not commit the ending state")
		return
	menu._select_tab(&"postgame")
	await get_tree().process_frame
	var rematch := menu._content.get_node_or_null("HighComptrollerRematch") as Button
	if rematch == null or rematch.disabled or not main.postgame_rematch_availability().get("allowed", false):
		_fail("Postgame Tribunal Ledger did not expose the town rematch path")
		return
	menu.close_menu()
	print("CAMPAIGN_MENU_SMOKE_OK slots=6 gear_stats=true equipment_ability=true skills=prerequisites+refund controller_menu=true telemetry_opt_in=true postgame_ledger=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_MENU_SMOKE_FAILED: " + message)
	get_tree().quit(1)
