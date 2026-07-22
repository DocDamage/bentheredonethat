class_name CampaignEmpyrealGround
extends Node2D

## Owns Empyreal's ground plane, sky continuation, marble terraces, and rear
## balustrade. Keeping it separate from CampaignMapVisual gives the universe an
## explicit area renderer while actors and tall props remain on their dedicated
## layers.

const TILE := 48
const EMPYREAL_ORIGIN := Vector2i(216, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var active_area: StringName = &"lab"
var cloud_bank: Texture2D
var profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	cloud_bank = profiles.texture(&"empyreal_sky_cloud_bank")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _profile_tile(profile_id: StringName, texture: Texture2D, destination_position: Vector2) -> void:
	if not texture or not profiles or not profiles.has(profile_id):
		push_error("Missing approved Empyreal ground profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	var position := Vector2(roundf(destination_position.x), roundf(destination_position.y))
	draw_texture_rect_region(texture, Rect2(position, size), source)


func _draw() -> void:
	if not active_area.begins_with("empyreal"):
		return
	var rooms := {
		&"empyreal_landing": [Vector2i(0, 0), &"landing"],
		&"empyreal_garden": [Vector2i(10, 0), &"garden"],
		&"empyreal_forum": [Vector2i(20, 0), &"forum"],
		&"empyreal_aerie": [Vector2i(10, 10), &"aerie"],
		&"empyreal_tribunal": [Vector2i(20, 10), &"tribunal"],
	}
	var definition: Array = rooms.get(active_area, [])
	if definition.is_empty():
		return
	_draw_room(Vector2(EMPYREAL_ORIGIN * TILE) + Vector2(definition[0] * TILE), definition[1])


func _draw_room(room_offset: Vector2, room_kind: StringName) -> void:
	draw_rect(Rect2(room_offset - Vector2(384, 96), Vector2(1152, 576)), Color(0.18, 0.44, 0.72), true)
	for cloud_x in [-424, -40, 344]:
		_profile_tile(&"empyreal_sky_cloud_bank", cloud_bank, room_offset + Vector2(cloud_x, 12))
	var floor_profile: StringName = {
		&"landing": &"empyreal_marble_plain_tile",
		&"garden": &"empyreal_marble_plain_tile",
		&"forum": &"empyreal_marble_gold_quarter_tile",
		&"aerie": &"empyreal_marble_cracked_tile",
		&"tribunal": &"empyreal_marble_gold_quarter_tile",
	}.get(room_kind, &"empyreal_marble_plain_tile")
	var floor_texture: Texture2D = profiles.texture(floor_profile)
	for y in range(3):
		for x in range(4):
			_profile_tile(floor_profile, floor_texture, room_offset + Vector2(x * 96, 144 + y * 96))
	var balustrade := profiles.texture(&"empyreal_blue_balustrade") as Texture2D
	for x in range(0, 384, 96):
		_profile_tile(&"empyreal_blue_balustrade", balustrade, room_offset + Vector2(x, 124))
	if room_kind == &"landing":
		draw_rect(Rect2(room_offset + Vector2(145, 176), Vector2(94, 4)), Color(0.32, 0.19, 0.08, 0.65), true)
