extends Node

const OUTPUT_NAMES := [
	"mansion-foyer-layout-pass.png",
	"mansion-archive-layout-pass.png",
	"mansion-gallery-layout-pass.png",
	"mansion-nursery-layout-pass.png",
	"mansion-ballroom-layout-pass.png",
]
const ROOM_CELLS := [
	Vector2i(4, 38),
	Vector2i(14, 37),
	Vector2i(4, 47),
	Vector2i(14, 47),
	Vector2i(23, 43),
]

var main: Node


func _ready() -> void:
	CampaignState.reset_new_game()
	CampaignState.build_facility(0, "Cafe")
	CampaignState.build_facility(1, "Library")
	CampaignState.build_facility(2, "Clinic")
	CampaignState.build_facility(3, "Haunted Mansion")
	for flag in [&"mansion_first_room_complete", &"mansion_ballroom_open"]:
		CampaignState.story_flags[flag] = true
	main = load("res://src/main.tscn").instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	for index in range(ROOM_CELLS.size()):
		main._place_player(ROOM_CELLS[index])
		await _settle()
		_capture(OUTPUT_NAMES[index])
	print("MANSION_VISUAL_CAPTURE_OK images=5")
	get_tree().quit()


func _settle() -> void:
	for _frame in range(5):
		await get_tree().process_frame


func _capture(file_name: String) -> void:
	var image := get_viewport().get_texture().get_image()
	var error := image.save_png("res://validation/%s" % file_name)
	if error != OK:
		push_error("Could not save visual capture %s: %s" % [file_name, error_string(error)])
