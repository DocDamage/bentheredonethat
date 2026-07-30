class_name CampaignNewPhiladelphiaInventionAnnex
extends Node2D

const ROOM_RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")

var _record: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	configure(ROOM_RECORDS.record(&"NP-02"))


func configure(record_definition: Dictionary) -> void:
	_record = record_definition.duplicate(true)
	name = "AuthoredNewPhiladelphiaRoom_NP-02"
	set_meta(&"room_id", &"NP-02")
	set_meta(&"runtime_enabled", true)
	set_meta(&"runtime_gated", true)
	set_meta(&"implementation_state", &"implemented")
	var collision_layer := get_node_or_null("NavigationAndCollision")
	if collision_layer and collision_layer.has_method(&"configure"):
		collision_layer.call(&"configure", _record.get("navigation", {}))
	var ground := get_node_or_null("GroundLayer")
	if ground and ground.has_method(&"configure"):
		ground.call(&"configure", _record.get("layout", {}))
	var props := get_node_or_null("YSortedActorsAndProps")
	if props and props.has_method(&"configure"):
		props.call(&"configure", _record.get("layout", {}))
	_install_feature_marker()


func room_record() -> Dictionary:
	return _record.duplicate(true)


func _install_feature_marker() -> void:
	var layer := get_node_or_null("InteractionLayer") as Node2D
	if not layer:
		return
	var marker := Node2D.new()
	marker.name = "NewPhiladelphiaFeature_InventionBench"
	marker.position = Vector2(12, 8) * 48.0
	marker.set_meta(&"feature_id", &"invention_bench")
	marker.set_meta(&"runtime_gated", true)
	layer.add_child(marker)
