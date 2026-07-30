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
	var center_x := _dimensions.x * 24.0
	# A broad silhouetted structure makes the supplied facade read as the lit
	# central entrance of a real mansion rather than a detached cottage sprite.
	var wing_rect := Rect2(Vector2(3 * 48, 2.35 * 48), Vector2((_dimensions.x - 6) * 48, 4.75 * 48))
	draw_rect(wing_rect, Color("17131c"), true)
	var roof := PackedVector2Array([Vector2(2.4 * 48, 2.5 * 48), Vector2(5.2 * 48, 1.35 * 48), Vector2(center_x, 2.1 * 48), Vector2((_dimensions.x - 5.2) * 48, 1.35 * 48), Vector2((_dimensions.x - 2.4) * 48, 2.5 * 48)])
	draw_colored_polygon(roof, Color("0d0c14"))
	for x in [4.2, 6.0, 12.0, 13.8]:
		var window := Rect2(Vector2(x * 48, 3.3 * 48), Vector2(25, 36))
		draw_rect(window, Color("332839"), true)
		draw_rect(window.grow(-4), Color("8d7257"), true)
		draw_line(window.position + Vector2(window.size.x * 0.5, 3), window.position + Vector2(window.size.x * 0.5, window.size.y - 3), Color("231b26"), 2.0)
	var enlarged := draw_size * 1.35
	var draw_position := Vector2((center_x - enlarged.x * 0.5), 1.65 * 48)
	draw_texture_rect_region(_exterior, Rect2(draw_position, enlarged), source)
