class_name CampaignHauntedMansionConservatory
extends Node2D

const FEATURE_INSTALLER := preload("res://ben_rpg/world/campaign_room_feature_installer.gd")
const VISUAL_PROFILE_REGISTRY := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")
const MANSION_ROOM_ART := preload("res://ben_rpg/world/campaign_mansion_room_art.gd")

var _dimensions := Vector2i.ZERO
var _profiles
var _lit_wall: Texture2D
var _plain_wall: Texture2D
var _tableau: Texture2D

func configure(room_id: StringName, definition: Dictionary) -> void:
	name = "AuthoredRoom_%s" % room_id
	set_meta(&"room_id", room_id)
	_dimensions = definition.get("dimensions", Vector2i.ZERO)
	position = Vector2(definition.get("worldOrigin", Vector2i.ZERO) * 48)
	var navigation_layer := get_node_or_null("NavigationAndCollision") as Node2D
	if navigation_layer:
		navigation_layer.set_meta(&"navigation_id", definition.get("navigationId", &""))
		navigation_layer.set_meta(&"collision_mask_id", definition.get("collisionMaskId", &""))
		navigation_layer.set_meta(&"navigation_layout", definition.get("navigationLayout", {}))
	FEATURE_INSTALLER.install(self, room_id, definition)
	queue_redraw()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILE_REGISTRY.new()
	_lit_wall = _profiles.texture(&"mansion_archive_wall_lit_tile")
	_plain_wall = _profiles.texture(&"mansion_archive_wall_plain_tile")
	_tableau = _profiles.texture(&"mansion_foyer_wall_tableau")
	queue_redraw()

func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(bounds, Color("15211c"), true)
	draw_rect(Rect2(Vector2(48, 3 * 48), Vector2((_dimensions.x - 2) * 48, (_dimensions.y - 4) * 48)), Color("314a35"), true)
	for x in range(2, _dimensions.x - 1, 3):
		draw_circle(Vector2(x * 48, 7 * 48), 27.0, Color("203526"))
	MANSION_ROOM_ART.draw_interior(self, _dimensions, _profiles, &"conservatory")
	_draw_profile(&"mansion_archive_wall_lit_tile", _lit_wall, Vector2(48, 48))
	_draw_profile(&"mansion_archive_wall_plain_tile", _plain_wall, Vector2((_dimensions.x - 4) * 48, 48))
	_draw_profile(&"mansion_foyer_wall_tableau", _tableau, Vector2((_dimensions.x / 2.0 - 1.5) * 48, 3 * 48))
	draw_rect(bounds, Color("a8be98"), false, 2.0)

func _draw_profile(profile_id: StringName, texture: Texture2D, draw_position: Vector2) -> void:
	if texture and _profiles and _profiles.has(profile_id):
		draw_texture_rect_region(texture, Rect2(draw_position, _profiles.world_draw_size(profile_id)), _profiles.region(profile_id))
