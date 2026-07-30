class_name CampaignNewPhiladelphiaFoundersSquare
extends Node2D
const RECORDS := preload("res://ben_rpg/world/campaign_new_philadelphia_room_records.gd")
var _record: Dictionary = {}
func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	configure(RECORDS.record(&"NP-04"))
func configure(record: Dictionary) -> void:
	_record = record.duplicate(true)
	set_meta(&"room_id", &"NP-04")
	set_meta(&"runtime_enabled", true)
	set_meta(&"runtime_gated", true)
	set_meta(&"implementation_state", &"implemented")
	for node_name in [&"NavigationAndCollision", &"GroundLayer", &"YSortedActorsAndProps"]:
		var node := get_node_or_null(NodePath(node_name))
		if node and node.has_method(&"configure"): node.call(&"configure", _record.get("navigation", {}) if node_name == &"NavigationAndCollision" else _record.get("layout", {}))
	var marker := Node2D.new()
	marker.name = "NewPhiladelphiaFeature_FoundingMonument"
	marker.position = Vector2(16, 11) * 48.0
	marker.set_meta(&"runtime_gated", true)
	get_node("InteractionLayer").add_child(marker)
