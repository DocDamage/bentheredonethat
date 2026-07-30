class_name CampaignMoonpetalGround
extends Node2D

## Owns Moonpetal's active night-garden ground and processional path. Tall
## gates, trees, temple facades, and lanterns remain in its foreground layer.

const TILE := 48
const MOONPETAL_ORIGIN := Vector2i(180, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const ROOM_KINDS := {
	&"moonpetal_gate": [Vector2i(0, 0), &"gate"],
	&"moonpetal_court": [Vector2i(10, 0), &"court"],
	&"moonpetal_garden": [Vector2i(20, 0), &"garden"],
	&"moonpetal_bell_walk": [Vector2i(10, 10), &"bell_walk"],
	&"moonpetal_palace": [Vector2i(20, 10), &"palace"],
}

var active_area: StringName = &"lab"
var profiles
var paths: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	paths = profiles.texture(&"moonpetal_processional_path")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _draw() -> void:
	if not ROOM_KINDS.has(active_area):
		return
	var definition: Array = ROOM_KINDS[active_area]
	var room_offset := Vector2(MOONPETAL_ORIGIN * TILE) + Vector2(definition[0] * TILE)
	var room_kind: StringName = definition[1]
	_draw_backdrop(room_offset)
	var ground_color := Color(0.16, 0.20, 0.12)
	match room_kind:
		&"gate": ground_color = Color(0.20, 0.16, 0.11)
		&"garden": ground_color = Color(0.10, 0.20, 0.18)
		&"bell_walk": ground_color = Color(0.13, 0.15, 0.16)
		&"palace": ground_color = Color(0.18, 0.12, 0.17)
	draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.045, 0.025, 0.065), true)
	draw_rect(Rect2(room_offset + Vector2(10, 10), Vector2(364, 364)), ground_color, true)
	draw_set_transform(room_offset + Vector2(220, 174), PI * 0.5)
	_profile_tile(&"moonpetal_processional_path", Vector2.ZERO)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_backdrop(room_offset: Vector2) -> void:
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.055, 0.022, 0.085), true)
	for x in range(0, int(bounds.size.x), TILE * 3):
		draw_circle(Vector2(bounds.position.x + x + 48, bounds.position.y + 74), 28.0, Color(0.23, 0.14, 0.30, 0.42))


func _profile_tile(profile_id: StringName, destination_position: Vector2) -> void:
	if not paths or not profiles or not profiles.has(profile_id):
		push_error("Missing approved Moonpetal ground profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	draw_texture_rect_region(paths, Rect2(destination_position, size), source)
