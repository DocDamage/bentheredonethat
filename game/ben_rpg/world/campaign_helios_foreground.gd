class_name CampaignHeliosForeground
extends Node2D

## Helios keeps its authored city quadrants intact in the ground pass. This
## overlay supplies only the elevated rails, canopy lips, and neon supports that
## should occlude actors moving under the arcology's upper walkways.

const TILE := 48
const HELIOS_ORIGIN := Vector2i(108, 32)

var active_area: StringName = &"lab"


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()


func set_active_area(area: StringName) -> void:
	if active_area == area:
		return
	active_area = area
	queue_redraw()


func _draw() -> void:
	if not active_area.begins_with("helios"):
		return
	var offset := Vector2(HELIOS_ORIGIN * TILE)
	match active_area:
		&"helios_skybridge": _draw_elevated_rail(offset, Color(0.19, 0.72, 0.94))
		&"helios_market": _draw_market_canopy(offset + Vector2(10 * TILE, 0))
		&"helios_transit": _draw_elevated_rail(offset + Vector2(20 * TILE, 0), Color(0.97, 0.54, 0.24))
		&"helios_clinic": _draw_clinic_hood(offset + Vector2(10 * TILE, 10 * TILE))
		&"helios_core": _draw_elevated_rail(offset + Vector2(20 * TILE, 10 * TILE), Color(0.92, 0.74, 0.22))


func _draw_elevated_rail(room_offset: Vector2, neon: Color) -> void:
	# Two compact suspended rail segments give the room an upper depth plane while
	# leaving the navigation/collision layer and authored quadrant untouched.
	for rail in [Rect2(room_offset + Vector2(0, 34), Vector2(144, 20)), Rect2(room_offset + Vector2(240, 34), Vector2(144, 20))]:
		draw_rect(rail, Color(0.035, 0.10, 0.18, 0.90), true)
		draw_rect(Rect2(rail.position + Vector2(0, 3), Vector2(rail.size.x, 3)), neon.darkened(0.12), true)
		draw_line(rail.position + Vector2(10, 15), rail.end - Vector2(10, 5), Color(0.68, 0.92, 1.0, 0.42), 1.0)
	for support_x in [20, 116, 260, 356]:
		draw_rect(Rect2(room_offset + Vector2(support_x, 48), Vector2(8, 72)), Color(0.04, 0.12, 0.20, 0.68), true)


func _draw_market_canopy(room_offset: Vector2) -> void:
	for canopy in [Rect2(room_offset + Vector2(12, 48), Vector2(132, 22)), Rect2(room_offset + Vector2(240, 48), Vector2(132, 22))]:
		draw_rect(canopy, Color(0.13, 0.05, 0.20, 0.88), true)
		draw_rect(Rect2(canopy.position + Vector2(0, 2), Vector2(canopy.size.x, 3)), Color(0.98, 0.25, 0.68, 0.82), true)
		draw_line(canopy.position + Vector2(8, 17), canopy.end - Vector2(8, 5), Color(0.64, 0.92, 1.0, 0.48), 1.0)


func _draw_clinic_hood(room_offset: Vector2) -> void:
	var hood := Rect2(room_offset + Vector2(66, 38), Vector2(252, 24))
	draw_rect(hood, Color(0.04, 0.18, 0.22, 0.88), true)
	draw_rect(Rect2(hood.position + Vector2(0, 3), Vector2(hood.size.x, 3)), Color(0.38, 0.96, 0.88, 0.82), true)
	for x in range(84, 312, 48):
		draw_rect(Rect2(room_offset + Vector2(x, 58), Vector2(6, 56)), Color(0.04, 0.14, 0.19, 0.60), true)
