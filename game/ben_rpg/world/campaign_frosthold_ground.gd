class_name CampaignFrostholdGround
extends Node2D

## Owns Frosthold's active ground plane and non-navigable snow continuation.
## Architecture remains in CampaignFrostholdForeground so actors retain their
## established depth relationship with gates, bridges, and throne structures.

const TILE := 48
const FROSTHOLD_ORIGIN := Vector2i(144, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const GROUND_TILE_PROFILES := [
	&"frosthold_snow_ground_tile",
	&"frosthold_snow_ground_variant_1",
	&"frosthold_snow_ground_variant_2",
	&"frosthold_snow_ground_variant_3",
	&"frosthold_snow_ground_variant_4",
	&"frosthold_snow_ground_variant_5",
	&"frosthold_snow_ground_variant_6",
	&"frosthold_snow_ground_variant_7",
]
const ROOM_DEFINITIONS := {
	&"frosthold_gate": [Vector2i(0, 0), 2],
	&"frosthold_market": [Vector2i(10, 0), 5],
	&"frosthold_causeway": [Vector2i(20, 0), 13],
	&"frosthold_rune_hall": [Vector2i(10, 10), 10],
	&"frosthold_throne": [Vector2i(20, 10), 18],
}

var active_area: StringName = &"lab"
var profiles
var frozen_ground: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	frozen_ground = profiles.texture(&"frosthold_snow_ground_tile")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _profile_tile(profile_id: StringName, destination_position: Vector2) -> void:
	if not frozen_ground or not profiles or not profiles.has(profile_id):
		push_error("Missing approved Frosthold ground profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
	draw_texture_rect_region(frozen_ground, Rect2(position, size), source)


func _draw() -> void:
	if not ROOM_DEFINITIONS.has(active_area):
		return
	var definition: Array = ROOM_DEFINITIONS[active_area]
	var room_offset := Vector2(FROSTHOLD_ORIGIN * TILE) + Vector2(definition[0] * TILE)
	_draw_backdrop(room_offset)
	_draw_ground(room_offset, int(definition[1]))


func _draw_backdrop(room_offset: Vector2) -> void:
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.035, 0.12, 0.23), true)
	for x in range(0, int(bounds.size.x), TILE * 2):
		var drift_y := bounds.position.y + 40.0 + float((x / TILE) % 4) * 26.0
		draw_line(Vector2(bounds.position.x + x + 12, drift_y), Vector2(bounds.position.x + x + 72, drift_y), Color(0.58, 0.80, 0.96, 0.20), 2.0)


func _draw_ground(room_offset: Vector2, room_seed: int) -> void:
	draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.07, 0.18, 0.32), true)
	for y in range(8):
		for x in range(8):
			var profile_id: StringName = GROUND_TILE_PROFILES[(x * 3 + y * 5 + room_seed) % GROUND_TILE_PROFILES.size()]
			_profile_tile(profile_id, room_offset + Vector2(x, y) * TILE)
