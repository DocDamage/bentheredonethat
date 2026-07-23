extends Node

const RECRUIT_NAVIGATION := preload("res://ben_rpg/world/campaign_recruit_navigation.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")


func _ready() -> void:
	assert(RECRUIT_NAVIGATION.validate().is_empty())
	for recruit_id in RECRUIT_NAVIGATION.ANCHORS:
		var anchor: Dictionary = RECRUIT_NAVIGATION.ANCHORS[recruit_id]
		var room := ROOM_REGISTRY.room(anchor["roomId"])
		var expected: Vector2i = room["worldOrigin"] + anchor["cell"]
		assert(RECRUIT_NAVIGATION.world_cell(recruit_id) == expected)
	print("CAMPAIGN_RECRUIT_NAVIGATION_SMOKE_OK anchors=%d manifest_relative=true" % RECRUIT_NAVIGATION.ANCHORS.size())
	get_tree().quit()
