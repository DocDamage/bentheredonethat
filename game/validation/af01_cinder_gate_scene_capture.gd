extends Node2D

const CAPTURE_GUARD := preload("res://validation/visual_capture_guard.gd")
const ROOM_SCENE := preload("res://ben_rpg/world/rooms/ashfall_cinder_gate.tscn")


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var room := ROOM_SCENE.instantiate() as Node2D
	add_child(room)
	var camera := Camera2D.new()
	camera.position = Vector2(624, 432)
	# Gameplay-scale framing deliberately favors a readable route over a map-like
	# full-room overview; the address camera must not expose exterior void.
	camera.zoom = Vector2(1.5, 1.5)
	add_child(camera)
	camera.make_current()
	for _frame in range(6):
		await get_tree().process_frame
	if not CAPTURE_GUARD.save_viewport_png(get_viewport(), "res://validation/af01-cinder-gate-scene-first-visit.png", "AF-01 Cinder Gate scene first-visit capture"):
		get_tree().quit(1)
		return
	print("AF01_CINDER_GATE_SCENE_CAPTURE_OK path=res://validation/af01-cinder-gate-scene-first-visit.png state=first_visit_only")
	get_tree().quit(0)
