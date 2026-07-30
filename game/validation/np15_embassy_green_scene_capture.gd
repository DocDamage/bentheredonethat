extends Node2D

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const ROOM_SCENE := preload("res://ben_rpg/world/rooms/new_philadelphia_embassy_green.tscn")


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var room := ROOM_SCENE.instantiate() as Node2D
	add_child(room)
	var camera := Camera2D.new()
	# Frame the Embassy Green's central charter-table approach at gameplay scale,
	# with enough of the perimeter landscaping visible for visual review.
	camera.position = Vector2(720, 480)
	camera.zoom = Vector2(1.35, 1.35)
	add_child(camera)
	camera.make_current()
	for _frame in range(6):
		await get_tree().process_frame
	# Custom-drawn terrain is submitted at render time. Capture after the
	# renderer has consumed the scene's queued draw calls.
	await RenderingServer.frame_post_draw
	if not CAPTURE_GUARD.save_viewport_png(get_viewport(), "res://validation/np15-embassy-green-scene-first-visit.png", "NP-15 Embassy Green scene first-visit capture"):
		get_tree().quit(1)
		return
	print("NP15_EMBASSY_GREEN_SCENE_CAPTURE_OK path=res://validation/np15-embassy-green-scene-first-visit.png state=initial_review_only")
	get_tree().quit(0)
