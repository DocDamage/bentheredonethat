class_name CampaignAshfallCinderGate
extends Node2D

## AF-01's authored scene is intentionally self-contained while the mandatory
## address gateway and combat database are still gated. It reads only the
## address room record and visual profiles; it must not become a second source
## of ports, assets, or encounter definitions.

const ROOM_RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")

var _record: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	configure(ROOM_RECORDS.record(&"AF-01"))


func configure(record_definition: Dictionary) -> void:
	_record = record_definition.duplicate(true)
	var layout: Dictionary = _record.get("layout", {})
	var navigation: Dictionary = _record.get("navigation", {})
	name = "AuthoredAddressRoom_%s" % _record.get("id", &"AF-01")
	set_meta(&"room_id", _record.get("id", &"AF-01"))
	set_meta(&"runtime_gated", true)
	var navigation_layer := get_node_or_null("NavigationAndCollision") as Node2D
	if navigation_layer:
		navigation_layer.set_meta(&"navigation_id", navigation.get("id", &""))
		navigation_layer.set_meta(&"collision_mask_id", navigation.get("collisionMaskId", &""))
		navigation_layer.set_meta(&"navigation_layout", navigation)
		if navigation_layer.has_method(&"configure"):
			navigation_layer.call(&"configure", navigation)
	var ground_layer := get_node_or_null("GroundLayer")
	if ground_layer and ground_layer.has_method(&"configure"):
		ground_layer.call(&"configure", layout)
	var prop_layer := get_node_or_null("YSortedActorsAndProps")
	if prop_layer and prop_layer.has_method(&"configure"):
		prop_layer.call(&"configure", layout)
	var foreground_layer := get_node_or_null("ForegroundLayer")
	if foreground_layer and foreground_layer.has_method(&"configure"):
		foreground_layer.call(&"configure", layout, navigation)
	queue_redraw()


func room_record() -> Dictionary:
	return _record.duplicate(true)


func _draw() -> void:
	var dimensions: Vector2i = (_record.get("layout", {}) as Dictionary).get("dimensions", Vector2i.ZERO)
	if dimensions == Vector2i.ZERO:
		return
	# The outline keeps the room boundary legible in the isolated scene without
	# treating it as a replacement for the collision audit still required before
	# the address gateway can register this room.
	draw_rect(Rect2(Vector2.ZERO, Vector2(dimensions * 48)), Color("bd7955"), false, 2.0)
