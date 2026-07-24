extends Node

const REGISTRY := preload("res://ben_rpg/world/campaign_annex_room_registry.gd")
const STREAMER := preload("res://ben_rpg/world/campaign_room_streamer.gd")
const RUNTIME := preload("res://ben_rpg/world/campaign_annex_room_runtime.gd")

func _ready() -> void:
	assert(REGISTRY.validate().is_empty())
	var streamer := STREAMER.new()
	var navigation := GameboardLayer.new()
	var runtime := RUNTIME.new()
	# The layer only provides cell storage here; keeping it off-tree avoids
	# registering a test-only layer with the global Gameboard lifecycle.
	add_child(streamer); add_child(runtime)
	runtime.configure(streamer, navigation)
	assert(not runtime.activate(&"NP-15"), "Review-gated annex room must not activate.")
	REGISTRY.DEFINITIONS[&"NP-15"]["runtimeEnabled"] = true
	assert(runtime.activate(&"NP-15"))
	assert(streamer.active_room_id() == &"NP-15" and runtime.active_room_id() == &"NP-15")
	assert(navigation.get_cell_atlas_coords(Vector2i(360, 0)) == Vector2i(1, 4))
	assert(navigation.get_cell_atlas_coords(Vector2i(361, 1)) == Vector2i(2, 2))
	REGISTRY.DEFINITIONS[&"NP-15"]["runtimeEnabled"] = false
	streamer.deactivate()
	navigation.free()
	print("ANNEX_ROOM_RUNTIME_SMOKE_OK gated=true stream=NP15 navigation=annex_origin")
	get_tree().quit()
