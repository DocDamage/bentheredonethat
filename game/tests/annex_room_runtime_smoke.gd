extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const STREAMER := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const RUNTIME := preload("res://ben_rpg/world/campaign_annex_room_runtime.gd")

func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	var previous_properties = Gameboard.properties
	var properties := GameboardProperties.new()
	properties.cell_size = Vector2i(48, 48)
	properties.extents = Rect2i(0, 0, 1000, 1000)
	Gameboard.properties = properties
	var streamer := STREAMER.new()
	var navigation := GameboardLayer.new()
	var runtime := RUNTIME.new()
	# The layer only provides cell storage here; keeping it off-tree avoids
	# registering a test-only layer with the global Gameboard lifecycle.
	add_child(streamer); add_child(runtime)
	runtime.configure(streamer, navigation)
	assert(runtime.activate(&"NP-15"))
	assert(streamer.active_room_id() == &"NP-15" and runtime.active_room_id() == &"NP-15")
	assert(navigation.get_cell_atlas_coords(Vector2i(650, 0)) == Vector2i(1, 4))
	assert(navigation.get_cell_atlas_coords(Vector2i(651, 1)) == Vector2i(2, 2))
	assert(runtime.activate(&"AF-01"))
	assert(streamer.active_room_id() == &"AF-01" and runtime.active_room_id() == &"AF-01")
	assert(navigation.get_cell_atlas_coords(Vector2i(650, 0)) == Vector2i(1, 4))
	assert(navigation.get_cell_atlas_coords(Vector2i(662, 9)) == Vector2i(2, 2))
	streamer.deactivate()
	navigation.free()
	Gameboard.properties = previous_properties
	print("ANNEX_ROOM_RUNTIME_SMOKE_OK admitted=true stream=phase3+phase5 navigation=shared_staging_origin")
	get_tree().quit()
