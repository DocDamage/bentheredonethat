extends Node

const MARKER_NAVIGATION := preload("res://ben_rpg/world/campaign_room_marker_navigation.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	assert(MARKER_NAVIGATION.validate().is_empty())
	for marker_id in MARKER_NAVIGATION.BOSS_ANCHORS:
		var anchor: Dictionary = MARKER_NAVIGATION.BOSS_ANCHORS[marker_id]
		assert(MARKER_NAVIGATION.room_id(marker_id) == anchor["roomId"])
		assert(MARKER_NAVIGATION.world_cell(marker_id) == ROOM_REGISTRY.room(anchor["roomId"])["worldOrigin"] + anchor["cell"])
	print("CAMPAIGN_ROOM_MARKER_NAVIGATION_SMOKE_OK anchors=%d manifest_relative=true" % MARKER_NAVIGATION.BOSS_ANCHORS.size())
	get_tree().quit()
