class_name CampaignAshfallCinderGateGround
extends Node2D

const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _layout: Dictionary = {}
var _profiles
var _ground: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILES.new()
	_ground = _profiles.texture(&"ashfall_cinder_gate_ground")
	queue_redraw()


func configure(layout: Dictionary) -> void:
	_layout = layout.duplicate(true)
	queue_redraw()


func _draw() -> void:
	var dimensions: Vector2i = _layout.get("dimensions", Vector2i.ZERO)
	if dimensions == Vector2i.ZERO or not _ground or not _profiles or not _profiles.has(&"ashfall_cinder_gate_ground"):
		return
	var source: Rect2 = _profiles.region(&"ashfall_cinder_gate_ground")
	var draw_size: Vector2 = _profiles.world_draw_size(&"ashfall_cinder_gate_ground")
	for y in range(dimensions.y):
		for x in range(dimensions.x):
			draw_texture_rect_region(_ground, Rect2(Vector2(x * 48, y * 48), draw_size), source)
