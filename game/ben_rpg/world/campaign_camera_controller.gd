class_name CampaignCameraController
extends Node

## Manifest camera contract. A live Camera2D can opt into this controller while
## legacy areas continue to use their compatibility adapter during migration.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")
const ANNEX_REGISTRY := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const FIELD_SCALE := preload("res://ben_rpg/world/campaign_field_scale.gd")

var active_room_id: StringName = &""
var active_bounds := Rect2i()
var active_zoom := Vector2.ONE
var _canvas_scale := Vector2.ONE


func bind_streamer(streamer: Node) -> void:
	if not streamer.active_room_changed.is_connected(_on_active_room_changed):
		streamer.active_room_changed.connect(_on_active_room_changed)


func set_canvas_scale(canvas_scale: Vector2) -> void:
	if canvas_scale.x <= 0.0 or canvas_scale.y <= 0.0:
		return
	_canvas_scale = canvas_scale
	if active_room_id != &"":
		_activate(active_room_id)


func apply_to(camera: Camera2D) -> bool:
	if active_room_id == &"" or active_bounds.size.x <= 0 or active_bounds.size.y <= 0:
		return false
	camera.zoom = active_zoom
	camera.limit_left = active_bounds.position.x
	camera.limit_top = active_bounds.position.y
	camera.limit_right = active_bounds.end.x
	camera.limit_bottom = active_bounds.end.y
	return true


func _on_active_room_changed(room_id: StringName, legacy_area: StringName) -> void:
	if legacy_area != &"" or (not ROOM_REGISTRY.is_authored_room(room_id) and not ANNEX_REGISTRY.is_runtime_admitted(room_id)):
		active_room_id = &""
		active_bounds = Rect2i()
		active_zoom = Vector2.ONE
		return
	_activate(room_id)


func _activate(room_id: StringName) -> void:
	active_room_id = room_id
	var definition := ANNEX_REGISTRY.room(room_id) if ANNEX_REGISTRY.is_runtime_admitted(room_id) else ROOM_REGISTRY.room(room_id)
	var local_bounds := definition.get("cameraBounds", Rect2i()) as Rect2i
	var world_origin := definition.get("worldOrigin", Vector2i.ZERO) as Vector2i
	var world_origin_pixels := world_origin * FIELD_SCALE.MOVEMENT_CELL_PIXELS
	var local_start := world_origin_pixels + local_bounds.position
	var local_end := world_origin_pixels + local_bounds.end
	var scaled_start := Vector2i(
		int(local_start.x * _canvas_scale.x),
		int(local_start.y * _canvas_scale.y),
	)
	var scaled_end := Vector2i(
		int(local_end.x * _canvas_scale.x),
		int(local_end.y * _canvas_scale.y),
	)
	active_bounds = Rect2i(scaled_start, scaled_end - scaled_start)
	active_zoom = definition.get("cameraZoom", Vector2.ONE) as Vector2


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	var bounds: Rect2i = ROOM_REGISTRY.room(&"TEST-01").get("cameraBounds", Rect2i()) as Rect2i
	if bounds != FIELD_SCALE.camera_bounds_for_cells(Vector2i(14, 10)):
		errors.append("Manifest test room camera bounds are invalid.")
	return PackedStringArray(errors)
