extends Node

const ENCOUNTER_RUNTIME := preload("res://ben_rpg/world/campaign_encounter_runtime.gd")


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	if not ENCOUNTER_RUNTIME.validate().is_empty():
		_fail("The legacy encounter runtime contract is invalid")
		return
	CampaignState.reset_new_game()
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	var runtime := world.get_node_or_null("CampaignEncounterRuntime") as Node
	if not runtime or not runtime.has_method(&"legacy_controller_names"):
		_fail("Bootstrap did not compose the encounter runtime")
		return
	var expected: Array[StringName] = [&"MansionEncounters", &"AsterionEncounters", &"PrimevalEncounters", &"HeliosEncounters", &"FrostholdEncounters", &"MoonpetalEncounters", &"EmpyrealEncounters"]
	var actual_names: Array = runtime.call(&"legacy_controller_names")
	if actual_names != expected:
		_fail("Encounter runtime did not preserve the controller names and order")
		return
	var encounter_layer := world.get_node_or_null("EncounterLayer")
	for controller_name in expected:
		var controller := encounter_layer.get_node_or_null(NodePath(controller_name)) as EncounterDirector
		if not controller or controller.battle != main.get_node("CampaignBattle"):
			_fail("Encounter runtime did not bind %s to CampaignBattle" % controller_name)
			return
	var room_runtime: Node = world.get_node("ManifestRoomRuntime")
	room_runtime.call(&"activate", &"HM-02")
	await get_tree().process_frame
	var manifest_controller = runtime.call(&"manifest_controller")
	if not manifest_controller or manifest_controller.room_id != &"HM-02" or manifest_controller.formation_pool().is_empty():
		_fail("Encounter runtime did not activate the room-owned manifest controller")
		return
	room_runtime.call(&"activate", &"HM-06")
	await get_tree().process_frame
	if runtime.call(&"manifest_controller") != null:
		_fail("Scripted-only rooms must not retain a random manifest controller")
		return
	print("CAMPAIGN_ENCOUNTER_RUNTIME_SMOKE_OK controllers=7 manifest=room_owned policy=zone+scripted_only battle_binding=preserved")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("CAMPAIGN_ENCOUNTER_RUNTIME_SMOKE_FAILED: " + message)
	get_tree().quit(1)
