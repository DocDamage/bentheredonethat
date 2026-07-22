class_name CampaignMansionForeground
extends Node2D

## Foreground occluders for the Mansion vertical slice.  These are intentionally
## independent of CampaignMapVisual's ground renderer: the layer can sit above
## actors while its matching navigation cells remain solid in CampaignBootstrap.

const TILE := 48
const MANSION_ORIGIN := Vector2i(0, 32)
const MANSION_ARCHIVE_OFFSET := Vector2i(10, 0)
const MANSION_GALLERY_OFFSET := Vector2i(0, 10)
const MANSION_NURSERY_OFFSET := Vector2i(10, 10)
const MANSION_BALLROOM_OFFSET := Vector2i(20, 5)
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var active_area: StringName = &"lab"
var haunted_interior: Texture2D
var haunted_storage: Texture2D
var haunted_bedroom: Texture2D
var profiles


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	profiles = VISUAL_PROFILE_REGISTRY.new()
	# These foreground source paths come from reviewed profiles rather than raw
	# literals. The remaining per-room crops can be converted independently.
	haunted_interior = profiles.texture(&"mansion_archive_cabinet")
	haunted_bedroom = profiles.texture(&"mansion_nursery_bed")
	haunted_storage = profiles.texture(&"mansion_archive_shelving")
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _tile(texture: Texture2D, source: Rect2, destination: Rect2) -> void:
	if texture:
		var aligned := Rect2(Vector2(roundf(destination.position.x), roundf(destination.position.y)), destination.size)
		draw_texture_rect_region(texture, aligned, source)


func _profile_tile(profile_id: StringName, texture: Texture2D, destination_position: Vector2) -> void:
	if not texture or not profiles or not profiles.has(profile_id):
		push_error("Missing approved Mansion visual profile: %s" % profile_id)
		return
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	_tile(texture, source, Rect2(destination_position, size))


func _draw() -> void:
	# Do not leave a copy of every room in the draw list.  Apart from reducing
	# overdraw, this keeps foreground occlusion local to the active room.
	if not active_area.begins_with("mansion"):
		return
	var mansion_offset := Vector2(MANSION_ORIGIN * TILE)
	match active_area:
		&"mansion_foyer":
			_tile(haunted_storage, Rect2(296, 672, 88, 96), Rect2(mansion_offset + Vector2(6.6, 2.65) * TILE, Vector2(66, 72)))
		&"mansion_archive":
			var room_offset := mansion_offset + Vector2(MANSION_ARCHIVE_OFFSET * TILE)
			_profile_tile(&"mansion_archive_shelving", haunted_storage, room_offset)
			_tile(haunted_storage, Rect2(190, 0, 190, 176), Rect2(room_offset + Vector2(4 * TILE, 0), Vector2(190, 176)))
			_tile(haunted_storage, Rect2(296, 672, 88, 96), Rect2(room_offset + Vector2(0.05, 2.65) * TILE, Vector2(66, 72)))
			_profile_tile(&"mansion_archive_cabinet", haunted_interior, room_offset + Vector2(2.35, 1.55) * TILE)
		&"mansion_gallery":
			var room_offset := mansion_offset + Vector2(MANSION_GALLERY_OFFSET * TILE)
			_tile(haunted_storage, Rect2(194, 5, 91, 137), Rect2(room_offset + Vector2(18, 14), Vector2(91, 137)))
			_tile(haunted_storage, Rect2(291, 5, 91, 137), Rect2(room_offset + Vector2(275, 14), Vector2(91, 137)))
			_tile(haunted_storage, Rect2(681, 386, 37, 43), Rect2(room_offset + Vector2(126, 44), Vector2(37, 43)))
			_tile(haunted_storage, Rect2(721, 386, 46, 43), Rect2(room_offset + Vector2(210, 44), Vector2(46, 43)))
			_tile(haunted_storage, Rect2(678, 440, 36, 41), Rect2(room_offset + Vector2(128, 99), Vector2(36, 41)))
			_tile(haunted_storage, Rect2(726, 431, 37, 50), Rect2(room_offset + Vector2(214, 93), Vector2(37, 50)))
			_tile(haunted_interior, Rect2(423, 679, 210, 82), Rect2(room_offset + Vector2(87, 221), Vector2(210, 82)))
		&"mansion_nursery":
			var room_offset := mansion_offset + Vector2(MANSION_NURSERY_OFFSET * TILE)
			_tile(haunted_storage, Rect2(583, 69, 46, 66), Rect2(room_offset + Vector2(5.85, 2.35) * TILE, Vector2(46, 66)))
			_profile_tile(&"mansion_nursery_bed", haunted_bedroom, room_offset + Vector2(1.1, 2.15) * TILE)
		&"mansion_ballroom":
			var room_offset := mansion_offset + Vector2(MANSION_BALLROOM_OFFSET * TILE)
			_tile(haunted_interior, Rect2(575, 9, 191, 88), Rect2(room_offset + Vector2(97, 22), Vector2(191, 88)))
			_tile(haunted_interior, Rect2(490, 12, 76, 77), Rect2(room_offset + Vector2(17, 40), Vector2(76, 77)))
			_tile(haunted_interior, Rect2(490, 12, 76, 77), Rect2(room_offset + Vector2(291, 40), Vector2(76, 77)))
