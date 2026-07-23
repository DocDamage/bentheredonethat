class_name CampaignHauntedMansionRainGateForeground
extends Node2D

var _dimensions := Vector2i.ZERO


func configure(dimensions: Vector2i) -> void:
	_dimensions = dimensions
	queue_redraw()


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	# The rail is intentionally above actors; its matching contact footprint is
	# reserved for the room navigation record rather than painted into a global map.
	draw_line(Vector2(6 * 48, 7 * 48), Vector2(12 * 48, 7 * 48), Color("2c2026"), 5.0)
	draw_rect(bounds, Color("9da2c7"), false, 2.0)
