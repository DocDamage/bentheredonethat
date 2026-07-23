extends Node


const CACHES := {
	&"primeval_ruins_plinth": {"room_id": &"PV-05", "node": "PrimevalRuinsTreasure", "cell": Vector2i(13, 8), "flag": &"primeval_ruins_treasure_claimed"},
	&"helios_market_terminal": {"room_id": &"HE-03", "node": "HeliosMarketTreasure", "cell": Vector2i(17, 8), "flag": &"helios_market_treasure_claimed"},
	&"frosthold_heat_cache": {"room_id": &"FR-03", "node": "FrostholdMarketTreasure", "cell": Vector2i(14, 8), "flag": &"frosthold_market_treasure_claimed"},
	&"moonpetal_offering": {"room_id": &"MP-04", "node": "MoonpetalGardenTreasure", "cell": Vector2i(12, 8), "flag": &"moonpetal_garden_treasure_claimed"},
	&"empyreal_tithe_basin": {"room_id": &"EM-03", "node": "EmpyrealGardenTreasure", "cell": Vector2i(14, 8), "flag": &"empyreal_garden_treasure_claimed"},
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.anchor_universe(3, &"haunted_mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.anchor_universe(4, &"asterion_station")
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.anchor_universe(5, &"primeval_expanse")
	CampaignState.story_flags[&"primeval_scenario_complete"] = true
	CampaignState.anchor_universe(6, &"helios_arcology")
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(8):
		await get_tree().process_frame
	var world: Node = main.get_node("Field/Map/CampaignWorld")
	var runtime: Node = world.get_node("ManifestRoomRuntime")
	var streamer: Node = world.get_node("RoomStreamer")
	if CampaignState.UNIVERSE_TREASURE_CACHES.size() != CACHES.size():
		_fail("The shared cache registry does not contain all five later universes")
		return
	if CampaignState.claim_universe_treasure(&"imaginary_cache").get("reason") != "unknown":
		_fail("An unknown treasure cache was accepted")
		return

	runtime.call(&"activate", &"HE-04")
	await get_tree().process_frame
	var transit_root := streamer.call(&"active_root") as Node2D
	if transit_root.get_node_or_null("InteractionLayer/HeliosMarketTreasure"):
		_fail("Helios Market treasure leaked into the adjacent Transit scene")
		return
	runtime.call(&"activate", &"HE-03")
	await get_tree().process_frame
	var market_root := streamer.call(&"active_root") as Node2D
	if not market_root.get_node_or_null("InteractionLayer/HeliosMarketTreasure"):
		_fail("Helios Market treasure was not installed in its authored room")
		return

	var expected_duckets := CampaignState.duckets
	for cache_id in CACHES:
		var expected: Dictionary = CACHES[cache_id]
		var room_id := StringName(expected["room_id"])
		runtime.call(&"activate", room_id)
		await get_tree().process_frame
		var root := streamer.call(&"active_root") as Node2D
		var interaction := root.get_node_or_null("InteractionLayer/%s" % expected["node"]) as UniverseTreasureInteraction
		if not interaction or interaction.cache_id != cache_id or interaction.area_id != "manifest:%s" % room_id:
			_fail("Missing or misconfigured room-scoped treasure interaction: %s" % expected["node"])
			return
		if Gameboard.pixel_to_cell(interaction.position) != expected["cell"]:
			_fail("Treasure hotspot is not grounded on its authored prop: %s" % cache_id)
			return
		if not interaction.has_node("InteractionArea2D") or not interaction.has_node("Button") or not interaction.get_node("TreasureMarker").visible:
			_fail("Treasure lacks visible, controller, or mouse affordances: %s" % cache_id)
			return
		var prior_gear := CampaignState.loot_inventory.size()
		var prior_inventory: Dictionary = CampaignState.inventory.duplicate(true)
		var rng := RandomNumberGenerator.new()
		rng.seed = hash(String(cache_id))
		var lines := interaction.apply_interaction(false, rng)
		await get_tree().process_frame
		if lines.size() != 2 or not bool(CampaignState.story_flags.get(expected["flag"], false)):
			_fail("Treasure did not produce its discovery text and persistent flag: %s" % cache_id)
			return
		if CampaignState.loot_inventory.size() != prior_gear + 1:
			_fail("Treasure did not guarantee one randomized equipment reward: %s" % cache_id)
			return
		var gear: Dictionary = CampaignState.loot_inventory[-1]
		if String(gear.get("rarity", "")).is_empty() or gear.get("modifiers", []).is_empty() or String(gear.get("source_pack", "")).is_empty():
			_fail("Treasure gear lost rarity, modifier, or source-pack metadata: %s" % cache_id)
			return
		if CampaignState.inventory == prior_inventory:
			_fail("Treasure did not include its guaranteed field supply: %s" % cache_id)
			return
		expected_duckets += int(CampaignState.UNIVERSE_TREASURE_CACHES[cache_id]["duckets"])
		if CampaignState.duckets != expected_duckets or interaction.get_node("TreasureMarker").visible:
			_fail("Treasure currency or opened visual state is wrong: %s" % cache_id)
			return
		var gear_after_claim := CampaignState.loot_inventory.size()
		var duckets_after_claim := CampaignState.duckets
		var revisit_lines := interaction.apply_interaction(false, rng)
		if revisit_lines.size() != 1 or CampaignState.loot_inventory.size() != gear_after_claim or CampaignState.duckets != duckets_after_claim:
			_fail("Revisiting a treasure cache duplicated its rewards: %s" % cache_id)
			return

	var saved_names: Array[String] = []
	for gear in CampaignState.loot_inventory:
		saved_names.append(String(gear.get("display_name", "")))
	var save_path := "user://universe_treasure_smoke.json"
	if CampaignState.save_game(save_path) != OK:
		_fail("Treasure discoveries could not be saved")
		return
	CampaignState.reset_new_game()
	if CampaignState.load_game(save_path) != OK:
		_fail("Treasure discoveries could not be loaded")
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
	if CampaignState.loot_inventory.size() != saved_names.size():
		_fail("Saved randomized treasure equipment was lost")
		return
	for cache_id in CACHES:
		if not bool(CampaignState.story_flags.get(CACHES[cache_id]["flag"], false)):
			_fail("Opened cache state was lost after reload: %s" % cache_id)
			return
	for index in range(saved_names.size()):
		if String(CampaignState.loot_inventory[index].get("display_name", "")) != saved_names[index]:
			_fail("Randomized treasure changed after reload")
			return

	print("UNIVERSE_TREASURE_SMOKE_OK caches=5 room_scoped=true visible=true controller+mouse=true randomized_gear=5 supplies=true duckets=true no_duplicates=true persistence=true")
	main.queue_free()
	await get_tree().process_frame
	get_tree().quit(0)


func _fail(message: String) -> void:
	printerr("UNIVERSE_TREASURE_SMOKE_FAILED: " + message)
	get_tree().quit(1)
