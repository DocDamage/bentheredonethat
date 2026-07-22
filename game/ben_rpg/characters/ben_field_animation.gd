@tool
class_name BenFieldAnimation
extends GamepieceAnimation

const FRAME_RATE := 10.0
const RUN_FRAME_COUNT := 6
const ASSET_ROOT := "res://game_assets/characters/Main Character/Ben_Franklin"
const RAPTOR_ROOT := "res://game_assets/characters/Velociraptor/Tiny_Velociraptor"
const DIRECTION_NAMES := {
	Directions.Points.NORTH: "north",
	Directions.Points.EAST: "east",
	Directions.Points.SOUTH: "south",
	Directions.Points.WEST: "west",
}
const RAPTOR_DIRECTION_NAMES := {
	# This pack has diagonal north run cycles rather than a straight-north run.
	Directions.Points.NORTH: "north-east",
	Directions.Points.EAST: "east",
	Directions.Points.SOUTH: "south",
	Directions.Points.WEST: "west",
}

var _sequence := "idle"
var _elapsed := 0.0
var _frame := 0
var _raptor_elapsed := 0.0
var _raptor_frame := 0
var _texture_cache: Dictionary = {}
@onready var _sprite: Sprite2D = $Anchor/Sprite
@onready var _raptor_sprite: Sprite2D = $Anchor/Raptor


func _ready() -> void:
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Campaign maps use a native 48px grid. Ben's 88px source canvas has a
	# roughly 40px opaque figure, so this keeps him near one cell in height.
	_sprite.scale = Vector2(1.25, 1.25)
	_sprite.position = Vector2(0, -4)
	_raptor_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# The source canvas is 60px, but the opaque raptor is about 30px tall.
	# Render it at roughly half Ben's height so it reads as a small dog-sized
	# companion instead of a second full-sized party member.
	_raptor_sprite.scale = Vector2(0.85, 0.85)
	_raptor_sprite.position = Vector2(-44, 8)
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
	var follow_offsets := {
		Directions.Points.NORTH: Vector2(30, 34),
		Directions.Points.EAST: Vector2(-44, 8),
		Directions.Points.SOUTH: Vector2(-44, 8),
		Directions.Points.WEST: Vector2(44, 8),
	}
	var target: Vector2 = follow_offsets.get(direction, Vector2(-44, 8))
	if _sequence != "run":
		# Interceptor-like field presence: the raptor quietly prowls around its
		# trailing cell rather than freezing as part of Ben's own sprite.
		var idle_time := Time.get_ticks_msec() * 0.001
		target += Vector2(sin(idle_time * 0.85) * 4.0, cos(idle_time * 0.62) * 2.0)
	_raptor_sprite.position = _raptor_sprite.position.lerp(target, minf(1.0, delta * 6.5))
	# Direction changes move the trailing target from one side of Ben to another.
	# Keep the interpolated path outside Ben's silhouette instead of cutting
	# directly through his feet while the pet circles into position.
	var separation := _raptor_sprite.position - _sprite.position
	if separation.length() < 42.0:
		var safe_direction := separation.normalized() if not separation.is_zero_approx() else (target - _sprite.position).normalized()
		_raptor_sprite.position = _sprite.position + safe_direction * 42.0
	_raptor_sprite.z_index = 1 if _raptor_sprite.position.y >= 0.0 else -1
	_raptor_elapsed += delta
	var raptor_rate := 10.0 if _sequence == "run" else 5.0
	var next_raptor_frame := int(_raptor_elapsed * raptor_rate) % RUN_FRAME_COUNT
	if next_raptor_frame != _raptor_frame:
		_raptor_frame = next_raptor_frame
		_update_raptor_texture()
	if _sequence == "run":
		_elapsed += delta
		var next_frame := int(_elapsed * FRAME_RATE) % RUN_FRAME_COUNT
		if next_frame != _frame:
			_frame = next_frame
			_update_texture()


func _update_texture() -> void:
	if not is_instance_valid(_sprite):
		return
	var facing: String = DIRECTION_NAMES.get(direction, "south")
	var path := "%s/rotations/%s.png" % [ASSET_ROOT, facing]
	if _sequence == "run":
		path = "%s/animations/Running/%s/frame_%03d.png" % [ASSET_ROOT, facing, _frame]
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	_sprite.texture = _texture_cache[path]
	_update_raptor_texture()


func _update_raptor_texture() -> void:
	if not is_instance_valid(_raptor_sprite):
		return
	var raptor_facing: String = RAPTOR_DIRECTION_NAMES.get(direction, "south")
	if _sequence != "run":
		# Face into the idle patrol so it reads as an active companion, not a
		# second copy of Ben's facing direction.
		raptor_facing = "east" if sin(Time.get_ticks_msec() * 0.00085) >= 0.0 else "west"
	var raptor_path := "%s/animations/Running/%s/frame_%03d.png" % [RAPTOR_ROOT, raptor_facing, _raptor_frame]
	if not _texture_cache.has(raptor_path):
		_texture_cache[raptor_path] = load(raptor_path)
	_raptor_sprite.texture = _texture_cache[raptor_path]
