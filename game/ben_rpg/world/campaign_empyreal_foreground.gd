class_name CampaignEmpyrealForeground
extends Node2D

## Empyreal's columns, gates, trees, and statuary occupy the foreground above
## the shared marble ground. This gives the floating terraces actual occlusion
## without turning their collision bases into detached renderer-only objects.

const TILE := 48
const EMPYREAL_ORIGIN := Vector2i(216, 32)
const SLICES := [
	"pediment_door", "tribunal_gate", "winged_statue", "horse_statue",
	"griffin_statue", "justice_statue", "music_statue", "silver_olive_tree",
	"golden_olive_tree", "appeal_fountain", "ordinance_book", "reliquary_portal",
	"gravity_crystal", "tribunal_orrery", "plain_column", "blue_column",
	"flower_offering", "fruit_offering", "crystal_altar", "lotus_altar",
]

var active_area: StringName = &"lab"
var slices: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	for slice_name in SLICES:
		slices[slice_name] = load("res://game_assets/Tilesets/Ancient Greek Mythology/Sliced/%s.png" % slice_name)
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _prop(slice_name: String, destination_position: Vector2, flip_h := false) -> void:
	var texture := slices.get(slice_name) as Texture2D
	if not texture:
		return
	var size := texture.get_size()
	var destination := Rect2(Vector2(roundf(destination_position.x), roundf(destination_position.y)), size)
	if flip_h:
		destination.position.x += size.x
		destination.size.x = -size.x
	draw_texture_rect_region(texture, destination, Rect2(Vector2.ZERO, size))


func _draw() -> void:
	if not active_area.begins_with("empyreal"):
		return
	var offset := Vector2(EMPYREAL_ORIGIN * TILE)
	match active_area:
		&"empyreal_landing":
			_prop("pediment_door", offset + Vector2(132, 4))
			_prop("winged_statue", offset + Vector2(22, 38))
			_prop("winged_statue", offset + Vector2(268, 38), true)
		&"empyreal_garden":
			var room_offset := offset + Vector2(10 * TILE, 0)
			_prop("silver_olive_tree", room_offset + Vector2(5, 31))
			_prop("golden_olive_tree", room_offset + Vector2(278, 31))
			_prop("appeal_fountain", room_offset + Vector2(141, 34))
			_prop("flower_offering", room_offset + Vector2(76, 190))
			_prop("fruit_offering", room_offset + Vector2(247, 190))
		&"empyreal_forum":
			var room_offset := offset + Vector2(20 * TILE, 0)
			_prop("plain_column", room_offset + Vector2(34, 11))
			_prop("blue_column", room_offset + Vector2(302, 11))
			_prop("ordinance_book", room_offset + Vector2(138, 65))
			_prop("horse_statue", room_offset + Vector2(58, 84))
			_prop("griffin_statue", room_offset + Vector2(267, 82))
		&"empyreal_aerie":
			var room_offset := offset + Vector2(10 * TILE, 10 * TILE)
			_prop("reliquary_portal", room_offset + Vector2(137, 11))
			_prop("crystal_altar", room_offset + Vector2(41, 101))
			_prop("lotus_altar", room_offset + Vector2(267, 101))
			_prop("gravity_crystal", room_offset + Vector2(167, 178))
		&"empyreal_tribunal":
			var room_offset := offset + Vector2(20 * TILE, 10 * TILE)
			_prop("tribunal_gate", room_offset + Vector2(111, 4))
			_prop("justice_statue", room_offset + Vector2(40, 38))
			_prop("music_statue", room_offset + Vector2(304, 38))
			_prop("tribunal_orrery", room_offset + Vector2(32, 187))
