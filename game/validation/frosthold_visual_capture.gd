extends Node

const OUTPUT_NAMES := [
	"frosthold-snow-gate.png",
	"frosthold-frozen-market.png",
	"frosthold-crystal-causeway.png",
	"frosthold-rune-hall.png",
	"frosthold-ice-throne.png",
]
const ROOM_CENTERS := [
	Vector2i(148, 38),
	Vector2i(158, 37),
	Vector2i(168, 37),
	Vector2i(158, 48),
	Vector2i(168, 48),
]


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.build_facility(4, "Observatory")
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.build_facility(5, "Trailhead Lodge")
	CampaignState.story_flags[&"primeval_scenario_complete"] = true
	CampaignState.build_facility(6, "Afterlight Club")
	CampaignState.story_flags[&"helios_scenario_complete"] = true
	CampaignState.build_facility(7, "Cold Storage")
	CampaignState.story_flags[&"frosthold_causeway_seal_open"] = true
	CampaignState.story_flags[&"frosthold_throne_open"] = true
	var main: Node = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	main.get_node("Field/Map/CampaignWorld/TownBuildController").hide()
	for index in range(ROOM_CENTERS.size()):
		main._place_player(ROOM_CENTERS[index])
		await _settle()
		_capture(OUTPUT_NAMES[index])
	print("FROSTHOLD_VISUAL_CAPTURE_OK images=5")
	get_tree().quit(0)


func _settle() -> void:
	for _frame in range(40):
		await get_tree().process_frame


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save Frosthold visual capture %s: %s" % [file_name, error_string(error)])
