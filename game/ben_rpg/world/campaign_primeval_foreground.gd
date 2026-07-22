class_name CampaignPrimevalForeground
extends Node2D

## Primeval's canopy, dwellings, ruins, and nests live above the ground pass.
## This gives the exploration route dependable occlusion while keeping only the
## active room on the canvas.

const TILE := 48
const PRIMEVAL_ORIGIN := Vector2i(72, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var active_area: StringName = &"lab"
var structures: Texture2D
var props: Texture2D
var trees: Texture2D
var ruins: Texture2D
var nests: Texture2D
var profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	structures = profiles.texture(&"primeval_village_dwelling")
	props = profiles.texture(&"primeval_anchor_totem")
	trees = profiles.texture(&"primeval_grove_canopy")
	ruins = profiles.texture(&"primeval_ruin_forecourt")
	nests = profiles.texture(&"primeval_relay_nest")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _prop(texture: Texture2D, source: Rect2, destination_position: Vector2, scale_factor := 1.0) -> void:
	if not texture:
		return
	# Primeval sources are either native 48px scenery or 96px Jurassic sheets.
	# Only native and exact reciprocal dimensions are allowed in the field.
	if scale_factor != 1.0 and scale_factor != 0.5:
		push_error("Primeval foreground received a non-standard scale: %s" % scale_factor)
		return
	var size := Vector2(roundi(source.size.x * scale_factor), roundi(source.size.y * scale_factor))
	var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
	draw_texture_rect_region(texture, Rect2(position, size), source)


func _profile_prop(profile_id: StringName, texture: Texture2D, destination_position: Vector2) -> void:
	if not texture or not profiles or not profiles.has(profile_id):
		push_error("Missing approved Primeval visual profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	draw_texture_rect_region(texture, Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size), source)


func _draw() -> void:
	if not active_area.begins_with("primeval"):
		return
	var offset := Vector2(PRIMEVAL_ORIGIN * TILE)
	match active_area:
		&"primeval_grove":
			_profile_prop(&"primeval_grove_canopy", trees, offset + Vector2(-8, 20))
			_profile_prop(&"primeval_grove_canopy_mid_left", trees, offset + Vector2(58, 14))
			_profile_prop(&"primeval_grove_canopy_mid", trees, offset + Vector2(258, 16))
			_profile_prop(&"primeval_grove_canopy_right", trees, offset + Vector2(325, 20))
			_profile_prop(&"primeval_grove_fern_left", trees, offset + Vector2(14, 152))
			_profile_prop(&"primeval_grove_fern_right", trees, offset + Vector2(320, 152))
			_profile_prop(&"primeval_anchor_totem", props, offset + Vector2(176, 74))
		&"primeval_village":
			var room_offset := offset + Vector2(10 * TILE, 0)
			_profile_prop(&"primeval_village_dwelling", structures, room_offset + Vector2(24, 36))
			_profile_prop(&"primeval_village_dwelling_right", structures, room_offset + Vector2(270, 32))
			_profile_prop(&"primeval_village_longhouse", structures, room_offset + Vector2(107, 62))
			_profile_prop(&"primeval_village_firepit", structures, room_offset + Vector2(167, 142))
			# The old 0.65 presentation scale was neither native nor reciprocal.
			# These perimeter awnings are now 0.5x and retain their clear route.
			_profile_prop(&"primeval_village_awning_left", structures, room_offset + Vector2(-8, 132))
			_profile_prop(&"primeval_village_awning_right", structures, room_offset + Vector2(280, 132))
		&"primeval_ruins":
			var room_offset := offset + Vector2(20 * TILE, 0)
			_profile_prop(&"primeval_ruin_forecourt", ruins, room_offset + Vector2(153, 20))
			_profile_prop(&"primeval_ruins_left_wall", ruins, room_offset + Vector2(34, 42))
			_profile_prop(&"primeval_ruins_right_wall", ruins, room_offset + Vector2(288, 42))
			_profile_prop(&"primeval_ruins_left_rubble", ruins, room_offset + Vector2(36, 139))
			_profile_prop(&"primeval_ruins_right_rubble", ruins, room_offset + Vector2(276, 139))
		&"primeval_nest":
			var room_offset := offset + Vector2(10 * TILE, 10 * TILE)
			_profile_prop(&"primeval_grove_canopy", trees, room_offset + Vector2(8, 26))
			_profile_prop(&"primeval_grove_canopy_right", trees, room_offset + Vector2(310, 28))
			_profile_prop(&"primeval_relay_nest", nests, room_offset + Vector2(148, 54))
			_profile_prop(&"primeval_nest_left", nests, room_offset + Vector2(14, 124))
			_profile_prop(&"primeval_nest_right", nests, room_offset + Vector2(286, 120))
			_profile_prop(&"primeval_grove_fern_left", trees, room_offset + Vector2(74, 146))
			_profile_prop(&"primeval_grove_fern_right", trees, room_offset + Vector2(270, 146))
			_profile_prop(&"primeval_anchor_totem", props, room_offset + Vector2(104, 73))
		&"primeval_caldera":
			var room_offset := offset + Vector2(20 * TILE, 10 * TILE)
			_prop(ruins, Rect2(548, 520, 180, 145), room_offset + Vector2(147, 18), 0.5)
			_prop(ruins, Rect2(48, 197, 124, 132), room_offset + Vector2(30, 38), 0.5)
			_prop(ruins, Rect2(608, 197, 125, 132), room_offset + Vector2(292, 38), 0.5)
			_prop(ruins, Rect2(367, 712, 99, 123), room_offset + Vector2(168, 86), 0.5)
			_prop(ruins, Rect2(48, 879, 100, 104), room_offset + Vector2(48, 132), 0.5)
			_prop(ruins, Rect2(997, 888, 128, 96), room_offset + Vector2(274, 136), 0.5)
