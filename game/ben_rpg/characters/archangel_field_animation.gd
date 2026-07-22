@tool
class_name ArchangelFieldAnimation
extends GamepieceAnimation

const FRAME_RATE := 8.0
const FRAME_COUNT := 11
const ASSET_ROOT := "res://game_assets/characters/Recruitable Characters/Archangel Commander — Legendary Celestial Warrior Hero"

var _elapsed := 0.0
var _frame := 0
var _texture_cache: Dictionary = {}
@onready var _sprite: Sprite2D = $Anchor/Sprite


func _ready() -> void:
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.position = Vector2(0, -15)
	_sprite.scale = Vector2(0.9, 0.9)
	_update_texture()


func play(_value: String) -> void:
	_elapsed = 0.0
	_frame = 0
	_update_texture()


func set_direction(value: Directions.Points) -> void:
	direction = value
	_update_texture()


func _process(delta: float) -> void:
	_elapsed += delta
	var next_frame := int(_elapsed * FRAME_RATE) % FRAME_COUNT
	if next_frame != _frame:
		_frame = next_frame
		_update_texture()


func _update_texture() -> void:
	if not is_instance_valid(_sprite):
		return
	var facing := "south"
	if direction == Directions.Points.WEST:
		facing = "west"
	elif direction == Directions.Points.EAST:
		facing = "east"
	var path := "%s/animations/Hover_Idle-b43681f6/%s/frame_%03d.png" % [ASSET_ROOT, facing, _frame]
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	_sprite.texture = _texture_cache[path]
