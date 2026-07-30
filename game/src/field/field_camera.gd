## Specialized camera that is constrained to the [Gameboard]'s boundaries.
##
## The camera's limits are set dynamically according to the viewport's dimensions. Normally, the
## camera is limited to the [member Gameboard.boundaries].
## [br][br]In some cases the gameboard is smaller than the viewport, in which case it will be
## snapped to the gameboard centre along the constrained axis/axes.
class_name FieldCamera
extends Camera2D

const FIELD_SCALE := preload("res://ben_rpg/world/campaign_field_scale.gd")

@export var gameboard_properties: GameboardProperties:
	set(value):
		_on_viewport_resized()


@export var gamepiece: Gamepiece:
	set(value):
		if gamepiece:
			gamepiece.animation_transform.remote_path = ""
		
		gamepiece = value
		if gamepiece:
			gamepiece.animation_transform.remote_path \
				= gamepiece.animation_transform.get_path_to(self)


func _ready() -> void:
	get_viewport().size_changed.connect(_on_viewport_resized)
	_on_viewport_resized()


func _process(_delta: float) -> void:
	# The field uses nearest-neighbor pixel art. Camera follow can land between
	# world pixels while a gamepiece is moving, which creates visible shimmer even
	# when every sprite itself is placed correctly. Snap only the final camera
	# position so movement retains its normal cadence without subpixel sampling.
	position = FIELD_SCALE.snap_to_world_pixels(position)


func reset_position() -> void:
	if gamepiece:
		position = gamepiece.position * scale
		
	reset_smoothing()


func _on_viewport_resized() -> void:
	if not gameboard_properties:
		return
	
	var frame := FIELD_SCALE.camera_frame(
		gameboard_properties.extents,
		gameboard_properties.cell_size,
		get_viewport_rect().size,
		global_scale,
		position,
	)
	if frame.is_empty():
		return
	position = frame.get("position", position)
	var limits: Rect2i = frame.get("limits", Rect2i())
	limit_left = limits.position.x
	limit_top = limits.position.y
	limit_right = limits.end.x
	limit_bottom = limits.end.y
