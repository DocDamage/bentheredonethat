extends Node


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Armory")
	CampaignState.story_flags[&"asterion_anchor_built"] = true
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.story_flags[&"second_universe_stabilized"] = true
	CampaignState.discover_recruit(&"fighter")
	CampaignState.hire_recruit(&"fighter")
	CampaignState.add_to_party(&"fighter")
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	for _frame in range(10):
		await get_tree().process_frame
	main.get_node("Field/Map/CampaignWorld/TownBuildController").hide()
	main._place_player(main.STATION_ORIGIN + Vector2i(24, 15))
	Camera.zoom = Vector2(1.25, 1.25)
	Camera._on_viewport_resized()
	Camera.reset_position()
	for _frame in range(8):
		await get_tree().process_frame
	_capture("bulkhead-warden-field.png")

	var battle := main.get_node("CampaignBattle") as CampaignBattle
	battle.suppress_persistence = true
	battle.begin(&"asterion_bulkhead_warden_trial", 1776)
	for _frame in range(8):
		await get_tree().process_frame
	var ben: Dictionary = battle.model.get_actor(&"ben")
	ben["atb"] = 100.0
	battle._show_commands(&"ben")
	for _frame in range(3):
		await get_tree().process_frame
	_capture("bulkhead-warden-battle.png")
	battle._play_actor_action(&"bulkhead_warden_challenger_0", &"piston_surge")
	await get_tree().create_timer(0.32).timeout
	_capture("bulkhead-warden-battle-power.png")
	print("BULKHEAD_WARDEN_CAPTURE_OK field=80px_slice battle=side_view states=idle+power")
	get_tree().quit(0)


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var result := image.save_png("res://validation/%s" % file_name)
	if result != OK:
		printerr("BULKHEAD_WARDEN_CAPTURE_FAILED file=%s error=%d" % [file_name, result])
		get_tree().quit(1)
