class_name CampaignHauntedMansionRainGateArchitecture
extends Node2D

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _dimensions := Vector2i.ZERO
var _profiles
var _exterior: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	_exterior = _profiles.texture(&"haunted_mansion_exterior")
	queue_redraw()


func configure(dimensions: Vector2i) -> void:
	_dimensions = dimensions
	queue_redraw()


func _draw() -> void:
	if _dimensions == Vector2i.ZERO or not _exterior or not _profiles or not _profiles.has(&"haunted_mansion_exterior"):
		return
	var source: Rect2 = _profiles.region(&"haunted_mansion_exterior")
	var draw_size: Vector2 = _profiles.world_draw_size(&"haunted_mansion_exterior")
	var draw_position := Vector2((_dimensions.x * 48 - draw_size.x) * 0.5, 2 * 48)
	draw_texture_rect_region(_exterior, Rect2(draw_position, draw_size), source)
