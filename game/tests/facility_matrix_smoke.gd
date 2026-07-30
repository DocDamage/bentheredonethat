extends Node

const TEST_SAVE := "user://facility_matrix_smoke.json"
const TOWN_ORIGIN := Vector2i(36, 0)
const TOWN_ARRIVAL := Vector2i(50, 8)
const FACILITIES: Array[String] = [
	"Cafe", "Library", "Clinic", "Armory", "Haunted Mansion", "Observatory",
	"Trailhead Lodge", "Afterlight Club", "Cold Storage", "Tea House", "Belfry",
]
const FACILITY_PLOTS: Array[Rect2i] = [
	Rect2i(7, 5, 5, 4), Rect2i(18, 5, 5, 4), Rect2i(7, 13, 5, 4),
	Rect2i(16, 12, 9, 5), Rect2i(25, 13, 7, 4), Rect2i(25, 5, 5, 4),
	Rect2i(1, 13, 5, 4), Rect2i(1, 4, 5, 5), Rect2i(16, 20, 5, 5),
	Rect2i(25, 20, 5, 5), Rect2i(7, 20, 5, 5),
]
const SERVICE_NODES := {
	"Cafe": "CafeService", "Library": "LibraryService", "Clinic": "ClinicService", "Armory": "ArmoryService",
}
const PORTAL_NODES := {
	"Haunted Mansion": ["HauntedMansionEntrance", "HauntedMansionExit"],
	"Observatory": ["AsterionStationEntrance", "AsterionStationExit"],
	"Trailhead Lodge": ["PrimevalExpanseEntrance", "PrimevalExpanseExit"],
	"Afterlight Club": ["HeliosArcologyEntrance", "HeliosArcologyExit"],
	"Cold Storage": ["FrostholdKingdomEntrance", "FrostholdKingdomExit"],
	"Tea House": ["MoonpetalCourtEntrance", "MoonpetalCourtExit"],
	"Belfry": ["EmpyrealCourtEntrance", "EmpyrealCourtExit"],
}
const UNIVERSES := {
	"Haunted Mansion": &"haunted_mansion", "Observatory": &"asterion_station",
	"Trailhead Lodge": &"primeval_expanse", "Afterlight Club": &"helios_arcology",
	"Cold Storage": &"frosthold_kingdom", "Tea House": &"moonpetal_court", "Belfry": &"empyreal_court",
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	_remove_test_save()
	var combinations := _record_placement_matrix()
	if combinations != FACILITIES.size() * FACILITY_PLOTS.size():
		_fail("Placement matrix recorded %d combinations instead of 121" % combinations)
		return
	if not _seed_all_facilities():
		return
	var main := await _launch_main()
	if not _assert_facility_runtime(main, "initial construction"):
		return
	if CampaignState.save_game(TEST_SAVE) != OK:
		_fail("Eleven-lot facility state could not be saved")
		return
	main.queue_free()
	await get_tree().process_frame
	CampaignState.reset_new_game()
	if CampaignState.load_game(TEST_SAVE) != OK:
		_fail("Eleven-lot facility state could not be reloaded")
		return
	main = await _launch_main()
	if not _assert_facility_runtime(main, "save reload"):
		return
	main.queue_free()
	await get_tree().process_frame
	if not await _assert_sandbox_relocation():
		return
	_remove_test_save()
	CampaignState.reset_new_game()
	print("FACILITY_MATRIX_SMOKE_OK combinations=121 collision=all_lots services=4 portals=7 returns=exact save_reload=true sandbox_relocation=true")
	get_tree().quit(0)


func _record_placement_matrix() -> int:
	var combinations := 0
	for facility_name in FACILITIES:
		for plot_index in range(FACILITY_PLOTS.size()):
			CampaignState.reset_new_game()
			if not CampaignState.build_facility(plot_index, facility_name):
				_fail("%s could not be recorded at lot %d" % [facility_name, plot_index + 1])
				return combinations
			if CampaignState.built_facilities.size() != 1 or CampaignState.built_facilities.get(plot_index) != facility_name:
				_fail("%s did not retain its lot-%d construction state" % [facility_name, plot_index + 1])
				return combinations
			var expected_universe: StringName = UNIVERSES.get(facility_name, &"")
			if CampaignState.anchored_universe_at(plot_index) != expected_universe:
				_fail("%s did not retain its expected portal destination at lot %d" % [facility_name, plot_index + 1])
				return combinations
			combinations += 1
	return combinations


func _seed_all_facilities() -> bool:
	CampaignState.reset_new_game()
	for plot_index in range(FACILITIES.size()):
		if not CampaignState.build_facility(plot_index, FACILITIES[plot_index]):
			_fail("Could not construct %s at canonical lot %d" % [FACILITIES[plot_index], plot_index + 1])
			return false
	return true


func _launch_main() -> Node:
	var main_scene: PackedScene = load("res://src/main.tscn")
	var main := main_scene.instantiate()
	main.get_node("Field").opening_cutscene = null
	get_tree().root.add_child(main)
	for _frame in range(5):
		await get_tree().process_frame
	return main


func _assert_facility_runtime(main: Node, phase: String) -> bool:
	var world := main.get_node_or_null("Field/Map/CampaignWorld")
	var visual := main.get_node_or_null("Field/Map/CampaignWorld/GroundLayer/Visuals")
	if world == null or visual == null:
		_fail("Campaign world was unavailable during %s" % phase)
		return false
	if visual.built_facilities.size() != FACILITIES.size():
		_fail("%s restored %d facilities instead of eleven" % [phase, visual.built_facilities.size()])
		return false
	for plot_index in range(FACILITIES.size()):
		var facility_name := FACILITIES[plot_index]
		var plot := FACILITY_PLOTS[plot_index]
		var door_cell := TOWN_ORIGIN + Vector2i(plot.position.x + int(plot.size.x / 2), plot.end.y - 1)
		var return_cell := door_cell + Vector2i(0, 1)
		if CampaignState.built_facilities.get(plot_index) != facility_name or visual.built_facilities.get(plot_index) != facility_name:
			_fail("%s did not keep %s at lot %d" % [phase, facility_name, plot_index + 1])
			return false
		if Gameboard.pathfinder.has_cell(TOWN_ORIGIN + plot.position):
			_fail("%s left the interior collision cell open for %s" % [phase, facility_name])
			return false
		if not Gameboard.pathfinder.has_cell(door_cell) or not Gameboard.pathfinder.has_cell(return_cell):
			_fail("%s blocked the doorway or return cell for %s" % [phase, facility_name])
			return false
		if SERVICE_NODES.has(facility_name):
			var service := world.get_node_or_null(String(SERVICE_NODES[facility_name])) as Node2D
			if service == null or service.position != Gameboard.cell_to_pixel(door_cell):
				_fail("%s service did not align with %s at lot %d" % [phase, facility_name, plot_index + 1])
				return false
		if PORTAL_NODES.has(facility_name):
			var portal_names: Array = PORTAL_NODES[facility_name]
			var entry := world.get_node_or_null(String(portal_names[0])) as AreaTransition
			var exit := world.get_node_or_null(String(portal_names[1])) as AreaTransition
			if entry == null or exit == null:
				_fail("%s portal pair was not installed for %s" % [phase, facility_name])
				return false
			if entry.position != Gameboard.cell_to_pixel(door_cell) or exit.arrival_coordinates != Gameboard.cell_to_pixel(return_cell):
				_fail("%s portal pair did not retain %s's exact lot return" % [phase, facility_name])
				return false
			if entry.arrival_coordinates == Vector2.ZERO or exit.position == Vector2.ZERO:
				_fail("%s portal pair did not expose a stable interior entry for %s" % [phase, facility_name])
				return false
	return true


func _assert_sandbox_relocation() -> bool:
	CampaignState.setup_sandbox(TOWN_ARRIVAL)
	for plot_index in range(FACILITIES.size()):
		if not CampaignState.build_facility(plot_index, FACILITIES[plot_index]):
			_fail("Sandbox could not retain %s at lot %d" % [FACILITIES[plot_index], plot_index + 1])
			return false
	var main := await _launch_main()
	if not _assert_facility_runtime(main, "sandbox construction"):
		return false
	var player := Player.gamepiece
	GamepieceRegistry.move_gamepiece(player, TOWN_ARRIVAL)
	player.position = Gameboard.cell_to_pixel(TOWN_ARRIVAL)
	player.rest_position = player.position
	var editor := main.get_node_or_null("SandboxTownEditor")
	var laboratory := CampaignState.town_object_with_role(&"town_lab")
	if editor == null or laboratory.is_empty():
		_fail("Sandbox relocation fixture could not find its protected laboratory")
		return false
	editor.suppress_persistence = true
	editor._set_active(true)
	editor.cursor_cell = Vector2i(int(laboratory.get("x", 0)), int(laboratory.get("y", 0)))
	editor._confirm_cursor()
	if editor.selected_instance_id != "sandbox_town_lab":
		_fail("Sandbox relocation fixture could not select its protected laboratory")
		return false
	editor.cursor_cell = Vector2i(55, 2)
	editor._confirm_cursor()
	var town_door := main.get_node_or_null("Field/Map/CampaignWorld/TownLaboratoryDoor") as AreaTransition
	var lab_exit := main.get_node_or_null("Field/Map/CampaignWorld/LaboratoryExit") as AreaTransition
	if town_door == null or lab_exit == null or town_door.position != Gameboard.cell_to_pixel(Vector2i(57, 4)) or lab_exit.arrival_coordinates != Gameboard.cell_to_pixel(Vector2i(57, 5)):
		_fail("Sandbox relocation did not retain the laboratory's doorway and return point")
		return false
	main.queue_free()
	await get_tree().process_frame
	return true


func _remove_test_save() -> void:
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE + ".bak"))


func _fail(message: String) -> void:
	printerr("FACILITY_MATRIX_SMOKE_FAILED: " + message)
	_remove_test_save()
	CampaignState.reset_new_game()
	get_tree().quit(1)
