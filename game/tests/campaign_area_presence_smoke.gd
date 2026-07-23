extends Node

const PRESENCE := preload("res://ben_rpg/world/campaign_area_presence.gd")
const BOOTSTRAP := preload("res://ben_rpg/world/campaign_bootstrap.gd")


func _ready() -> void:
	var campaign := BOOTSTRAP.new()
	assert(PRESENCE.snapshot(campaign, Vector2i(50, 8))[&"town"])
	assert(PRESENCE.snapshot(campaign, Vector2i(36, 32))[&"station"])
	assert(PRESENCE.snapshot(campaign, Vector2i(72, 32))[&"primeval"])
	assert(PRESENCE.snapshot(campaign, Vector2i(108, 32))[&"helios"])
	assert(PRESENCE.snapshot(campaign, Vector2i(144, 32))[&"frosthold"])
	assert(PRESENCE.snapshot(campaign, Vector2i(180, 32))[&"moonpetal"])
	assert(PRESENCE.snapshot(campaign, Vector2i(216, 32))[&"empyreal"])
	assert(PRESENCE.snapshot(campaign, Vector2i(0, 32))[&"mansion_room"] == 1)
	assert(PRESENCE.snapshot(campaign, Vector2i(10, 32))[&"mansion_room"] == 2)
	assert(PRESENCE.snapshot(campaign, Vector2i(0, 42))[&"mansion_room"] == 3)
	assert(PRESENCE.snapshot(campaign, Vector2i(10, 42))[&"mansion_room"] == 4)
	assert(PRESENCE.snapshot(campaign, Vector2i(20, 37))[&"mansion_room"] == 5)
	campaign.free()
	print("CAMPAIGN_AREA_PRESENCE_SMOKE_OK areas=8 mansion_rooms=5")
	get_tree().quit()
