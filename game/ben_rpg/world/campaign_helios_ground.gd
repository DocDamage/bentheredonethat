class_name CampaignHeliosGround
extends Node2D

## Owns Helios's active authored city quadrant and atmospheric continuation.
## Elevated rails and canopy lips remain in CampaignHeliosForeground.

const TILE := 48
const HELIOS_ORIGIN := Vector2i(108, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const ROOM_PROFILES := {
	&"helios_skybridge": [Vector2i(0, 0), &"helios_skybridge_quadrant"],
	&"helios_market": [Vector2i(10, 0), &"helios_market_quadrant"],
	&"helios_transit": [Vector2i(20, 0), &"helios_transit_quadrant"],
	&"helios_clinic": [Vector2i(10, 10), &"helios_clinic_quadrant"],
	&"helios_core": [Vector2i(20, 10), &"helios_core_quadrant"],
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
	if not ROOM_PROFILES.has(active_area):
		return
	var definition: Array = ROOM_PROFILES[active_area]
	var room_offset := Vector2(HELIOS_ORIGIN * TILE) + Vector2(definition[0] * TILE)
	var profile_id: StringName = definition[1]
	_draw_backdrop(room_offset)
	draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.48, 0.60, 0.69), true)
	_profile_tile(profile_id, room_offset)
	if active_area == &"helios_core":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.04, 0.08, 0.20, 0.22), true)


func _draw_backdrop(room_offset: Vector2) -> void:
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.19, 0.32, 0.45), true)
	draw_rect(Rect2(bounds.position + Vector2(0, 88), Vector2(bounds.size.x, 8)), Color(0.42, 0.70, 0.82, 0.22), true)
	draw_rect(Rect2(bounds.position + Vector2(0, 452), Vector2(bounds.size.x, 12)), Color(0.08, 0.16, 0.25, 0.42), true)
	for x in range(0, int(bounds.size.x), TILE * 3):
		var tower_height := 112.0 + float((x / TILE) % 3) * 56.0
		var tower := Rect2(bounds.position + Vector2(x + 20, bounds.size.y - tower_height), Vector2(104, tower_height))
		draw_rect(tower, Color(0.13, 0.24, 0.36, 0.56), true)
		draw_line(Vector2(tower.position.x + 10, tower.position.y + 18), Vector2(tower.position.x + 10, tower.end.y - 12), Color(0.48, 0.82, 0.94, 0.30), 2.0)


func _profile_tile(profile_id: StringName, destination_position: Vector2) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved Helios ground profile: %s" % profile_id)
		return
	var texture: Texture2D = profiles.texture(profile_id)
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	if texture:
		draw_texture_rect_region(texture, Rect2(destination_position, size), source)
