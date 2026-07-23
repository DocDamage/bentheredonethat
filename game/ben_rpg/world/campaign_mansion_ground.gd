class_name CampaignMansionGround
extends Node2D

## Owns the Mansion's room shell, wall material, and walkable plank floor.
## Tall furniture, portraits, doors, and chandeliers remain in the foreground.

const TILE := 48
const MANSION_ORIGIN := Vector2i(0, 32)
const ROOM_OFFSETS := {
	&"mansion_foyer": Vector2i.ZERO,
	&"mansion_archive": Vector2i(10, 0),
	&"mansion_gallery": Vector2i(0, 10),
	&"mansion_nursery": Vector2i(10, 10),
	&"mansion_ballroom": Vector2i(20, 5),
}
const INTERIOR_WALL_PROFILES := [
	[&"mansion_interior_wall_0_0", &"mansion_interior_wall_1_0", &"mansion_interior_wall_2_0", &"mansion_interior_wall_3_0"],
	[&"mansion_interior_wall_0_1", &"mansion_interior_wall_1_1", &"mansion_interior_wall_2_1", &"mansion_interior_wall_3_1"],
]
const NURSERY_WALL_PROFILES := [
	[&"mansion_nursery_wall_0_0", &"mansion_nursery_wall_1_0", &"mansion_nursery_wall_2_0", &"mansion_nursery_wall_3_0", &"mansion_nursery_wall_4_0", &"mansion_nursery_wall_5_0", &"mansion_nursery_wall_6_0", &"mansion_nursery_wall_7_0"],
	[&"mansion_nursery_wall_0_1", &"mansion_nursery_wall_1_1", &"mansion_nursery_wall_2_1", &"mansion_nursery_wall_3_1", &"mansion_nursery_wall_4_1", &"mansion_nursery_wall_5_1", &"mansion_nursery_wall_6_1", &"mansion_nursery_wall_7_1"],
]
const PLANK_GRAIN_PROFILES := [
	[&"mansion_plank_grain_0_0", &"mansion_plank_grain_1_0"],
	[&"mansion_plank_grain_0_1", &"mansion_plank_grain_1_1"],
	[&"mansion_plank_grain_0_2", &"mansion_plank_grain_1_2"],
	[&"mansion_plank_grain_0_3", &"mansion_plank_grain_1_3"],
]
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


func _draw() -> void:
	if not ROOM_OFFSETS.has(active_area):
		return
	var room_offset := Vector2(MANSION_ORIGIN * TILE) + Vector2(ROOM_OFFSETS[active_area] * TILE)
	draw_rect(Rect2(room_offset, Vector2(8 * TILE, 8 * TILE)), Color(0.025, 0.021, 0.028), true)
	match active_area:
		&"mansion_foyer": _draw_foyer(room_offset)
		&"mansion_archive": _draw_archive(room_offset)
		&"mansion_nursery": _draw_nursery(room_offset)
		_:
			_draw_room_shell(room_offset, false)
	if active_area == &"mansion_foyer":
		draw_rect(Rect2(room_offset + Vector2(3 * TILE, 7 * TILE), Vector2(2 * TILE, TILE)), Color(0.36, 0.24, 0.16, 0.32), true)


func _draw_foyer(room_offset: Vector2) -> void:
	_draw_room_shell(room_offset, false)
	_profile_tile(&"mansion_foyer_clock", room_offset + Vector2(20, 18))
	_profile_tile(&"mansion_foyer_wall_tableau", room_offset + Vector2(100, 26))
	_profile_tile(&"mansion_archive_cabinet", room_offset + Vector2(216, 74))


func _draw_archive(room_offset: Vector2) -> void:
	for y in range(4):
		for x in range(8):
			var profile_id: StringName = &"mansion_archive_wall_lit_tile" if (x + y) % 3 == 0 else &"mansion_archive_wall_plain_tile"
			_profile_tile(profile_id, room_offset + Vector2(x, y) * TILE)
	_draw_plank_floor(room_offset)


func _draw_nursery(room_offset: Vector2) -> void:
	_draw_room_shell(room_offset, true)
	_profile_tile(&"mansion_nursery_left_wall_panel", room_offset + Vector2(1, 2))
	_profile_tile(&"mansion_nursery_right_wall_panel", room_offset + Vector2(193, 2))


func _draw_room_shell(room_offset: Vector2, nursery_wall: bool) -> void:
	for y in range(4):
		for x in range(8):
			var profile_id: StringName = NURSERY_WALL_PROFILES[y % 2][x % 8] if nursery_wall else INTERIOR_WALL_PROFILES[y % 2][x % 4]
			_profile_tile(profile_id, room_offset + Vector2(x, y) * TILE)
	_draw_plank_floor(room_offset)


func _draw_plank_floor(room_offset: Vector2) -> void:
	var floor_top := 192
	var floor_height := 192
	draw_rect(Rect2(room_offset + Vector2(0, floor_top), Vector2(384, floor_height)), Color("4a342b"), true)
	var board_colors := [Color("543d32"), Color("594034"), Color("4e382f"), Color("5d4437")]
	var board_height := 16
	var board_width := 64
	for row in range(int(floor_height / board_height)):
		var y := floor_top + row * board_height
		var first_x := -32 if row % 2 == 1 else 0
		var board_index := 0
		for board_x in range(first_x, 384, board_width):
			var left := maxi(board_x, 0)
			var right := mini(board_x + board_width, 384)
			if right <= left:
				continue
			var color: Color = board_colors[(row * 2 + board_index) % board_colors.size()]
			draw_rect(Rect2(room_offset + Vector2(left, y), Vector2(right - left, board_height)), color, true)
			for grain_x in range(left, right, 32):
				var grain_row := (row * 3 + board_index) % 4
				var grain_column := (row + board_index + int((grain_x - left) / 32.0)) % 2
				_profile_tile(PLANK_GRAIN_PROFILES[grain_row][grain_column], room_offset + Vector2(grain_x, y))
			draw_line(room_offset + Vector2(left, y), room_offset + Vector2(right, y), Color("2a1c19"), 2.0)
			if left > 0:
				draw_line(room_offset + Vector2(left, y), room_offset + Vector2(left, y + board_height), Color("34231e"), 1.0)
			var grain_x := left + 7 + ((row * 11 + board_index * 17) % 18)
			var grain_end := mini(grain_x + 16 + ((row + board_index) % 15), right - 5)
			if grain_end > grain_x:
				draw_line(room_offset + Vector2(grain_x, y + 5), room_offset + Vector2(grain_end, y + 5), Color("3b2923"), 1.0)
			if (row + board_index) % 2 == 0:
				var second_x := maxi(left + 5, right - 27)
				draw_line(room_offset + Vector2(second_x, y + 11), room_offset + Vector2(right - 7, y + 11), Color("6a4d3f"), 1.0)
			board_index += 1
	# A restrained threshold line joins the wall and floor without reintroducing
	# the repeated torn-board ridge from the sampled showcase fragment.
	draw_rect(Rect2(room_offset + Vector2(0, floor_top - 4), Vector2(384, 6)), Color("2d201c"), true)


func _profile_tile(profile_id: StringName, destination_position: Vector2) -> void:
	if not profiles or not profiles.has(profile_id):
		push_error("Missing approved Mansion ground profile: %s" % profile_id)
		return
	var texture: Texture2D = profiles.texture(profile_id)
	var source: Rect2 = profiles.region(profile_id)
	var size: Vector2 = profiles.world_draw_size(profile_id)
	if texture:
		draw_texture_rect_region(texture, Rect2(destination_position, size), source)
