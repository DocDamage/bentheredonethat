class_name CampaignNewPhiladelphiaFranklinLaboratoryProps
extends Node2D

const PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const PLACEMENTS := [
	[Vector2i(6, 5), &"laboratory_west_storage"], [Vector2i(11, 5), &"laboratory_west_terminal"],
	[Vector2i(19, 5), &"laboratory_east_reactor"], [Vector2i(24, 5), &"laboratory_east_calibrator"],
	[Vector2i(6, 14), &"laboratory_analysis_station"], [Vector2i(11, 14), &"laboratory_west_spectrometer"],
	[Vector2i(19, 14), &"laboratory_east_coolant"], [Vector2i(24, 14), &"laboratory_center_storage"],
	[Vector2i(15, 10), &"laboratory_east_fabricator"], [Vector2i(15, 4), &"laboratory_utility_bank"],
	[Vector2i(15, 18), &"laboratory_exit_doors"],
]

var _profiles
var _textures: Dictionary = {}


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = PROFILES.new()
	for placement in PLACEMENTS:
		var profile_id: StringName = placement[1]
		_textures[profile_id] = _profiles.texture(profile_id)


func configure(_layout: Dictionary) -> void:
	queue_redraw()


func _draw() -> void:
	for placement in PLACEMENTS:
		var cell: Vector2i = placement[0]
		var profile_id: StringName = placement[1]
		var texture: Texture2D = _textures.get(profile_id) as Texture2D
		if not texture:
			continue
		var size: Vector2 = _profiles.world_draw_size(profile_id)
		draw_texture_rect_region(texture, Rect2(Vector2(cell) * 48.0 - Vector2(size.x * 0.5, size.y * 0.75), size), _profiles.region(profile_id))
