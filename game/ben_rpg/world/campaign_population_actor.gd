class_name CampaignPopulationActor
extends Node2D

## A room-owned SakPix resident with all eight authored field rotations.

var _sprite: Sprite2D
var _regions: Dictionary = {}
var _foot_anchors: Dictionary = {}
var facing: StringName = &"south"


func configure(identity_id: StringName, profile: Dictionary, texture: Texture2D, room_id: StringName, anchor: StringName, cell: Vector2i) -> bool:
	if identity_id == &"" or profile.is_empty() or not texture:
		return false
	_regions = (profile.get("directions", {}) as Dictionary).duplicate(true)
	if _regions.size() != 8:
		return false
	name = "PopulationActor_%s" % _safe_name(identity_id)
	position = Vector2(cell) * 48.0
	set_meta(&"identity_id", identity_id)
	set_meta(&"runtime_profile_id", StringName(profile.get("id", &"")))
	set_meta(&"room_id", room_id)
	set_meta(&"anchor", anchor)
	set_meta(&"cell", cell)
	set_meta(&"available_directions", _regions.keys())
	_sprite = Sprite2D.new()
	_sprite.name = "ProfileSprite"
	_sprite.texture = texture
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.centered = false
	_sprite.region_enabled = true
	add_child(_sprite)
	for raw_direction in _regions:
		var direction := StringName(raw_direction)
		var values: Array = _regions[raw_direction]
		_foot_anchors[direction] = Vector2(float(values[2]) * 0.5, float(values[3] - 1))
	face(StringName(profile.get("defaultDirection", &"south")))
	return true


func face(direction: StringName) -> bool:
	if not _regions.has(String(direction)) and not _regions.has(direction):
		return false
	var values: Array = _regions.get(String(direction), _regions.get(direction, []))
	if values.size() != 4:
		return false
	facing = direction
	_sprite.region_rect = Rect2(values[0], values[1], values[2], values[3])
	_sprite.position = -(_foot_anchors.get(direction, Vector2.ZERO) as Vector2)
	set_meta(&"facing", facing)
	return true


static func _safe_name(identity_id: StringName) -> String:
	var result := String(identity_id)
	for character in [":", "/", "\\", " ", "."]:
		result = result.replace(character, "_")
	return result
