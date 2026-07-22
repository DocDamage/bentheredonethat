@tool
class_name CrimsonOniFieldAnimation
extends GamepieceAnimation

const FRAME_RATE := 8.0
const IDLE_FRAME_COUNT := 4
const RUN_FRAME_COUNT := 8
const ASSET_ROOT := "res://game_assets/characters/Recruitable Characters/crimson oni samurai"
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
	# The 188px source canvas contains a roughly 94px figure. This scale keeps
	# the Oni aligned with the campaign's 48px field actors.
	_sprite.scale = Vector2(0.56, 0.56)
	_sprite.position = Vector2(0, -10)
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
	var frame_count := RUN_FRAME_COUNT if _sequence == "run" else IDLE_FRAME_COUNT
	var next_frame := int(_elapsed * FRAME_RATE) % frame_count
	if next_frame != _frame:
		_frame = next_frame
		_update_texture()


func _update_texture() -> void:
	if not is_instance_valid(_sprite):
		return
	var facing: String = DIRECTION_NAMES.get(direction, "south")
	var path := "%s/rotations/%s.png" % [ASSET_ROOT, facing]
	if _sequence == "run":
		var horizontal := "west" if direction in [Directions.Points.WEST, Directions.Points.NORTH] else "east"
		path = "%s/animations/Running-94ed778f/%s/frame_%03d.png" % [ASSET_ROOT, horizontal, _frame]
	else:
		var idle_facing := facing if facing in ["east", "south", "west"] else "south"
		path = "%s/animations/Breathing_Idle-caed6390/%s/frame_%03d.png" % [ASSET_ROOT, idle_facing, _frame]
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	_sprite.texture = _texture_cache[path]
