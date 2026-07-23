class_name CampaignPrimevalGround
extends Node2D

## Primeval's ground and atmosphere are an area-owned renderer. Its tall
## scenery remains in CampaignPrimevalForeground, preserving the shared actor
## depth contract without keeping this universe in CampaignMapVisual.

const TILE := 48
const PRIMEVAL_ORIGIN := Vector2i(72, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

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


func _profile_tile(profile_id: StringName, destination_position: Vector2) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved Primeval ground profile: %s" % profile_id)
		return
	var texture: Texture2D = profiles.texture(profile_id)
	if not texture:
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
	draw_texture_rect_region(texture, Rect2(position, size), source)


func _draw() -> void:
	if not active_area.begins_with("primeval"):
		return
	var rooms := {
		&"primeval_grove": [Vector2i(0, 0), &"grove"],
		&"primeval_village": [Vector2i(10, 0), &"village"],
		&"primeval_ruins": [Vector2i(20, 0), &"ruins"],
		&"primeval_nest": [Vector2i(10, 10), &"nest"],
		&"primeval_caldera": [Vector2i(20, 10), &"caldera"],
	}
	var definition: Array = rooms.get(active_area, [])
	if definition.is_empty():
		return
	_draw_room(Vector2(PRIMEVAL_ORIGIN * TILE) + Vector2(definition[0] * TILE), definition[1])


func _draw_room(room_offset: Vector2, room_kind: StringName) -> void:
	var bounds := Rect2(room_offset - Vector2(288, 96), Vector2(960, 576))
	draw_rect(bounds, Color(0.015, 0.075, 0.025), true)
	for x in range(0, int(bounds.size.x), TILE * 2):
		var canopy_y := bounds.position.y + 42.0 + float((x / TILE) % 3) * 18.0
		draw_circle(Vector2(bounds.position.x + x + 36, canopy_y), 38.0, Color(0.045, 0.19, 0.055, 0.62))
	var ground_profile: StringName = &"primeval_desert_ground_quadrant" if room_kind == &"ruins" or room_kind == &"caldera" else &"primeval_ground_quadrant"
	_profile_tile(ground_profile, room_offset)
	if room_kind == &"nest":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.02, 0.12, 0.03, 0.16), true)
	elif room_kind == &"caldera":
		draw_rect(Rect2(room_offset, Vector2(384, 384)), Color(0.28, 0.045, 0.018, 0.30), true)
