extends Node2D

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const ROOM_SCENE := preload("res://ben_rpg/world/rooms/new_philadelphia_franklin_laboratory.tscn")


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var room := ROOM_SCENE.instantiate() as Node2D
	add_child(room)
	var camera := Camera2D.new()
	# Keep both linked entrance routes and Franklin's central workbench in view.
	camera.position = Vector2(720, 480)
	camera.zoom = Vector2(1.35, 1.35)
	add_child(camera)
	camera.make_current()
	for _frame in range(6):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	if not CAPTURE_GUARD.save_viewport_png(get_viewport(), "res://validation/np01-franklin-laboratory-scene-first-visit.png", "NP-01 Franklin Laboratory scene first-visit capture"):
		get_tree().quit(1)
		return
	print("NP01_FRANKLIN_LABORATORY_SCENE_CAPTURE_OK path=res://validation/np01-franklin-laboratory-scene-first-visit.png state=initial_review_only")
	get_tree().quit(0)
