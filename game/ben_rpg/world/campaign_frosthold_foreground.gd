class_name CampaignFrostholdForeground
extends Node2D

## Frosthold's structures sit above its ice ground so characters can pass behind
## gate trees, market roofs, bridge banks, and the throne hall architecture.

const TILE := 48
const FROSTHOLD_ORIGIN := Vector2i(144, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var active_area: StringName = &"lab"
var houses: Texture2D
var castle: Texture2D
var crystals: Texture2D
var ruins: Texture2D
var runes: Texture2D
var trees: Texture2D
var bridges: Texture2D
var market: Texture2D
var torches: Texture2D
var gate_torches: Texture2D
var profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	houses = profiles.texture(&"frosthold_market_house")
	castle = profiles.texture(&"frosthold_gate_castle")
	crystals = profiles.texture(&"frosthold_causeway_crystal_bank")
	ruins = profiles.texture(&"frosthold_gate_ruin")
	runes = profiles.texture(&"frosthold_causeway_rune")
	trees = profiles.texture(&"frosthold_gate_tree")
	bridges = profiles.texture(&"frosthold_causeway_bridge")
	market = profiles.texture(&"frosthold_market_stall")
	torches = profiles.texture(&"frosthold_blue_torch")
	gate_torches = profiles.texture(&"frosthold_gate_torch_right")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _prop(texture: Texture2D, source: Rect2, destination_position: Vector2, flip_h := false) -> void:
	if not texture:
		return
	var size := Vector2(roundi(source.size.x * 0.5), roundi(source.size.y * 0.5))
	var destination := Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size)
	if flip_h:
		destination.position.x += size.x
		destination.size.x = -size.x
	draw_texture_rect_region(texture, destination, source)


func _profile_prop(profile_id: StringName, texture: Texture2D, destination_position: Vector2) -> void:
	if not texture or not profiles or not profiles.has(profile_id):
		push_error("Missing approved Frosthold visual profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	draw_texture_rect_region(texture, Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size), source)


func _draw() -> void:
	if not active_area.begins_with("frosthold"):
		return
	var offset := Vector2(FROSTHOLD_ORIGIN * TILE)
	match active_area:
		&"frosthold_gate":
			_profile_prop(&"frosthold_gate_tree", trees, offset + Vector2(-8, 32))
			_profile_prop(&"frosthold_gate_tree_right", trees, offset + Vector2(300, 34))
			_profile_prop(&"frosthold_gate_castle", castle, offset + Vector2(105, 24))
			_profile_prop(&"frosthold_gate_ruin", ruins, offset + Vector2(22, 103))
			_profile_prop(&"frosthold_gate_ruin_right", ruins, offset + Vector2(280, 103))
			_profile_prop(&"frosthold_blue_torch", torches, offset + Vector2(120, 89))
			_profile_prop(&"frosthold_gate_torch_right", gate_torches, offset + Vector2(220, 89))
		&"frosthold_market":
			var room_offset := offset + Vector2(10 * TILE, 0)
			_profile_prop(&"frosthold_market_house", houses, room_offset + Vector2(-8, 12))
			_profile_prop(&"frosthold_market_house_right", houses, room_offset + Vector2(290, 8))
			_profile_prop(&"frosthold_market_stall", market, room_offset + Vector2(44, 72))
			_profile_prop(&"frosthold_market_stall_right", market, room_offset + Vector2(238, 72))
			_profile_prop(&"frosthold_market_supply_stall", market, room_offset + Vector2(160, 92))
		&"frosthold_causeway":
			var room_offset := offset + Vector2(20 * TILE, 0)
			_profile_prop(&"frosthold_causeway_crystal_bank", crystals, room_offset + Vector2(10, 36))
			_prop(crystals, Rect2(286, 176, 184, 230), room_offset + Vector2(286, 40))
			_profile_prop(&"frosthold_causeway_bridge", bridges, room_offset + Vector2(149, 20))
			_prop(bridges, Rect2(280, 174, 170, 215), room_offset + Vector2(149, 122))
			_profile_prop(&"frosthold_causeway_rune", runes, room_offset + Vector2(160, 226))
		&"frosthold_rune_hall":
			var room_offset := offset + Vector2(10 * TILE, 10 * TILE)
			_prop(castle, Rect2(728, 741, 172, 217), room_offset + Vector2(26, 28))
			_prop(castle, Rect2(933, 734, 347, 224), room_offset + Vector2(105, 22))
			_prop(castle, Rect2(728, 741, 172, 217), room_offset + Vector2(270, 28))
			_prop(torches, Rect2(77, 170, 94, 205), room_offset + Vector2(76, 90))
			_prop(torches, Rect2(246, 170, 94, 205), room_offset + Vector2(262, 90))
			_prop(runes, Rect2(237, 736, 129, 128), room_offset + Vector2(104, 232))
			_prop(runes, Rect2(414, 736, 127, 128), room_offset + Vector2(216, 232))
		&"frosthold_throne":
			var room_offset := offset + Vector2(20 * TILE, 10 * TILE)
			_prop(castle, Rect2(41, 718, 105, 242), room_offset + Vector2(34, 28))
			_prop(castle, Rect2(175, 718, 106, 242), room_offset + Vector2(298, 28))
			_prop(castle, Rect2(933, 734, 347, 224), room_offset + Vector2(105, 34))
			_prop(torches, Rect2(77, 170, 94, 205), room_offset + Vector2(78, 90))
			_prop(torches, Rect2(246, 170, 94, 205), room_offset + Vector2(270, 90))
			_prop(runes, Rect2(1320, 736, 128, 128), room_offset + Vector2(160, 238))
