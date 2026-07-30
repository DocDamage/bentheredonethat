@tool
class_name CavemanFieldAnimation
extends GamepieceAnimation

const FRAME_RATE := 9.0
const RUN_FRAME_COUNT := 6
const ASSET_ROOT := "res://game_assets/characters/Recruitable Characters/caveman/Caveman"
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
	_sprite.position = Vector2(0, -8)
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
	if _sequence != "run":
		return
	_elapsed += delta
	var next_frame := int(_elapsed * FRAME_RATE) % RUN_FRAME_COUNT
	if next_frame != _frame:
		_frame = next_frame
		_update_texture()


func _update_texture() -> void:
	if not is_instance_valid(_sprite):
		return
	var facing: String = DIRECTION_NAMES.get(direction, "south")
	var path := "%s/animations/Running/%s/frame_%03d.png" % [ASSET_ROOT, facing, _frame] if _sequence == "run" else "%s/rotations/%s.png" % [ASSET_ROOT, facing]
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	_sprite.texture = _texture_cache[path]
