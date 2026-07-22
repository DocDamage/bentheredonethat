class_name CampaignEmpyrealForeground
extends Node2D

## Empyreal's columns, gates, trees, and statuary occupy the foreground above
## the shared marble ground. This gives the floating terraces actual occlusion
## without turning their collision bases into detached renderer-only objects.

const TILE := 48
const EMPYREAL_ORIGIN := Vector2i(216, 32)
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


func _profile_prop(profile_id: StringName, destination_position: Vector2, flip_h := false) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved Empyreal visual profile: %s" % profile_id)
		return
	var texture: Texture2D = profiles.texture(profile_id)
	if not texture:
		return
	var size: Vector2 = profiles.world_draw_size(profile_id)
	var destination := Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size)
	if flip_h:
		destination.position.x += size.x
		destination.size.x = -size.x
	draw_texture_rect_region(texture, destination, profiles.region(profile_id))


func _draw() -> void:
	if not active_area.begins_with("empyreal"):
		return
	var offset := Vector2(EMPYREAL_ORIGIN * TILE)
	match active_area:
		&"empyreal_landing":
			_profile_prop(&"empyreal_pediment_door", offset + Vector2(132, 4))
			_profile_prop(&"empyreal_winged_statue", offset + Vector2(22, 38))
			_profile_prop(&"empyreal_winged_statue", offset + Vector2(268, 38), true)
		&"empyreal_garden":
			var room_offset := offset + Vector2(10 * TILE, 0)
			_profile_prop(&"empyreal_silver_olive_tree", room_offset + Vector2(5, 31))
			_profile_prop(&"empyreal_golden_olive_tree", room_offset + Vector2(278, 31))
			_profile_prop(&"empyreal_appeal_fountain", room_offset + Vector2(141, 34))
			_profile_prop(&"empyreal_flower_offering", room_offset + Vector2(76, 190))
			_profile_prop(&"empyreal_fruit_offering", room_offset + Vector2(247, 190))
		&"empyreal_forum":
			var room_offset := offset + Vector2(20 * TILE, 0)
			_profile_prop(&"empyreal_plain_column", room_offset + Vector2(34, 11))
			_profile_prop(&"empyreal_blue_column", room_offset + Vector2(302, 11))
			_profile_prop(&"empyreal_ordinance_book", room_offset + Vector2(138, 65))
			_profile_prop(&"empyreal_horse_statue", room_offset + Vector2(58, 84))
			_profile_prop(&"empyreal_griffin_statue", room_offset + Vector2(267, 82))
		&"empyreal_aerie":
			var room_offset := offset + Vector2(10 * TILE, 10 * TILE)
			_profile_prop(&"empyreal_reliquary_portal", room_offset + Vector2(137, 11))
			_profile_prop(&"empyreal_crystal_altar", room_offset + Vector2(41, 101))
			_profile_prop(&"empyreal_lotus_altar", room_offset + Vector2(267, 101))
			_profile_prop(&"empyreal_gravity_crystal", room_offset + Vector2(167, 178))
		&"empyreal_tribunal":
			var room_offset := offset + Vector2(20 * TILE, 10 * TILE)
			_profile_prop(&"empyreal_tribunal_gate", room_offset + Vector2(111, 4))
			_profile_prop(&"empyreal_justice_statue", room_offset + Vector2(40, 38))
			_profile_prop(&"empyreal_music_statue", room_offset + Vector2(304, 38))
			_profile_prop(&"empyreal_tribunal_orrery", room_offset + Vector2(32, 187))
