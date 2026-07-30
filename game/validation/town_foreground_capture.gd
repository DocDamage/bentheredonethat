extends Node

## Isolated native-scale review capture for the first town foreground block.


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	CampaignState.reset_new_game()
	var main: Node = (load("res://src/main.tscn") as PackedScene).instantiate()
	main.get_node("Field").opening_cutscene = null
	add_child(main)
	await _settle()
	main.call("_place_player", Vector2i(50, 8))
	await _settle()
	if not _save("user://town_foreground_lab_approach.png"):
		return
	main.call("_place_player", Vector2i(38, 3))
	await _settle()
	if not _save("user://town_foreground_tree_approach.png"):
		return
	main.queue_free()
	await get_tree().process_frame
	print("TOWN_FOREGROUND_CAPTURE_OK images=2 native_scale=true")
	get_tree().quit(0)


func _settle() -> void:
	for _frame in range(6):
		await get_tree().process_frame


func _save(path: String) -> bool:
	var viewport_texture := get_viewport().get_texture()
	if not viewport_texture:
		printerr("TOWN_FOREGROUND_CAPTURE_FAILED: rendering texture unavailable; run windowed")
		get_tree().quit(1)
		return false
	if viewport_texture.get_image().save_png(path) != OK:
		printerr("TOWN_FOREGROUND_CAPTURE_FAILED: could not write " + path)
		get_tree().quit(1)
		return false
	print("TOWN_FOREGROUND_CAPTURE image=%s" % ProjectSettings.globalize_path(path))
	return true
