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
	for x in [1.5, 3.0, 15.0, 16.5]:
		var trunk_x: float = float(x) * 48.0
		draw_line(Vector2(trunk_x, 5.4 * 48), Vector2(trunk_x, 8.2 * 48), Color("17131b"), 11.0)
		draw_line(Vector2(trunk_x, 6.0 * 48), Vector2(trunk_x - 34, 5.1 * 48), Color("17131b"), 7.0)
		draw_line(Vector2(trunk_x, 6.3 * 48), Vector2(trunk_x + 38, 5.35 * 48), Color("17131b"), 6.0)
	for x in range(1, _dimensions.x):
		draw_line(Vector2(x * 48, 7.65 * 48), Vector2(x * 48, 8.35 * 48), Color("211923"), 4.0)
	draw_line(Vector2(48, 8.15 * 48), Vector2((_dimensions.x - 1) * 48, 8.15 * 48), Color("211923"), 5.0)
	draw_rect(bounds, Color("9da2c7"), false, 2.0)
