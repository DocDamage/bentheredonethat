extends Node

const OUTPUT_NAMES := [
	"asterion-dock-rebuilt.png",
	"asterion-mess-rebuilt.png",
	"asterion-hydroponics-rebuilt.png",
	"asterion-medical-rebuilt.png",
	"asterion-control-rebuilt.png",
]
const ROOM_CELLS := [
	Vector2i(40, 37),
	Vector2i(50, 37),
	Vector2i(60, 37),
	Vector2i(50, 47),
	Vector2i(60, 47),
]

var main: Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Haunted Mansion")
	CampaignState.story_flags[&"mansion_archive_boss_defeated"] = true
	CampaignState.story_flags[&"haunted_mansion_scenario_complete"] = true
	CampaignState.build_facility(4, "Observatory")
	CampaignState.story_flags[&"asterion_dock_cleared"] = true
	CampaignState.story_flags[&"asterion_astronaut_met"] = true
	CampaignState.discover_recruit(&"astronaut")
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	main._place_player(main.TOWN_ORIGIN + Vector2i(24, 18))
	await _settle()
	_capture("town-observatory-rebuilt.png")
	for index in range(ROOM_CELLS.size()):
		main._place_player(ROOM_CELLS[index])
		await _settle()
		_capture(OUTPUT_NAMES[index])
	print("ASTERION_VISUAL_CAPTURE_OK images=6")
	get_tree().quit()


func _settle() -> void:
	for _frame in range(5):
		await get_tree().process_frame


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save visual capture %s: %s" % [file_name, error_string(error)])
