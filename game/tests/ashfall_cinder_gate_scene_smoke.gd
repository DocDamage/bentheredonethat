extends Node

const RECORDS := preload("res://ben_rpg/world/campaign_address_room_records.gd")
const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")


func _ready() -> void:
	CampaignState.reset_new_game()
	var record := RECORDS.record(&"AF-01")
	var scene := load(String(record.get("scenePath", ""))) as PackedScene
	assert(scene, "AF-01 authored scene must load from its room record.")
	var room := scene.instantiate() as Node2D
	assert(room, "AF-01 authored scene must instantiate.")
	add_child(room)
	await get_tree().process_frame
	assert(room.get_meta(&"room_id", &"") == &"AF-01")
	assert(bool(room.get_meta(&"runtime_gated", false)))
	assert(room.get_meta(&"population_state", &"") == &"arrival_raid_pending")
	assert(room.has_node("GroundLayer") and room.has_node("NavigationAndCollision") and room.has_node("ForegroundLayer"))
	assert(room.get_node("GroundLayer").has_method(&"configure"))
	assert(room.get_node("YSortedActorsAndProps").has_method(&"configure"))
	var profiles := VISUAL_PROFILES.new()
	assert(profiles.has(&"ashfall_cinder_gate_barricade"))
	assert(profiles.texture(&"ashfall_cinder_gate_barricade") is Texture2D)
	assert(profiles.has(&"ashfall_cinder_gate_air_beacon") and profiles.texture(&"ashfall_cinder_gate_air_beacon") is Texture2D)
	assert(profiles.has(&"ashfall_cinder_gate_filter_cache") and profiles.texture(&"ashfall_cinder_gate_filter_cache") is Texture2D)
	var navigation := room.get_node("NavigationAndCollision") as Node2D
	assert(navigation.get_meta(&"navigation_id", &"") == &"af01-cinder-gate-navigation-v1")
	assert(navigation.get_meta(&"collision_mask_id", &"") == &"af01-cinder-gate-boundary-collision-v1")
	assert(navigation.has_method(&"blocked_cell_count") and navigation.has_method(&"blocks_cell"))
	assert(navigation.call(&"blocked_cell_count") == 102)
	assert(navigation.get_child_count() == 102)
	assert(bool(navigation.call(&"blocks_cell", Vector2i(0, 0))))
	assert(bool(navigation.call(&"blocks_cell", Vector2i(10, 2))))
	assert(not bool(navigation.call(&"blocks_cell", Vector2i(13, 9))))
	var features := room.get_node("InteractionLayer").get_children().filter(func(child): return String(child.name).begins_with("AddressFeature_"))
	assert(features.size() == 2)
	assert(room.get_node("InteractionLayer/AddressFeature_air_quality_beacon").get_meta(&"anchor", &"") == &"Icenter")
	assert(room.get_node("InteractionLayer/AddressFeature_air_filter_cache").get_meta(&"anchor", &"") == &"Tnw")
	for body in navigation.get_children():
		assert(body is StaticBody2D and body.get_child_count() == 1 and body.get_child(0) is CollisionShape2D)
	CampaignState.story_flags[&"ashfall_cinder_gate_arrival_raid_cleared"] = true
	CampaignState.state_changed.emit()
	await get_tree().process_frame
	assert(room.get_meta(&"population_state", &"") == &"review_gated")
	assert(room.get_node("YSortedActorsAndProps").get_children().filter(func(child): return String(child.name).begins_with("AddressActor_")).is_empty())
	CampaignState.reset_new_game()
	print("ASHFALL_CINDER_GATE_SCENE_SMOKE_OK room=AF-01 collision_cells=102 stabilized_preview=review_gated runtime_gated=true")
	get_tree().quit(0)
