class_name CampaignAshfallCinderGateForeground
extends Node2D

var _layout: Dictionary = {}
var _navigation: Dictionary = {}


func configure(layout: Dictionary, navigation: Dictionary) -> void:
	_layout = layout.duplicate(true)
	_navigation = navigation.duplicate(true)
	queue_redraw()


func _draw() -> void:
	var dimensions: Vector2i = _layout.get("dimensions", Vector2i.ZERO)
	if dimensions == Vector2i.ZERO:
		return
	var bounds := Rect2(Vector2.ZERO, Vector2(dimensions * 48))
	# Ash banks frame the route and are intentionally painted above actors. The
	# matching blocked cells live in the navigation record, not in this renderer.
	draw_rect(bounds, Color("201719"), false, 10.0)
	for cell in _layout.get("foregroundCells", []):
		var position: Vector2i = cell
		draw_circle(Vector2(position * 48) + Vector2(24, 24), 18.0, Color(0.12, 0.09, 0.1, 0.58))
