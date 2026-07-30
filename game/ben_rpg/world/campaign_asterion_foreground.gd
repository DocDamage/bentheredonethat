class_name CampaignAsterionForeground
extends Node2D

## Asterion's room props live above the shared field ground. The navigation
## layer owns their solid bases; this layer owns their visual occlusion and is
## restricted to the active room to avoid drawing neighboring station sets.

const TILE := 48
const STATION_ORIGIN := Vector2i(36, 32)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var active_area: StringName = &"lab"
var architecture: Texture2D
var mess: Texture2D
var hydro: Texture2D
var command: Texture2D
var exterior: Texture2D
var medical: Texture2D
var profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	architecture = profiles.texture(&"asterion_station_architecture")
	mess = profiles.texture(&"asterion_mess_banner")
	hydro = profiles.texture(&"asterion_hydroponics_bed")
	command = profiles.texture(&"asterion_command_console")
	exterior = profiles.texture(&"asterion_dock_hull")
	medical = profiles.texture(&"asterion_medical_station")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _profile_prop(profile_id: StringName, texture: Texture2D, destination_position: Vector2) -> void:
	if not texture or not profiles or not profiles.has(profile_id):
		push_error("Missing approved Asterion visual profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	draw_texture_rect_region(texture, Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size), source)


func _draw() -> void:
	if not active_area.begins_with("station"):
		return
	var offset := Vector2(STATION_ORIGIN * TILE)
	match active_area:
		&"station_dock":
			_profile_prop(&"asterion_dock_hull", exterior, offset + Vector2(68, 12))
			_profile_prop(&"asterion_dock_bulkhead", exterior, offset + Vector2(2, 92))
			_profile_prop(&"asterion_station_architecture", architecture, offset + Vector2(297, 108))
		&"station_mess":
			var room_offset := offset + Vector2(10 * TILE, 0)
			_profile_prop(&"asterion_station_architecture", architecture, room_offset + Vector2(7, 108))
			_profile_prop(&"asterion_station_architecture", architecture, room_offset + Vector2(297, 108))
			_profile_prop(&"asterion_mess_banner", mess, room_offset + Vector2(117, 10))
			_profile_prop(&"asterion_mess_wall_fixture_left", mess, room_offset + Vector2(164, 10))
			_profile_prop(&"asterion_mess_wall_fixture_right", mess, room_offset + Vector2(212, 10))
			_profile_prop(&"asterion_mess_service_hatch", exterior, room_offset + Vector2(76, 104))
			_profile_prop(&"asterion_mess_counter", mess, room_offset + Vector2(214, 136))
		&"station_hydro":
			var room_offset := offset + Vector2(20 * TILE, 0)
			_profile_prop(&"asterion_station_architecture", architecture, room_offset + Vector2(7, 108))
			_profile_prop(&"asterion_hydroponics_bed", hydro, room_offset + Vector2(72, 16))
			_profile_prop(&"asterion_hydro_control_bank", hydro, room_offset + Vector2(100, 132))
			_profile_prop(&"asterion_hydro_reservoir", hydro, room_offset + Vector2(304, 86))
		&"station_medical":
			var room_offset := offset + Vector2(10 * TILE, 10 * TILE)
			_profile_prop(&"asterion_medical_station", medical, room_offset + Vector2(14, 12))
			_profile_prop(&"asterion_medical_cabinet", medical, room_offset + Vector2(70, 12))
			_profile_prop(&"asterion_medical_treatment_bed", medical, room_offset + Vector2(108, 116))
			_profile_prop(&"asterion_medical_supply_cart", medical, room_offset + Vector2(224, 101))
			_profile_prop(&"asterion_medical_control_console", command, room_offset + Vector2(286, 62))
		&"station_control":
			var room_offset := offset + Vector2(20 * TILE, 10 * TILE)
			_profile_prop(&"asterion_command_console", command, room_offset + Vector2(48, 18))
