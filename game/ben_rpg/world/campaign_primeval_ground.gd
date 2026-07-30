class_name CampaignPrimevalGround
extends Node2D

## Owns Primeval's active terrain quadrant and unwalkable jungle continuation.
## Canopy, structures, ruins, and nests remain in CampaignPrimevalForeground.

const TILE := 48
const PRIMEVAL_ORIGIN := Vector2i(72, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const ROOM_PROFILES := {
	&"primeval_grove": [Vector2i(0, 0), &"primeval_ground_quadrant"],
	&"primeval_village": [Vector2i(10, 0), &"primeval_ground_quadrant"],
	&"primeval_ruins": [Vector2i(20, 0), &"primeval_desert_ground_quadrant"],
	&"primeval_nest": [Vector2i(10, 10), &"primeval_ground_quadrant"],
	&"primeval_caldera": [Vector2i(20, 10), &"primeval_desert_ground_quadrant"],
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
	var room_offset := Vector2(PRIMEVAL_ORIGIN * TILE) + Vector2(definition[0] * TILE)
	_draw_backdrop(room_offset)
	_profile_tile(definition[1], room_offset)
	if active_area == &"primeval_nest":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.02, 0.12, 0.03, 0.16), true)
	elif active_area == &"primeval_caldera":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.28, 0.045, 0.018, 0.30), true)


func _draw_backdrop(room_offset: Vector2) -> void:
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.015, 0.075, 0.025), true)
	for x in range(0, int(bounds.size.x), TILE * 2):
		var canopy_y := bounds.position.y + 42.0 + float((x / TILE) % 3) * 18.0
		draw_circle(Vector2(bounds.position.x + x + 36, canopy_y), 38.0, Color(0.045, 0.19, 0.055, 0.62))


func _profile_tile(profile_id: StringName, destination_position: Vector2) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved Primeval ground profile: %s" % profile_id)
		return
	var texture: Texture2D = profiles.texture(profile_id)
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	if texture:
		draw_texture_rect_region(texture, Rect2(destination_position, size), source)
