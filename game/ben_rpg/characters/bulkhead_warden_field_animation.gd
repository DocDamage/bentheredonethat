@tool
class_name BulkheadWardenFieldAnimation
extends GamepieceAnimation

const FRAME_RATE := 8.0
const ASSET_ROOT := "res://game_assets/characters/Topdown Monsters Part 1/Sliced/Bulkhead Warden"
const SEQUENCES := {
	"idle": {"folder": "00_idle", "frames": 6},
	"run": {"folder": "01_walk", "frames": 8},
}

var _sequence := "idle"
var _elapsed := 0.0
var _frame := 0
var _texture_cache: Dictionary = {}
@onready var _sprite: Sprite2D = $Anchor/Sprite


func _ready() -> void:
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# The source frame is 80x80, but the figure itself is about 50px tall.
	# This keeps the construct imposing without making it building-sized.
	_sprite.scale = Vector2(0.8, 0.8)
	_sprite.position = Vector2(0, -14)
	_update_texture()


func play(value: String) -> void:
	_sequence = "run" if value == "run" else "idle"
	_elapsed = 0.0
	_frame = 0
	_update_texture()


func set_direction(value: Directions.Points) -> void:
	direction = value
	_sprite.flip_h = direction == Directions.Points.EAST


func _process(delta: float) -> void:
	_elapsed += delta
	var frame_count := int(SEQUENCES[_sequence]["frames"])
	var next_frame := int(_elapsed * FRAME_RATE) % frame_count
	if next_frame != _frame:
		_frame = next_frame
		_update_texture()


func _update_texture() -> void:
	if not is_instance_valid(_sprite):
		return
	var folder := String(SEQUENCES[_sequence]["folder"])
	var path := "%s/%s/frame_%03d.png" % [ASSET_ROOT, folder, _frame]
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	_sprite.texture = _texture_cache[path]
