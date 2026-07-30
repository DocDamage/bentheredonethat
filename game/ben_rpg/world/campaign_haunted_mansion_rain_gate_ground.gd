class_name CampaignHauntedMansionRainGateGround
extends Node2D

const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _dimensions := Vector2i.ZERO
var _profiles
var _stone: Texture2D
var _planks: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	_stone = _profiles.texture(&"sandbox_haunted_stone")
	_planks = _profiles.texture(&"sandbox_haunted_planks")
	queue_redraw()


func configure(dimensions: Vector2i) -> void:
	_dimensions = dimensions
	queue_redraw()


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(Rect2(Vector2(-8 * 48, -8 * 48), Vector2((_dimensions.x + 16) * 48, (_dimensions.y + 16) * 48)), Color("080a18"), true)
	draw_rect(bounds, Color("111326"), true)
	# Layered storm bands and a low horizon give the gate a sense of place before
	# the playable stone court begins.
	for band in range(5):
		draw_rect(Rect2(Vector2(0, band * 54), Vector2(_dimensions.x * 48, 54)), Color(0.045 + band * 0.006, 0.05 + band * 0.007, 0.11 + band * 0.012), true)
	# Wet stone forecourt and the dry porch route are intentionally distinct so
	# HM-01 exposes its safe-strip contract before combat content activates.
	for y in range(7, _dimensions.y - 1):
		for x in range(1, _dimensions.x - 1):
			_draw_tile(_stone, &"sandbox_haunted_stone", Vector2(x * 48, y * 48), Color("8791a8"))
	for y in range(5, 8):
		for x in range(6, 12):
			_draw_tile(_planks, &"sandbox_haunted_planks", Vector2(x * 48, y * 48), Color("9d887e"))
	draw_rect(Rect2(Vector2(48, 7 * 48), Vector2((_dimensions.x - 2) * 48, (_dimensions.y - 8) * 48)), Color(0.08, 0.1, 0.18, 0.18), true)
	var path := PackedVector2Array([Vector2(6 * 48, 7 * 48), Vector2(12 * 48, 7 * 48), Vector2(15 * 48, _dimensions.y * 48), Vector2(3 * 48, _dimensions.y * 48)])
	draw_colored_polygon(path, Color(0.18, 0.17, 0.24, 0.48))
	for y in range(8, _dimensions.y, 2):
		var inset := maxi(0, (_dimensions.y - y) * 7)
		draw_line(Vector2(3 * 48 + inset, y * 48), Vector2(15 * 48 - inset, y * 48), Color(0.45, 0.48, 0.61, 0.25), 2.0)
	for puddle in [Rect2(2.0 * 48, 8.2 * 48, 2.4 * 48, 18), Rect2(12.8 * 48, 9.3 * 48, 2.8 * 48, 16)]:
		draw_rect(puddle, Color(0.24, 0.32, 0.5, 0.28), true)
		draw_line(puddle.position + Vector2(8, 5), puddle.end - Vector2(10, 8), Color(0.55, 0.66, 0.86, 0.25), 1.0)
	for x in range(1, _dimensions.x - 1):
		var rain_x := float(x * 48 + 16)
		for rain_y in range(18, _dimensions.y * 48, 132):
			draw_line(Vector2(rain_x, rain_y), Vector2(rain_x - 8, rain_y + 36), Color(0.58, 0.68, 0.9, 0.26), 2.0)


func _draw_tile(texture: Texture2D, profile_id: StringName, draw_position: Vector2, tint: Color) -> void:
	if texture and _profiles and _profiles.has(profile_id):
		draw_texture_rect_region(texture, Rect2(draw_position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id), tint)
