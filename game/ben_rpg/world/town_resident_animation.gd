extends GamepieceAnimation

const DIRECTION_NAMES := {
	Directions.Points.NORTH: "north",
	Directions.Points.EAST: "east",
	Directions.Points.SOUTH: "south",
	Directions.Points.WEST: "west",
}
const BADGE_REVEAL_DISTANCE := 128.0

var asset_root := ""
var resident_name := "Resident"
var activity := "AT HOME"
var activity_pose: StringName = &"rest"
var _sequence := "idle"
var _elapsed := 0.0
var _texture_cache: Dictionary = {}
@onready var _sprite: Sprite2D = $Anchor/Sprite
@onready var _badge: Label = $Anchor/ActivityBadge


func _ready() -> void:
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.scale = Vector2(1.55, 1.55)
	_sprite.position = Vector2(0, -6)
	_refresh_badge()
	_update_texture()


func configure(display_name: String, source_root: String) -> void:
	resident_name = display_name
	asset_root = source_root
	_refresh_badge()
	_update_texture()


func play(value: String) -> void:
	_sequence = value
	_elapsed = 0.0
	_update_texture()


func set_direction(value: Directions.Points) -> void:
	direction = value
	_update_texture()


func set_activity(value: String, pose: StringName = &"rest") -> void:
	activity = value
	activity_pose = pose
	_refresh_badge()


func _process(delta: float) -> void:
	if not is_instance_valid(_sprite):
		return
	# Activity plaques are useful when approaching a resident, but become map
	# clutter when every worker broadcasts across the whole town.
	_badge.visible = Player.gamepiece != null and global_position.distance_to(Player.gamepiece.global_position) <= BADGE_REVEAL_DISTANCE
	_elapsed += delta
	if _sequence == "run":
		_sprite.position.y = -6.0 + sin(_elapsed * 13.0) * 1.5
		_sprite.rotation = sin(_elapsed * 6.5) * 0.025
	else:
		match activity_pose:
			&"craft":
				_sprite.position = Vector2(sin(_elapsed * 4.5) * 0.7, -6.0 + abs(sin(_elapsed * 4.5)) * 0.9)
				_sprite.rotation = sin(_elapsed * 4.5) * 0.035
			&"serve":
				_sprite.position = Vector2(sin(_elapsed * 2.8) * 1.0, -6.0)
				_sprite.rotation = sin(_elapsed * 2.8) * 0.02
			&"inspect":
				_sprite.position = Vector2(0, -6.0 + sin(_elapsed * 3.2) * 0.5)
				_sprite.rotation = sin(_elapsed * 1.6) * 0.045
			&"social":
				_sprite.position = Vector2(0, -6.0 + abs(sin(_elapsed * 3.8)) * 1.1)
				_sprite.rotation = sin(_elapsed * 3.8) * 0.025
			_:
				_sprite.position = Vector2(0, -6.0 + sin(_elapsed * 2.2) * 0.35)
				_sprite.rotation = 0.0


func _update_texture() -> void:
	if not is_instance_valid(_sprite) or asset_root.is_empty():
		return
	var facing: String = DIRECTION_NAMES.get(direction, "south")
	var path := "%s/rotations/%s.png" % [asset_root, facing]
	if not ResourceLoader.exists(path):
		return
	if not _texture_cache.has(path):
		_texture_cache[path] = load(path)
	_sprite.texture = _texture_cache[path]


func _refresh_badge() -> void:
	if not is_instance_valid(_badge):
		return
	var first_name := resident_name.get_slice(" ", 0).capitalize()
	_badge.text = "%s • %s" % [first_name, _compact_activity(activity)]
	_badge.tooltip_text = "%s — %s" % [resident_name, activity.capitalize()]


func _compact_activity(value: String) -> String:
	var compact := value
	if compact.begins_with("WALKING • "):
		return "On the way"
	var replacements := {
		"GRINDING COFFEE": "Grinding coffee",
		"SERVING THE COUNTER": "Serving",
		"CHECKING THE PANTRY": "Checking pantry",
		"SHELVING FIELD REPORTS": "Shelving reports",
		"CATALOGING MONSTERS": "Cataloging",
		"DECODING A FAULT-LINE MAP": "Decoding a map",
		"WATERING THE EAST ROW": "Watering crops",
		"TURNING COMPOST": "Turning compost",
		"HARVESTING TOWN PRODUCE": "Harvesting",
		"STERILIZING INSTRUMENTS": "Sterilizing",
		"PREPARING TONICS": "Preparing tonics",
		"CHECKING RECOVERY COTS": "Checking cots",
		"LUNCH AT THE PLAZA": "Lunch break",
		"EVENING IN THE PLAZA": "At the plaza",
		"RUNNING AN ERRAND": "On an errand",
		"WAITING • ROUTE CLOSED": "Route blocked",
		"WAITING • YIELDING": "Letting someone pass",
	}
	return String(replacements.get(compact, compact.capitalize()))
