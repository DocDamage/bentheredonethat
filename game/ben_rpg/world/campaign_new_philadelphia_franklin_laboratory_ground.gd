class_name CampaignNewPhiladelphiaFranklinLaboratoryGround
extends Node2D

const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _layout: Dictionary = {}
var _profiles
var _textures: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = PROFILES.new()
	for profile_id in [&"laboratory_floor_tile", &"laboratory_wall_tile"]:
		_textures[profile_id] = _profiles.texture(profile_id)


func configure(layout: Dictionary) -> void:
	_layout = layout.duplicate(true)
	queue_redraw()


func _draw() -> void:
	var dimensions: Vector2i = _layout.get("dimensions", Vector2i.ZERO)
	draw_rect(Rect2(Vector2(-8 * 48, -8 * 48), Vector2((dimensions.x + 16) * 48, (dimensions.y + 16) * 48)), Color("111821"), true)
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			var profile_id: StringName = &"laboratory_wall_tile" if x == 0 or y == 0 or x == dimensions.x - 1 or y == dimensions.y - 1 else &"laboratory_floor_tile"
			var texture: Texture2D = _textures.get(profile_id) as Texture2D
			if texture:
				draw_texture_rect_region(texture, Rect2(Vector2(x, y) * 48.0, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
	var size := Vector2(dimensions * 48)
	draw_rect(Rect2(Vector2(48, 48), Vector2(size.x - 96, 2 * 48)), Color(0.12, 0.19, 0.27, 0.68), true)
	for pipe_y in [70.0, 102.0]:
		draw_line(Vector2(72, pipe_y), Vector2(size.x - 72, pipe_y), Color("6b8497"), 8.0)
		draw_line(Vector2(72, pipe_y - 3), Vector2(size.x - 72, pipe_y - 3), Color("b8d3dc"), 2.0)
	for light_x in range(4 * 48, int(size.x - 3 * 48), 6 * 48):
		draw_rect(Rect2(Vector2(light_x, 118), Vector2(3 * 48, 12)), Color(0.73, 0.94, 1.0, 0.7), true)
	draw_line(Vector2(48, 3 * 48), Vector2(size.x - 48, 3 * 48), Color("5aa7bf"), 4.0)
	# Dark service lanes and hazard boxes turn the repeated clean-room tile into
	# functional laboratory zones while keeping every navigation cell intact.
	var central_lane := Rect2(Vector2(size.x * 0.43, 3 * 48), Vector2(size.x * 0.14, size.y - 6 * 48))
	draw_rect(central_lane, Color(0.16, 0.22, 0.28, 0.48), true)
	draw_rect(central_lane, Color(0.34, 0.61, 0.68, 0.55), false, 3.0)
	for cell in [Vector2i(6, 5), Vector2i(12, 5), Vector2i(18, 5), Vector2i(24, 5), Vector2i(6, 14), Vector2i(12, 14), Vector2i(18, 14), Vector2i(24, 14)]:
		var zone := Rect2(Vector2(cell - Vector2i(2, 2)) * 48.0, Vector2(4, 4) * 48.0)
		draw_rect(zone, Color(0.13, 0.19, 0.23, 0.22), true)
		draw_rect(zone, Color("d0a84d"), false, 2.0)
		for offset in range(12, int(zone.size.x - 8), 24):
			draw_line(zone.position + Vector2(offset, 0), zone.position + Vector2(offset + 10, 0), Color("efe098"), 3.0)
