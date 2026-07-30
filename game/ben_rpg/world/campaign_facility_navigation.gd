class_name CampaignFacilityNavigation
extends RefCounted

# Facility footprints are blocked except for the front-door cell. The adjacent
# town-side cell is the mandatory portal return/approach, so sandbox decoration
# must preserve both cells.
static func local_door(plot: Rect2i) -> Vector2i:
	return Vector2i(plot.position.x + int(plot.size.x / 2), plot.end.y - 1)


static func door_cell(town_origin: Vector2i, plot: Rect2i) -> Vector2i:
	return town_origin + local_door(plot)


static func return_cell(town_origin: Vector2i, plot: Rect2i) -> Vector2i:
	return door_cell(town_origin, plot) + Vector2i.DOWN


static func blocked_cells(town_origin: Vector2i, plot: Rect2i) -> Array[Vector2i]:
	var blocked: Array[Vector2i] = []
	var door := local_door(plot)
	for y in range(plot.position.y, plot.end.y):
		for x in range(plot.position.x, plot.end.x):
			var local_cell := Vector2i(x, y)
			if local_cell != door:
				blocked.append(town_origin + local_cell)
	return blocked


static func access_cells(town_origin: Vector2i, plots: Array, built_facilities: Dictionary) -> Dictionary:
	var access := {}
	for raw_plot_index in built_facilities.keys():
		var plot_index := int(raw_plot_index)
		if plot_index < 0 or plot_index >= plots.size():
			continue
		var plot: Rect2i = plots[plot_index]
		access[door_cell(town_origin, plot)] = true
		access[return_cell(town_origin, plot)] = true
	return access
