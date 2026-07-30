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
	draw_rect(bounds, Color("111326"), true)
	# Wet stone forecourt and the dry porch route are intentionally distinct so
	# HM-01 exposes its safe-strip contract before combat content activates.
	for y in range(7, _dimensions.y - 1):
		for x in range(1, _dimensions.x - 1):
			_draw_tile(_stone, &"sandbox_haunted_stone", Vector2(x * 48, y * 48), Color("8791a8"))
	for y in range(5, 8):
		for x in range(6, 12):
			_draw_tile(_planks, &"sandbox_haunted_planks", Vector2(x * 48, y * 48), Color("9d887e"))
	draw_rect(Rect2(Vector2(48, 7 * 48), Vector2((_dimensions.x - 2) * 48, (_dimensions.y - 8) * 48)), Color(0.08, 0.1, 0.18, 0.18), true)
	for x in range(1, _dimensions.x - 1):
		var rain_x := float(x * 48 + 16)
		draw_line(Vector2(rain_x, 18), Vector2(rain_x - 8, 54), Color(0.58, 0.68, 0.9, 0.32), 2.0)


func _draw_tile(texture: Texture2D, profile_id: StringName, draw_position: Vector2, tint: Color) -> void:
	if texture and _profiles and _profiles.has(profile_id):
		draw_texture_rect_region(texture, Rect2(draw_position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id), tint)
