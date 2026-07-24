class_name CampaignNewPhiladelphiaPowerRecordsBasement
extends Node2D

const ROOM_RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
var _record: Dictionary = {}

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	configure(ROOM_RECORDS.record(&"NP-03"))

func configure(record_definition: Dictionary) -> void:
	_record = record_definition.duplicate(true)
	name = "AuthoredNewPhiladelphiaRoom_NP-03"
	set_meta(&"room_id", &"NP-03")
	set_meta(&"runtime_gated", true)
	var collision_layer := get_node_or_null("NavigationAndCollision")
	if collision_layer and collision_layer.has_method(&"configure"): collision_layer.call(&"configure", _record.get("navigation", {}))
	var ground := get_node_or_null("GroundLayer")
	if ground and ground.has_method(&"configure"): ground.call(&"configure", _record.get("layout", {}))
	var props := get_node_or_null("YSortedActorsAndProps")
	if props and props.has_method(&"configure"): props.call(&"configure", _record.get("layout", {}))
	var layer := get_node_or_null("InteractionLayer") as Node2D
	if layer:
		var marker := Node2D.new()
		marker.name = "NewPhiladelphiaFeature_FaultLineRegulator"
		marker.position = Vector2(9, 8) * 48.0
		marker.set_meta(&"feature_id", &"fault_line_regulator")
		marker.set_meta(&"runtime_gated", true)
		layer.add_child(marker)

func room_record() -> Dictionary:
	return _record.duplicate(true)
