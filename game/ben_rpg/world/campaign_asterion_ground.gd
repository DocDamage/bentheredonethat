class_name CampaignAsterionGround
extends Node2D

## Owns Asterion's active interior shell and the non-navigable station hull.
## Room-specific machinery and overhead props remain in CampaignAsterionForeground.

const TILE := 48
const STATION_ORIGIN := Vector2i(36, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const WALL_TILE_PROFILES := [
	[&"asterion_station_wall_0_0", &"asterion_station_wall_1_0"],
	[&"asterion_station_wall_0_1", &"asterion_station_wall_1_1"],
]
const FLOOR_TILE_PROFILES := [
	[&"asterion_station_floor_0_0", &"asterion_station_floor_1_0"],
	[&"asterion_station_floor_0_1", &"asterion_station_floor_1_1"],
]
const ROOM_OFFSETS := {
	&"station_dock": Vector2i(0, 0),
	&"station_mess": Vector2i(10, 0),
	&"station_hydro": Vector2i(20, 0),
	&"station_medical": Vector2i(10, 10),
	&"station_control": Vector2i(20, 10),
}

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
	if not ROOM_OFFSETS.has(active_area):
		return
	var room_offset := Vector2(STATION_ORIGIN * TILE) + Vector2(ROOM_OFFSETS[active_area] * TILE)
	_draw_backdrop(room_offset)
	_draw_room_shell(room_offset)


func _draw_backdrop(room_offset: Vector2) -> void:
	# The camera is larger than the 8x8 playable station chamber. This hull is
	# intentionally non-navigable; it prevents the default engine canvas from
	# framing a compact authored interior.
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.008, 0.018, 0.043), true)
	var seam_color := Color(0.10, 0.21, 0.34, 0.38)
	for x in range(0, 21):
		var line_x := bounds.position.x + x * TILE
		draw_line(Vector2(line_x, bounds.position.y), Vector2(line_x, bounds.end.y), seam_color, 2.0)
	for y in range(0, 13):
		var line_y := bounds.position.y + y * TILE
		draw_line(Vector2(bounds.position.x, line_y), Vector2(bounds.end.x, line_y), seam_color, 2.0)


func _draw_room_shell(room_offset: Vector2) -> void:
	for y in range(8):
		for x in range(8):
			var profile_id: StringName = WALL_TILE_PROFILES[y % 2][x % 2] if y < 4 else FLOOR_TILE_PROFILES[y % 2][x % 2]
			_profile_tile(profile_id, room_offset + Vector2(x, y) * TILE)
	# This hard baseboard makes the blocked wall band and open floor legible.
	draw_rect(Rect2(room_offset + Vector2(0, 190), Vector2(384, 4)), Color(0.08, 0.16, 0.24, 0.9), true)


func _profile_tile(profile_id: StringName, destination_position: Vector2) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved Asterion ground profile: %s" % profile_id)
		return
	var texture: Texture2D = profiles.texture(profile_id)
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	if texture:
		draw_texture_rect_region(texture, Rect2(destination_position, size), source)
