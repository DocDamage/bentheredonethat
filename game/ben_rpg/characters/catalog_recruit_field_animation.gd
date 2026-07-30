@tool
class_name CatalogRecruitFieldAnimation
extends GamepieceAnimation

@export_dir var asset_root := ""
@export_enum("Directional", "Flat") var asset_layout := "Directional"
@export var run_folder := "Running"
@export var run_frame_count := 6
@export var flat_idle_folder := "Idle"
@export var flat_idle_prefix := "idle_"
@export var flat_run_folder := "Walk"
@export var flat_run_prefix := "walk_"
@export var flat_frame_count := 4
@export var frame_rate := 8.0
@export var use_diagonal_walk := false
@export var sprite_scale := Vector2.ONE
@export var sprite_offset := Vector2(0, -8)

const DIRECTION_NAMES := {
	Directions.Points.NORTH: "north",
	Directions.Points.EAST: "east",
	Directions.Points.SOUTH: "south",
	Directions.Points.WEST: "west",
}

var _sequence := "idle"
var _elapsed := 0.0
var _frame := 0
var _texture_cache: Dictionary = {}
@onready var _sprite: Sprite2D = $Anchor/Sprite


func _ready() -> void:
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = sprite_scale
	_sprite.position = sprite_offset
	_update_texture()


func play(value: String) -> void:
	_sequence = value
	_elapsed = 0.0
	_frame = 0
	_update_texture()


func set_direction(value: Directions.Points) -> void:
	direction = value
	_update_texture()


func _process(delta: float) -> void:
	var frame_count := flat_frame_count if asset_layout == "Flat" else run_frame_count
	if _sequence != "run" and asset_layout != "Flat":
		return
	_elapsed += delta
	var next_frame := int(_elapsed * frame_rate) % maxi(1, frame_count)
	if next_frame != _frame:
		_frame = next_frame
		_update_texture()


func _update_texture() -> void:
	if not is_instance_valid(_sprite) or asset_root.is_empty():
		return
	var path := ""
	_sprite.flip_h = false
	if asset_layout == "Flat":
		var folder := flat_run_folder if _sequence == "run" else flat_idle_folder
		var prefix := flat_run_prefix if _sequence == "run" else flat_idle_prefix
		path = "%s/%s/%s%02d.png" % [asset_root, folder, prefix, _frame + 1]
		_sprite.flip_h = direction == Directions.Points.EAST
	else:
		var facing: String = DIRECTION_NAMES.get(direction, "south")
		if _sequence == "run":
			if use_diagonal_walk:
				facing = _diagonal_walk_direction(direction)
			path = "%s/animations/%s/%s/frame_%03d.png" % [asset_root, run_folder, facing, _frame]
		else:
			path = "%s/rotations/%s.png" % [asset_root, facing]
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	_sprite.texture = _texture_cache[path]


func _diagonal_walk_direction(value: Directions.Points) -> String:
	match value:
		Directions.Points.NORTH:
			return "north-west"
		Directions.Points.SOUTH:
			return "south-west"
		Directions.Points.EAST:
			return "east"
		_:
			return "west"
