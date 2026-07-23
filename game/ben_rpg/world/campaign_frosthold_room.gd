class_name CampaignFrostholdRoom
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TILE := 48
const GROUND_PROFILES := [
	&"frosthold_snow_ground_tile", &"frosthold_snow_ground_variant_1", &"frosthold_snow_ground_variant_2",
	&"frosthold_snow_ground_variant_3", &"frosthold_snow_ground_variant_4", &"frosthold_snow_ground_variant_5",
	&"frosthold_snow_ground_variant_6", &"frosthold_snow_ground_variant_7",
]
const ROOM_SEEDS := {&"FR-01": 2, &"FR-02": 5, &"FR-03": 7, &"FR-04": 13, &"FR-05": 10}
const ROOM_PROPS := {
	&"FR-01": [[&"frosthold_gate_tree", Vector2(-8, 32)], [&"frosthold_gate_tree_right", Vector2(300, 34)], [&"frosthold_gate_castle", Vector2(105, 24)], [&"frosthold_gate_ruin", Vector2(22, 103)], [&"frosthold_gate_ruin_right", Vector2(280, 103)], [&"frosthold_blue_torch", Vector2(120, 89)], [&"frosthold_gate_torch_right", Vector2(220, 89)]],
	&"FR-02": [[&"frosthold_market_house", Vector2(-8, 12)], [&"frosthold_market_house_right", Vector2(290, 8)], [&"frosthold_market_stall", Vector2(44, 72)], [&"frosthold_market_supply_stall", Vector2(160, 92)]],
	&"FR-03": [[&"frosthold_market_house", Vector2(-8, 12)], [&"frosthold_market_house_right", Vector2(290, 8)], [&"frosthold_market_stall", Vector2(44, 72)], [&"frosthold_market_stall_right", Vector2(238, 72)], [&"frosthold_market_supply_stall", Vector2(160, 92)]],
	&"FR-04": [[&"frosthold_causeway_crystal_bank", Vector2(10, 36)], [&"frosthold_causeway_crystal_bank_right", Vector2(286, 40)], [&"frosthold_causeway_bridge", Vector2(149, 20)], [&"frosthold_causeway_bridge_lower", Vector2(149, 122)], [&"frosthold_causeway_rune", Vector2(160, 226)]],
	&"FR-05": [[&"frosthold_hall_side_arch", Vector2(26, 28)], [&"frosthold_hall_central_arch", Vector2(105, 22)], [&"frosthold_hall_side_arch", Vector2(270, 28)], [&"frosthold_hall_torch_left", Vector2(76, 90)], [&"frosthold_gate_torch_right", Vector2(262, 90)], [&"frosthold_hall_rune_left", Vector2(104, 232)], [&"frosthold_hall_rune_right", Vector2(216, 232)]],
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
			push_error("Missing approved Frosthold room profile: %s" % profile_id)
			return
		var profile_texture: Texture2D = _profiles.texture(profile_id)
		if not profile_texture:
			return
		draw_data = {
			"texture": profile_texture,
			"source": _profiles.region(profile_id),
			"size": _profiles.world_draw_size(profile_id),
		}
		_profile_draw_data[profile_id] = draw_data
	var texture: Texture2D = draw_data["texture"]
	var source: Rect2 = draw_data["source"]
	var size: Vector2 = draw_data["size"]
	draw_texture_rect_region(texture, Rect2(Vector2(roundf(destination.x), roundf(destination.y)), size), source)


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * TILE))
	draw_rect(bounds, Color("0a2035"), true)
	var seed := int(ROOM_SEEDS.get(_room_id, 0))
	for y in range(_dimensions.y):
		for x in range(_dimensions.x):
			var profile_id: StringName = GROUND_PROFILES[(x * 3 + y * 5 + seed) % GROUND_PROFILES.size()]
			_draw_profile(profile_id, Vector2(x, y) * TILE)
	var composition_offset := (bounds.size - Vector2(384, 384)) * 0.5
	for prop_definition in ROOM_PROPS.get(_room_id, []):
		_draw_profile(StringName(prop_definition[0]), composition_offset + (prop_definition[1] as Vector2))
	draw_rect(bounds, Color("b6e9ff"), false, 2.0)
