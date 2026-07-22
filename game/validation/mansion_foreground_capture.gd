extends Node

## Native-scale review capture for the Mansion foreground migration.  These are
## deliberately written to user:// so visual review never overwrites approved
## repository captures while the composition is still under review.

const ROOMS := {
	"foyer": Vector2i(4, 38),
	"archive": Vector2i(14, 37),
	"gallery": Vector2i(4, 47),
	"nursery": Vector2i(14, 47),
	"ballroom": Vector2i(23, 43),
}


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	CampaignState.reset_new_game()
	for facility in ["Cafe", "Library", "Clinic", "Haunted Mansion"]:
		CampaignState.build_facility(["Cafe", "Library", "Clinic", "Haunted Mansion"].find(facility), facility)
	CampaignState.story_flags[&"mansion_first_room_complete"] = true
	CampaignState.story_flags[&"mansion_ballroom_open"] = true
	var main: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	for room_name in ROOMS:
		main.call("_place_player", ROOMS[room_name])
		await _settle()
		var output := "user://mansion_foreground_%s.png" % room_name
		var viewport_texture := get_viewport().get_texture()
		if not viewport_texture:
			printerr("MANSION_FOREGROUND_CAPTURE_FAILED: rendering texture unavailable; run windowed")
			get_tree().quit(1)
			return
		if viewport_texture.get_image().save_png(output) != OK:
			printerr("MANSION_FOREGROUND_CAPTURE_FAILED: " + output)
			get_tree().quit(1)
			return
		print("MANSION_FOREGROUND_CAPTURE image=%s" % ProjectSettings.globalize_path(output))
	main.queue_free()
	await get_tree().process_frame
	print("MANSION_FOREGROUND_CAPTURE_OK rooms=%d native_scale=true" % ROOMS.size())
	get_tree().quit(0)


func _settle() -> void:
	for _frame in range(6):
		await get_tree().process_frame
