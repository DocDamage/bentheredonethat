class_name CampaignNewPhiladelphiaDistrict
extends Node2D

## Shared scene shell for early New Philadelphia exterior districts. Each room
## keeps its semantic contract in CampaignNewPhiladelphiaRoomRecords; this
## script only realizes that reviewed data as collision, profile drawing, and
## explicitly gated interaction markers.

const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")

@export var room_id: StringName
var _record: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	configure(RECORDS.record(room_id))


func configure(record_definition: Dictionary) -> void:
	_record = record_definition.duplicate(true)
	room_id = StringName(_record.get("id", room_id))
	name = "AuthoredNewPhiladelphiaRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	set_meta(&"runtime_enabled", true)
	set_meta(&"runtime_gated", true) # compatibility metadata for staged-scene tooling
	set_meta(&"implementation_state", &"implemented")
	var navigation: Dictionary = _record.get("navigation", {})
	var layout: Dictionary = _record.get("layout", {})
	for node_name in [&"NavigationAndCollision", &"GroundLayer", &"YSortedActorsAndProps"]:
		var node := get_node_or_null(NodePath(node_name))
		if node and node.has_method(&"configure"):
			node.call(&"configure", navigation if node_name == &"NavigationAndCollision" else layout)
	_install_feature_markers(layout)


func room_record() -> Dictionary:
	return _record.duplicate(true)


func _install_feature_markers(layout: Dictionary) -> void:
	var layer := get_node_or_null("InteractionLayer") as Node2D
	if not layer:
		return
	for feature in layout.get("featureContracts", []) as Array:
		var definition := feature as Dictionary
		var feature_id := StringName(definition.get("id", &""))
		if feature_id == &"":
			continue
		var marker := Node2D.new()
		marker.name = "NewPhiladelphiaFeature_%s" % feature_id
		marker.position = Vector2(definition.get("cell", Vector2i.ZERO)) * 48.0
		marker.set_meta(&"feature_id", feature_id)
		marker.set_meta(&"runtime_gated", true)
		layer.add_child(marker)
