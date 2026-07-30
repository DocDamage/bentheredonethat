class_name CampaignMoonpetalRoom
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TILE := 48
const PATH_PROFILE := &"moonpetal_processional_path"
const ROOM_PROPS := {
	&"MP-01": [[&"moonpetal_vermilion_gate", Vector2(120, 8)], [&"moonpetal_gate_lantern", Vector2(44, 118)], [&"moonpetal_gate_lantern_right", Vector2(282, 118)], [&"moonpetal_court_tree_canopy", Vector2(-10, 170)], [&"moonpetal_court_tree_canopy_right", Vector2(266, 170)]],
	&"MP-02": [[&"moonpetal_court_temple", Vector2(99, 8)], [&"moonpetal_court_tree_canopy", Vector2(-8, 108)], [&"moonpetal_court_tree_canopy_right", Vector2(264, 108)], [&"moonpetal_framed_garden_island", Vector2(58, 238)], [&"moonpetal_framed_garden_island_right", Vector2(234, 238)]],
	&"MP-03": [[&"moonpetal_court_temple", Vector2(99, 12)], [&"moonpetal_gate_lantern", Vector2(44, 112)], [&"moonpetal_gate_lantern_right", Vector2(282, 112)], [&"moonpetal_framed_garden_island", Vector2(58, 238)], [&"moonpetal_framed_garden_island_right", Vector2(234, 238)]],
	&"MP-04": [[&"moonpetal_court_tree_canopy", Vector2(-10, 16)], [&"moonpetal_court_tree_canopy_right", Vector2(266, 16)], [&"moonpetal_mirror_pond", Vector2(60, 114)], [&"moonpetal_framed_garden_island", Vector2(38, 260)], [&"moonpetal_framed_garden_island_right", Vector2(258, 260)]],
	&"MP-05": [[&"moonpetal_court_temple", Vector2(99, 8)], [&"moonpetal_framed_garden_island", Vector2(46, 176)], [&"moonpetal_framed_garden_island_right", Vector2(246, 176)], [&"moonpetal_gate_lantern", Vector2(42, 276)], [&"moonpetal_gate_lantern_right", Vector2(282, 276)]],
	&"MP-06": [[&"moonpetal_bell_walk_gate_left", Vector2(18, 24)], [&"moonpetal_bell_walk_gate_right", Vector2(226, 24)], [&"moonpetal_court_tree_canopy", Vector2(-8, 176)], [&"moonpetal_court_tree_canopy_right", Vector2(264, 176)], [&"moonpetal_gate_lantern", Vector2(82, 250)], [&"moonpetal_gate_lantern_right", Vector2(244, 250)]],
	&"MP-07": [[&"moonpetal_palace_facade", Vector2(33, 6)], [&"moonpetal_palace_garden_left", Vector2(38, 202)], [&"moonpetal_palace_garden_right", Vector2(252, 202)], [&"moonpetal_mirror_pond", Vector2(60, 270)]],
	&"MP-08": [[&"moonpetal_palace_facade", Vector2(33, 0)], [&"moonpetal_palace_garden_left", Vector2(34, 216)], [&"moonpetal_palace_garden_right", Vector2(256, 216)], [&"moonpetal_gate_lantern", Vector2(78, 278)], [&"moonpetal_gate_lantern_right", Vector2(244, 278)]],
	&"MP-09": [[&"moonpetal_court_temple", Vector2(99, 12)], [&"moonpetal_framed_garden_island", Vector2(42, 176)], [&"moonpetal_framed_garden_island_right", Vector2(250, 176)], [&"moonpetal_gate_lantern", Vector2(78, 278)], [&"moonpetal_gate_lantern_right", Vector2(244, 278)]],
	&"MP-10": [[&"moonpetal_court_tree_canopy", Vector2(-8, 16)], [&"moonpetal_court_tree_canopy_right", Vector2(264, 16)], [&"moonpetal_mirror_pond", Vector2(60, 102)], [&"moonpetal_framed_garden_island", Vector2(32, 254)], [&"moonpetal_framed_garden_island_right", Vector2(260, 254)]],
	&"MP-11": [[&"moonpetal_court_temple", Vector2(99, 8)], [&"moonpetal_bell_walk_gate_left", Vector2(18, 152)], [&"moonpetal_bell_walk_gate_right", Vector2(226, 152)], [&"moonpetal_gate_lantern", Vector2(72, 272)], [&"moonpetal_gate_lantern_right", Vector2(250, 272)]],
	&"MP-12": [[&"moonpetal_court_temple", Vector2(99, 10)], [&"moonpetal_gate_lantern", Vector2(42, 112)], [&"moonpetal_gate_lantern_right", Vector2(282, 112)], [&"moonpetal_framed_garden_island", Vector2(48, 238)], [&"moonpetal_framed_garden_island_right", Vector2(244, 238)]],
	&"MP-13": [[&"moonpetal_bell_walk_gate_left", Vector2(14, 10)], [&"moonpetal_bell_walk_gate_right", Vector2(230, 10)], [&"moonpetal_court_temple", Vector2(99, 136)], [&"moonpetal_gate_lantern", Vector2(52, 272)], [&"moonpetal_gate_lantern_right", Vector2(274, 272)]],
	&"MP-14": [[&"moonpetal_court_tree_canopy", Vector2(-6, 30)], [&"moonpetal_court_tree_canopy_right", Vector2(262, 30)], [&"moonpetal_mirror_pond", Vector2(60, 116)], [&"moonpetal_framed_garden_island", Vector2(38, 262)], [&"moonpetal_framed_garden_island_right", Vector2(258, 262)]],
}

