class_name CampaignMoonpetalForeground
extends Node2D

## Tall Moonpetal scenery is separated from the courtyard ground so the player,
## followers, and residents retain a dependable depth relationship with gates,
## canopy, temple eaves, lanterns, and garden islands.

const TILE := 48
const MOONPETAL_ORIGIN := Vector2i(180, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var active_area: StringName = &"lab"
var gates: Texture2D
var lanterns: Texture2D
var temple: Texture2D
var trees: Texture2D
var water: Texture2D
var gardens: Texture2D
var profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	gates = profiles.texture(&"moonpetal_vermilion_gate")
	lanterns = profiles.texture(&"moonpetal_gate_lantern")
	temple = profiles.texture(&"moonpetal_court_temple")
	trees = profiles.texture(&"moonpetal_court_tree_canopy")
	water = profiles.texture(&"moonpetal_mirror_pond")
	gardens = profiles.texture(&"moonpetal_framed_garden_island")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _prop(texture: Texture2D, source: Rect2, destination_position: Vector2, scale: float) -> void:
	if texture:
		# Exact reciprocal source scaling is allowed, but destination dimensions
		# still land on whole world pixels so the foreground cannot shimmer.
		var size := Vector2(roundi(source.size.x * scale), roundi(source.size.y * scale))
		var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
		draw_texture_rect_region(texture, Rect2(position, size), source)


func _profile_prop(profile_id: StringName, texture: Texture2D, destination_position: Vector2) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved Moonpetal visual profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
	draw_texture_rect_region(texture, Rect2(position, size), source)


func _draw() -> void:
	if not active_area.begins_with("moonpetal"):
		return
	var offset := Vector2(MOONPETAL_ORIGIN * TILE)
	match active_area:
		&"moonpetal_gate":
			_profile_prop(&"moonpetal_vermilion_gate", gates, offset + Vector2(120, 20))
			_profile_prop(&"moonpetal_gate_lantern", lanterns, offset + Vector2(2, 115))
			_profile_prop(&"moonpetal_gate_lantern_right", lanterns, offset + Vector2(325, 115))
		&"moonpetal_court":
			var room_offset := offset + Vector2(10 * TILE, 0)
			_profile_prop(&"moonpetal_court_temple", temple, room_offset + Vector2(99, 18))
			_profile_prop(&"moonpetal_court_tree_canopy", trees, room_offset + Vector2(8, 66))
			_prop(trees, Rect2(326, 548, 245, 250), room_offset + Vector2(238, 66), 0.5)
		&"moonpetal_garden":
			var room_offset := offset + Vector2(20 * TILE, 0)
			_profile_prop(&"moonpetal_mirror_pond", water, room_offset + Vector2(60, 24))
			_profile_prop(&"moonpetal_framed_garden_island", gardens, room_offset + Vector2(14, 99))
			_prop(gardens, Rect2(681, 133, 184, 174), room_offset + Vector2(277, 99), 0.5)
		&"moonpetal_bell_walk":
			var room_offset := offset + Vector2(10 * TILE, 10 * TILE)
			_prop(gates, Rect2(170, 398, 140, 142), room_offset + Vector2(40, 42), 1.0)
			_prop(gates, Rect2(321, 398, 140, 142), room_offset + Vector2(204, 42), 1.0)
			_prop(lanterns, Rect2(37, 331, 115, 145), room_offset + Vector2(2, 115), 0.5)
			_prop(lanterns, Rect2(164, 331, 114, 145), room_offset + Vector2(325, 115), 0.5)
		&"moonpetal_palace":
			var room_offset := offset + Vector2(20 * TILE, 10 * TILE)
			_prop(temple, Rect2(42, 580, 318, 177), room_offset + Vector2(33, 18), 1.0)
			_prop(gardens, Rect2(368, 496, 187, 181), room_offset + Vector2(18, 196), 0.5)
			_prop(gardens, Rect2(575, 496, 187, 181), room_offset + Vector2(273, 196), 0.5)
