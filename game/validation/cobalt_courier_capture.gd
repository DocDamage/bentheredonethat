extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.story_flags[&"helios_scenario_complete"] = true
	CampaignState.story_flags[&"fourth_universe_stabilized"] = true
	CampaignState.discover_recruit(&"fighter")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	main.get_node("Field/Map/CampaignWorld/TownBuildController").hide()
	main._place_player(main.HELIOS_ORIGIN + Vector2i(24, 5))
	Camera.zoom = Vector2(1.25, 1.25)
	Camera._on_viewport_resized()
	Camera.reset_position()
	for _frame in range(6):
		await get_tree().process_frame
	_capture("cobalt-courier-field.png")

	var battle := main.get_node("CampaignBattle") as CampaignBattle
	battle.suppress_persistence = true
	battle.begin(&"helios_cobalt_courier_trial", 1776)
	for _frame in range(8):
		await get_tree().process_frame
	var ben: Dictionary = battle.model.get_actor(&"ben")
	ben["atb"] = 100.0
	battle._show_commands(&"ben")
	for _frame in range(3):
		await get_tree().process_frame
	_capture("cobalt-courier-battle.png")
	battle._play_actor_action(&"cobalt_courier_challenger_0", &"express_jolt")
	await get_tree().create_timer(0.32).timeout
	_capture("cobalt-courier-battle-power.png")
	print("COBALT_COURIER_CAPTURE_OK field=80px_slice battle=side_view states=idle+power")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png("res://validation/%s" % file_name)
	if result != OK:
		printerr("COBALT_COURIER_CAPTURE_FAILED file=%s error=%d" % [file_name, result])
		get_tree().quit(1)
