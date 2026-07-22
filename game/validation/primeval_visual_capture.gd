extends Node
const OUTPUT_NAMES := [
	"primeval-grove-rebuilt.png",
	"primeval-village-rebuilt.png",
	"primeval-ruins-rebuilt.png",
	"primeval-nest-rebuilt.png",
	"primeval-caldera-rebuilt.png",
]
const ROOM_AREAS := [
	&"primeval_grove",
	&"primeval_village",
	&"primeval_ruins",
	&"primeval_nest",
	&"primeval_caldera",
]
const ROOM_CENTERS := [
	Vector2i(76, 36),
	Vector2i(86, 36),
	Vector2i(96, 36),
	Vector2i(86, 46),
	Vector2i(96, 46),
]

var main: Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.anchor_universe(3, &"haunted_mansion")
	CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.anchor_universe(4, &"asterion_station")
	CampaignState.story_flags[&"asterion_station_complete"] = true
	CampaignState.anchor_universe(5, &"primeval_expanse")
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	main._place_player(main.TOWN_ORIGIN + Vector2i(27, 10))
	await _settle()
	_capture("town-trailhead-lodge-rebuilt.png")
	for index in range(ROOM_AREAS.size()):
		main._place_player(ROOM_CENTERS[index])
		await _settle()
		_capture(OUTPUT_NAMES[index])
	var battle: CampaignBattle = main.get_node("CampaignBattle")
	battle.suppress_persistence = true
	battle.begin(&"primeval_commute_tyrant", 1776)
	await _settle()
	_capture("primeval-boss-battle-rebuilt.png")
	print("PRIMEVAL_VISUAL_CAPTURE_OK images=7")
	get_tree().quit(0)


func _settle() -> void:
	for _frame in range(5):
		await get_tree().process_frame


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save Primeval visual capture %s: %s" % [file_name, error_string(error)])
