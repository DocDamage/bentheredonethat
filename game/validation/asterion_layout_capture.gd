extends Node

const ROOMS := {
	"dock": Vector2i(40, 38),
	"mess": Vector2i(50, 38),
	"hydro": Vector2i(60, 38),
	"medical": Vector2i(50, 48),
	"control": Vector2i(60, 48),
}


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	CampaignState.reset_new_game()
	var main: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	for room_name in ROOMS:
		main.call("_place_player", ROOMS[room_name])
		await _settle()
		if not _save("user://asterion_layout_%s.png" % room_name):
			return
	main.queue_free()
	await get_tree().process_frame
	print("ASTERION_LAYOUT_CAPTURE_OK rooms=%d native_scale=true" % ROOMS.size())
	get_tree().quit(0)


func _settle() -> void:
	for _frame in range(6):
		await get_tree().process_frame


func _save(path: String) -> bool:
	var viewport_texture := get_viewport().get_texture()
	if not viewport_texture:
		printerr("ASTERION_LAYOUT_CAPTURE_FAILED: rendering texture unavailable; run windowed")
		get_tree().quit(1)
		return false
	if viewport_texture.get_image().save_png(path) != OK:
		printerr("ASTERION_LAYOUT_CAPTURE_FAILED: could not write " + path)
		get_tree().quit(1)
		return false
	print("ASTERION_LAYOUT_CAPTURE image=%s" % ProjectSettings.globalize_path(path))
	return true
