@tool
class_name AstronautFieldAnimation
extends GamepieceAnimation

const FRAME_RATE := 9.0
const RUN_FRAME_COUNT := 6
const IDLE_FRAME_COUNT := 4
const ASSET_ROOT := "res://game_assets/characters/Recruitable Characters/astronaut/Astronaut"
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
	_sprite.position = Vector2(0, -7)
	# The painted astronaut occupies roughly 36px of the supplied 64px frame.
	# Scale the actor island—not the texture crop—to match Ben's field height.
	_sprite.scale = Vector2(1.7, 1.7)
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
	_elapsed += delta
	var count := RUN_FRAME_COUNT if _sequence == "run" else IDLE_FRAME_COUNT
	var next_frame := int(_elapsed * FRAME_RATE) % count
	if next_frame != _frame:
		_frame = next_frame
		_update_texture()


func _update_texture() -> void:
	if not is_instance_valid(_sprite):
		return
	var facing: String = DIRECTION_NAMES.get(direction, "south")
	var animation := "Running" if _sequence == "run" else "Breathing_Idle"
	var path := "%s/animations/%s/%s/frame_%03d.png" % [ASSET_ROOT, animation, facing, _frame]
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	_sprite.texture = _texture_cache[path]
