class_name CampaignTownForeground
extends Node2D

## Town façade and canopy occluders.  These were previously painted together
## with the ground in CampaignMapVisual, which made every actor render over a
## roof or tree.  Keeping them in ForegroundLayer gives the town block the same
## explicit depth contract as the Mansion vertical slice.

const TILE := 48
const TOWN_ORIGIN := Vector2i(36, 0)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var active_area: StringName = &"lab"
var trees: Texture2D
var town_structures: Texture2D
var profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	trees = profiles.texture(&"town_ranch_tree_small")
	town_structures = profiles.texture(&"laboratory_exterior")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _tile(texture: Texture2D, source: Rect2, destination: Rect2) -> void:
	if texture:
		draw_texture_rect_region(texture, destination, source)


func _profile_tile(profile_id: StringName, texture: Texture2D, destination_position: Vector2) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved town visual profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	_tile(texture, source, Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size))


func _draw() -> void:
	if active_area != &"town" or CampaignState.sandbox_mode:
		return
	var offset := Vector2(TOWN_ORIGIN * TILE)
	# The door stays on the navigation layer while the roof, façade, and its
	# contained shadow now occlude actors who walk behind the laboratory.
	var lab_center_x := offset.x + 14 * TILE
	var lab_size: Vector2 = profiles.world_draw_size(&"laboratory_exterior")
	var lab_destination := Rect2(
		Vector2(lab_center_x - lab_size.x * 0.5, offset.y + 7 * TILE - lab_size.y),
		lab_size
	)
	draw_rect(Rect2(lab_destination.position + Vector2(7, lab_destination.size.y - 14), Vector2(lab_destination.size.x - 14, 18)), Color(0.04, 0.07, 0.04, 0.28), true)
	_profile_tile(&"laboratory_exterior", town_structures, lab_destination.position)
	# Complete landmark-tree islands retain their actual alpha silhouettes rather
	# than becoming rectangular decals. Their solid navigation footprints remain
	# authored in CampaignBootstrap's town collision map.
	for entry in [[2, 2, false], [29, 3, true], [3, 20, true], [30, 20, false]]:
		var profile_id: StringName = &"town_ranch_tree_tall" if entry[2] else &"town_ranch_tree_small"
		var size: Vector2 = profiles.world_draw_size(profile_id)
		var center := offset + Vector2(entry[0], entry[1]) * TILE
		_profile_tile(profile_id, trees, center - Vector2(size.x * 0.5, size.y * 0.75))
