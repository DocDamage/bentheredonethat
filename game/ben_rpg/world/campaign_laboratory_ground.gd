class_name CampaignLaboratoryGround
extends Node2D

## Owns the laboratory's floor, rear architecture, equipment banks, and exit.
## The laboratory remains a single active area, so this renderer has no room map.

const TILE := 48
const LAB_SIZE := Vector2i(20, 12)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var active_area: StringName = &"lab"
var profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _draw() -> void:
	if active_area != &"lab":
		return
	for y in range(LAB_SIZE.y):
		for x in range(LAB_SIZE.x):
			var floor_profile: StringName = &"laboratory_wall_tile" if y <= 2 else &"laboratory_floor_tile"
			_profile_tile(floor_profile, Vector2(x * TILE, y * TILE))
	_profile_tile(&"laboratory_utility_bank", Vector2(TILE, TILE))
	_profile_tile(&"laboratory_ventilation_run", Vector2(11 * TILE, 0))
	_profile_tile(&"laboratory_analysis_station", Vector2(48, 190))
	_profile_tile(&"laboratory_west_terminal", Vector2(166, 198))
	_profile_tile(&"laboratory_west_spectrometer", Vector2(282, 198))
	_profile_tile(&"laboratory_east_fabricator", Vector2(528, 198))
	_profile_tile(&"laboratory_east_reactor", Vector2(646, 198))
	_profile_tile(&"laboratory_east_calibrator", Vector2(764, 198))
	_profile_tile(&"laboratory_west_storage", Vector2(48, 384))
	_profile_tile(&"laboratory_center_storage", Vector2(190, 384))
	_profile_tile(&"laboratory_east_generator", Vector2(676, 350))
	_profile_tile(&"laboratory_east_coolant", Vector2(790, 350))
	_profile_tile(&"laboratory_exit_doors", Vector2(9 * TILE, 10 * TILE))


func _profile_tile(profile_id: StringName, destination_position: Vector2) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved laboratory ground profile: %s" % profile_id)
		return
	var texture: Texture2D = profiles.texture(profile_id)
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	if texture:
		draw_texture_rect_region(texture, Rect2(destination_position, size), source)
