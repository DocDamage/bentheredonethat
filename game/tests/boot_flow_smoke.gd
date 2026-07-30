extends Node

const TEST_SAVE := "user://boot_flow_smoke.json"
const MISSING_SAVE := "user://boot_flow_missing.json"


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(MISSING_SAVE))
	CampaignState.reset_new_game()
	CampaignState.duckets = 321
	CampaignState.play_time_seconds = 7384.0
	CampaignState.last_save_cell = Vector2i(50, 8)
	CampaignState.last_location = "New Philadelphia"
	CampaignState.build_facility(0, "Cafe")
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Could not create isolated campaign save")
		return
	var summary := CampaignState.read_save_summary(TEST_SAVE)
	if not summary.get("valid", false) or summary.get("location") != "New Philadelphia":
		_fail("Safe save summary did not expose location metadata")
		return
	if CampaignState.format_play_time(summary.get("play_time_seconds", 0.0)) != "02:03:04":
		_fail("Save summary play time was not formatted correctly")
		return

	CampaignState.reset_new_game()
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.campaign_save_path = TEST_SAVE
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var title = main.get_node_or_null("CampaignTitleScreen")
	if not title or title._continue_button.disabled or Cutscene.is_cutscene_in_progress():
		_fail("Normal boot did not stop at a usable title screen")
		return
	if not title.choose_mode(&"continue"):
		_fail("Continue rejected a valid isolated save")
		return
	for _frame in range(5):
		await get_tree().process_frame
	if main.has_node("CampaignTitleScreen") or CampaignState.duckets != 321:
		_fail("Continue did not dismiss the title and restore campaign data")
		return
	if GamepieceRegistry.get_cell(Player.gamepiece) != Vector2i(50, 8):
		_fail("Continue did not restore the saved field cell")
		return
	var visual: CampaignMapVisual = main.get_node("Field/Map/CampaignWorld/GroundLayer/Visuals")
	if visual.built_facilities.get(0) != "Cafe":
		_fail("Continue did not rebuild saved town facilities")
		return
	main.queue_free()
	for _frame in range(5):
		await get_tree().process_frame

	CampaignState.reset_new_game()
	var sandbox_main := main_scene.instantiate()
	sandbox_main.campaign_save_path = MISSING_SAVE
	get_tree().root.add_child(sandbox_main)
	for _frame in range(8):
		await get_tree().process_frame
	var sandbox_title = sandbox_main.get_node_or_null("CampaignTitleScreen")
	if not sandbox_title or not sandbox_title._continue_button.disabled:
		_fail("Missing save did not disable Continue")
		return
	# Disabled Continue is removed from controller focus order, so one D-pad step
	# reaches Sandbox Workshop deterministically.
	await _send_joy_button(JOY_BUTTON_DPAD_DOWN)
	await _send_joy_button(JOY_BUTTON_A)
	for _frame in range(5):
		await get_tree().process_frame
	if sandbox_main.has_node("CampaignTitleScreen") or not CampaignState.sandbox_mode:
		_fail("Controller navigation did not launch Sandbox Workshop")
		return
	if CampaignState.party != [&"ben", &"fighter", &"astronaut"] or CampaignState.duckets < 999999:
		_fail("Sandbox did not provide the unlocked company setup")
		return
	if CampaignState.owned_inventions.size() != CampaignState.INVENTION_DEFINITIONS.size():
		_fail("Sandbox did not unlock laboratory inventions")
		return
	if GamepieceRegistry.get_cell(Player.gamepiece) != sandbox_main.TOWN_ARRIVAL:
		_fail("Sandbox did not begin in the empty town")
		return
	var unchanged := CampaignState.read_save_summary(TEST_SAVE)
	if int(unchanged.get("duckets", -1)) != 321:
		_fail("Sandbox altered the campaign save slot")
		return

	sandbox_main.queue_free()
	await get_tree().process_frame
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	CampaignState.reset_new_game()
	print("BOOT_FLOW_SMOKE_OK title=true continue=metadata+cell+world controller=true sandbox=separate opening=deferred")
	get_tree().quit(0)


func _send_joy_button(button: JoyButton) -> void:
	var press := InputEventJoypadButton.new()
	press.button_index = button
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventJoypadButton.new()
	release.button_index = button
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame


func _fail(message: String) -> void:
	printerr("BOOT_FLOW_SMOKE_FAILED: " + message)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	get_tree().quit(1)