var _dimensions := Vector2i.ZERO
var _room_id: StringName = &""
var _profiles
var _profile_draw_data: Dictionary = {}


func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	_room_id = room_id
	position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * TILE)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	FEATURE_INSTALLER.install(self, room_id, definition)
	queue_redraw()


func _draw_profile(profile_id: StringName, destination: Vector2) -> void:
	var draw_data: Dictionary = _profile_draw_data.get(profile_id, {})
	if draw_data.is_empty():
		if not _profiles or not _profiles.has(profile_id):
			push_error("Missing approved Moonpetal room profile: %s" % profile_id)
			return
		var profile_texture: Texture2D = _profiles.texture(profile_id)
		if not profile_texture:
			return
		draw_data = {"texture": profile_texture, "source": _profiles.region(profile_id), "size": _profiles.world_draw_size(profile_id)}
		_profile_draw_data[profile_id] = draw_data
	draw_texture_rect_region(draw_data["texture"], Rect2(Vector2(roundf(destination.x), roundf(destination.y)), draw_data["size"]), draw_data["source"])


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * TILE))
	draw_rect(Rect2(Vector2(-8 * TILE, -8 * TILE), Vector2((_dimensions.x + 16) * TILE, (_dimensions.y + 16) * TILE)), Color("081b17"), true)
	draw_rect(bounds, Color("193e35"), true)
	# Layered garden beds and a vertical stepping-stone approach connect the
	# player's arrival to the authored horizontal processional way.
	for y in range(TILE, int(bounds.size.y), TILE):
		for x in range(TILE, int(bounds.size.x), TILE):
			var petal_index := int(x / TILE) + int(y / TILE) + int(_room_id.trim_prefix("MP-"))
			if petal_index % 5 == 0:
				draw_circle(Vector2(x + 13, y + 9), 3.0, Color(0.82, 0.46, 0.62, 0.34))
				draw_circle(Vector2(x + 19, y + 14), 2.0, Color(0.94, 0.74, 0.82, 0.3))
	var path_size: Vector2 = _profiles.world_draw_size(PATH_PROFILE) if _profiles and _profiles.has(PATH_PROFILE) else Vector2(153, 57)
	var path_y := floorf((bounds.size.y - path_size.y) * 0.5)
	var approach := PackedVector2Array([Vector2(bounds.size.x * 0.44, 0), Vector2(bounds.size.x * 0.56, 0), Vector2(bounds.size.x * 0.59, path_y + path_size.y), Vector2(bounds.size.x * 0.41, path_y + path_size.y)])
	draw_colored_polygon(approach, Color(0.45, 0.42, 0.31, 0.58))
	for step_y in range(TILE, int(path_y), TILE):
		var step_offset := -12 if int(step_y / TILE) % 2 == 0 else 12
		draw_circle(Vector2(bounds.size.x * 0.5 + step_offset, step_y), 13.0, Color("8f8a70"))
	for path_x in range(0, ceili(bounds.size.x), ceili(path_size.x)):
		_draw_profile(PATH_PROFILE, Vector2(path_x, path_y))
	var composition_offset := (bounds.size - Vector2(384, 384)) * 0.5
	for prop_definition in ROOM_PROPS.get(_room_id, []):
		_draw_profile(StringName(prop_definition[0]), composition_offset + (prop_definition[1] as Vector2))
	# Framing lanterns keep large blueprints composed even when the arrival port
	# puts the camera above the room-specific landmark cluster.
	_draw_profile(&"moonpetal_gate_lantern", Vector2(TILE, path_y - 72))
	_draw_profile(&"moonpetal_gate_lantern_right", Vector2(bounds.size.x - 2 * TILE, path_y - 72))
	draw_rect(bounds, Color("f3b4c9"), false, 2.0)
