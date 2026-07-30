extends Node2D
const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const ROOM_SCENE := preload("res://ben_rpg/world/rooms/new_philadelphia_founders_square.tscn")
func _ready() -> void: _capture.call_deferred()
func _capture() -> void:
	var room := ROOM_SCENE.instantiate() as Node2D
	add_child(room)
	var camera := Camera2D.new()
	camera.position = Vector2(768, 528)
	camera.zoom = Vector2(1.25, 1.25)
	add_child(camera)
	camera.make_current()
	for _frame in range(6): await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if not CAPTURE_GUARD.save_viewport_png(get_viewport(), "res://validation/np04-founders-square-scene-first-visit.png", "NP-04 Founders Square scene first-visit capture"):
		get_tree().quit(1)
		return
	get_tree().quit(0)
