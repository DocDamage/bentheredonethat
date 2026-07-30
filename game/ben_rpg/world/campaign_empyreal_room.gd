class_name CampaignEmpyrealRoom
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const TILE := 48
const GROUND_BY_ROOM := {&"EM-01": &"empyreal_marble_plain_tile", &"EM-02": &"empyreal_marble_plain_tile", &"EM-03": &"empyreal_marble_gold_quarter_tile", &"EM-04": &"empyreal_marble_gold_quarter_tile", &"EM-05": &"empyreal_marble_plain_tile", &"EM-06": &"empyreal_marble_cracked_tile", &"EM-07": &"empyreal_marble_gold_quarter_tile", &"EM-08": &"empyreal_marble_cracked_tile", &"EM-09": &"empyreal_marble_gold_quarter_tile", &"EM-10": &"empyreal_marble_plain_tile", &"EM-11": &"empyreal_marble_plain_tile", &"EM-12": &"empyreal_marble_cracked_tile", &"EM-13": &"empyreal_marble_gold_quarter_tile", &"EM-14": &"empyreal_marble_gold_quarter_tile", &"EM-15": &"empyreal_marble_cracked_tile", &"EM-16": &"empyreal_marble_plain_tile"}
const ROOM_PROPS := {
	&"EM-01": [[&"empyreal_sky_cloud_bank", Vector2(-36, -42)], [&"empyreal_pediment_door", Vector2(132, 40)], [&"empyreal_blue_column", Vector2(54, 104)], [&"empyreal_blue_column", Vector2(282, 104)], [&"empyreal_winged_statue", Vector2(148, 206)]],
	&"EM-02": [[&"empyreal_sky_cloud_bank", Vector2(-34, -50)], [&"empyreal_plain_column", Vector2(54, 40)], [&"empyreal_plain_column", Vector2(282, 40)], [&"empyreal_ordinance_book", Vector2(138, 168)], [&"empyreal_blue_balustrade", Vector2(144, 282)]],
	&"EM-03": [[&"empyreal_sky_cloud_bank", Vector2(-34, -48)], [&"empyreal_appeal_fountain", Vector2(141, 112)], [&"empyreal_golden_olive_tree", Vector2(28, 158)], [&"empyreal_silver_olive_tree", Vector2(254, 158)], [&"empyreal_justice_statue", Vector2(160, 212)]],
	&"EM-04": [[&"empyreal_sky_cloud_bank", Vector2(-34, -44)], [&"empyreal_griffin_statue", Vector2(70, 118)], [&"empyreal_horse_statue", Vector2(254, 118)], [&"empyreal_ordinance_book", Vector2(138, 210)], [&"empyreal_blue_column", Vector2(32, 214)], [&"empyreal_blue_column", Vector2(304, 214)]],
	&"EM-05": [[&"empyreal_sky_cloud_bank", Vector2(-34, -42)], [&"empyreal_pediment_door", Vector2(132, 26)], [&"empyreal_gravity_crystal", Vector2(116, 186)], [&"empyreal_gravity_crystal", Vector2(220, 186)], [&"empyreal_blue_balustrade", Vector2(144, 282)]],
	&"EM-06": [[&"empyreal_sky_cloud_bank", Vector2(-34, -46)], [&"empyreal_blue_balustrade", Vector2(40, 112)], [&"empyreal_blue_balustrade", Vector2(248, 112)], [&"empyreal_blue_column", Vector2(72, 178)], [&"empyreal_blue_column", Vector2(264, 178)], [&"empyreal_gravity_crystal", Vector2(168, 226)]],
	&"EM-07": [[&"empyreal_sky_cloud_bank", Vector2(-34, -44)], [&"empyreal_reliquary_portal", Vector2(134, 28)], [&"empyreal_crystal_altar", Vector2(58, 176)], [&"empyreal_lotus_altar", Vector2(242, 176)], [&"empyreal_winged_statue", Vector2(148, 236)]],
	&"EM-08": [[&"empyreal_sky_cloud_bank", Vector2(-34, -46)], [&"empyreal_tribunal_gate", Vector2(111, 22)], [&"empyreal_blue_column", Vector2(42, 166)], [&"empyreal_blue_column", Vector2(294, 166)], [&"empyreal_gravity_crystal", Vector2(168, 242)]],
	&"EM-09": [[&"empyreal_sky_cloud_bank", Vector2(-34, -48)], [&"empyreal_tribunal_gate", Vector2(111, 18)], [&"empyreal_tribunal_orrery", Vector2(145, 184)], [&"empyreal_justice_statue", Vector2(70, 182)], [&"empyreal_winged_statue", Vector2(250, 184)]],
	&"EM-10": [[&"empyreal_sky_cloud_bank", Vector2(-34, -48)], [&"empyreal_gravity_crystal", Vector2(72, 120)], [&"empyreal_gravity_crystal", Vector2(264, 120)], [&"empyreal_appeal_fountain", Vector2(141, 196)]],
	&"EM-11": [[&"empyreal_sky_cloud_bank", Vector2(-34, -46)], [&"empyreal_plain_column", Vector2(42, 36)], [&"empyreal_plain_column", Vector2(294, 36)], [&"empyreal_ordinance_book", Vector2(138, 152)], [&"empyreal_crystal_altar", Vector2(150, 250)]],
	&"EM-12": [[&"empyreal_sky_cloud_bank", Vector2(-34, -46)], [&"empyreal_blue_balustrade", Vector2(40, 104)], [&"empyreal_blue_balustrade", Vector2(248, 104)], [&"empyreal_winged_statue", Vector2(145, 180)], [&"empyreal_gravity_crystal", Vector2(168, 256)]],
	&"EM-13": [[&"empyreal_sky_cloud_bank", Vector2(-34, -46)], [&"empyreal_golden_olive_tree", Vector2(26, 100)], [&"empyreal_silver_olive_tree", Vector2(256, 100)], [&"empyreal_griffin_statue", Vector2(76, 230)], [&"empyreal_horse_statue", Vector2(250, 230)]],
	&"EM-14": [[&"empyreal_sky_cloud_bank", Vector2(-34, -44)], [&"empyreal_reliquary_portal", Vector2(134, 22)], [&"empyreal_crystal_altar", Vector2(56, 198)], [&"empyreal_lotus_altar", Vector2(242, 198)], [&"empyreal_ordinance_book", Vector2(138, 268)]],
	&"EM-15": [[&"empyreal_sky_cloud_bank", Vector2(-34, -48)], [&"empyreal_blue_column", Vector2(30, 36)], [&"empyreal_blue_column", Vector2(306, 36)], [&"empyreal_blue_balustrade", Vector2(42, 166)], [&"empyreal_blue_balustrade", Vector2(246, 166)], [&"empyreal_gravity_crystal", Vector2(168, 252)]],
	&"EM-16": [[&"empyreal_sky_cloud_bank", Vector2(-34, -48)], [&"empyreal_pediment_door", Vector2(132, 40)], [&"empyreal_blue_balustrade", Vector2(42, 210)], [&"empyreal_blue_balustrade", Vector2(246, 210)], [&"empyreal_winged_statue", Vector2(145, 234)]],
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
			push_error("Missing approved Empyreal room profile: %s" % profile_id)
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
	draw_rect(bounds, Color("2a6fa6"), true)
	var ground_profile: StringName = GROUND_BY_ROOM.get(_room_id, &"empyreal_marble_plain_tile")
	for y in range(0, ceili(bounds.size.y), 96):
		for x in range(0, ceili(bounds.size.x), 96):
			_draw_profile(ground_profile, Vector2(x, y))
	var runner := Rect2(Vector2(bounds.size.x * 0.5 - 96, 0), Vector2(192, bounds.size.y))
	draw_rect(runner, Color(0.18, 0.49, 0.72, 0.18), true)
	draw_line(runner.position + Vector2(10, 0), runner.position + Vector2(10, runner.size.y), Color(0.76, 0.61, 0.22, 0.62), 4.0)
	draw_line(runner.position + Vector2(runner.size.x - 10, 0), runner.position + Vector2(runner.size.x - 10, runner.size.y), Color(0.76, 0.61, 0.22, 0.62), 4.0)
	for medallion_y in range(72, int(bounds.size.y), 192):
		draw_circle(Vector2(bounds.size.x * 0.5, medallion_y), 22.0, Color(0.85, 0.7, 0.31, 0.24))
		draw_circle(Vector2(bounds.size.x * 0.5, medallion_y), 14.0, Color(0.3, 0.62, 0.82, 0.24))
	var composition_offset := (bounds.size - Vector2(384, 384)) * 0.5
	for prop_definition in ROOM_PROPS.get(_room_id, []):
		_draw_profile(StringName(prop_definition[0]), composition_offset + (prop_definition[1] as Vector2))
	draw_rect(bounds, Color("d9e8ff"), false, 2.0)
