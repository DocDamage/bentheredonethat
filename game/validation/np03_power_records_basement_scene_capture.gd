extends Node2D
const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const ROOM_SCENE := preload("res://ben_rpg/world/rooms/new_philadelphia_power_records_basement.tscn")
func _ready() -> void: _capture.call_deferred()
func _capture() -> void:
	var room := ROOM_SCENE.instantiate() as Node2D
	add_child(room)
	var camera := Camera2D.new()
	camera.position = Vector2(432, 384)
	camera.zoom = Vector2(1.5, 1.5)
	add_child(camera)
	camera.make_current()
	for _frame in range(6): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if not CAPTURE_GUARD.save_viewport_png(get_viewport(), "res://validation/np03-power-records-basement-scene-first-visit.png", "NP-03 Power and Records Basement scene first-visit capture"):
		get_tree().quit(1)
		return
	print("NP03_POWER_RECORDS_BASEMENT_SCENE_CAPTURE_OK path=res://validation/np03-power-records-basement-scene-first-visit.png state=initial_review_only")
	get_tree().quit(0)
