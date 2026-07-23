class_name CampaignCameraController
extends Node

## Manifest camera contract. A live Camera2D can opt into this controller while
## legacy areas continue to use their compatibility adapter during migration.

const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

var active_room_id: StringName = &""
var active_bounds := Rect2i()


func bind_streamer(streamer: Node) -> void:
	streamer.active_room_changed.connect(_on_active_room_changed)


func apply_to(camera: Camera2D) -> void:
	camera.limit_left = active_bounds.position.x
	camera.limit_top = active_bounds.position.y
	camera.limit_right = active_bounds.end.x
	camera.limit_bottom = active_bounds.end.y


func _on_active_room_changed(room_id: StringName, _legacy_area: StringName) -> void:
	if not ROOM_REGISTRY.is_authored_room(room_id):
		return
	active_room_id = room_id
	active_bounds = ROOM_REGISTRY.room(room_id).get("cameraBounds", Rect2i()) as Rect2i


static func validate() -> PackedStringArray:
	var errors: Array[String] = []
	var bounds: Rect2i = ROOM_REGISTRY.room(&"TEST-01").get("cameraBounds", Rect2i()) as Rect2i
	if bounds != Rect2i(0, 0, 672, 480):
		errors.append("Manifest test room camera bounds are invalid.")
	return PackedStringArray(errors)
