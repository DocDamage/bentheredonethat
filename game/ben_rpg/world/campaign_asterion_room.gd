class_name CampaignAsterionRoom
extends Node2D

## Shared bounded composition for the first Asterion migration slice. Each
## manifest record supplies the room identity, footprint, and state-owned
## features; the renderer only owns its station visual language.

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const ROOM_REGISTRY := preload("res://ben_rpg/world/campaign_room_registry.gd")

var _room_id: StringName = &""
var _dimensions := Vector2i.ZERO
var _profiles
var _primary: Texture2D
var _secondary: Texture2D


func configure(room_id: StringName, definition: Dictionary) -> void:
	_room_id = room_id
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * 48)
	FEATURE_INSTALLER.install(self, room_id, definition)
	queue_redraw()


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	var visual_ids: Array = ROOM_REGISTRY.room(_room_id).get("visualProfileIds", [])
	if not visual_ids.is_empty():
		_primary = _profiles.texture(StringName(visual_ids[0]))
	if visual_ids.size() > 1:
		_secondary = _profiles.texture(StringName(visual_ids[1]))
	queue_redraw()


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	var breathable := bool(CampaignState.story_flags.get(&"asterion_station_restored", false))
	var floor_color := Color("1f4052") if breathable else Color("402631")
	var light_color := Color("67d8ff") if breathable else Color("ff8b62")
	draw_rect(bounds, Color("0b141d"), true)
	draw_rect(Rect2(Vector2(48, 48), Vector2((_dimensions.x - 2) * 48, (_dimensions.y - 2) * 48)), floor_color, true)
	for x in range(2, _dimensions.x - 1, 3):
		draw_line(Vector2(x * 48, 48), Vector2(x * 48, (_dimensions.y - 1) * 48), Color("142733"), 2.0)
	for y in range(2, _dimensions.y - 1, 3):
		draw_line(Vector2(48, y * 48), Vector2((_dimensions.x - 1) * 48, y * 48), Color("142733"), 2.0)
	_draw_profile(_primary, Vector2(3 * 48, 2 * 48), Vector2(160, 96))
	_draw_profile(_secondary, Vector2((_dimensions.x - 7) * 48, 2 * 48), Vector2(160, 96))
	if _room_id == &"AS-01":
		draw_circle(Vector2((_dimensions.x - 4) * 48, 4 * 48), 58.0, Color("101f38"))
		draw_circle(Vector2((_dimensions.x - 4) * 48, 4 * 48), 34.0, Color("4d7bc4"))
	elif _room_id == &"AS-02":
		draw_rect(Rect2(Vector2(6 * 48, 7 * 48), Vector2(8 * 48, 48)), Color("8b693b"), true)
	elif _room_id == &"AS-03":
		for x in range(5, _dimensions.x - 4, 4):
			draw_rect(Rect2(Vector2(x * 48, 7 * 48), Vector2(2 * 48, 48)), Color("4b6976"), true)
	draw_rect(bounds, light_color, false, 2.0)


func _draw_profile(texture: Texture2D, draw_position: Vector2, draw_size: Vector2) -> void:
	if texture:
		draw_texture_rect(texture, Rect2(draw_position, draw_size), false)
