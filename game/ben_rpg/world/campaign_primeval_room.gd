class_name CampaignPrimevalRoom
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TILE := 48
const ROOM_PROPS := {
	&"PV-01": [[&"primeval_village_dwelling", Vector2(4, 12)], [&"primeval_village_longhouse", Vector2(178, 4)], [&"primeval_village_dwelling_right", Vector2(294, 12)], [&"primeval_village_firepit", Vector2(164, 214)], [&"primeval_anchor_totem", Vector2(170, 116)]],
	&"PV-02": [[&"primeval_grove_canopy", Vector2(-18, 0)], [&"primeval_grove_canopy_mid", Vector2(128, -6)], [&"primeval_grove_canopy_right", Vector2(274, 0)], [&"primeval_grove_fern_left", Vector2(32, 230)], [&"primeval_grove_fern_right", Vector2(304, 230)]],
	&"PV-03": [[&"primeval_ruin_forecourt", Vector2(82, 20)], [&"primeval_ruins_left_wall", Vector2(4, 84)], [&"primeval_ruins_right_wall", Vector2(284, 84)], [&"primeval_ruins_left_rubble", Vector2(60, 246)], [&"primeval_ruins_right_rubble", Vector2(286, 246)]],
	&"PV-04": [[&"primeval_grove_canopy", Vector2(-14, 4)], [&"primeval_grove_canopy_right", Vector2(272, 4)], [&"primeval_relay_nest", Vector2(122, 104)], [&"primeval_nest_left", Vector2(32, 236)], [&"primeval_nest_right", Vector2(292, 236)]],
	&"PV-05": [[&"primeval_village_longhouse", Vector2(124, 8)], [&"primeval_village_awning_left", Vector2(22, 124)], [&"primeval_village_awning_right", Vector2(296, 124)], [&"primeval_village_firepit", Vector2(164, 226)]],
	&"PV-06": [[&"primeval_grove_canopy", Vector2(-16, 0)], [&"primeval_grove_canopy_mid_left", Vector2(96, -4)], [&"primeval_grove_canopy_right", Vector2(274, 0)], [&"primeval_anchor_totem", Vector2(170, 178)]],
	&"PV-07": [[&"primeval_ruins_left_wall", Vector2(8, 26)], [&"primeval_ruins_right_wall", Vector2(280, 26)], [&"primeval_relay_nest", Vector2(124, 98)], [&"primeval_nest_left", Vector2(34, 238)], [&"primeval_nest_right", Vector2(290, 238)]],
	&"PV-08": [[&"primeval_ruin_forecourt", Vector2(82, 10)], [&"primeval_anchor_totem", Vector2(170, 142)], [&"primeval_ruins_left_rubble", Vector2(52, 242)], [&"primeval_ruins_right_rubble", Vector2(292, 242)]],
	&"PV-09": [[&"primeval_caldera_forecourt", Vector2(76, 18)], [&"primeval_caldera_pillar", Vector2(168, 118)], [&"primeval_caldera_rubble_left", Vector2(24, 242)], [&"primeval_caldera_rubble_right", Vector2(298, 242)]],
	&"PV-10": [[&"primeval_grove_canopy", Vector2(-16, 0)], [&"primeval_grove_canopy_right", Vector2(272, 0)], [&"primeval_village_firepit", Vector2(164, 196)], [&"primeval_grove_fern_left", Vector2(46, 246)], [&"primeval_grove_fern_right", Vector2(294, 246)]],
	&"PV-11": [[&"primeval_ruins_left_wall", Vector2(4, 34)], [&"primeval_ruins_right_wall", Vector2(284, 34)], [&"primeval_anchor_totem", Vector2(170, 112)], [&"primeval_ruins_left_rubble", Vector2(54, 246)], [&"primeval_ruins_right_rubble", Vector2(292, 246)]],
	&"PV-12": [[&"primeval_caldera_forecourt", Vector2(76, 12)], [&"primeval_caldera_pillar", Vector2(168, 126)], [&"primeval_caldera_rubble_left", Vector2(20, 244)], [&"primeval_caldera_rubble_right", Vector2(302, 244)]],
	&"PV-13": [[&"primeval_relay_nest", Vector2(122, 54)], [&"primeval_nest_left", Vector2(24, 198)], [&"primeval_nest_right", Vector2(300, 198)], [&"primeval_grove_fern_left", Vector2(78, 270)], [&"primeval_grove_fern_right", Vector2(264, 270)]],
	&"PV-14": [[&"primeval_caldera_forecourt", Vector2(76, 8)], [&"primeval_caldera_pillar", Vector2(168, 104)], [&"primeval_anchor_totem", Vector2(170, 214)], [&"primeval_caldera_rubble_left", Vector2(18, 254)], [&"primeval_caldera_rubble_right", Vector2(304, 254)]],
}

var _dimensions := Vector2i.ZERO
var _room_id: StringName = &""
var _profiles
var _draw_cache: Dictionary = {}

func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	_room_id = room_id
	position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * 48)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	FEATURE_INSTALLER.install(self, room_id, definition)
	queue_redraw()

func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(Rect2(Vector2(-8 * TILE, -8 * TILE), Vector2((_dimensions.x + 16) * TILE, (_dimensions.y + 16) * TILE)), Color("071914"), true)
	draw_rect(bounds, Color("102e27"), true)
	var ground_id := &"primeval_desert_ground_quadrant" if _room_id in [&"PV-09", &"PV-12", &"PV-14"] else &"primeval_ground_quadrant"
	var ground_size: Vector2 = _profiles.world_draw_size(ground_id)
	for y in range(0, ceili(bounds.size.y), maxi(1, int(ground_size.y))):
		for x in range(0, ceili(bounds.size.x), maxi(1, int(ground_size.x))):
			_draw_profile(ground_id, Vector2(x, y))
	# A dirt procession trail links the authored ports and prevents broad maps
	# from reading as a single repeated grass stamp.
	var trail := PackedVector2Array([Vector2(bounds.size.x * 0.43, 0), Vector2(bounds.size.x * 0.57, 0), Vector2(bounds.size.x * 0.66, bounds.size.y), Vector2(bounds.size.x * 0.34, bounds.size.y)])
	draw_colored_polygon(trail, Color(0.48, 0.36, 0.19, 0.38))
	for y in range(TILE, int(bounds.size.y), 2 * TILE):
		draw_circle(Vector2(bounds.size.x * 0.5 + (-18 if int(y / TILE) % 4 == 1 else 18), y), 5.0, Color(0.67, 0.56, 0.33, 0.34))
	var composition_offset := (bounds.size - Vector2(384, 384)) * 0.5
	for prop_definition in ROOM_PROPS.get(_room_id, []):
		_draw_profile(StringName(prop_definition[0]), composition_offset + (prop_definition[1] as Vector2))
	draw_rect(bounds, Color("9fca65"), false, 2.0)


func _draw_profile(profile_id: StringName, destination: Vector2) -> void:
	var data: Dictionary = _draw_cache.get(profile_id, {})
	if data.is_empty():
		if not _profiles or not _profiles.has(profile_id): return
		var texture: Texture2D = _profiles.texture(profile_id)
		if not texture: return
		data = {"texture": texture, "region": _profiles.region(profile_id), "size": _profiles.world_draw_size(profile_id)}
		_draw_cache[profile_id] = data
	draw_texture_rect_region(data["texture"], Rect2(Vector2(roundf(destination.x), roundf(destination.y)), data["size"]), data["region"])
