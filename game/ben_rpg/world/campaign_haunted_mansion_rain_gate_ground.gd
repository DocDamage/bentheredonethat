class_name CampaignHauntedMansionRainGateGround
extends Node2D

var _dimensions := Vector2i.ZERO


func configure(dimensions: Vector2i) -> void:
	_dimensions = dimensions
	queue_redraw()


func _draw() -> void:
	if _dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(_dimensions * 48))
	draw_rect(bounds, Color("111326"), true)
	# Wet stone forecourt and the dry porch route are intentionally distinct so
	# HM-01 exposes its safe-strip contract before combat content activates.
	draw_rect(Rect2(Vector2(48, 8 * 48), Vector2((_dimensions.x - 2) * 48, 48)), Color("4c4a5d"), true)
	draw_rect(Rect2(Vector2(6 * 48, 6 * 48), Vector2(6 * 48, 3 * 48)), Color("78615b"), true)
	for x in range(1, _dimensions.x - 1):
		var rain_x := float(x * 48 + 16)
		draw_line(Vector2(rain_x, 18), Vector2(rain_x - 8, 54), Color(0.58, 0.68, 0.9, 0.32), 2.0)
