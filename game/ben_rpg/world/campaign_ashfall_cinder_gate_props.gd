class_name CampaignAshfallCinderGateProps
extends Node2D

const VISUAL_PROFILES := preload("res://ben_rpg/world/campaign_visual_profile_registry.gd")

var _layout: Dictionary = {}
var _profiles
var _dead_tree: Texture2D


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_profiles = VISUAL_PROFILES.new()
	_dead_tree = _profiles.texture(&"ashfall_cinder_gate_dead_tree")
	queue_redraw()


func configure(layout: Dictionary) -> void:
	_layout = layout.duplicate(true)
	queue_redraw()


func _draw() -> void:
	if not _dead_tree or not _profiles or not _profiles.has(&"ashfall_cinder_gate_dead_tree"):
		return
	var source: Rect2 = _profiles.region(&"ashfall_cinder_gate_dead_tree")
	var draw_size: Vector2 = _profiles.world_draw_size(&"ashfall_cinder_gate_dead_tree")
	for placement in _layout.get("propPlacements", []):
		if StringName(placement.get("profileId", &"")) != &"ashfall_cinder_gate_dead_tree":
			continue
		var draw_position: Vector2i = placement.get("drawPosition", Vector2i.ZERO)
		draw_texture_rect_region(_dead_tree, Rect2(Vector2(draw_position), draw_size), source)
