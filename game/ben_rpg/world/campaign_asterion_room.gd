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
var _primary_id: StringName = &""
var _secondary_id: StringName = &""


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
		_primary_id = StringName(visual_ids[0])
	if visual_ids.size() > 1:
		_secondary_id = StringName(visual_ids[1])
	queue_redraw()


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	var breathable := bool(CampaignState.story_flags.get(&"asterion_station_restored", false))
	var floor_color := Color("1f4052") if breathable else Color("402631")
	var light_color := Color("67d8ff") if breathable else Color("ff8b62")
	draw_rect(Rect2(Vector2(-8 * 48, -8 * 48), Vector2((_dimensions.x + 16) * 48, (_dimensions.y + 16) * 48)), Color("050a10"), true)
	draw_rect(bounds, Color("0b141d"), true)
	for y in range(1, _dimensions.y - 1):
		for x in range(1, _dimensions.x - 1):
			var tile_id := StringName("asterion_station_wall_%d_%d" % [x % 2, y % 2]) if y < 4 else StringName("asterion_station_floor_%d_%d" % [x % 2, y % 2])
			_draw_profile_at(tile_id, Vector2(x, y) * 48.0)
	# Structural ribs, a luminous center lane, and recessed side bays make the
	# station read at gameplay scale without covering its validated walk space.
	for x in range(2, _dimensions.x - 1, 4):
		draw_rect(Rect2(Vector2(x * 48 - 5, 48), Vector2(10, (_dimensions.y - 2) * 48)), Color("101923"), true)
		draw_line(Vector2(x * 48, 4 * 48), Vector2(x * 48, (_dimensions.y - 1) * 48), Color(light_color, 0.35), 2.0)
	var lane := Rect2(Vector2(3 * 48, 4 * 48), Vector2((_dimensions.x - 6) * 48, 2 * 48))
	draw_rect(lane, Color(floor_color, 0.72), true)
	draw_rect(lane, Color(light_color, 0.62), false, 4.0)
	for marker_x in range(4 * 48, int(bounds.size.x - 4 * 48), 3 * 48):
		draw_rect(Rect2(Vector2(marker_x, lane.position.y + lane.size.y * 0.5 - 3), Vector2(64, 6)), Color(light_color, 0.7), true)
	_draw_profile_at(_primary_id, Vector2(3 * 48, 2.1 * 48))
	if _secondary_id != &"":
		var secondary_size: Vector2 = _profiles.world_draw_size(_secondary_id)
		_draw_profile_at(_secondary_id, Vector2((_dimensions.x - 3) * 48 - secondary_size.x, 2.1 * 48))
	if _room_id == &"AS-01":
		draw_circle(Vector2((_dimensions.x - 4) * 48, 4 * 48), 58.0, Color("101f38"))
		draw_circle(Vector2((_dimensions.x - 4) * 48, 4 * 48), 34.0, Color("4d7bc4"))
	elif _room_id == &"AS-02":
		draw_rect(Rect2(Vector2(6 * 48, 7 * 48), Vector2(8 * 48, 48)), Color("8b693b"), true)
	elif _room_id == &"AS-03":
		for x in range(5, _dimensions.x - 4, 4):
			draw_rect(Rect2(Vector2(x * 48, 7 * 48), Vector2(2 * 48, 48)), Color("4b6976"), true)
	draw_rect(bounds, light_color, false, 2.0)


func _draw_profile_at(profile_id: StringName, draw_position: Vector2) -> void:
	if profile_id == &"" or not _profiles or not _profiles.has(profile_id):
		return
	var texture: Texture2D = _profiles.texture(profile_id)
	if texture:
		draw_texture_rect_region(texture, Rect2(draw_position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
